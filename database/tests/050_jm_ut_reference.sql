--liquibase formatted sql

--changeset adetola:test-050-reference-spec endDelimiter:/ runOnChange:true stripComments:false context:dev,test
--comment: Reference data and scheduler suite: roles, departments, lookups, ICD-10 subset, visit-lock job (FR-ADM-01, FR-CLN-03, FR-CLN-04). Test environments only.
CREATE OR REPLACE PACKAGE jm_ut_reference AUTHID DEFINER
IS
    --%suite(Reference data and scheduled jobs)
    --%suitepath(jmeds.database)

    --%test(Exactly the eight application roles are seeded (FR-ADM-01))
    PROCEDURE roles_seeded;

    --%test(Exactly the seven departments are seeded (FR-ADM-01))
    PROCEDURE departments_seeded;

    --%test(Every lookup type is present, active, with unique display order (FR-ADM-01))
    PROCEDURE lookups_seeded;

    --%test(The ICD-10 subset has 200 well-formed, described codes (FR-CLN-03))
    PROCEDURE icd10_subset_valid;

    --%test(The visit-lock job exists, is enabled and runs hourly (FR-CLN-04))
    PROCEDURE lock_job_scheduled;

    --%test(The visit-lock job locks only visits completed more than 24 hours ago (FR-CLN-04))
    --%disabled(DEF-005: the job logic is an anonymous block that commits, so it cannot run inside a rolled-back test; moves to JM_CLINICAL_API.lock_completed_visits in the API phase)
    PROCEDURE lock_job_locks_only_expired;
END jm_ut_reference;
/
--rollback DROP PACKAGE jm_ut_reference;

--changeset adetola:test-050-reference-body endDelimiter:/ runOnChange:true stripComments:false context:dev,test
--comment: Reference data and scheduler suite body (FR-ADM-01, FR-CLN-03, FR-CLN-04). Test environments only.
CREATE OR REPLACE PACKAGE BODY jm_ut_reference
IS
    PROCEDURE roles_seeded
    IS
        l_actual   SYS_REFCURSOR;
        l_expected SYS_REFCURSOR;
    BEGIN
        OPEN l_actual FOR SELECT role_code FROM jm_roles ORDER BY role_code;
        OPEN l_expected FOR
            SELECT COLUMN_VALUE AS role_code
              FROM TABLE(sys.odcivarchar2list('ADMIN', 'CASHIER', 'DOCTOR', 'FRONTDESK', 'LABSCI', 'MANAGER', 'NURSE', 'PHARMACIST'))
             ORDER BY 1;
        ut.expect(l_actual).to_equal(l_expected);
    END roles_seeded;

    PROCEDURE departments_seeded
    IS
        l_actual   SYS_REFCURSOR;
        l_expected SYS_REFCURSOR;
    BEGIN
        OPEN l_actual FOR SELECT dept_code FROM jm_departments WHERE dept_code NOT LIKE 'UT-%' ORDER BY dept_code;
        OPEN l_expected FOR
            SELECT COLUMN_VALUE AS dept_code
              FROM TABLE(sys.odcivarchar2list('ADM', 'BIL', 'LAB', 'NUR', 'OPD', 'PHM', 'REC'))
             ORDER BY 1;
        ut.expect(l_actual).to_equal(l_expected);
    END departments_seeded;

    PROCEDURE lookups_seeded
    IS
        l_missing  SYS_REFCURSOR;
        l_problems SYS_REFCURSOR;
    BEGIN
        OPEN l_missing FOR
            SELECT COLUMN_VALUE AS lookup_type
              FROM TABLE(sys.odcivarchar2list(
                     'ALLERGY_SEVERITY', 'APT_STATUS', 'BLOOD_GROUP', 'CHANNEL', 'CONSENT_TYPE', 'DIAGNOSIS_TYPE',
                     'DOSAGE_FORM', 'FREQUENCY', 'GENDER', 'GENOTYPE', 'INVOICE_STATUS', 'LAB_ORDER_STATUS',
                     'LAB_URGENCY', 'PATIENT_STATUS', 'PAYMENT_STATUS', 'PAY_METHOD', 'PRESCRIPTION_STATUS',
                     'RELATIONSHIP', 'SAMPLE_TYPE', 'TRIAGE', 'VISIT_STATUS'))
            MINUS
            SELECT lookup_type FROM jm_lookups;
        ut.expect(l_missing).to_be_empty();

        OPEN l_problems FOR
            SELECT lookup_type, lookup_code, 'inactive' AS problem FROM jm_lookups WHERE active_flag <> 'Y'
            UNION ALL
            SELECT lookup_type, NULL, 'duplicate display_seq'
              FROM jm_lookups GROUP BY lookup_type, display_seq HAVING COUNT(*) > 1
            UNION ALL
            SELECT lookup_type, NULL, 'fewer than two values'
              FROM jm_lookups GROUP BY lookup_type HAVING COUNT(*) < 2;
        ut.expect(l_problems).to_be_empty();
    END lookups_seeded;

    PROCEDURE icd10_subset_valid
    IS
        l_count PLS_INTEGER;
        l_bad   SYS_REFCURSOR;
    BEGIN
        SELECT COUNT(*) INTO l_count FROM jm_icd10_codes;
        ut.expect(l_count, 'ICD-10 codes loaded').to_equal(200);
        OPEN l_bad FOR
            SELECT icd10_code, description
              FROM jm_icd10_codes
             WHERE NOT REGEXP_LIKE(icd10_code, '^[A-Z][0-9]{2}(\.[0-9A-Z]{1,4})?$')
                OR TRIM(description) IS NULL;
        ut.expect(l_bad).to_be_empty();
    END icd10_subset_valid;

    PROCEDURE lock_job_scheduled
    IS
        l_enabled  user_scheduler_jobs.enabled%TYPE;
        l_interval user_scheduler_jobs.repeat_interval%TYPE;
        l_action   user_scheduler_jobs.job_action%TYPE;
    BEGIN
        SELECT enabled, repeat_interval, job_action
          INTO l_enabled, l_interval, l_action
          FROM user_scheduler_jobs
         WHERE job_name = 'JM_LOCK_COMPLETED_VISITS';
        ut.expect(l_enabled).to_equal('TRUE');
        ut.expect(l_interval).to_equal('FREQ=HOURLY;BYMINUTE=5');
        ut.expect(UPPER(l_action)).to_be_like('%STATUS = ''COMPLETED''%');
        ut.expect(UPPER(l_action)).to_be_like('%INTERVAL ''1'' DAY%');
    END lock_job_scheduled;

    PROCEDURE lock_job_locks_only_expired
    IS
    BEGIN
        ut.fail('Not runnable until DEF-005 is fixed');
    END lock_job_locks_only_expired;
END jm_ut_reference;
/
--rollback DROP PACKAGE BODY jm_ut_reference;
