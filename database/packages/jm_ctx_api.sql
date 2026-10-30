--liquibase formatted sql

--changeset adetola:pkg-jm_ctx_api-spec endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_CTX_API specification: sets and reads the JM_CTX application context, the identity behind every API call (NFR-SEC-01, NFR-SEC-02)
CREATE OR REPLACE PACKAGE jm_ctx_api AUTHID DEFINER
IS
    -- The only code that can write JM_CTX (CREATE CONTEXT jm_ctx USING jmeds.jm_ctx_api).
    --
    -- Database sessions are pooled by APEX and ORDS, so the context must be set at the start of every request
    -- and cleared at the end; every set_* clears first, so nothing leaks from the previous request.
    --   APEX  Security > Initialization PL/SQL Code:
    --             jm_ctx_api.set_staff(:APP_USER, 'APEX', owa_util.get_cgi_env('REMOTE_ADDR'));
    --         Security > Cleanup PL/SQL Code:  jm_ctx_api.clear;
    --   ORDS  each handler, after OAuth2 has mapped the token to a patient account:
    --             jm_ctx_api.set_patient(<account_id>, 'ORDS', :client_ip);  ...  jm_ctx_api.clear;
    --   Jobs and synthetic-data loads (JMEDS sessions only):  jm_ctx_api.set_system('<JOB_NAME>');
    --
    -- Context attributes: ACTOR, ACTOR_TYPE (STAFF/PATIENT/SYSTEM), STAFF_ID, PATIENT_ID, ACCOUNT_ID,
    -- PATIENT_STATUS, ROLES (':DOCTOR:NURSE:'), CLIENT (APEX/ORDS/JOB), IP_ADDRESS.
    -- ACTOR is what JM_CURRENT_USER returns, so it fills CREATED_BY/UPDATED_BY/DELETED_BY and JM_AUDIT_LOG.ACTOR:
    -- the staff username, 'PATIENT:<account_id>' (never the login ID, which is personal data), or the job name.

    c_staff   CONSTANT VARCHAR2(10) := 'STAFF';
    c_patient CONSTANT VARCHAR2(10) := 'PATIENT';
    c_system  CONSTANT VARCHAR2(10) := 'SYSTEM';

    -- ORA-20100: no identified actor (context not set, or unknown, inactive, locked or role-less account)
    e_not_identified EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_not_identified, -20100);
    -- ORA-20101: the actor is identified but not allowed to do this
    e_not_authorised EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_not_authorised, -20101);
    -- ORA-20102: invalid argument (client or job name)
    e_invalid_argument EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_invalid_argument, -20102);

    -- A signed-in staff member (APEX, or ORDS for staff integrations). The staff record must be active and hold
    -- at least one role. Inside APEX the username must be the signed-in APEX user.
    PROCEDURE set_staff (
        p_username   IN VARCHAR2,
        p_client     IN VARCHAR2 DEFAULT 'APEX',
        p_ip_address IN VARCHAR2 DEFAULT NULL);

    -- A patient signed in to the mobile app. The account must be unlocked and its patient record neither
    -- deleted nor anonymised. PENDING (unverified, FR-PAT-04) patients are identified; APIs decide what they may do.
    PROCEDURE set_patient (
        p_account_id IN NUMBER,
        p_client     IN VARCHAR2 DEFAULT 'ORDS',
        p_ip_address IN VARCHAR2 DEFAULT NULL);

    -- A scheduler job or deployment load acting for the hospital. Only for sessions logged in as the schema owner,
    -- so the APEX/ORDS connection cannot claim it.
    PROCEDURE set_system (p_job_name IN VARCHAR2);

    PROCEDURE clear;

    FUNCTION actor          RETURN VARCHAR2;
    FUNCTION actor_type     RETURN VARCHAR2;
    FUNCTION staff_id       RETURN NUMBER;
    FUNCTION patient_id     RETURN NUMBER;
    FUNCTION account_id     RETURN NUMBER;
    FUNCTION patient_status RETURN VARCHAR2;
    FUNCTION client         RETURN VARCHAR2;
    FUNCTION ip_address     RETURN VARCHAR2;

    -- True when the staff actor holds the role.
    FUNCTION has_role (p_role_code IN VARCHAR2) RETURN BOOLEAN;

    -- Raises ORA-20101 unless the actor is a system job or a staff member holding any of the comma-separated roles,
    -- e.g. require_role('DOCTOR,NURSE'). Raises ORA-20100 when no actor is identified.
    PROCEDURE require_role (p_role_codes IN VARCHAR2);

    -- Row-level guard for patient data (NFR-SEC-02): a patient actor may reach only their own record.
    -- Staff and system actors pass; each API checks their roles with require_role.
    PROCEDURE require_patient_access (p_patient_id IN NUMBER);
END jm_ctx_api;
/
--rollback DROP PACKAGE jm_ctx_api;

--changeset adetola:pkg-jm_ctx_api-body endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_CTX_API body (NFR-SEC-01, NFR-SEC-02)
CREATE OR REPLACE PACKAGE BODY jm_ctx_api
IS
    c_namespace CONSTANT VARCHAR2(30) := 'JM_CTX';

    PROCEDURE put (p_attribute IN VARCHAR2, p_value IN VARCHAR2)
    IS
    BEGIN
        DBMS_SESSION.set_context(c_namespace, p_attribute, p_value);
    END put;

    FUNCTION get (p_attribute IN VARCHAR2) RETURN VARCHAR2
    IS
    BEGIN
        RETURN SYS_CONTEXT(c_namespace, p_attribute);
    END get;

    PROCEDURE check_client (p_client IN VARCHAR2, p_allowed IN VARCHAR2)
    IS
    BEGIN
        IF p_client IS NULL OR INSTR(',' || p_allowed || ',', ',' || p_client || ',') = 0 THEN
            RAISE_APPLICATION_ERROR(-20102, 'Client must be one of ' || p_allowed || '.');
        END IF;
    END check_client;

    PROCEDURE clear
    IS
    BEGIN
        DBMS_SESSION.clear_all_context(c_namespace);
    END clear;

    PROCEDURE set_staff (
        p_username   IN VARCHAR2,
        p_client     IN VARCHAR2 DEFAULT 'APEX',
        p_ip_address IN VARCHAR2 DEFAULT NULL)
    IS
        l_username jm_staff.username%TYPE := UPPER(TRIM(p_username));
        l_staff_id jm_staff.staff_id%TYPE;
        l_roles    VARCHAR2(4000);
        l_apex     VARCHAR2(255) := SYS_CONTEXT('APEX$SESSION', 'APP_USER');
    BEGIN
        clear;
        check_client(p_client, 'APEX,ORDS');
        IF l_apex IS NOT NULL AND UPPER(l_apex) <> l_username THEN
            RAISE_APPLICATION_ERROR(-20101, 'Staff identity must be the signed-in APEX user.');
        END IF;

        BEGIN
            SELECT s.staff_id INTO l_staff_id
              FROM jm_staff s
             WHERE s.username = l_username AND s.active_flag = 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20100, 'No active staff account for this user.');
        END;

        SELECT ':' || LISTAGG(r.role_code, ':') WITHIN GROUP (ORDER BY r.role_code) || ':'
          INTO l_roles
          FROM jm_staff_roles sr
          JOIN jm_roles r ON r.role_id = sr.role_id
         WHERE sr.staff_id = l_staff_id;
        IF l_roles = '::' THEN
            RAISE_APPLICATION_ERROR(-20100, 'This staff account has no roles.');
        END IF;

        put('ACTOR', l_username);
        put('ACTOR_TYPE', c_staff);
        put('STAFF_ID', l_staff_id);
        put('ROLES', l_roles);
        put('CLIENT', p_client);
        put('IP_ADDRESS', SUBSTR(p_ip_address, 1, 45));
    END set_staff;

    PROCEDURE set_patient (
        p_account_id IN NUMBER,
        p_client     IN VARCHAR2 DEFAULT 'ORDS',
        p_ip_address IN VARCHAR2 DEFAULT NULL)
    IS
        l_patient_id jm_patients.patient_id%TYPE;
        l_status     jm_patients.status%TYPE;
    BEGIN
        clear;
        check_client(p_client, 'ORDS,APEX');
        BEGIN
            SELECT p.patient_id, p.status
              INTO l_patient_id, l_status
              FROM jm_patient_accounts a
              JOIN jm_patients p ON p.patient_id = a.patient_id
             WHERE a.account_id = p_account_id
               AND a.locked_flag = 'N'
               AND a.record_status = 'ACTIVE'
               AND p.record_status = 'ACTIVE'
               AND p.status IN ('PENDING', 'ACTIVE');
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20100, 'No usable patient account.');
        END;

        put('ACTOR', 'PATIENT:' || p_account_id);
        put('ACTOR_TYPE', c_patient);
        put('PATIENT_ID', l_patient_id);
        put('ACCOUNT_ID', p_account_id);
        put('PATIENT_STATUS', l_status);
        put('CLIENT', p_client);
        put('IP_ADDRESS', SUBSTR(p_ip_address, 1, 45));
    END set_patient;

    PROCEDURE set_system (p_job_name IN VARCHAR2)
    IS
    BEGIN
        clear;
        IF SYS_CONTEXT('USERENV', 'SESSION_USER') <> $$PLSQL_UNIT_OWNER THEN
            RAISE_APPLICATION_ERROR(-20101, 'A system identity is only available to ' || $$PLSQL_UNIT_OWNER || ' sessions.');
        END IF;
        IF p_job_name IS NULL OR NOT REGEXP_LIKE(p_job_name, '^[A-Z][A-Z0-9_]{0,99}$') THEN
            RAISE_APPLICATION_ERROR(-20102, 'Job name must be upper case letters, digits and underscores.');
        END IF;

        put('ACTOR', p_job_name);
        put('ACTOR_TYPE', c_system);
        put('CLIENT', 'JOB');
    END set_system;

    FUNCTION actor          RETURN VARCHAR2 IS BEGIN RETURN get('ACTOR'); END actor;
    FUNCTION actor_type     RETURN VARCHAR2 IS BEGIN RETURN get('ACTOR_TYPE'); END actor_type;
    FUNCTION staff_id       RETURN NUMBER   IS BEGIN RETURN TO_NUMBER(get('STAFF_ID')); END staff_id;
    FUNCTION patient_id     RETURN NUMBER   IS BEGIN RETURN TO_NUMBER(get('PATIENT_ID')); END patient_id;
    FUNCTION account_id     RETURN NUMBER   IS BEGIN RETURN TO_NUMBER(get('ACCOUNT_ID')); END account_id;
    FUNCTION patient_status RETURN VARCHAR2 IS BEGIN RETURN get('PATIENT_STATUS'); END patient_status;
    FUNCTION client         RETURN VARCHAR2 IS BEGIN RETURN get('CLIENT'); END client;
    FUNCTION ip_address     RETURN VARCHAR2 IS BEGIN RETURN get('IP_ADDRESS'); END ip_address;

    FUNCTION has_role (p_role_code IN VARCHAR2) RETURN BOOLEAN
    IS
    BEGIN
        RETURN get('ACTOR_TYPE') = c_staff
           AND INSTR(get('ROLES'), ':' || UPPER(TRIM(p_role_code)) || ':') > 0;
    END has_role;

    PROCEDURE require_actor
    IS
    BEGIN
        IF get('ACTOR_TYPE') IS NULL THEN
            RAISE_APPLICATION_ERROR(-20100, 'Not signed in.');
        END IF;
    END require_actor;

    PROCEDURE require_role (p_role_codes IN VARCHAR2)
    IS
    BEGIN
        require_actor;
        IF get('ACTOR_TYPE') = c_system THEN
            RETURN;
        END IF;
        FOR r IN (SELECT TRIM(REGEXP_SUBSTR(p_role_codes, '[^,]+', 1, LEVEL)) AS role_code
                    FROM dual
                 CONNECT BY REGEXP_SUBSTR(p_role_codes, '[^,]+', 1, LEVEL) IS NOT NULL) LOOP
            IF has_role(r.role_code) THEN
                RETURN;
            END IF;
        END LOOP;
        RAISE_APPLICATION_ERROR(-20101, 'Not authorised: needs role ' || REPLACE(p_role_codes, ',', ' or ') || '.');
    END require_role;

    PROCEDURE require_patient_access (p_patient_id IN NUMBER)
    IS
    BEGIN
        require_actor;
        IF get('ACTOR_TYPE') = c_patient AND (p_patient_id IS NULL OR p_patient_id <> patient_id) THEN
            RAISE_APPLICATION_ERROR(-20101, 'Not authorised: this is not your record.');
        END IF;
    END require_patient_access;
END jm_ctx_api;
/
--rollback DROP PACKAGE BODY jm_ctx_api;

--changeset adetola:grant-jm_ctx_api
--comment: APEX and ORDS (parsing schema JMEDS_API) set the context through JM_CTX_API; no table grants (NFR-SEC-02, NFR-MNT-01)
GRANT EXECUTE ON jm_ctx_api TO jmeds_api;
--rollback REVOKE EXECUTE ON jm_ctx_api FROM jmeds_api;
