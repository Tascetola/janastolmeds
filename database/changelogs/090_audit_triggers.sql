--liquibase formatted sql

--changeset adetola:090-01 endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_CURRENT_USER: who is acting, for audit columns (APEX user, API context, or DB user)
CREATE OR REPLACE FUNCTION jm_current_user RETURN VARCHAR2
IS
BEGIN
    RETURN SUBSTR(COALESCE(
               SYS_CONTEXT('APEX$SESSION', 'APP_USER'),
               SYS_CONTEXT('JM_CTX', 'ACTOR'),
               SYS_CONTEXT('USERENV', 'SESSION_USER')), 1, 100);
END jm_current_user;
/
--rollback DROP FUNCTION jm_current_user;

--changeset adetola:090-trg-departments endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_DEPARTMENTS
CREATE OR REPLACE TRIGGER jm_departments_biu
BEFORE INSERT OR UPDATE ON jm_departments
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_departments_biu;

--changeset adetola:090-trg-staff endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_STAFF
CREATE OR REPLACE TRIGGER jm_staff_biu
BEFORE INSERT OR UPDATE ON jm_staff
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_staff_biu;

--changeset adetola:090-trg-roles endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_ROLES
CREATE OR REPLACE TRIGGER jm_roles_biu
BEFORE INSERT OR UPDATE ON jm_roles
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_roles_biu;

--changeset adetola:090-trg-staff_roles endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_STAFF_ROLES
CREATE OR REPLACE TRIGGER jm_staff_roles_biu
BEFORE INSERT OR UPDATE ON jm_staff_roles
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_staff_roles_biu;

--changeset adetola:090-trg-lookups endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_LOOKUPS
CREATE OR REPLACE TRIGGER jm_lookups_biu
BEFORE INSERT OR UPDATE ON jm_lookups
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_lookups_biu;

--changeset adetola:090-trg-hmo_plans endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_HMO_PLANS
CREATE OR REPLACE TRIGGER jm_hmo_plans_biu
BEFORE INSERT OR UPDATE ON jm_hmo_plans
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_hmo_plans_biu;

--changeset adetola:090-trg-patients endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_PATIENTS
CREATE OR REPLACE TRIGGER jm_patients_biu
BEFORE INSERT OR UPDATE ON jm_patients
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_patients_biu;

--changeset adetola:090-trg-patient_consents endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_PATIENT_CONSENTS
CREATE OR REPLACE TRIGGER jm_patient_consents_biu
BEFORE INSERT OR UPDATE ON jm_patient_consents
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_patient_consents_biu;

--changeset adetola:090-trg-patient_allergies endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_PATIENT_ALLERGIES
CREATE OR REPLACE TRIGGER jm_patient_allergies_biu
BEFORE INSERT OR UPDATE ON jm_patient_allergies
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_patient_allergies_biu;

--changeset adetola:090-trg-patient_accounts endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_PATIENT_ACCOUNTS
CREATE OR REPLACE TRIGGER jm_patient_accounts_biu
BEFORE INSERT OR UPDATE ON jm_patient_accounts
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_patient_accounts_biu;

--changeset adetola:090-trg-doctor_schedules endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_DOCTOR_SCHEDULES
CREATE OR REPLACE TRIGGER jm_doctor_schedules_biu
BEFORE INSERT OR UPDATE ON jm_doctor_schedules
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_doctor_schedules_biu;

--changeset adetola:090-trg-appointments endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_APPOINTMENTS
CREATE OR REPLACE TRIGGER jm_appointments_biu
BEFORE INSERT OR UPDATE ON jm_appointments
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_appointments_biu;

--changeset adetola:090-trg-icd10_codes endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_ICD10_CODES
CREATE OR REPLACE TRIGGER jm_icd10_codes_biu
BEFORE INSERT OR UPDATE ON jm_icd10_codes
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_icd10_codes_biu;

--changeset adetola:090-trg-visits endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_VISITS
CREATE OR REPLACE TRIGGER jm_visits_biu
BEFORE INSERT OR UPDATE ON jm_visits
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_visits_biu;

--changeset adetola:090-trg-vitals endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_VITALS
CREATE OR REPLACE TRIGGER jm_vitals_biu
BEFORE INSERT OR UPDATE ON jm_vitals
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_vitals_biu;

--changeset adetola:090-trg-visit_diagnoses endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_VISIT_DIAGNOSES
CREATE OR REPLACE TRIGGER jm_visit_diagnoses_biu
BEFORE INSERT OR UPDATE ON jm_visit_diagnoses
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_visit_diagnoses_biu;

--changeset adetola:090-trg-visit_addenda endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_VISIT_ADDENDA
CREATE OR REPLACE TRIGGER jm_visit_addenda_biu
BEFORE INSERT OR UPDATE ON jm_visit_addenda
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_visit_addenda_biu;

--changeset adetola:090-trg-drugs endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_DRUGS
CREATE OR REPLACE TRIGGER jm_drugs_biu
BEFORE INSERT OR UPDATE ON jm_drugs
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_drugs_biu;

--changeset adetola:090-trg-drug_batches endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_DRUG_BATCHES
CREATE OR REPLACE TRIGGER jm_drug_batches_biu
BEFORE INSERT OR UPDATE ON jm_drug_batches
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_drug_batches_biu;

--changeset adetola:090-trg-prescriptions endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_PRESCRIPTIONS
CREATE OR REPLACE TRIGGER jm_prescriptions_biu
BEFORE INSERT OR UPDATE ON jm_prescriptions
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_prescriptions_biu;

--changeset adetola:090-trg-dispenses endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_DISPENSES
CREATE OR REPLACE TRIGGER jm_dispenses_biu
BEFORE INSERT OR UPDATE ON jm_dispenses
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_dispenses_biu;

--changeset adetola:090-trg-lab_tests endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_LAB_TESTS
CREATE OR REPLACE TRIGGER jm_lab_tests_biu
BEFORE INSERT OR UPDATE ON jm_lab_tests
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_lab_tests_biu;

--changeset adetola:090-trg-lab_orders endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_LAB_ORDERS
CREATE OR REPLACE TRIGGER jm_lab_orders_biu
BEFORE INSERT OR UPDATE ON jm_lab_orders
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_lab_orders_biu;

--changeset adetola:090-trg-lab_results endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_LAB_RESULTS
CREATE OR REPLACE TRIGGER jm_lab_results_biu
BEFORE INSERT OR UPDATE ON jm_lab_results
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_lab_results_biu;

--changeset adetola:090-trg-services endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_SERVICES
CREATE OR REPLACE TRIGGER jm_services_biu
BEFORE INSERT OR UPDATE ON jm_services
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_services_biu;

--changeset adetola:090-trg-invoices endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_INVOICES
CREATE OR REPLACE TRIGGER jm_invoices_biu
BEFORE INSERT OR UPDATE ON jm_invoices
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_invoices_biu;

--changeset adetola:090-trg-invoice_lines endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_INVOICE_LINES
CREATE OR REPLACE TRIGGER jm_invoice_lines_biu
BEFORE INSERT OR UPDATE ON jm_invoice_lines
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_invoice_lines_biu;

--changeset adetola:090-trg-payments endDelimiter:/ runOnChange:true stripComments:false
--comment: Standard audit columns and optimistic-lock version for JM_PAYMENTS
CREATE OR REPLACE TRIGGER jm_payments_biu
BEFORE INSERT OR UPDATE ON jm_payments
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.created_by  := NVL(:new.created_by, jm_current_user);
        :new.created_on  := NVL(:new.created_on, SYSTIMESTAMP);
        :new.row_version := 1;
    ELSE
        :new.created_by  := :old.created_by;
        :new.created_on  := :old.created_on;
        :new.updated_by  := jm_current_user;
        :new.updated_on  := SYSTIMESTAMP;
        :new.row_version := :old.row_version + 1;
    END IF;
END;
/
--rollback DROP TRIGGER jm_payments_biu;

--changeset adetola:090-lock-visits endDelimiter:/ runOnChange:true stripComments:false
--comment: Locked visits cannot be changed; corrections go to JM_VISIT_ADDENDA (FR-CLN-04)
CREATE OR REPLACE TRIGGER jm_visits_lock_guard
BEFORE UPDATE OR DELETE ON jm_visits
FOR EACH ROW
BEGIN
    IF :old.status = 'LOCKED' THEN
        RAISE_APPLICATION_ERROR(-20010, 'Visit ' || :old.visit_no || ' is locked. Add an addendum instead.');
    END IF;
END;
/
--rollback DROP TRIGGER jm_visits_lock_guard;

--changeset adetola:090-lock-vitals endDelimiter:/ runOnChange:true stripComments:false
--comment: Block changes to JM_VITALS when the old or new parent visit is locked; an unknown visit is left to the FK (FR-CLN-04; DEF-003)
CREATE OR REPLACE TRIGGER jm_vitals_lock_guard
BEFORE INSERT OR UPDATE OR DELETE ON jm_vitals
FOR EACH ROW
BEGIN
    FOR r IN (SELECT visit_no
                FROM jm_visits
               WHERE status = 'LOCKED'
                 AND visit_id IN (:old.visit_id, :new.visit_id)) LOOP
        RAISE_APPLICATION_ERROR(-20011, 'Visit ' || r.visit_no || ' is locked. Add an addendum instead.');
    END LOOP;
END;
/
--rollback DROP TRIGGER jm_vitals_lock_guard;

--changeset adetola:090-lock-visit_diagnoses endDelimiter:/ runOnChange:true stripComments:false
--comment: Block changes to JM_VISIT_DIAGNOSES when the old or new parent visit is locked; an unknown visit is left to the FK (FR-CLN-04; DEF-003)
CREATE OR REPLACE TRIGGER jm_visit_diagnoses_lock_guard
BEFORE INSERT OR UPDATE OR DELETE ON jm_visit_diagnoses
FOR EACH ROW
BEGIN
    FOR r IN (SELECT visit_no
                FROM jm_visits
               WHERE status = 'LOCKED'
                 AND visit_id IN (:old.visit_id, :new.visit_id)) LOOP
        RAISE_APPLICATION_ERROR(-20011, 'Visit ' || r.visit_no || ' is locked. Add an addendum instead.');
    END LOOP;
END;
/
--rollback DROP TRIGGER jm_visit_diagnoses_lock_guard;

--changeset adetola:090-addenda-locked-only endDelimiter:/ runOnChange:true stripComments:false
--comment: Addenda are allowed only on locked visits; an unknown visit is left to the FK (FR-CLN-04; DEF-003)
CREATE OR REPLACE TRIGGER jm_visit_addenda_guard
BEFORE INSERT ON jm_visit_addenda
FOR EACH ROW
DECLARE
    l_status jm_visits.status%TYPE;
BEGIN
    SELECT status INTO l_status FROM jm_visits WHERE visit_id = :new.visit_id;
    IF l_status <> 'LOCKED' THEN
        RAISE_APPLICATION_ERROR(-20012, 'Addenda are only for locked visits; edit the visit directly.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;  -- unknown visit: JM_VISIT_ADDENDA_VISIT_FK reports it
END;
/
--rollback DROP TRIGGER jm_visit_addenda_guard;

--changeset adetola:090-audit-log-guard endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_AUDIT_LOG is append-only, even for the schema owner (NFR-PRV-03)
CREATE OR REPLACE TRIGGER jm_audit_log_no_change
BEFORE UPDATE OR DELETE ON jm_audit_log
BEGIN
    RAISE_APPLICATION_ERROR(-20020, 'JM_AUDIT_LOG is append-only. Purges run only through the documented DBA retention job.');
END;
/
--rollback DROP TRIGGER jm_audit_log_no_change;
