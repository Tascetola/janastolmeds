--liquibase formatted sql

--changeset adetola:test-040-triggers-spec endDelimiter:/ runOnChange:true stripComments:false context:dev,test
--comment: Trigger suite: audit columns and optimistic-lock version, visit lock guards, addenda, append-only audit log (FR-ADM-02, FR-CLN-04, NFR-PRV-03). Test environments only.
CREATE OR REPLACE PACKAGE jm_ut_triggers AUTHID DEFINER
IS
    --%suite(Database triggers (JM-DOC-03 sections 1 and 5))
    --%suitepath(jmeds.database)
    --%beforeall(jm_ut_fixture.build)

    --%context(Audit columns and ROW_VERSION on every table)

    --%test(Inserts record who and when, with ROW_VERSION 1)
    PROCEDURE insert_sets_audit_columns;

    --%test(Updates record who and when, bump ROW_VERSION by one and protect CREATED_BY/CREATED_ON)
    PROCEDURE update_maintains_audit_columns;

    --%test(JM_CURRENT_USER falls back to the database session user outside APEX and the API context)
    PROCEDURE current_user_fallback;

    --%endcontext

    --%context(Visit lock: locked consultations cannot change (FR-CLN-04))

    --%test(A locked visit cannot be updated)
    --%throws(-20010)
    PROCEDURE locked_visit_not_updatable;

    --%test(A locked visit cannot be deleted)
    --%throws(-20010)
    PROCEDURE locked_visit_not_deletable;

    --%test(An open or completed visit can still be edited)
    PROCEDURE unlocked_visit_editable;

    --%test(Vitals cannot be added to a locked visit)
    --%throws(-20011)
    PROCEDURE vitals_insert_on_locked_visit;

    --%test(Vitals of a locked visit cannot be changed)
    --%throws(-20011)
    PROCEDURE vitals_update_on_locked_visit;

    --%test(Vitals of a locked visit cannot be deleted)
    --%throws(-20011)
    PROCEDURE vitals_delete_on_locked_visit;

    --%test(Vitals cannot be moved off a locked visit (DEF-003 regression))
    --%throws(-20011)
    PROCEDURE vitals_moved_off_locked_visit;

    --%test(Diagnoses cannot be added to a locked visit)
    --%throws(-20011)
    PROCEDURE diagnosis_insert_on_locked_visit;

    --%test(Diagnoses of a locked visit cannot be changed)
    --%throws(-20011)
    PROCEDURE diagnosis_update_on_locked_visit;

    --%test(Diagnoses of a locked visit cannot be deleted)
    --%throws(-20011)
    PROCEDURE diagnosis_delete_on_locked_visit;

    --%test(Diagnoses cannot be moved off a locked visit (DEF-003 regression))
    --%throws(-20011)
    PROCEDURE diagnosis_moved_off_locked_visit;

    --%test(An unknown visit is reported by the foreign key, not hidden by the guard (DEF-003 regression))
    --%throws(-2291)
    PROCEDURE vitals_unknown_visit_reports_fk;

    --%endcontext

    --%context(Addenda (FR-CLN-04))

    --%test(Addenda can be added to a locked visit)
    PROCEDURE addendum_on_locked_visit;

    --%test(Addenda are refused on a visit that is not locked)
    --%throws(-20012)
    PROCEDURE addendum_on_open_visit;

    --%test(An addendum for an unknown visit is reported by the foreign key (DEF-003 regression))
    --%throws(-2291)
    PROCEDURE addendum_unknown_visit_reports_fk;

    --%endcontext

    --%context(Audit log is append-only (NFR-PRV-03))

    --%test(Audit rows can be inserted)
    PROCEDURE audit_log_insert_allowed;

    --%test(Audit rows cannot be updated)
    --%throws(-20020)
    PROCEDURE audit_log_update_blocked;

    --%test(Audit rows cannot be deleted)
    --%throws(-20020)
    PROCEDURE audit_log_delete_blocked;

    --%endcontext
END jm_ut_triggers;
/
--rollback DROP PACKAGE jm_ut_triggers;

--changeset adetola:test-040-triggers-body endDelimiter:/ runOnChange:true stripComments:false context:dev,test
--comment: Trigger suite body (FR-ADM-02, FR-CLN-04, NFR-PRV-03). Test environments only.
CREATE OR REPLACE PACKAGE BODY jm_ut_triggers
IS
    g_failures VARCHAR2(32767);

    PROCEDURE note (p_text IN VARCHAR2)
    IS
    BEGIN
        IF NVL(LENGTH(g_failures), 0) < 30000 THEN
            g_failures := g_failures || p_text || CHR(10);
        END IF;
    END note;

    FUNCTION pk_column (p_table IN VARCHAR2) RETURN VARCHAR2
    IS
        l_column user_cons_columns.column_name%TYPE;
    BEGIN
        SELECT cc.column_name INTO l_column
          FROM user_constraints c
          JOIN user_cons_columns cc ON cc.constraint_name = c.constraint_name
         WHERE c.table_name = p_table AND c.constraint_type = 'P';
        RETURN l_column;
    END pk_column;

    -- A third visit, opened with vitals and a diagnosis, then locked: used by the guard tests.
    FUNCTION locked_visit_with_children RETURN NUMBER
    IS
        l_visit NUMBER;
    BEGIN
        INSERT INTO jm_visits (visit_no, patient_id, doctor_id)
        VALUES ('UT-VIS-3', jm_ut_fixture.id('JM_PATIENTS'), jm_ut_fixture.id('JM_STAFF'))
        RETURNING visit_id INTO l_visit;
        INSERT INTO jm_vitals (visit_id, taken_by, temperature_c) VALUES (l_visit, jm_ut_fixture.id('JM_STAFF'), 36.8);
        INSERT INTO jm_visit_diagnoses (visit_id, icd10_code) VALUES (l_visit, jm_ut_fixture.key('JM_ICD10_CODES'));
        UPDATE jm_visits SET status = 'LOCKED', completed_at = SYSTIMESTAMP - INTERVAL '2' DAY, locked_at = SYSTIMESTAMP
         WHERE visit_id = l_visit;
        RETURN l_visit;
    END locked_visit_with_children;

    ---------------------------------------------------------------------------
    PROCEDURE insert_sets_audit_columns
    IS
        l_by      VARCHAR2(100);
        l_on      TIMESTAMP WITH LOCAL TIME ZONE;
        l_upd_by  VARCHAR2(100);
        l_version NUMBER;
        l_tables  PLS_INTEGER := 0;
    BEGIN
        g_failures := NULL;
        -- Fixture rows were inserted by this session; seed rows (roles, lookups, ICD-10) by the Liquibase deploy.
        FOR t IN (SELECT table_name FROM user_tables
                   WHERE table_name LIKE 'JM\_%' ESCAPE '\' AND table_name <> 'JM_AUDIT_LOG'
                   ORDER BY table_name) LOOP
            EXECUTE IMMEDIATE 'SELECT created_by, created_on, updated_by, row_version FROM ' ||
                              DBMS_ASSERT.simple_sql_name(t.table_name) || ' WHERE ' ||
                              DBMS_ASSERT.simple_sql_name(pk_column(t.table_name)) || ' = :k'
                INTO l_by, l_on, l_upd_by, l_version USING jm_ut_fixture.key(t.table_name);
            IF l_by IS NULL OR l_on IS NULL OR l_upd_by IS NOT NULL OR l_version <> 1 THEN
                note(t.table_name || ': created_by=' || l_by || ' created_on=' || l_on ||
                     ' updated_by=' || l_upd_by || ' row_version=' || l_version);
            END IF;
            IF t.table_name NOT IN ('JM_ROLES', 'JM_LOOKUPS', 'JM_ICD10_CODES') AND l_by <> jm_current_user THEN
                note(t.table_name || ': created_by ' || l_by || ', expected ' || jm_current_user);
            END IF;
            l_tables := l_tables + 1;
        END LOOP;
        ut.expect(l_tables, 'tables examined').to_equal(28);
        ut.expect(g_failures).to_be_null();
    END insert_sets_audit_columns;

    PROCEDURE update_maintains_audit_columns
    IS
        l_where   VARCHAR2(200);
        l_by0     VARCHAR2(100);
        l_on0     TIMESTAMP WITH LOCAL TIME ZONE;
        l_ver0    NUMBER;
        l_by      VARCHAR2(100);
        l_on      TIMESTAMP WITH LOCAL TIME ZONE;
        l_upd_by  VARCHAR2(100);
        l_upd_on  TIMESTAMP WITH LOCAL TIME ZONE;
        l_ver     NUMBER;
        l_tables  PLS_INTEGER := 0;
    BEGIN
        g_failures := NULL;
        FOR t IN (SELECT table_name FROM user_tables
                   WHERE table_name LIKE 'JM\_%' ESCAPE '\' AND table_name <> 'JM_AUDIT_LOG'
                   ORDER BY table_name) LOOP
            l_where := ' FROM ' || DBMS_ASSERT.simple_sql_name(t.table_name) || ' WHERE ' ||
                       DBMS_ASSERT.simple_sql_name(pk_column(t.table_name)) || ' = :k';
            EXECUTE IMMEDIATE 'SELECT created_by, created_on, row_version' || l_where
                INTO l_by0, l_on0, l_ver0 USING jm_ut_fixture.key(t.table_name);
            -- A client trying to rewrite history and set its own version must be overruled by the trigger.
            EXECUTE IMMEDIATE 'UPDATE ' || DBMS_ASSERT.simple_sql_name(t.table_name) ||
                              ' SET created_by = ''SPOOFED'', created_on = TIMESTAMP ''2000-01-01 00:00:00'', row_version = 99' ||
                              ' WHERE ' || DBMS_ASSERT.simple_sql_name(pk_column(t.table_name)) || ' = :k'
                USING jm_ut_fixture.key(t.table_name);
            EXECUTE IMMEDIATE 'SELECT created_by, created_on, updated_by, updated_on, row_version' || l_where
                INTO l_by, l_on, l_upd_by, l_upd_on, l_ver USING jm_ut_fixture.key(t.table_name);
            IF l_by <> l_by0 OR l_on <> l_on0 OR l_ver <> l_ver0 + 1
               OR l_upd_by IS NULL OR l_upd_by <> jm_current_user OR l_upd_on IS NULL THEN
                note(t.table_name || ': created_by ' || l_by0 || '->' || l_by || ', created_on changed=' ||
                     CASE WHEN l_on <> l_on0 THEN 'Y' ELSE 'N' END || ', row_version ' || l_ver0 || '->' || l_ver ||
                     ', updated_by=' || l_upd_by || ', updated_on=' || l_upd_on);
            END IF;
            l_tables := l_tables + 1;
        END LOOP;
        ut.expect(l_tables, 'tables examined').to_equal(28);
        ut.expect(g_failures).to_be_null();
    END update_maintains_audit_columns;

    PROCEDURE current_user_fallback
    IS
    BEGIN
        ut.expect(jm_current_user).to_equal(SYS_CONTEXT('USERENV', 'SESSION_USER'));
    END current_user_fallback;

    ---------------------------------------------------------------------------
    PROCEDURE locked_visit_not_updatable IS
    BEGIN
        UPDATE jm_visits SET plan_notes = 'changed after lock' WHERE visit_id = jm_ut_fixture.id('LOCKED_VISIT');
    END locked_visit_not_updatable;

    PROCEDURE locked_visit_not_deletable IS
    BEGIN
        DELETE FROM jm_visit_addenda WHERE visit_id = jm_ut_fixture.id('LOCKED_VISIT');
        DELETE FROM jm_visits WHERE visit_id = jm_ut_fixture.id('LOCKED_VISIT');
    END locked_visit_not_deletable;

    PROCEDURE unlocked_visit_editable
    IS
        l_status jm_visits.status%TYPE;
    BEGIN
        UPDATE jm_visits SET exam_notes = 'Examined', status = 'COMPLETED', completed_at = SYSTIMESTAMP
         WHERE visit_id = jm_ut_fixture.id('JM_VISITS');
        UPDATE jm_visits SET plan_notes = 'Amended within 24 hours' WHERE visit_id = jm_ut_fixture.id('JM_VISITS');
        UPDATE jm_vitals SET pulse_bpm = 80 WHERE vitals_id = jm_ut_fixture.id('JM_VITALS');
        SELECT status INTO l_status FROM jm_visits WHERE visit_id = jm_ut_fixture.id('JM_VISITS');
        ut.expect(l_status).to_equal('COMPLETED');
    END unlocked_visit_editable;

    PROCEDURE vitals_insert_on_locked_visit IS
    BEGIN
        INSERT INTO jm_vitals (visit_id, taken_by, temperature_c)
        VALUES (jm_ut_fixture.id('LOCKED_VISIT'), jm_ut_fixture.id('JM_STAFF'), 37);
    END vitals_insert_on_locked_visit;

    PROCEDURE vitals_update_on_locked_visit
    IS
        l_visit NUMBER := locked_visit_with_children;
    BEGIN
        UPDATE jm_vitals SET temperature_c = 38 WHERE visit_id = l_visit;
    END vitals_update_on_locked_visit;

    PROCEDURE vitals_delete_on_locked_visit
    IS
        l_visit NUMBER := locked_visit_with_children;
    BEGIN
        DELETE FROM jm_vitals WHERE visit_id = l_visit;
    END vitals_delete_on_locked_visit;

    PROCEDURE vitals_moved_off_locked_visit
    IS
        l_visit NUMBER := locked_visit_with_children;
    BEGIN
        UPDATE jm_vitals SET visit_id = jm_ut_fixture.id('JM_VISITS') WHERE visit_id = l_visit;
    END vitals_moved_off_locked_visit;

    PROCEDURE diagnosis_insert_on_locked_visit IS
    BEGIN
        INSERT INTO jm_visit_diagnoses (visit_id, icd10_code)
        VALUES (jm_ut_fixture.id('LOCKED_VISIT'), jm_ut_fixture.key('JM_ICD10_CODES'));
    END diagnosis_insert_on_locked_visit;

    PROCEDURE diagnosis_update_on_locked_visit
    IS
        l_visit NUMBER := locked_visit_with_children;
    BEGIN
        UPDATE jm_visit_diagnoses SET remarks = 'changed after lock' WHERE visit_id = l_visit;
    END diagnosis_update_on_locked_visit;

    PROCEDURE diagnosis_delete_on_locked_visit
    IS
        l_visit NUMBER := locked_visit_with_children;
    BEGIN
        DELETE FROM jm_visit_diagnoses WHERE visit_id = l_visit;
    END diagnosis_delete_on_locked_visit;

    PROCEDURE diagnosis_moved_off_locked_visit
    IS
        l_visit NUMBER := locked_visit_with_children;
        l_other NUMBER;
    BEGIN
        -- move to an open visit that does not already carry the same code
        INSERT INTO jm_visits (visit_no, patient_id, doctor_id)
        VALUES ('UT-VIS-4', jm_ut_fixture.id('JM_PATIENTS'), jm_ut_fixture.id('JM_STAFF'))
        RETURNING visit_id INTO l_other;
        UPDATE jm_visit_diagnoses SET visit_id = l_other WHERE visit_id = l_visit;
    END diagnosis_moved_off_locked_visit;

    PROCEDURE vitals_unknown_visit_reports_fk IS
    BEGIN
        INSERT INTO jm_vitals (visit_id, taken_by, temperature_c) VALUES (-999, jm_ut_fixture.id('JM_STAFF'), 37);
    END vitals_unknown_visit_reports_fk;

    ---------------------------------------------------------------------------
    PROCEDURE addendum_on_locked_visit
    IS
        l_count PLS_INTEGER;
    BEGIN
        INSERT INTO jm_visit_addenda (visit_id, author_id, addendum_text)
        VALUES (jm_ut_fixture.id('LOCKED_VISIT'), jm_ut_fixture.id('JM_STAFF'), 'Second addendum');
        SELECT COUNT(*) INTO l_count FROM jm_visit_addenda WHERE visit_id = jm_ut_fixture.id('LOCKED_VISIT');
        ut.expect(l_count).to_equal(2);
    END addendum_on_locked_visit;

    PROCEDURE addendum_on_open_visit IS
    BEGIN
        INSERT INTO jm_visit_addenda (visit_id, author_id, addendum_text)
        VALUES (jm_ut_fixture.id('JM_VISITS'), jm_ut_fixture.id('JM_STAFF'), 'Too early');
    END addendum_on_open_visit;

    PROCEDURE addendum_unknown_visit_reports_fk IS
    BEGIN
        INSERT INTO jm_visit_addenda (visit_id, author_id, addendum_text)
        VALUES (-999, jm_ut_fixture.id('JM_STAFF'), 'No such visit');
    END addendum_unknown_visit_reports_fk;

    ---------------------------------------------------------------------------
    PROCEDURE add_audit_row (p_id OUT NUMBER)
    IS
    BEGIN
        INSERT INTO jm_audit_log (actor, actor_type, action, table_name, record_id, client, row_hash)
        VALUES ('UT_DOCTOR1', 'STAFF', 'VIEW', 'JM_PATIENTS', jm_ut_fixture.id('JM_PATIENTS'), 'APEX', RPAD('0', 64, '0'))
        RETURNING audit_id INTO p_id;
    END add_audit_row;

    PROCEDURE audit_log_insert_allowed
    IS
        l_id    NUMBER;
        l_count PLS_INTEGER;
    BEGIN
        add_audit_row(l_id);
        SELECT COUNT(*) INTO l_count FROM jm_audit_log WHERE audit_id = l_id;
        ut.expect(l_count).to_equal(1);
    END audit_log_insert_allowed;

    PROCEDURE audit_log_update_blocked
    IS
        l_id NUMBER;
    BEGIN
        add_audit_row(l_id);
        UPDATE jm_audit_log SET actor = 'SOMEONE_ELSE' WHERE audit_id = l_id;
    END audit_log_update_blocked;

    PROCEDURE audit_log_delete_blocked
    IS
        l_id NUMBER;
    BEGIN
        add_audit_row(l_id);
        DELETE FROM jm_audit_log WHERE audit_id = l_id;
    END audit_log_delete_blocked;
END jm_ut_triggers;
/
--rollback DROP PACKAGE BODY jm_ut_triggers;
