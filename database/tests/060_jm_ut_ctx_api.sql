--liquibase formatted sql

--changeset adetola:test-060-ctx-api-spec endDelimiter:/ runOnChange:true stripComments:false context:dev,test
--comment: JM_CTX_API suite: identity, roles, patient isolation, session hygiene, audit columns (NFR-SEC-01, NFR-SEC-02; DEF-008). Test environments only.
CREATE OR REPLACE PACKAGE jm_ut_ctx_api AUTHID DEFINER
IS
    --%suite(JM_CTX_API: who is calling (NFR-SEC-01, NFR-SEC-02))
    --%suitepath(jmeds.api)
    --%beforeall(jm_ut_fixture.build)
    --%aftereach(jm_ctx_api.clear)

    --%context(Staff identity)

    --%test(A signed-in staff member is identified with their roles, client and address)
    PROCEDURE staff_identified;

    --%test(An unknown username is refused)
    --%throws(-20100)
    PROCEDURE staff_unknown_refused;

    --%test(An inactive staff member is refused)
    --%throws(-20100)
    PROCEDURE staff_inactive_refused;

    --%test(A staff member without roles is refused)
    --%throws(-20100)
    PROCEDURE staff_without_roles_refused;

    --%test(Staff cannot claim the JOB client)
    --%throws(-20102)
    PROCEDURE staff_job_client_refused;

    --%endcontext

    --%context(Patient identity)

    --%test(A signed-in patient is identified by account, without login ID, staff ID or roles)
    PROCEDURE patient_identified;

    --%test(A pending (unverified) patient is identified with status PENDING (FR-PAT-04))
    PROCEDURE patient_pending_identified;

    --%test(An unknown account is refused)
    --%throws(-20100)
    PROCEDURE patient_unknown_refused;

    --%test(A locked account is refused (NFR-SEC-03))
    --%throws(-20100)
    PROCEDURE patient_locked_refused;

    --%test(A deleted account is refused (DEF-006))
    --%throws(-20100)
    PROCEDURE patient_deleted_account_refused;

    --%test(An anonymised patient is refused)
    --%throws(-20100)
    PROCEDURE patient_anonymised_refused;

    --%test(Patients cannot claim the JOB client)
    --%throws(-20102)
    PROCEDURE patient_job_client_refused;

    --%endcontext

    --%context(System identity)

    --%test(A job in a schema-owner session is identified as SYSTEM with client JOB)
    PROCEDURE system_identified;

    --%test(A job name must be upper case letters, digits and underscores)
    --%throws(-20102)
    PROCEDURE system_bad_name_refused;

    --%test(A missing job name is refused)
    --%throws(-20102)
    PROCEDURE system_null_name_refused;

    --%endcontext

    --%context(Roles and patient isolation (NFR-SEC-02))

    --%test(has_role is true only for the staff actor's own roles, in any letter case)
    PROCEDURE has_role_matches_own_roles;

    --%test(require_role passes when the staff actor holds any of the listed roles)
    PROCEDURE require_role_any_of;

    --%test(require_role refuses a staff actor without the role)
    --%throws(-20101)
    PROCEDURE require_role_missing_refused;

    --%test(require_role refuses a patient actor)
    --%throws(-20101)
    PROCEDURE require_role_patient_refused;

    --%test(require_role passes a system job)
    PROCEDURE require_role_system_passes;

    --%test(require_role refuses a call with no identity)
    --%throws(-20100)
    PROCEDURE require_role_anonymous_refused;

    --%test(A patient may reach their own record)
    PROCEDURE patient_reaches_own_record;

    --%test(A patient can never reach another patient's record)
    --%throws(-20101)
    PROCEDURE patient_blocked_from_other_record;

    --%test(A patient cannot pass a missing patient ID)
    --%throws(-20101)
    PROCEDURE patient_blocked_from_null_record;

    --%test(Staff pass the patient guard; their roles are checked separately)
    PROCEDURE staff_pass_patient_guard;

    --%test(The patient guard refuses a call with no identity)
    --%throws(-20100)
    PROCEDURE patient_guard_anonymous_refused;

    --%endcontext

    --%context(Pooled sessions: nothing leaks between requests)

    --%test(clear removes every attribute)
    PROCEDURE clear_removes_everything;

    --%test(Switching from staff to patient drops the staff ID and roles)
    PROCEDURE switch_drops_previous_identity;

    --%test(A failed sign-in leaves no identity behind)
    PROCEDURE failed_set_leaves_no_identity;

    --%endcontext

    --%context(Audit columns follow the context (DEF-008))

    --%test(CREATED_BY, UPDATED_BY and DELETED_BY record the context actor)
    PROCEDURE audit_columns_use_context_actor;

    --%test(Caller-supplied CREATED_BY and CREATED_ON are overruled on insert)
    PROCEDURE created_stamp_not_spoofable;

    --%test(Without a context, the database user is recorded)
    PROCEDURE no_context_uses_session_user;

    --%test(No audit trigger keeps a caller-supplied creator or creation time)
    PROCEDURE no_trigger_trusts_caller_stamp;

    --%endcontext

    --%test(JMEDS_API holds only EXECUTE on JM_*_API packages: no table privileges (NFR-MNT-01))
    PROCEDURE jmeds_api_execute_only;
END jm_ut_ctx_api;
/
--rollback DROP PACKAGE jm_ut_ctx_api;

--changeset adetola:test-060-ctx-api-body endDelimiter:/ runOnChange:true stripComments:false context:dev,test
--comment: JM_CTX_API suite body (NFR-SEC-01, NFR-SEC-02; DEF-008). Test environments only.
CREATE OR REPLACE PACKAGE BODY jm_ut_ctx_api
IS
    c_doctor CONSTANT VARCHAR2(30) := 'UT_DOCTOR1';

    PROCEDURE expect_no_identity
    IS
    BEGIN
        ut.expect(jm_ctx_api.actor, 'actor').to_be_null();
        ut.expect(jm_ctx_api.actor_type, 'actor_type').to_be_null();
        ut.expect(jm_ctx_api.staff_id, 'staff_id').to_be_null();
        ut.expect(jm_ctx_api.patient_id, 'patient_id').to_be_null();
        ut.expect(jm_ctx_api.account_id, 'account_id').to_be_null();
        ut.expect(jm_ctx_api.patient_status, 'patient_status').to_be_null();
        ut.expect(jm_ctx_api.client, 'client').to_be_null();
        ut.expect(jm_ctx_api.ip_address, 'ip_address').to_be_null();
        ut.expect(SYS_CONTEXT('JM_CTX', 'ROLES'), 'roles').to_be_null();
    END expect_no_identity;

    PROCEDURE sign_in_patient
    IS
    BEGIN
        jm_ctx_api.set_patient(jm_ut_fixture.id('JM_PATIENT_ACCOUNTS'));
    END sign_in_patient;

    ---------------------------------------------------------------------------
    PROCEDURE staff_identified IS
    BEGIN
        jm_ctx_api.set_staff(' ut_doctor1 ', 'APEX', '10.0.0.7');
        ut.expect(jm_ctx_api.actor).to_equal(c_doctor);
        ut.expect(jm_ctx_api.actor_type).to_equal(jm_ctx_api.c_staff);
        ut.expect(jm_ctx_api.staff_id).to_equal(jm_ut_fixture.id('JM_STAFF'));
        ut.expect(SYS_CONTEXT('JM_CTX', 'ROLES')).to_equal(':DOCTOR:');
        ut.expect(jm_ctx_api.client).to_equal('APEX');
        ut.expect(jm_ctx_api.ip_address).to_equal('10.0.0.7');
        ut.expect(jm_ctx_api.patient_id, 'patient_id').to_be_null();
        ut.expect(jm_current_user, 'JM_CURRENT_USER').to_equal(c_doctor);
    END staff_identified;

    PROCEDURE staff_unknown_refused IS
    BEGIN
        jm_ctx_api.set_staff('UT_NOBODY');
    END staff_unknown_refused;

    PROCEDURE staff_inactive_refused IS
    BEGIN
        UPDATE jm_staff SET active_flag = 'N' WHERE staff_id = jm_ut_fixture.id('JM_STAFF');
        jm_ctx_api.set_staff(c_doctor);
    END staff_inactive_refused;

    PROCEDURE staff_without_roles_refused IS
    BEGIN
        jm_ctx_api.set_staff('UT_LABSCI1');
    END staff_without_roles_refused;

    PROCEDURE staff_job_client_refused IS
    BEGIN
        jm_ctx_api.set_staff(c_doctor, 'JOB');
    END staff_job_client_refused;

    ---------------------------------------------------------------------------
    PROCEDURE patient_identified IS
        l_account NUMBER := jm_ut_fixture.id('JM_PATIENT_ACCOUNTS');
    BEGIN
        jm_ctx_api.set_patient(l_account, 'ORDS', '2001:db8::1');
        ut.expect(jm_ctx_api.actor).to_equal('PATIENT:' || l_account);
        ut.expect(jm_ctx_api.actor_type).to_equal(jm_ctx_api.c_patient);
        ut.expect(jm_ctx_api.patient_id).to_equal(jm_ut_fixture.id('JM_PATIENTS'));
        ut.expect(jm_ctx_api.account_id).to_equal(l_account);
        ut.expect(jm_ctx_api.patient_status).to_equal('ACTIVE');
        ut.expect(jm_ctx_api.client).to_equal('ORDS');
        ut.expect(jm_ctx_api.ip_address).to_equal('2001:db8::1');
        ut.expect(jm_ctx_api.staff_id, 'staff_id').to_be_null();
        ut.expect(SYS_CONTEXT('JM_CTX', 'ROLES'), 'roles').to_be_null();
        ut.expect(jm_ctx_api.actor, 'no login ID in the actor').not_to_be_like('%@%');
    END patient_identified;

    PROCEDURE patient_pending_identified IS
    BEGIN
        UPDATE jm_patients SET status = 'PENDING' WHERE patient_id = jm_ut_fixture.id('JM_PATIENTS');
        sign_in_patient;
        ut.expect(jm_ctx_api.patient_status).to_equal('PENDING');
    END patient_pending_identified;

    PROCEDURE patient_unknown_refused IS
    BEGIN
        jm_ctx_api.set_patient(-1);
    END patient_unknown_refused;

    PROCEDURE patient_locked_refused IS
    BEGIN
        UPDATE jm_patient_accounts SET locked_flag = 'Y' WHERE account_id = jm_ut_fixture.id('JM_PATIENT_ACCOUNTS');
        sign_in_patient;
    END patient_locked_refused;

    PROCEDURE patient_deleted_account_refused IS
    BEGIN
        UPDATE jm_patient_accounts SET record_status = 'DELETED', delete_reason = 'Closed at patient request (UT)'
         WHERE account_id = jm_ut_fixture.id('JM_PATIENT_ACCOUNTS');
        sign_in_patient;
    END patient_deleted_account_refused;

    PROCEDURE patient_anonymised_refused IS
    BEGIN
        UPDATE jm_patients SET status = 'ANONYMISED' WHERE patient_id = jm_ut_fixture.id('JM_PATIENTS');
        sign_in_patient;
    END patient_anonymised_refused;

    PROCEDURE patient_job_client_refused IS
    BEGIN
        jm_ctx_api.set_patient(jm_ut_fixture.id('JM_PATIENT_ACCOUNTS'), 'JOB');
    END patient_job_client_refused;

    ---------------------------------------------------------------------------
    PROCEDURE system_identified IS
    BEGIN
        jm_ctx_api.set_system('JM_TEST_DATA');
        ut.expect(jm_ctx_api.actor).to_equal('JM_TEST_DATA');
        ut.expect(jm_ctx_api.actor_type).to_equal(jm_ctx_api.c_system);
        ut.expect(jm_ctx_api.client).to_equal('JOB');
        ut.expect(jm_ctx_api.staff_id, 'staff_id').to_be_null();
        ut.expect(jm_ctx_api.patient_id, 'patient_id').to_be_null();
    END system_identified;

    PROCEDURE system_bad_name_refused IS
    BEGIN
        jm_ctx_api.set_system('jm_test data');
    END system_bad_name_refused;

    PROCEDURE system_null_name_refused IS
    BEGIN
        jm_ctx_api.set_system(NULL);
    END system_null_name_refused;

    ---------------------------------------------------------------------------
    PROCEDURE has_role_matches_own_roles IS
    BEGIN
        jm_ctx_api.set_staff(c_doctor);
        ut.expect(jm_ctx_api.has_role('DOCTOR'), 'DOCTOR').to_be_true();
        ut.expect(jm_ctx_api.has_role(' doctor '), 'doctor').to_be_true();
        ut.expect(jm_ctx_api.has_role('NURSE'), 'NURSE').to_be_false();
        ut.expect(jm_ctx_api.has_role('DOC'), 'partial code').to_be_false();
        sign_in_patient;
        ut.expect(jm_ctx_api.has_role('DOCTOR'), 'patient').to_be_false();
    END has_role_matches_own_roles;

    PROCEDURE require_role_any_of IS
    BEGIN
        jm_ctx_api.set_staff(c_doctor);
        jm_ctx_api.require_role('NURSE, doctor');
        jm_ctx_api.require_role('DOCTOR');
        ut.expect(jm_ctx_api.actor).to_equal(c_doctor);
    END require_role_any_of;

    PROCEDURE require_role_missing_refused IS
    BEGIN
        jm_ctx_api.set_staff(c_doctor);
        jm_ctx_api.require_role('CASHIER,ADMIN');
    END require_role_missing_refused;

    PROCEDURE require_role_patient_refused IS
    BEGIN
        sign_in_patient;
        jm_ctx_api.require_role('DOCTOR');
    END require_role_patient_refused;

    PROCEDURE require_role_system_passes IS
    BEGIN
        jm_ctx_api.set_system('JM_LOCK_COMPLETED_VISITS');
        jm_ctx_api.require_role('DOCTOR');
        ut.expect(jm_ctx_api.actor_type).to_equal(jm_ctx_api.c_system);
    END require_role_system_passes;

    PROCEDURE require_role_anonymous_refused IS
    BEGIN
        jm_ctx_api.require_role('DOCTOR');
    END require_role_anonymous_refused;

    PROCEDURE patient_reaches_own_record IS
    BEGIN
        sign_in_patient;
        jm_ctx_api.require_patient_access(jm_ut_fixture.id('JM_PATIENTS'));
        ut.expect(jm_ctx_api.patient_id).to_equal(jm_ut_fixture.id('JM_PATIENTS'));
    END patient_reaches_own_record;

    PROCEDURE patient_blocked_from_other_record IS
    BEGIN
        sign_in_patient;
        jm_ctx_api.require_patient_access(jm_ut_fixture.id('JM_PATIENTS') + 1);
    END patient_blocked_from_other_record;

    PROCEDURE patient_blocked_from_null_record IS
    BEGIN
        sign_in_patient;
        jm_ctx_api.require_patient_access(NULL);
    END patient_blocked_from_null_record;

    PROCEDURE staff_pass_patient_guard IS
    BEGIN
        jm_ctx_api.set_staff(c_doctor);
        jm_ctx_api.require_patient_access(jm_ut_fixture.id('JM_PATIENTS'));
        jm_ctx_api.set_system('JM_TEST_DATA');
        jm_ctx_api.require_patient_access(jm_ut_fixture.id('JM_PATIENTS'));
        ut.expect(jm_ctx_api.actor_type).to_equal(jm_ctx_api.c_system);
    END staff_pass_patient_guard;

    PROCEDURE patient_guard_anonymous_refused IS
    BEGIN
        jm_ctx_api.require_patient_access(jm_ut_fixture.id('JM_PATIENTS'));
    END patient_guard_anonymous_refused;

    ---------------------------------------------------------------------------
    PROCEDURE clear_removes_everything IS
    BEGIN
        jm_ctx_api.set_staff(c_doctor, 'APEX', '10.0.0.7');
        jm_ctx_api.clear;
        expect_no_identity;
    END clear_removes_everything;

    PROCEDURE switch_drops_previous_identity IS
    BEGIN
        jm_ctx_api.set_staff(c_doctor);
        sign_in_patient;
        ut.expect(jm_ctx_api.actor_type).to_equal(jm_ctx_api.c_patient);
        ut.expect(jm_ctx_api.staff_id, 'staff_id').to_be_null();
        ut.expect(SYS_CONTEXT('JM_CTX', 'ROLES'), 'roles').to_be_null();
        ut.expect(jm_ctx_api.has_role('DOCTOR'), 'DOCTOR').to_be_false();
    END switch_drops_previous_identity;

    PROCEDURE failed_set_leaves_no_identity IS
    BEGIN
        jm_ctx_api.set_staff(c_doctor);
        BEGIN
            jm_ctx_api.set_staff('UT_NOBODY');
        EXCEPTION
            WHEN jm_ctx_api.e_not_identified THEN NULL;
        END;
        expect_no_identity;

        sign_in_patient;
        BEGIN
            jm_ctx_api.set_patient(jm_ut_fixture.id('JM_PATIENT_ACCOUNTS'), 'JOB');
        EXCEPTION
            WHEN jm_ctx_api.e_invalid_argument THEN NULL;
        END;
        expect_no_identity;
    END failed_set_leaves_no_identity;

    ---------------------------------------------------------------------------
    PROCEDURE audit_columns_use_context_actor
    IS
        l_id      NUMBER;
        l_created jm_departments.created_by%TYPE;
        l_updated jm_departments.updated_by%TYPE;
        l_deleted jm_patient_allergies.deleted_by%TYPE;
    BEGIN
        jm_ctx_api.set_staff(c_doctor);
        INSERT INTO jm_departments (dept_code, dept_name) VALUES ('UT-CTX', 'Context test')
        RETURNING department_id INTO l_id;
        UPDATE jm_departments SET dept_name = 'Context test 2' WHERE department_id = l_id;
        SELECT created_by, updated_by INTO l_created, l_updated FROM jm_departments WHERE department_id = l_id;
        ut.expect(l_created, 'created_by').to_equal(c_doctor);
        ut.expect(l_updated, 'updated_by').to_equal(c_doctor);

        sign_in_patient;
        UPDATE jm_patient_allergies SET record_status = 'DELETED', delete_reason = 'Entered in error (UT)'
         WHERE allergy_id = jm_ut_fixture.id('JM_PATIENT_ALLERGIES');
        SELECT deleted_by INTO l_deleted FROM jm_patient_allergies WHERE allergy_id = jm_ut_fixture.id('JM_PATIENT_ALLERGIES');
        ut.expect(l_deleted, 'deleted_by').to_equal('PATIENT:' || jm_ut_fixture.id('JM_PATIENT_ACCOUNTS'));
    END audit_columns_use_context_actor;

    PROCEDURE created_stamp_not_spoofable
    IS
        l_by jm_departments.created_by%TYPE;
        l_on jm_departments.created_on%TYPE;
    BEGIN
        jm_ctx_api.set_system('JM_TEST_DATA');
        INSERT INTO jm_departments (dept_code, dept_name, created_by, created_on)
        VALUES ('UT-SPF', 'Spoof test', 'SPOOFED', TIMESTAMP '2000-01-01 00:00:00')
        RETURNING created_by, created_on INTO l_by, l_on;
        ut.expect(l_by).to_equal('JM_TEST_DATA');
        ut.expect(l_on > SYSTIMESTAMP - INTERVAL '1' MINUTE, 'created_on is now').to_be_true();
    END created_stamp_not_spoofable;

    PROCEDURE no_context_uses_session_user IS
    BEGIN
        jm_ctx_api.clear;
        ut.expect(jm_current_user).to_equal(SYS_CONTEXT('USERENV', 'SESSION_USER'));
    END no_context_uses_session_user;

    PROCEDURE no_trigger_trusts_caller_stamp
    IS
        l_bad      SYS_REFCURSOR;
        l_triggers PLS_INTEGER;
    BEGIN
        SELECT COUNT(*) INTO l_triggers FROM user_triggers WHERE trigger_name LIKE 'JM\_%\_BIU' ESCAPE '\';
        ut.expect(l_triggers, 'audit triggers').to_equal(29);
        OPEN l_bad FOR
            SELECT name, line, text
              FROM user_source
             WHERE type = 'TRIGGER'
               AND name LIKE 'JM\_%\_BIU' ESCAPE '\'
               AND REGEXP_LIKE(text, 'NVL\s*\(\s*:new\.created_(by|on)', 'i');
        ut.expect(l_bad).to_be_empty();
    END no_trigger_trusts_caller_stamp;

    PROCEDURE jmeds_api_execute_only
    IS
        l_bad   SYS_REFCURSOR;
        l_count PLS_INTEGER;
    BEGIN
        OPEN l_bad FOR
            SELECT table_name, privilege
              FROM user_tab_privs_made
             WHERE grantee = 'JMEDS_API'
               AND NOT (privilege = 'EXECUTE' AND table_name LIKE 'JM\_%\_API' ESCAPE '\'
                        AND table_name NOT LIKE 'JM\_UT\_%' ESCAPE '\');
        ut.expect(l_bad).to_be_empty();
        SELECT COUNT(*) INTO l_count
          FROM user_tab_privs_made
         WHERE grantee = 'JMEDS_API' AND table_name = 'JM_CTX_API' AND privilege = 'EXECUTE';
        ut.expect(l_count, 'EXECUTE on JM_CTX_API').to_equal(1);
    END jmeds_api_execute_only;
END jm_ut_ctx_api;
/
--rollback DROP PACKAGE BODY jm_ut_ctx_api;
