--liquibase formatted sql

--changeset adetola:test-020-schema-spec endDelimiter:/ runOnChange:true stripComments:false context:dev,test
--comment: Schema conformance suite: naming, typing and structural conventions of JM-DOC-03 section 1 (NFR-MNT-01, NFR-MNT-02). Test environments only.
CREATE OR REPLACE PACKAGE jm_ut_schema AUTHID DEFINER
IS
    --%suite(Database schema conventions (JM-DOC-03 section 1))
    --%suitepath(jmeds.database)

    --%test(Every application table has the JM_ prefix)
    PROCEDURE tables_have_prefix;

    --%test(Every table has a primary key named <TABLE>_PK)
    PROCEDURE primary_keys_named;

    --%test(Foreign, unique and check constraints are named <TABLE>_..._FK/_UK/_CK)
    PROCEDURE constraints_named;

    --%test(Only NOT NULL constraints have system-generated names)
    PROCEDURE no_system_named_constraints;

    --%test(Secondary indexes are named <TABLE>_..._IX or _UK)
    PROCEDURE indexes_named;

    --%test(Every foreign key column is indexed)
    PROCEDURE foreign_keys_indexed;

    --%test(Single-column numeric primary keys are identity columns)
    PROCEDURE primary_keys_are_identity;

    --%test(Every table except JM_AUDIT_LOG has the five audit columns with the standard types)
    PROCEDURE audit_columns_standard;

    --%test(Every table except JM_AUDIT_LOG has an enabled <TABLE>_BIU row trigger)
    PROCEDURE audit_triggers_present;

    --%test(Text columns longer than one character use CHAR length semantics)
    PROCEDURE strings_use_char_semantics;

    --%test(Flag columns are VARCHAR2(1) with a check constraint)
    PROCEDURE flags_are_checked;

    --%test(Money columns are NUMBER(12,2), except the derived LINE_AMOUNT)
    PROCEDURE money_is_number_12_2;

    --%test(Event columns ending _AT are TIMESTAMP WITH LOCAL TIME ZONE)
    PROCEDURE events_are_tsltz;

    --%test(No invalid objects and no disabled triggers or constraints)
    PROCEDURE everything_valid_and_enabled;

    --%test(Status check constraints and their JM_LOOKUPS lists hold the same codes)
    PROCEDURE lookups_match_checks;
END jm_ut_schema;
/
--rollback DROP PACKAGE jm_ut_schema;

--changeset adetola:test-020-schema-body endDelimiter:/ runOnChange:true stripComments:false context:dev,test
--comment: Schema conformance suite body (NFR-MNT-01, NFR-MNT-02). Test environments only.
CREATE OR REPLACE PACKAGE BODY jm_ut_schema
IS
    c_audit_log CONSTANT VARCHAR2(30) := 'JM_AUDIT_LOG';

    PROCEDURE tables_have_prefix
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        OPEN l_offenders FOR
            SELECT table_name
              FROM user_tables
             WHERE table_name NOT LIKE 'JM\_%' ESCAPE '\'
               AND table_name NOT LIKE 'DATABASECHANGELOG%';
        ut.expect(l_offenders).to_be_empty();
    END tables_have_prefix;

    PROCEDURE primary_keys_named
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        OPEN l_offenders FOR
            SELECT t.table_name, c.constraint_name
              FROM user_tables t
              LEFT JOIN user_constraints c
                ON c.table_name = t.table_name AND c.constraint_type = 'P'
             WHERE t.table_name LIKE 'JM\_%' ESCAPE '\'
               AND (c.constraint_name IS NULL OR c.constraint_name <> t.table_name || '_PK');
        ut.expect(l_offenders).to_be_empty();
    END primary_keys_named;

    PROCEDURE constraints_named
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        OPEN l_offenders FOR
            SELECT table_name, constraint_name, constraint_type
              FROM user_constraints
             WHERE table_name LIKE 'JM\_%' ESCAPE '\'
               AND constraint_name NOT LIKE 'SYS\_%' ESCAPE '\'
               AND (   (constraint_type = 'R' AND constraint_name NOT LIKE '%\_FK' ESCAPE '\')
                    OR (constraint_type = 'U' AND constraint_name NOT LIKE '%\_UK' ESCAPE '\')
                    OR (constraint_type = 'C' AND constraint_name NOT LIKE '%\_CK' ESCAPE '\')
                    OR (constraint_type IN ('R', 'U', 'C') AND constraint_name NOT LIKE table_name || '\_%' ESCAPE '\'));
        ut.expect(l_offenders).to_be_empty();
    END constraints_named;

    PROCEDURE no_system_named_constraints
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        OPEN l_offenders FOR
            SELECT table_name, constraint_name, constraint_type, search_condition_vc
              FROM user_constraints
             WHERE table_name LIKE 'JM\_%' ESCAPE '\'
               AND constraint_name LIKE 'SYS\_%' ESCAPE '\'
               AND NOT (constraint_type = 'C' AND search_condition_vc LIKE '"%" IS NOT NULL');
        ut.expect(l_offenders).to_be_empty();
    END no_system_named_constraints;

    PROCEDURE indexes_named
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        OPEN l_offenders FOR
            SELECT i.table_name, i.index_name, i.uniqueness
              FROM user_indexes i
             WHERE i.table_name LIKE 'JM\_%' ESCAPE '\'
               AND i.index_type <> 'LOB'
               AND NOT EXISTS (SELECT 1 FROM user_constraints c
                                WHERE c.index_name = i.index_name AND c.constraint_type IN ('P', 'U'))
               AND (   i.index_name NOT LIKE i.table_name || '\_%' ESCAPE '\'
                    OR (i.uniqueness = 'UNIQUE'    AND i.index_name NOT LIKE '%\_UK' ESCAPE '\')
                    OR (i.uniqueness = 'NONUNIQUE' AND i.index_name NOT LIKE '%\_IX' ESCAPE '\'));
        ut.expect(l_offenders).to_be_empty();
    END indexes_named;

    PROCEDURE foreign_keys_indexed
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        -- A foreign key is covered when some index starts with exactly its columns, in order.
        OPEN l_offenders FOR
            SELECT c.table_name, c.constraint_name
              FROM user_constraints c
             WHERE c.constraint_type = 'R'
               AND c.table_name LIKE 'JM\_%' ESCAPE '\'
               AND NOT EXISTS (
                     SELECT 1
                       FROM user_indexes i
                      WHERE i.table_name = c.table_name
                        AND NOT EXISTS (
                              SELECT 1
                                FROM user_cons_columns cc
                               WHERE cc.constraint_name = c.constraint_name
                                 AND NOT EXISTS (SELECT 1 FROM user_ind_columns ic
                                                  WHERE ic.index_name = i.index_name
                                                    AND ic.column_name = cc.column_name
                                                    AND ic.column_position = cc.position)));
        ut.expect(l_offenders).to_be_empty();
    END foreign_keys_indexed;

    PROCEDURE primary_keys_are_identity
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        OPEN l_offenders FOR
            SELECT tc.table_name, tc.column_name
              FROM user_constraints c
              JOIN user_cons_columns cc ON cc.constraint_name = c.constraint_name
              JOIN user_tab_columns tc ON tc.table_name = cc.table_name AND tc.column_name = cc.column_name
             WHERE c.constraint_type = 'P'
               AND c.table_name LIKE 'JM\_%' ESCAPE '\'
               AND tc.data_type = 'NUMBER'
               AND tc.identity_column <> 'YES'
               AND (SELECT COUNT(*) FROM user_cons_columns x WHERE x.constraint_name = c.constraint_name) = 1;
        ut.expect(l_offenders).to_be_empty();
    END primary_keys_are_identity;

    PROCEDURE audit_columns_standard
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        OPEN l_offenders FOR
            WITH expected (column_name, data_type, char_length, nullable) AS (
                SELECT 'CREATED_BY',  'VARCHAR2', 100, 'N' FROM dual UNION ALL
                SELECT 'CREATED_ON',  'TIMESTAMP(6) WITH LOCAL TIME ZONE', 0, 'N' FROM dual UNION ALL
                SELECT 'UPDATED_BY',  'VARCHAR2', 100, 'Y' FROM dual UNION ALL
                SELECT 'UPDATED_ON',  'TIMESTAMP(6) WITH LOCAL TIME ZONE', 0, 'Y' FROM dual UNION ALL
                SELECT 'ROW_VERSION', 'NUMBER', 0, 'N' FROM dual)
            SELECT t.table_name, e.column_name,
                   NVL2(c.column_name, c.data_type || ' ' || c.char_length || ' ' || c.nullable, 'missing') AS found
              FROM user_tables t
             CROSS JOIN expected e
              LEFT JOIN user_tab_columns c ON c.table_name = t.table_name AND c.column_name = e.column_name
             WHERE t.table_name LIKE 'JM\_%' ESCAPE '\'
               AND t.table_name <> c_audit_log
               AND (   c.column_name IS NULL
                    OR c.data_type <> e.data_type
                    OR c.char_length <> e.char_length
                    OR c.nullable <> e.nullable);
        ut.expect(l_offenders).to_be_empty();
    END audit_columns_standard;

    PROCEDURE audit_triggers_present
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        OPEN l_offenders FOR
            SELECT t.table_name, g.trigger_name, g.status, g.trigger_type, g.triggering_event
              FROM user_tables t
              LEFT JOIN user_triggers g ON g.trigger_name = t.table_name || '_BIU'
             WHERE t.table_name LIKE 'JM\_%' ESCAPE '\'
               AND t.table_name <> c_audit_log
               AND (   g.trigger_name IS NULL
                    OR g.status <> 'ENABLED'
                    OR g.table_name <> t.table_name
                    OR g.trigger_type <> 'BEFORE EACH ROW'
                    OR g.triggering_event <> 'INSERT OR UPDATE');
        ut.expect(l_offenders).to_be_empty();
    END audit_triggers_present;

    PROCEDURE strings_use_char_semantics
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        OPEN l_offenders FOR
            SELECT table_name, column_name, data_type, char_length, char_used
              FROM user_tab_columns
             WHERE table_name LIKE 'JM\_%' ESCAPE '\'
               AND data_type = 'VARCHAR2'
               AND char_length > 1
               AND char_used <> 'C';
        ut.expect(l_offenders).to_be_empty();
    END strings_use_char_semantics;

    PROCEDURE flags_are_checked
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        OPEN l_offenders FOR
            SELECT c.table_name, c.column_name, c.data_type, c.char_length
              FROM user_tab_columns c
             WHERE c.table_name LIKE 'JM\_%' ESCAPE '\'
               AND (c.column_name LIKE '%\_FLAG' ESCAPE '\' OR c.column_name IN ('HMO_COVERED', 'ALLERGY_OVERRIDE'))
               AND (   c.data_type <> 'VARCHAR2'
                    OR c.char_length <> 1
                    OR NOT EXISTS (SELECT 1
                                     FROM user_constraints k
                                     JOIN user_cons_columns kc ON kc.constraint_name = k.constraint_name
                                    WHERE k.table_name = c.table_name
                                      AND k.constraint_type = 'C'
                                      AND k.constraint_name NOT LIKE 'SYS\_%' ESCAPE '\'
                                      AND kc.column_name = c.column_name));
        ut.expect(l_offenders).to_be_empty();
    END flags_are_checked;

    PROCEDURE money_is_number_12_2
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        OPEN l_offenders FOR
            SELECT table_name, column_name, data_type, data_precision, data_scale
              FROM user_tab_columns
             WHERE table_name LIKE 'JM\_%' ESCAPE '\'
               AND (column_name IN ('PRICE', 'UNIT_PRICE', 'COST_PRICE', 'AMOUNT')
                    OR column_name LIKE '%\_AMOUNT' ESCAPE '\'
                    OR column_name = 'AMOUNT_PAID')
               AND column_name <> 'LINE_AMOUNT'
               AND NOT (data_type = 'NUMBER' AND data_precision = 12 AND data_scale = 2);
        ut.expect(l_offenders).to_be_empty();
    END money_is_number_12_2;

    PROCEDURE events_are_tsltz
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        OPEN l_offenders FOR
            SELECT table_name, column_name, data_type
              FROM user_tab_columns
             WHERE table_name LIKE 'JM\_%' ESCAPE '\'
               AND column_name LIKE '%\_AT' ESCAPE '\'
               AND data_type NOT LIKE 'TIMESTAMP(%) WITH LOCAL TIME ZONE';
        ut.expect(l_offenders).to_be_empty();
    END events_are_tsltz;

    PROCEDURE everything_valid_and_enabled
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        OPEN l_offenders FOR
            SELECT object_type AS kind, object_name AS name, status FROM user_objects WHERE status <> 'VALID'
            UNION ALL
            SELECT 'TRIGGER', trigger_name, status FROM user_triggers
             WHERE trigger_name LIKE 'JM\_%' ESCAPE '\' AND status <> 'ENABLED'
            UNION ALL
            SELECT 'CONSTRAINT', constraint_name, status || '/' || validated FROM user_constraints
             WHERE table_name LIKE 'JM\_%' ESCAPE '\' AND (status <> 'ENABLED' OR validated <> 'VALIDATED');
        ut.expect(l_offenders).to_be_empty();
    END everything_valid_and_enabled;

    PROCEDURE lookups_match_checks
    IS
        l_offenders SYS_REFCURSOR;
    BEGIN
        -- Each status-like IN-list check constraint, mapped to the lookup type that labels it on screen.
        OPEN l_offenders FOR
            WITH mapping (constraint_name, lookup_type) AS (
                SELECT 'JM_PATIENTS_GENDER_CK',               'GENDER'              FROM dual UNION ALL
                SELECT 'JM_PATIENTS_STATUS_CK',               'PATIENT_STATUS'      FROM dual UNION ALL
                SELECT 'JM_PATIENTS_REG_CHANNEL_CK',          'CHANNEL'             FROM dual UNION ALL
                SELECT 'JM_APPOINTMENTS_VIA_CK',              'CHANNEL'             FROM dual UNION ALL
                SELECT 'JM_PATIENT_CONSENTS_VIA_CK',          'CHANNEL'             FROM dual UNION ALL
                SELECT 'JM_PATIENT_CONSENTS_TYPE_CK',         'CONSENT_TYPE'        FROM dual UNION ALL
                SELECT 'JM_PATIENT_ALLERGIES_SEVERITY_CK',    'ALLERGY_SEVERITY'    FROM dual UNION ALL
                SELECT 'JM_APPOINTMENTS_STATUS_CK',           'APT_STATUS'          FROM dual UNION ALL
                SELECT 'JM_VISITS_STATUS_CK',                 'VISIT_STATUS'        FROM dual UNION ALL
                SELECT 'JM_VISIT_DIAGNOSES_TYPE_CK',          'DIAGNOSIS_TYPE'      FROM dual UNION ALL
                SELECT 'JM_PRESCRIPTIONS_STATUS_CK',          'PRESCRIPTION_STATUS' FROM dual UNION ALL
                SELECT 'JM_LAB_ORDERS_STATUS_CK',             'LAB_ORDER_STATUS'    FROM dual UNION ALL
                SELECT 'JM_LAB_ORDERS_URGENCY_CK',            'LAB_URGENCY'         FROM dual UNION ALL
                SELECT 'JM_INVOICES_STATUS_CK',               'INVOICE_STATUS'      FROM dual UNION ALL
                SELECT 'JM_PAYMENTS_METHOD_CK',               'PAY_METHOD'          FROM dual UNION ALL
                SELECT 'JM_PAYMENTS_STATUS_CK',               'PAYMENT_STATUS'      FROM dual),
            cons AS (
                -- read the dictionary once; joining it inside the row generator is very slow
                SELECT /*+ MATERIALIZE */ c.constraint_name, c.search_condition_vc AS cond
                  FROM user_constraints c
                 WHERE c.table_name LIKE 'JM\_%' ESCAPE '\'
                   AND c.constraint_type = 'C'
                   AND c.constraint_name IN (SELECT constraint_name FROM mapping)),
            check_codes AS (
                SELECT m.constraint_name, m.lookup_type,
                       REGEXP_SUBSTR(c.cond, '''([^'']+)''', 1, n.pos, NULL, 1) AS code
                  FROM mapping m
                  JOIN cons c ON c.constraint_name = m.constraint_name
                 CROSS JOIN (SELECT LEVEL AS pos FROM dual CONNECT BY LEVEL <= 20) n
                 WHERE REGEXP_SUBSTR(c.cond, '''([^'']+)''', 1, n.pos, NULL, 1) IS NOT NULL),
            lookup_codes AS (
                SELECT m.constraint_name, m.lookup_type, l.lookup_code AS code
                  FROM mapping m
                  JOIN jm_lookups l ON l.lookup_type = m.lookup_type)
            SELECT constraint_name, lookup_type, code, 'in check, not in lookups' AS problem
              FROM (SELECT constraint_name, lookup_type, code FROM check_codes
                    MINUS SELECT constraint_name, lookup_type, code FROM lookup_codes)
            UNION ALL
            SELECT constraint_name, lookup_type, code, 'in lookups, not in check'
              FROM (SELECT constraint_name, lookup_type, code FROM lookup_codes
                    MINUS SELECT constraint_name, lookup_type, code FROM check_codes)
            UNION ALL
            SELECT m.constraint_name, m.lookup_type, NULL, 'constraint does not exist'
              FROM mapping m
             WHERE NOT EXISTS (SELECT 1 FROM cons c WHERE c.constraint_name = m.constraint_name);
        ut.expect(l_offenders).to_be_empty();
    END lookups_match_checks;
END jm_ut_schema;
/
--rollback DROP PACKAGE BODY jm_ut_schema;
