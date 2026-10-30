--liquibase formatted sql

--changeset adetola:test-030-constraints-spec endDelimiter:/ runOnChange:true stripComments:false context:dev,test
--comment: Constraint suite: every check, foreign, unique and NOT NULL constraint rejects bad data; JM-DOC-03 section 5 rules (FR-APT-02, FR-BIL-01, FR-BIL-02, FR-BIL-03, FR-CLN-01, FR-LAB-03, FR-PHM-02, FR-PHM-03). Test environments only.
CREATE OR REPLACE PACKAGE jm_ut_constraints AUTHID DEFINER
IS
    --%suite(Database constraints (JM-DOC-03 sections 4 and 5))
    --%suitepath(jmeds.database)
    --%beforeall(jm_ut_fixture.build)

    --%context(Generic: every constraint in the data dictionary)

    --%test(The fixture builds a valid row in every table except JM_AUDIT_LOG)
    PROCEDURE fixture_covers_all_tables;

    --%test(Every check constraint rejects a violating value, or has its own named test)
    PROCEDURE every_check_constraint;

    --%test(Every foreign key rejects a reference to a missing parent)
    PROCEDURE every_foreign_key;

    --%test(Every NOT NULL column rejects NULL)
    PROCEDURE every_not_null_column;

    --%test(Every table with one unique key rejects a duplicate row; tables with more have a named test per key)
    PROCEDURE every_unique_key;

    --%endcontext

    --%context(Check constraints that need a crafted violation)

    --%test(JM_APPOINTMENTS_SLOT_CK: slot must end after it starts (FR-APT-02))
    PROCEDURE appointments_slot_ck;
    --%test(JM_DOCTOR_SCHEDULES_START_CK: start time must be HH24:MI (FR-APT-01))
    PROCEDURE doctor_schedules_start_ck;
    --%test(JM_DOCTOR_SCHEDULES_END_CK: end time must be HH24:MI (FR-APT-01))
    PROCEDURE doctor_schedules_end_ck;
    --%test(JM_DOCTOR_SCHEDULES_WINDOW_CK: session must end after it starts (FR-APT-01))
    PROCEDURE doctor_schedules_window_ck;
    --%test(JM_DOCTOR_SCHEDULES_VALID_CK: validity cannot end before it starts (FR-APT-01))
    PROCEDURE doctor_schedules_valid_ck;
    --%test(JM_INVOICES_AMOUNTS_CK: no negative amounts (FR-BIL-01))
    PROCEDURE invoices_amounts_ck;
    --%test(JM_INVOICES_PAID_CK: payments cannot exceed the patient portion (FR-BIL-02))
    PROCEDURE invoices_paid_ck;
    --%test(JM_INVOICES_SPLIT_CK: HMO plus patient portions equal the total (FR-BIL-03))
    PROCEDURE invoices_split_ck;
    --%test(JM_LAB_RESULTS_VALUE_CK: a result needs a numeric or text value (FR-LAB-02))
    PROCEDURE lab_results_value_ck;
    --%test(JM_LAB_RESULTS_VERIFIED_CK: verifier and verification time go together (FR-LAB-03))
    PROCEDURE lab_results_verified_ck;
    --%test(JM_LAB_RESULTS_VERIFIER_CK: verifier must differ from the entrant (FR-LAB-03))
    PROCEDURE lab_results_verifier_ck;
    --%test(JM_LAB_TESTS_RANGE_CK: reference high cannot be below low (FR-LAB-01))
    PROCEDURE lab_tests_range_ck;
    --%test(JM_PATIENTS_HMO_MEMBER_CK: HMO plan requires a member number (FR-BIL-03))
    PROCEDURE patients_hmo_member_ck;
    --%test(JM_PRESCRIPTIONS_OVERRIDE_CK: allergy override requires a reason (FR-PHM-02))
    PROCEDURE prescriptions_override_ck;
    --%test(JM_PRESCRIPTIONS_ALLERGY_OVERRIDE_CK: override flag is Y or N, even with a reason given (FR-PHM-02))
    PROCEDURE prescriptions_allergy_override_ck;
    --%test(JM_PRESCRIPTIONS_QTY_CK: cannot dispense more than prescribed (FR-PHM-03))
    PROCEDURE prescriptions_qty_ck;
    --%test(JM_STAFF_USERNAME_UPPER_CK: usernames are upper case (FR-ADM-01))
    PROCEDURE staff_username_upper_ck;
    --%test(JM_VISITS_COMPLETED_CK: a completed visit has a completion time (FR-CLN-04))
    PROCEDURE visits_completed_ck;
    --%test(JM_VISITS_STATUS_CK: visit status is OPEN, COMPLETED or LOCKED, even with a completion time (FR-CLN-04))
    PROCEDURE visits_status_ck;
    --%test(JM_AUDIT_LOG_ACTION_CK: action must be a known audit action (FR-ADM-02))
    PROCEDURE audit_log_action_ck;
    --%test(JM_AUDIT_LOG_ACTOR_TYPE_CK: actor type must be STAFF, PATIENT or SYSTEM (FR-ADM-02))
    PROCEDURE audit_log_actor_type_ck;
    --%test(JM_AUDIT_LOG_CLIENT_CK: client must be APEX, ORDS or JOB (FR-ADM-02))
    PROCEDURE audit_log_client_ck;
    --%test(JM_AUDIT_LOG_DETAIL_JSON_CK: detail must be valid JSON (FR-ADM-02))
    PROCEDURE audit_log_detail_json_ck;
    --%test(JM_INVOICES_HMO_PAID_CK: the HMO cannot pay more than its share (FR-BIL-03; DEF-009))
    PROCEDURE invoices_hmo_paid_ck;
    --%test(JM_HMO_CLAIMS_AMOUNTS_CK: claim is positive and approval cannot exceed it (FR-BIL-04; DEF-009))
    PROCEDURE hmo_claims_amounts_ck;
    --%test(JM_HMO_CLAIMS_PAID_CK: remittance cannot exceed the approved amount (FR-BIL-04; DEF-009))
    PROCEDURE hmo_claims_paid_ck;
    --%test(JM_HMO_CLAIMS_SUBMITTED_CK: a claim past DRAFT has a submission time (FR-BIL-04; DEF-009))
    PROCEDURE hmo_claims_submitted_ck;
    --%test(JM_HMO_CLAIMS_DECIDED_CK: an approved, paid or rejected claim has a decision time (FR-BIL-04; DEF-009))
    PROCEDURE hmo_claims_decided_ck;
    --%test(JM_HMO_CLAIMS_REJECTED_CK: a rejected claim needs a reason (FR-BIL-04; DEF-009))
    PROCEDURE hmo_claims_rejected_ck;
    --%test(<TABLE>_DELETED_CK on every soft-delete table: a delete needs a reason; an active row has no delete details (DEF-006))
    PROCEDURE deleted_ck_every_table;

    --%endcontext

    --%context(Unique keys on tables with more than one)

    --%test(JM_STAFF_NO_UK: employee numbers are unique (FR-ADM-01))
    PROCEDURE staff_no_uk;
    --%test(JM_STAFF_USERNAME_UK: login names are unique (FR-ADM-01))
    PROCEDURE staff_username_uk;
    --%test(JM_PATIENT_ACCOUNTS_PATIENT_UK: one mobile account per patient (NFR-SEC-01))
    PROCEDURE patient_accounts_patient_uk;
    --%test(JM_PATIENT_ACCOUNTS_LOGIN_UK: login IDs are unique (NFR-SEC-01))
    PROCEDURE patient_accounts_login_uk;
    --%test(JM_APPOINTMENTS_NO_UK: appointment numbers are unique (FR-APT-02))
    PROCEDURE appointments_no_uk;
    --%test(JM_APPOINTMENTS_SLOT_UK: a doctor's slot cannot be double-booked (FR-APT-02))
    PROCEDURE appointments_slot_uk;
    --%test(JM_VISITS_NO_UK: visit numbers are unique (FR-CLN-02))
    PROCEDURE visits_no_uk;
    --%test(JM_VISITS_APPOINTMENT_UK: one visit per appointment (FR-CLN-02))
    PROCEDURE visits_appointment_uk;
    --%test(JM_INVOICES_NO_UK: invoice numbers are unique (FR-BIL-01))
    PROCEDURE invoices_no_uk;
    --%test(JM_INVOICES_VISIT_UK: one invoice per visit (FR-BIL-01))
    PROCEDURE invoices_visit_uk;
    --%test(JM_HMO_CLAIMS_NO_UK: claim numbers are unique (FR-BIL-04))
    PROCEDURE hmo_claims_no_uk;
    --%test(JM_HMO_CLAIMS_INVOICE_UK: one live claim per invoice (FR-BIL-04; DEF-009))
    PROCEDURE hmo_claims_invoice_uk;

    --%endcontext

    --%context(Business rules: accepted cases and boundaries)

    --%test(A cancelled or no-show slot can be booked again (FR-APT-02))
    PROCEDURE rebook_after_cancel_or_no_show;
    --%test(Each charge source is billed once, but the same id under another source type is allowed (FR-BIL-01))
    PROCEDURE invoice_line_source_billed_once;
    --%test(A self-paying patient needs no HMO member number (FR-BIL-03))
    PROCEDURE self_pay_patient_accepted;
    --%test(Vital signs: range limits accepted, values just outside rejected (FR-CLN-01))
    PROCEDURE vitals_boundaries;
    --%test(Stock on hand can reach zero but not go below (FR-PHM-03))
    PROCEDURE stock_zero_not_negative;
    --%test(HMO is not a patient payment method; HMO money goes to JM_HMO_CLAIMS (FR-BIL-02; DEF-009 regression))
    PROCEDURE hmo_not_a_patient_payment_method;
    --%test(A deleted diagnosis, lab result, invoice line, batch, account or visit frees its key for the corrected record (DEF-006))
    PROCEDURE soft_delete_frees_business_keys;
    --%test(A voided invoice can be replaced and a rejected claim resubmitted (FR-BIL-01, FR-BIL-04))
    PROCEDURE void_invoice_and_rejected_claim_replaceable;

    --%endcontext
END jm_ut_constraints;
/
--rollback DROP PACKAGE jm_ut_constraints;

--changeset adetola:test-030-constraints-body endDelimiter:/ runOnChange:true stripComments:false context:dev,test
--comment: Constraint suite body (FR-APT-02, FR-BIL-01, FR-BIL-02, FR-BIL-03, FR-BIL-04, FR-CLN-01, FR-LAB-03, FR-PHM-02, FR-PHM-03; DEF-006, DEF-009). Test environments only.
CREATE OR REPLACE PACKAGE BODY jm_ut_constraints
IS
    c_check_violated  CONSTANT PLS_INTEGER := -2290;
    c_parent_missing  CONSTANT PLS_INTEGER := -2291;
    c_unique_violated CONSTANT PLS_INTEGER := -1;
    c_null_update     CONSTANT PLS_INTEGER := -1407;
    c_null_insert     CONSTANT PLS_INTEGER := -1400;

    g_failures VARCHAR2(32767);

    ---------------------------------------------------------------------------
    -- helpers
    ---------------------------------------------------------------------------
    PROCEDURE note (p_text IN VARCHAR2)
    IS
    BEGIN
        IF LENGTH(g_failures) > 30000 THEN
            RETURN;
        END IF;
        g_failures := g_failures || p_text || CHR(10);
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

    -- Runs one dynamic UPDATE of the fixture row and records whether the expected error was raised.
    -- p_set is "<column> = :v" (bound to p_text, or to p_num when given) or "<column> = NULL".
    PROCEDURE try_update (p_table      IN VARCHAR2,
                          p_set        IN VARCHAR2,
                          p_sqlcode    IN PLS_INTEGER,
                          p_expect     IN VARCHAR2,
                          p_label      IN VARCHAR2,
                          p_text       IN VARCHAR2 := NULL,
                          p_num        IN NUMBER := NULL)
    IS
        l_sql VARCHAR2(1000) := 'UPDATE ' || DBMS_ASSERT.simple_sql_name(p_table) ||
                                '   SET ' || p_set ||
                                ' WHERE ' || DBMS_ASSERT.simple_sql_name(pk_column(p_table)) || ' = :k';
    BEGIN
        IF p_num IS NOT NULL THEN
            EXECUTE IMMEDIATE l_sql USING p_num, jm_ut_fixture.key(p_table);
        ELSIF p_text IS NOT NULL THEN
            EXECUTE IMMEDIATE l_sql USING p_text, jm_ut_fixture.key(p_table);
        ELSE
            EXECUTE IMMEDIATE l_sql USING jm_ut_fixture.key(p_table);
        END IF;
        note(p_label || ': accepted ' || COALESCE(p_text, TO_CHAR(p_num), 'NULL'));
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE <> p_sqlcode OR INSTR(SQLERRM, p_expect) = 0 THEN
                note(p_label || ': expected ' || p_sqlcode || ' ' || p_expect || ', got ' || SQLERRM);
            END IF;
    END try_update;

    -- Tables with a <TABLE>_NO_CHANGE trigger accept inserts only, so their constraints are probed by inserting
    -- a copy of the fixture row with one column replaced (bound to p_text or p_num, or NULL when neither is given).
    FUNCTION insert_only (p_table IN VARCHAR2) RETURN BOOLEAN
    IS
        l_count PLS_INTEGER;
    BEGIN
        SELECT COUNT(*) INTO l_count FROM user_triggers WHERE trigger_name = p_table || '_NO_CHANGE';
        RETURN l_count > 0;
    END insert_only;

    PROCEDURE try_insert_copy (p_table      IN VARCHAR2,
                               p_column     IN VARCHAR2,
                               p_sqlcode    IN PLS_INTEGER,
                               p_expect     IN VARCHAR2,
                               p_label      IN VARCHAR2,
                               p_text       IN VARCHAR2 := NULL,
                               p_num        IN NUMBER := NULL)
    IS
        l_columns VARCHAR2(4000);
        l_values  VARCHAR2(4000);
        l_sql     VARCHAR2(9000);
    BEGIN
        SELECT LISTAGG(column_name, ', ') WITHIN GROUP (ORDER BY column_id),
               LISTAGG(CASE WHEN column_name = p_column
                            THEN CASE WHEN COALESCE(p_text, TO_CHAR(p_num)) IS NULL THEN 'NULL' ELSE ':v' END
                            ELSE column_name END, ', ') WITHIN GROUP (ORDER BY column_id)
          INTO l_columns, l_values
          FROM user_tab_cols
         WHERE table_name = p_table
           AND identity_column = 'NO' AND virtual_column = 'NO' AND hidden_column = 'NO';
        l_sql := 'INSERT INTO ' || DBMS_ASSERT.simple_sql_name(p_table) || ' (' || l_columns || ') SELECT ' || l_values ||
                 ' FROM ' || DBMS_ASSERT.simple_sql_name(p_table) ||
                 ' WHERE ' || DBMS_ASSERT.simple_sql_name(pk_column(p_table)) || ' = :k';
        IF p_num IS NOT NULL THEN
            EXECUTE IMMEDIATE l_sql USING p_num, jm_ut_fixture.key(p_table);
        ELSIF p_text IS NOT NULL THEN
            EXECUTE IMMEDIATE l_sql USING p_text, jm_ut_fixture.key(p_table);
        ELSE
            EXECUTE IMMEDIATE l_sql USING jm_ut_fixture.key(p_table);
        END IF;
        note(p_label || ': accepted ' || COALESCE(p_text, TO_CHAR(p_num), 'NULL'));
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE <> p_sqlcode OR INSTR(SQLERRM, p_expect) = 0 THEN
                note(p_label || ': expected ' || p_sqlcode || ' ' || p_expect || ', got ' || SQLERRM);
            END IF;
    END try_insert_copy;

    FUNCTION has_named_test (p_constraint IN VARCHAR2) RETURN BOOLEAN
    IS
        l_count PLS_INTEGER;
    BEGIN
        -- The <TABLE>_DELETED_CK on every soft-delete table is covered by one test, deleted_ck_every_table.
        SELECT COUNT(*) INTO l_count
          FROM user_procedures
         WHERE object_name = 'JM_UT_CONSTRAINTS'
           AND procedure_name = CASE WHEN p_constraint LIKE 'JM\_%\_DELETED\_CK' ESCAPE '\'
                                     THEN 'DELETED_CK_EVERY_TABLE'
                                     ELSE SUBSTR(p_constraint, 4) END;
        RETURN l_count > 0;
    END has_named_test;

    -- Asserts the statement just failed with the given error and constraint (called from a handler).
    PROCEDURE expect_error (p_sqlcode IN PLS_INTEGER, p_sqlerrm IN VARCHAR2,
                            p_expected_code IN PLS_INTEGER, p_constraint IN VARCHAR2)
    IS
    BEGIN
        ut.expect(p_sqlcode, 'error code').to_equal(p_expected_code);
        ut.expect(p_sqlerrm, 'violated constraint').to_be_like('%' || p_constraint || '%');
    END expect_error;

    PROCEDURE not_raised (p_constraint IN VARCHAR2)
    IS
    BEGIN
        ut.fail('Statement succeeded; expected ' || p_constraint || ' to reject it');
    END not_raised;

    PROCEDURE insert_audit (p_action IN VARCHAR2 := 'VIEW', p_actor_type IN VARCHAR2 := 'STAFF',
                            p_client IN VARCHAR2 := 'APEX', p_detail IN CLOB := '{"ut":true}')
    IS
    BEGIN
        INSERT INTO jm_audit_log (actor, actor_type, action, table_name, record_id, client, detail, row_hash)
        VALUES ('UT_DOCTOR1', p_actor_type, p_action, 'JM_PATIENTS', jm_ut_fixture.id('JM_PATIENTS'),
                p_client, p_detail, RPAD('0', 64, '0'));
    END insert_audit;

    ---------------------------------------------------------------------------
    -- generic
    ---------------------------------------------------------------------------
    PROCEDURE fixture_covers_all_tables
    IS
        l_missing VARCHAR2(4000);
    BEGIN
        FOR t IN (SELECT table_name FROM user_tables
                   WHERE table_name LIKE 'JM\_%' ESCAPE '\' AND table_name <> 'JM_AUDIT_LOG'
                   ORDER BY table_name) LOOP
            IF NOT jm_ut_fixture.has_row(t.table_name) THEN
                l_missing := l_missing || t.table_name || ' ';
            END IF;
        END LOOP;
        ut.expect(l_missing, 'tables without a fixture row').to_be_null();
    END fixture_covers_all_tables;

    PROCEDURE every_check_constraint
    IS
        l_column VARCHAR2(128);
        l_tested PLS_INTEGER := 0;
    BEGIN
        g_failures := NULL;
        FOR c IN (SELECT table_name, constraint_name, search_condition_vc AS cond
                    FROM user_constraints
                   WHERE table_name LIKE 'JM\_%' ESCAPE '\'
                     AND constraint_type = 'C'
                     AND constraint_name NOT LIKE 'SYS\_%' ESCAPE '\'
                   ORDER BY table_name, constraint_name) LOOP
            l_column := NULL;
            -- A constraint with its own named test is covered there; the generic probe could trip a neighbouring rule.
            IF has_named_test(c.constraint_name) THEN
                l_column := '(named test)';
            ELSIF jm_ut_fixture.has_row(c.table_name) THEN
                l_column := REGEXP_SUBSTR(c.cond, '^"?([a-z_0-9]+)"? IN \(', 1, 1, 'i', 1);
                IF l_column IS NOT NULL THEN
                    try_update(c.table_name, DBMS_ASSERT.simple_sql_name(l_column) || ' = :v',
                               c_check_violated, c.constraint_name, c.constraint_name, p_text => 'Z');
                ELSE
                    l_column := REGEXP_SUBSTR(c.cond, '^"?([a-z_0-9]+)"? (BETWEEN [0-9.]+ AND [0-9.]+|>=? 0)$', 1, 1, 'i', 1);
                    IF l_column IS NOT NULL THEN
                        try_update(c.table_name, DBMS_ASSERT.simple_sql_name(l_column) || ' = :v',
                                   c_check_violated, c.constraint_name, c.constraint_name, p_num => -1);
                    END IF;
                END IF;
            END IF;
            IF l_column IS NULL AND NOT has_named_test(c.constraint_name) THEN
                note(c.constraint_name || ': not generically testable and has no named test ' || LOWER(SUBSTR(c.constraint_name, 4)));
            END IF;
            l_tested := l_tested + 1;
        END LOOP;
        ut.expect(l_tested, 'check constraints examined').to_be_greater_than(0);
        ut.expect(g_failures).to_be_null();
    END every_check_constraint;

    PROCEDURE every_foreign_key
    IS
        l_tested PLS_INTEGER := 0;
    BEGIN
        g_failures := NULL;
        FOR f IN (SELECT c.table_name, c.constraint_name, cc.column_name, tc.data_type
                    FROM user_constraints c
                    JOIN user_cons_columns cc ON cc.constraint_name = c.constraint_name
                    JOIN user_tab_columns tc ON tc.table_name = cc.table_name AND tc.column_name = cc.column_name
                   WHERE c.table_name LIKE 'JM\_%' ESCAPE '\'
                     AND c.constraint_type = 'R'
                   ORDER BY c.table_name, c.constraint_name) LOOP
            IF NOT jm_ut_fixture.has_row(f.table_name) THEN
                note(f.constraint_name || ': no fixture row to test with');
            ELSIF insert_only(f.table_name) THEN
                IF f.data_type = 'NUMBER' THEN
                    try_insert_copy(f.table_name, f.column_name, c_parent_missing, f.constraint_name, f.constraint_name, p_num => -999);
                ELSE
                    try_insert_copy(f.table_name, f.column_name, c_parent_missing, f.constraint_name, f.constraint_name, p_text => 'UT-NONE');
                END IF;
            ELSIF f.data_type = 'NUMBER' THEN
                try_update(f.table_name, DBMS_ASSERT.simple_sql_name(f.column_name) || ' = :v',
                           c_parent_missing, f.constraint_name, f.constraint_name, p_num => -999);
            ELSE
                try_update(f.table_name, DBMS_ASSERT.simple_sql_name(f.column_name) || ' = :v',
                           c_parent_missing, f.constraint_name, f.constraint_name, p_text => 'UT-NONE');
            END IF;
            l_tested := l_tested + 1;
        END LOOP;
        ut.expect(l_tested, 'foreign keys examined').to_be_greater_than(0);
        ut.expect(g_failures).to_be_null();
    END every_foreign_key;

    PROCEDURE every_not_null_column
    IS
        l_tested PLS_INTEGER := 0;
    BEGIN
        g_failures := NULL;
        FOR n IN (SELECT c.table_name, c.column_name, c.identity_column
                    FROM user_tab_cols c
                   WHERE c.table_name LIKE 'JM\_%' ESCAPE '\'
                     AND c.table_name <> 'JM_AUDIT_LOG'
                     AND c.nullable = 'N'
                     AND c.hidden_column = 'NO'
                     AND c.virtual_column = 'NO'
                     AND c.column_name NOT IN ('CREATED_BY', 'CREATED_ON', 'UPDATED_BY', 'UPDATED_ON', 'ROW_VERSION')
                   ORDER BY c.table_name, c.column_id) LOOP
            -- The audit columns are maintained by the BIU triggers and are covered by the trigger suite.
            IF insert_only(n.table_name) AND n.identity_column = 'YES' THEN
                NULL;  -- GENERATED BY DEFAULT ON NULL: an inserted NULL is replaced by the next key
            ELSIF insert_only(n.table_name) THEN
                try_insert_copy(n.table_name, n.column_name, c_null_insert, '"' || n.column_name || '"',
                                n.table_name || '.' || n.column_name);
            ELSE
                try_update(n.table_name, DBMS_ASSERT.simple_sql_name(n.column_name) || ' = NULL',
                           c_null_update, '"' || n.column_name || '"', n.table_name || '.' || n.column_name);
            END IF;
            l_tested := l_tested + 1;
        END LOOP;
        ut.expect(l_tested, 'NOT NULL columns examined').to_be_greater_than(0);
        ut.expect(g_failures).to_be_null();
    END every_not_null_column;

    PROCEDURE every_unique_key
    IS
        l_columns VARCHAR2(4000);
        l_tested  PLS_INTEGER := 0;
    BEGIN
        g_failures := NULL;
        FOR t IN (SELECT i.table_name, COUNT(*) AS key_count,
                         LISTAGG(NVL(c.constraint_name, i.index_name), ',') WITHIN GROUP (ORDER BY i.index_name) AS key_names
                    FROM user_indexes i
                    LEFT JOIN user_constraints c ON c.index_name = i.index_name AND c.constraint_type = 'U'
                   WHERE i.table_name LIKE 'JM\_%' ESCAPE '\'
                     AND i.uniqueness = 'UNIQUE'
                     AND i.index_type <> 'LOB'
                     AND NOT EXISTS (SELECT 1 FROM user_constraints p
                                      WHERE p.index_name = i.index_name AND p.constraint_type = 'P')
                   GROUP BY i.table_name
                   ORDER BY i.table_name) LOOP
            IF t.key_count > 1 THEN
                FOR k IN (SELECT REGEXP_SUBSTR(t.key_names, '[^,]+', 1, LEVEL) AS key_name
                            FROM dual CONNECT BY LEVEL <= t.key_count) LOOP
                    IF NOT has_named_test(k.key_name) THEN
                        note(k.key_name || ': table has several unique keys and this one has no named test');
                    END IF;
                END LOOP;
            ELSE
                SELECT LISTAGG(column_name, ', ') WITHIN GROUP (ORDER BY column_id) INTO l_columns
                  FROM user_tab_cols
                 WHERE table_name = t.table_name
                   AND identity_column = 'NO' AND virtual_column = 'NO' AND hidden_column = 'NO';
                BEGIN
                    EXECUTE IMMEDIATE 'INSERT INTO ' || DBMS_ASSERT.simple_sql_name(t.table_name) ||
                                      ' (' || l_columns || ') SELECT ' || l_columns ||
                                      ' FROM ' || DBMS_ASSERT.simple_sql_name(t.table_name) ||
                                      ' WHERE ' || DBMS_ASSERT.simple_sql_name(pk_column(t.table_name)) || ' = :k'
                        USING jm_ut_fixture.key(t.table_name);
                    note(t.key_names || ': accepted a duplicate row');
                EXCEPTION
                    WHEN OTHERS THEN
                        IF SQLCODE <> c_unique_violated OR INSTR(SQLERRM, t.key_names) = 0 THEN
                            note(t.key_names || ': expected ORA-00001, got ' || SQLERRM);
                        END IF;
                END;
            END IF;
            l_tested := l_tested + 1;
        END LOOP;
        ut.expect(l_tested, 'tables with unique keys examined').to_be_greater_than(0);
        ut.expect(g_failures).to_be_null();
    END every_unique_key;

    ---------------------------------------------------------------------------
    -- crafted check violations
    ---------------------------------------------------------------------------
    PROCEDURE appointments_slot_ck IS
    BEGIN
        UPDATE jm_appointments SET slot_end = slot_start WHERE appointment_id = jm_ut_fixture.id('JM_APPOINTMENTS');
        not_raised('JM_APPOINTMENTS_SLOT_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_APPOINTMENTS_SLOT_CK');
    END appointments_slot_ck;

    PROCEDURE doctor_schedules_start_ck IS
    BEGIN
        UPDATE jm_doctor_schedules SET start_time = '08:60' WHERE schedule_id = jm_ut_fixture.id('JM_DOCTOR_SCHEDULES');
        not_raised('JM_DOCTOR_SCHEDULES_START_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_DOCTOR_SCHEDULES_START_CK');
    END doctor_schedules_start_ck;

    PROCEDURE doctor_schedules_end_ck IS
    BEGIN
        UPDATE jm_doctor_schedules SET end_time = '11:60' WHERE schedule_id = jm_ut_fixture.id('JM_DOCTOR_SCHEDULES');
        not_raised('JM_DOCTOR_SCHEDULES_END_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_DOCTOR_SCHEDULES_END_CK');
    END doctor_schedules_end_ck;

    PROCEDURE doctor_schedules_window_ck IS
    BEGIN
        UPDATE jm_doctor_schedules SET end_time = '08:00' WHERE schedule_id = jm_ut_fixture.id('JM_DOCTOR_SCHEDULES');
        not_raised('JM_DOCTOR_SCHEDULES_WINDOW_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_DOCTOR_SCHEDULES_WINDOW_CK');
    END doctor_schedules_window_ck;

    PROCEDURE doctor_schedules_valid_ck IS
    BEGIN
        UPDATE jm_doctor_schedules SET valid_to = valid_from - 1 WHERE schedule_id = jm_ut_fixture.id('JM_DOCTOR_SCHEDULES');
        not_raised('JM_DOCTOR_SCHEDULES_VALID_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_DOCTOR_SCHEDULES_VALID_CK');
    END doctor_schedules_valid_ck;

    PROCEDURE invoices_amounts_ck IS
    BEGIN
        UPDATE jm_invoices SET amount_paid = -1 WHERE invoice_id = jm_ut_fixture.id('JM_INVOICES');
        not_raised('JM_INVOICES_AMOUNTS_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_INVOICES_AMOUNTS_CK');
    END invoices_amounts_ck;

    PROCEDURE invoices_paid_ck IS
    BEGIN
        UPDATE jm_invoices SET amount_paid = patient_amount + 0.01 WHERE invoice_id = jm_ut_fixture.id('JM_INVOICES');
        not_raised('JM_INVOICES_PAID_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_INVOICES_PAID_CK');
    END invoices_paid_ck;

    PROCEDURE invoices_split_ck IS
    BEGIN
        UPDATE jm_invoices SET hmo_amount = hmo_amount - 1 WHERE invoice_id = jm_ut_fixture.id('JM_INVOICES');
        not_raised('JM_INVOICES_SPLIT_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_INVOICES_SPLIT_CK');
    END invoices_split_ck;

    PROCEDURE lab_results_value_ck IS
    BEGIN
        UPDATE jm_lab_results SET result_numeric = NULL, result_text = NULL WHERE lab_result_id = jm_ut_fixture.id('JM_LAB_RESULTS');
        not_raised('JM_LAB_RESULTS_VALUE_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_LAB_RESULTS_VALUE_CK');
    END lab_results_value_ck;

    PROCEDURE lab_results_verified_ck IS
    BEGIN
        UPDATE jm_lab_results SET verified_at = NULL WHERE lab_result_id = jm_ut_fixture.id('JM_LAB_RESULTS');
        not_raised('JM_LAB_RESULTS_VERIFIED_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_LAB_RESULTS_VERIFIED_CK');
    END lab_results_verified_ck;

    PROCEDURE lab_results_verifier_ck IS
    BEGIN
        UPDATE jm_lab_results SET verified_by = entered_by WHERE lab_result_id = jm_ut_fixture.id('JM_LAB_RESULTS');
        not_raised('JM_LAB_RESULTS_VERIFIER_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_LAB_RESULTS_VERIFIER_CK');
    END lab_results_verifier_ck;

    PROCEDURE lab_tests_range_ck IS
    BEGIN
        UPDATE jm_lab_tests SET ref_high = ref_low - 1 WHERE lab_test_id = jm_ut_fixture.id('JM_LAB_TESTS');
        not_raised('JM_LAB_TESTS_RANGE_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_LAB_TESTS_RANGE_CK');
    END lab_tests_range_ck;

    PROCEDURE patients_hmo_member_ck IS
    BEGIN
        UPDATE jm_patients SET hmo_member_no = NULL WHERE patient_id = jm_ut_fixture.id('JM_PATIENTS');
        not_raised('JM_PATIENTS_HMO_MEMBER_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_PATIENTS_HMO_MEMBER_CK');
    END patients_hmo_member_ck;

    PROCEDURE prescriptions_override_ck IS
    BEGIN
        UPDATE jm_prescriptions SET allergy_override = 'Y', override_reason = NULL
         WHERE prescription_id = jm_ut_fixture.id('JM_PRESCRIPTIONS');
        not_raised('JM_PRESCRIPTIONS_OVERRIDE_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_PRESCRIPTIONS_OVERRIDE_CK');
    END prescriptions_override_ck;

    PROCEDURE prescriptions_allergy_override_ck IS
    BEGIN
        -- a reason is supplied so JM_PRESCRIPTIONS_OVERRIDE_CK is satisfied and only the flag list can fail
        UPDATE jm_prescriptions SET allergy_override = 'Z', override_reason = 'Reviewed with patient'
         WHERE prescription_id = jm_ut_fixture.id('JM_PRESCRIPTIONS');
        not_raised('JM_PRESCRIPTIONS_ALLERGY_OVERRIDE_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_PRESCRIPTIONS_ALLERGY_OVERRIDE_CK');
    END prescriptions_allergy_override_ck;

    PROCEDURE prescriptions_qty_ck IS
    BEGIN
        UPDATE jm_prescriptions SET qty_dispensed = qty_prescribed + 1 WHERE prescription_id = jm_ut_fixture.id('JM_PRESCRIPTIONS');
        not_raised('JM_PRESCRIPTIONS_QTY_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_PRESCRIPTIONS_QTY_CK');
    END prescriptions_qty_ck;

    PROCEDURE staff_username_upper_ck IS
    BEGIN
        UPDATE jm_staff SET username = LOWER(username) WHERE staff_id = jm_ut_fixture.id('JM_STAFF');
        not_raised('JM_STAFF_USERNAME_UPPER_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_STAFF_USERNAME_UPPER_CK');
    END staff_username_upper_ck;

    PROCEDURE visits_completed_ck IS
    BEGIN
        UPDATE jm_visits SET status = 'COMPLETED', completed_at = NULL WHERE visit_id = jm_ut_fixture.id('JM_VISITS');
        not_raised('JM_VISITS_COMPLETED_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_VISITS_COMPLETED_CK');
    END visits_completed_ck;

    PROCEDURE visits_status_ck IS
    BEGIN
        -- a completion time is supplied so JM_VISITS_COMPLETED_CK is satisfied and only the status list can fail
        UPDATE jm_visits SET status = 'Z', completed_at = SYSTIMESTAMP WHERE visit_id = jm_ut_fixture.id('JM_VISITS');
        not_raised('JM_VISITS_STATUS_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_VISITS_STATUS_CK');
    END visits_status_ck;

    PROCEDURE audit_log_action_ck IS
    BEGIN
        insert_audit(p_action => 'PRINT');
        not_raised('JM_AUDIT_LOG_ACTION_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_AUDIT_LOG_ACTION_CK');
    END audit_log_action_ck;

    PROCEDURE audit_log_actor_type_ck IS
    BEGIN
        insert_audit(p_actor_type => 'ROBOT');
        not_raised('JM_AUDIT_LOG_ACTOR_TYPE_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_AUDIT_LOG_ACTOR_TYPE_CK');
    END audit_log_actor_type_ck;

    PROCEDURE audit_log_client_ck IS
    BEGIN
        insert_audit(p_client => 'CURL');
        not_raised('JM_AUDIT_LOG_CLIENT_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_AUDIT_LOG_CLIENT_CK');
    END audit_log_client_ck;

    PROCEDURE audit_log_detail_json_ck IS
    BEGIN
        insert_audit(p_detail => 'not json');
        not_raised('JM_AUDIT_LOG_DETAIL_JSON_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_AUDIT_LOG_DETAIL_JSON_CK');
    END audit_log_detail_json_ck;

    PROCEDURE invoices_hmo_paid_ck IS
    BEGIN
        UPDATE jm_invoices SET hmo_amount_paid = hmo_amount + 0.01 WHERE invoice_id = jm_ut_fixture.id('JM_INVOICES');
        not_raised('JM_INVOICES_HMO_PAID_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_INVOICES_HMO_PAID_CK');
    END invoices_hmo_paid_ck;

    PROCEDURE hmo_claims_amounts_ck IS
    BEGIN
        UPDATE jm_hmo_claims SET approved_amount = claim_amount + 1 WHERE claim_id = jm_ut_fixture.id('JM_HMO_CLAIMS');
        not_raised('JM_HMO_CLAIMS_AMOUNTS_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_HMO_CLAIMS_AMOUNTS_CK');
    END hmo_claims_amounts_ck;

    PROCEDURE hmo_claims_paid_ck IS
    BEGIN
        UPDATE jm_hmo_claims SET paid_amount = approved_amount + 0.01 WHERE claim_id = jm_ut_fixture.id('JM_HMO_CLAIMS');
        not_raised('JM_HMO_CLAIMS_PAID_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_HMO_CLAIMS_PAID_CK');
    END hmo_claims_paid_ck;

    PROCEDURE hmo_claims_submitted_ck IS
    BEGIN
        UPDATE jm_hmo_claims SET submitted_at = NULL WHERE claim_id = jm_ut_fixture.id('JM_HMO_CLAIMS');
        not_raised('JM_HMO_CLAIMS_SUBMITTED_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_HMO_CLAIMS_SUBMITTED_CK');
    END hmo_claims_submitted_ck;

    PROCEDURE hmo_claims_decided_ck IS
    BEGIN
        UPDATE jm_hmo_claims SET decided_at = NULL WHERE claim_id = jm_ut_fixture.id('JM_HMO_CLAIMS');
        not_raised('JM_HMO_CLAIMS_DECIDED_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_HMO_CLAIMS_DECIDED_CK');
    END hmo_claims_decided_ck;

    PROCEDURE hmo_claims_rejected_ck IS
    BEGIN
        UPDATE jm_hmo_claims SET status = 'REJECTED', rejection_reason = NULL WHERE claim_id = jm_ut_fixture.id('JM_HMO_CLAIMS');
        not_raised('JM_HMO_CLAIMS_REJECTED_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_HMO_CLAIMS_REJECTED_CK');
    END hmo_claims_rejected_ck;

    PROCEDURE deleted_ck_every_table
    IS
        l_tested PLS_INTEGER := 0;
    BEGIN
        g_failures := NULL;
        FOR t IN (SELECT table_name FROM user_tab_columns
                   WHERE table_name LIKE 'JM\_%' ESCAPE '\' AND column_name = 'RECORD_STATUS'
                   ORDER BY table_name) LOOP
            -- the record guard stamps who and when, so only the missing reason can fail
            try_update(t.table_name, 'record_status = :v', c_check_violated, t.table_name || '_DELETED_CK',
                       t.table_name || ' deleted without a reason', p_text => 'DELETED');
            try_update(t.table_name, 'delete_reason = :v', c_check_violated, t.table_name || '_DELETED_CK',
                       t.table_name || ' active row with a delete reason', p_text => 'UT reason');
            l_tested := l_tested + 1;
        END LOOP;
        ut.expect(l_tested, 'soft-delete tables examined').to_equal(18);
        ut.expect(g_failures).to_be_null();
    END deleted_ck_every_table;

    ---------------------------------------------------------------------------
    -- unique keys on multi-key tables
    ---------------------------------------------------------------------------
    PROCEDURE staff_no_uk IS
    BEGIN
        INSERT INTO jm_staff (staff_no, username, first_name, last_name, department_id)
        VALUES ('UT-S1', 'UT_OTHER', 'Other', 'Person', jm_ut_fixture.id('JM_DEPARTMENTS'));
        not_raised('JM_STAFF_NO_UK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_unique_violated, 'JM_STAFF_NO_UK');
    END staff_no_uk;

    PROCEDURE staff_username_uk IS
    BEGIN
        INSERT INTO jm_staff (staff_no, username, first_name, last_name, department_id)
        VALUES ('UT-S9', 'UT_DOCTOR1', 'Other', 'Person', jm_ut_fixture.id('JM_DEPARTMENTS'));
        not_raised('JM_STAFF_USERNAME_UK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_unique_violated, 'JM_STAFF_USERNAME_UK');
    END staff_username_uk;

    PROCEDURE patient_accounts_patient_uk IS
    BEGIN
        INSERT INTO jm_patient_accounts (patient_id, login_id, password_hash, password_salt)
        VALUES (jm_ut_fixture.id('JM_PATIENTS'), 'second.login@example.test', 'h', 's');
        not_raised('JM_PATIENT_ACCOUNTS_PATIENT_UK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_unique_violated, 'JM_PATIENT_ACCOUNTS_PATIENT_UK');
    END patient_accounts_patient_uk;

    PROCEDURE patient_accounts_login_uk IS
        l_patient NUMBER;
    BEGIN
        INSERT INTO jm_patients (mrn, first_name, last_name, date_of_birth, gender, phone)
        VALUES ('UT-2026-000002', 'Second', 'Patient', DATE '1985-01-01', 'MALE', '08030000002')
        RETURNING patient_id INTO l_patient;
        INSERT INTO jm_patient_accounts (patient_id, login_id, password_hash, password_salt)
        VALUES (l_patient, 'ut.patient@example.test', 'h', 's');
        not_raised('JM_PATIENT_ACCOUNTS_LOGIN_UK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_unique_violated, 'JM_PATIENT_ACCOUNTS_LOGIN_UK');
    END patient_accounts_login_uk;

    PROCEDURE appointments_no_uk IS
    BEGIN
        INSERT INTO jm_appointments (appointment_no, patient_id, staff_id, schedule_id, slot_start, slot_end)
        VALUES ('UT-APT-1', jm_ut_fixture.id('JM_PATIENTS'), jm_ut_fixture.id('JM_STAFF'), jm_ut_fixture.id('JM_DOCTOR_SCHEDULES'),
                TRUNC(SYSDATE) + 1 + 10/24, TRUNC(SYSDATE) + 1 + 10/24 + 15/1440);
        not_raised('JM_APPOINTMENTS_NO_UK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_unique_violated, 'JM_APPOINTMENTS_NO_UK');
    END appointments_no_uk;

    PROCEDURE appointments_slot_uk IS
    BEGIN
        INSERT INTO jm_appointments (appointment_no, patient_id, staff_id, schedule_id, slot_start, slot_end)
        SELECT 'UT-APT-2', patient_id, staff_id, schedule_id, slot_start, slot_end
          FROM jm_appointments WHERE appointment_id = jm_ut_fixture.id('JM_APPOINTMENTS');
        not_raised('JM_APPOINTMENTS_SLOT_UK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_unique_violated, 'JM_APPOINTMENTS_SLOT_UK');
    END appointments_slot_uk;

    PROCEDURE visits_no_uk IS
    BEGIN
        INSERT INTO jm_visits (visit_no, patient_id, doctor_id)
        VALUES ('UT-VIS-1', jm_ut_fixture.id('JM_PATIENTS'), jm_ut_fixture.id('JM_STAFF'));
        not_raised('JM_VISITS_NO_UK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_unique_violated, 'JM_VISITS_NO_UK');
    END visits_no_uk;

    PROCEDURE visits_appointment_uk IS
    BEGIN
        INSERT INTO jm_visits (visit_no, patient_id, appointment_id, doctor_id)
        VALUES ('UT-VIS-9', jm_ut_fixture.id('JM_PATIENTS'), jm_ut_fixture.id('JM_APPOINTMENTS'), jm_ut_fixture.id('JM_STAFF'));
        not_raised('JM_VISITS_APPOINTMENT_UK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_unique_violated, 'JM_VISITS_APPOINTMENT_UK');
    END visits_appointment_uk;

    PROCEDURE invoices_no_uk IS
    BEGIN
        INSERT INTO jm_invoices (invoice_no, visit_id, patient_id)
        VALUES ('UT-INV-1', jm_ut_fixture.id('LOCKED_VISIT'), jm_ut_fixture.id('JM_PATIENTS'));
        not_raised('JM_INVOICES_NO_UK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_unique_violated, 'JM_INVOICES_NO_UK');
    END invoices_no_uk;

    PROCEDURE invoices_visit_uk IS
    BEGIN
        INSERT INTO jm_invoices (invoice_no, visit_id, patient_id)
        VALUES ('UT-INV-9', jm_ut_fixture.id('JM_VISITS'), jm_ut_fixture.id('JM_PATIENTS'));
        not_raised('JM_INVOICES_VISIT_UK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_unique_violated, 'JM_INVOICES_VISIT_UK');
    END invoices_visit_uk;

    PROCEDURE hmo_claims_no_uk IS
    BEGIN
        -- a rejected claim is outside JM_HMO_CLAIMS_INVOICE_UK, so only the claim number can clash
        INSERT INTO jm_hmo_claims (claim_no, invoice_id, hmo_plan_id, claim_amount, status,
                                   submitted_at, decided_at, rejection_reason)
        VALUES ('UT-CLM-1', jm_ut_fixture.id('JM_INVOICES'), jm_ut_fixture.id('JM_HMO_PLANS'), 100, 'REJECTED',
                SYSTIMESTAMP, SYSTIMESTAMP, 'Duplicate number test');
        not_raised('JM_HMO_CLAIMS_NO_UK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_unique_violated, 'JM_HMO_CLAIMS_NO_UK');
    END hmo_claims_no_uk;

    PROCEDURE hmo_claims_invoice_uk IS
    BEGIN
        INSERT INTO jm_hmo_claims (claim_no, invoice_id, hmo_plan_id, claim_amount)
        VALUES ('UT-CLM-2', jm_ut_fixture.id('JM_INVOICES'), jm_ut_fixture.id('JM_HMO_PLANS'), 100);
        not_raised('JM_HMO_CLAIMS_INVOICE_UK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_unique_violated, 'JM_HMO_CLAIMS_INVOICE_UK');
    END hmo_claims_invoice_uk;

    ---------------------------------------------------------------------------
    -- business rules: accepted cases and boundaries
    ---------------------------------------------------------------------------
    PROCEDURE rebook_after_cancel_or_no_show
    IS
        l_count PLS_INTEGER;
    BEGIN
        UPDATE jm_appointments SET status = 'CANCELLED', cancelled_at = SYSTIMESTAMP
         WHERE appointment_id = jm_ut_fixture.id('JM_APPOINTMENTS');
        INSERT INTO jm_appointments (appointment_no, patient_id, staff_id, schedule_id, slot_start, slot_end, status)
        SELECT 'UT-APT-2', patient_id, staff_id, schedule_id, slot_start, slot_end, 'NO_SHOW'
          FROM jm_appointments WHERE appointment_id = jm_ut_fixture.id('JM_APPOINTMENTS');
        INSERT INTO jm_appointments (appointment_no, patient_id, staff_id, schedule_id, slot_start, slot_end)
        SELECT 'UT-APT-3', patient_id, staff_id, schedule_id, slot_start, slot_end
          FROM jm_appointments WHERE appointment_id = jm_ut_fixture.id('JM_APPOINTMENTS');
        SELECT COUNT(*) INTO l_count
          FROM jm_appointments
         WHERE appointment_no IN ('UT-APT-1', 'UT-APT-2', 'UT-APT-3');
        ut.expect(l_count).to_equal(3);
    END rebook_after_cancel_or_no_show;

    PROCEDURE invoice_line_source_billed_once
    IS
    BEGIN
        -- same id, different source type: allowed
        INSERT INTO jm_invoice_lines (invoice_id, source_type, source_id, description, qty, unit_price)
        VALUES (jm_ut_fixture.id('JM_INVOICES'), 'LAB', jm_ut_fixture.id('JM_SERVICES'), 'Different source type', 1, 10);
        -- same source twice: rejected
        BEGIN
            INSERT INTO jm_invoice_lines (invoice_id, source_type, source_id, description, qty, unit_price)
            VALUES (jm_ut_fixture.id('JM_INVOICES'), 'SERVICE', jm_ut_fixture.id('JM_SERVICES'), 'Billed twice', 1, 10);
            not_raised('JM_INVOICE_LINES_SOURCE_UK');
        EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_unique_violated, 'JM_INVOICE_LINES_SOURCE_UK');
        END;
    END invoice_line_source_billed_once;

    PROCEDURE self_pay_patient_accepted
    IS
        l_count PLS_INTEGER;
    BEGIN
        INSERT INTO jm_patients (mrn, first_name, last_name, date_of_birth, gender, phone)
        VALUES ('UT-2026-000003', 'Self', 'Payer', DATE '2001-02-03', 'MALE', '08030000003');
        SELECT COUNT(*) INTO l_count FROM jm_patients WHERE mrn = 'UT-2026-000003' AND hmo_plan_id IS NULL;
        ut.expect(l_count).to_equal(1);
    END self_pay_patient_accepted;

    PROCEDURE vitals_boundaries
    IS
        TYPE t_range IS RECORD (col VARCHAR2(30), low NUMBER, high NUMBER, step NUMBER, ck VARCHAR2(30));
        TYPE t_ranges IS TABLE OF t_range;
        l_ranges t_ranges := t_ranges(
            t_range('TEMPERATURE_C', 30,  45,  0.1, 'JM_VITALS_TEMP_CK'),
            t_range('SYSTOLIC_BP',   50,  260, 1,   'JM_VITALS_SYSTOLIC_CK'),
            t_range('DIASTOLIC_BP',  30,  160, 1,   'JM_VITALS_DIASTOLIC_CK'),
            t_range('PULSE_BPM',     20,  250, 1,   'JM_VITALS_PULSE_CK'),
            t_range('RESP_RATE',     5,   80,  1,   'JM_VITALS_RESP_CK'),
            t_range('SPO2_PCT',      50,  100, 1,   'JM_VITALS_SPO2_CK'),
            t_range('WEIGHT_KG',     0.5, 400, 0.1, 'JM_VITALS_WEIGHT_CK'),
            t_range('HEIGHT_CM',     30,  250, 0.1, 'JM_VITALS_HEIGHT_CK'));
        l_set   VARCHAR2(100);
        l_limit NUMBER;
    BEGIN
        g_failures := NULL;
        FOR i IN 1 .. l_ranges.COUNT LOOP
            l_set := DBMS_ASSERT.simple_sql_name(l_ranges(i).col) || ' = :v';
            -- both limits are accepted
            FOR side IN 1 .. 2 LOOP
                l_limit := CASE side WHEN 1 THEN l_ranges(i).low ELSE l_ranges(i).high END;
                BEGIN
                    EXECUTE IMMEDIATE 'UPDATE jm_vitals SET ' || l_set || ' WHERE vitals_id = :k'
                        USING l_limit, jm_ut_fixture.id('JM_VITALS');
                EXCEPTION
                    WHEN OTHERS THEN note(l_ranges(i).col || ' = ' || l_limit || ' rejected: ' || SQLERRM);
                END;
            END LOOP;
            -- one step outside either limit is rejected by the named constraint
            try_update('JM_VITALS', l_set, c_check_violated, l_ranges(i).ck, l_ranges(i).col || ' below range',
                       p_num => l_ranges(i).low - l_ranges(i).step);
            try_update('JM_VITALS', l_set, c_check_violated, l_ranges(i).ck, l_ranges(i).col || ' above range',
                       p_num => l_ranges(i).high + l_ranges(i).step);
        END LOOP;
        ut.expect(g_failures).to_be_null();
    END vitals_boundaries;

    PROCEDURE stock_zero_not_negative
    IS
        l_on_hand NUMBER;
    BEGIN
        UPDATE jm_drug_batches SET qty_on_hand = 0 WHERE batch_id = jm_ut_fixture.id('JM_DRUG_BATCHES');
        SELECT qty_on_hand INTO l_on_hand FROM jm_drug_batches WHERE batch_id = jm_ut_fixture.id('JM_DRUG_BATCHES');
        ut.expect(l_on_hand).to_equal(0);
        BEGIN
            UPDATE jm_drug_batches SET qty_on_hand = qty_on_hand - 1 WHERE batch_id = jm_ut_fixture.id('JM_DRUG_BATCHES');
            not_raised('JM_DRUG_BATCHES_ON_HAND_CK');
        EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_DRUG_BATCHES_ON_HAND_CK');
        END;
    END stock_zero_not_negative;

    PROCEDURE hmo_not_a_patient_payment_method IS
    BEGIN
        INSERT INTO jm_payments (receipt_no, invoice_id, amount, pay_method, received_by)
        VALUES ('UT-RCP-HMO', jm_ut_fixture.id('JM_INVOICES'), 100, 'HMO', jm_ut_fixture.id('JM_STAFF'));
        not_raised('JM_PAYMENTS_METHOD_CK');
    EXCEPTION WHEN OTHERS THEN expect_error(SQLCODE, SQLERRM, c_check_violated, 'JM_PAYMENTS_METHOD_CK');
    END hmo_not_a_patient_payment_method;

    PROCEDURE soft_delete (p_table IN VARCHAR2)
    IS
    BEGIN
        EXECUTE IMMEDIATE 'UPDATE ' || DBMS_ASSERT.simple_sql_name(p_table) ||
                          ' SET record_status = ''DELETED'', delete_reason = ''Entered in error (UT)''' ||
                          ' WHERE ' || DBMS_ASSERT.simple_sql_name(pk_column(p_table)) || ' = :k'
            USING jm_ut_fixture.key(p_table);
    END soft_delete;

    PROCEDURE soft_delete_frees_business_keys
    IS
        l_count PLS_INTEGER;
    BEGIN
        soft_delete('JM_VISIT_DIAGNOSES');
        INSERT INTO jm_visit_diagnoses (visit_id, icd10_code)
        VALUES (jm_ut_fixture.id('JM_VISITS'), jm_ut_fixture.key('JM_ICD10_CODES'));

        soft_delete('JM_LAB_RESULTS');
        INSERT INTO jm_lab_results (lab_order_id, result_numeric, entered_by)
        VALUES (jm_ut_fixture.id('JM_LAB_ORDERS'), 14.1, jm_ut_fixture.id('STAFF2'));

        soft_delete('JM_INVOICE_LINES');
        INSERT INTO jm_invoice_lines (invoice_id, source_type, source_id, description, qty, unit_price)
        VALUES (jm_ut_fixture.id('JM_INVOICES'), 'SERVICE', jm_ut_fixture.id('JM_SERVICES'), 'Corrected line', 1, 5000);

        soft_delete('JM_DRUG_BATCHES');
        INSERT INTO jm_drug_batches (drug_id, batch_no, expiry_date, qty_received, qty_on_hand)
        VALUES (jm_ut_fixture.id('JM_DRUGS'), 'UT-BATCH1', ADD_MONTHS(TRUNC(SYSDATE), 18), 100, 100);

        soft_delete('JM_PATIENT_ACCOUNTS');
        INSERT INTO jm_patient_accounts (patient_id, login_id, password_hash, password_salt)
        VALUES (jm_ut_fixture.id('JM_PATIENTS'), 'ut.patient@example.test', 'h', 's');

        soft_delete('JM_VISITS');
        INSERT INTO jm_visits (visit_no, patient_id, appointment_id, doctor_id)
        VALUES ('UT-VIS-5', jm_ut_fixture.id('JM_PATIENTS'), jm_ut_fixture.id('JM_APPOINTMENTS'), jm_ut_fixture.id('JM_STAFF'));

        soft_delete('JM_APPOINTMENTS');
        INSERT INTO jm_appointments (appointment_no, patient_id, staff_id, schedule_id, slot_start, slot_end)
        SELECT 'UT-APT-5', patient_id, staff_id, schedule_id, slot_start, slot_end
          FROM jm_appointments WHERE appointment_id = jm_ut_fixture.id('JM_APPOINTMENTS');

        -- each corrected record sits beside the deleted original, which stays in the table
        SELECT COUNT(*) INTO l_count FROM jm_visit_diagnoses
         WHERE visit_id = jm_ut_fixture.id('JM_VISITS') AND icd10_code = jm_ut_fixture.key('JM_ICD10_CODES');
        ut.expect(l_count, 'diagnosis rows').to_equal(2);
        SELECT COUNT(*) INTO l_count FROM jm_lab_results WHERE lab_order_id = jm_ut_fixture.id('JM_LAB_ORDERS');
        ut.expect(l_count, 'lab result rows').to_equal(2);
        SELECT COUNT(*) INTO l_count FROM jm_visits
         WHERE appointment_id = jm_ut_fixture.id('JM_APPOINTMENTS') AND record_status = 'ACTIVE';
        ut.expect(l_count, 'active visits for the appointment').to_equal(1);
    END soft_delete_frees_business_keys;

    PROCEDURE void_invoice_and_rejected_claim_replaceable
    IS
        l_count PLS_INTEGER;
    BEGIN
        UPDATE jm_hmo_claims SET status = 'REJECTED', rejection_reason = 'Member not covered on visit date'
         WHERE claim_id = jm_ut_fixture.id('JM_HMO_CLAIMS');
        INSERT INTO jm_hmo_claims (claim_no, invoice_id, hmo_plan_id, claim_amount)
        VALUES ('UT-CLM-2', jm_ut_fixture.id('JM_INVOICES'), jm_ut_fixture.id('JM_HMO_PLANS'), 4000);

        UPDATE jm_invoices SET status = 'VOID' WHERE invoice_id = jm_ut_fixture.id('JM_INVOICES');
        INSERT INTO jm_invoices (invoice_no, visit_id, patient_id)
        VALUES ('UT-INV-2', jm_ut_fixture.id('JM_VISITS'), jm_ut_fixture.id('JM_PATIENTS'));

        SELECT COUNT(*) INTO l_count FROM jm_invoices WHERE visit_id = jm_ut_fixture.id('JM_VISITS');
        ut.expect(l_count, 'invoices for the visit').to_equal(2);
        SELECT COUNT(*) INTO l_count FROM jm_hmo_claims WHERE invoice_id = jm_ut_fixture.id('JM_INVOICES');
        ut.expect(l_count, 'claims for the invoice').to_equal(2);
    END void_invoice_and_rejected_claim_replaceable;
END jm_ut_constraints;
/
--rollback DROP PACKAGE BODY jm_ut_constraints;
