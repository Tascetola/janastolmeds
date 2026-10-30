--liquibase formatted sql

-- DEF-006 (decided 29 Oct 2026): patient, clinical and financial records are never physically deleted.
-- A "delete" sets RECORD_STATUS = 'DELETED' with a reason; the row stays in the database, the trigger records
-- who and when, the applications hide it, and a deleted record can no longer be changed or restored.
-- Physical DELETE is refused by every <TABLE>_RECORD_GUARD trigger. Addenda can never be changed at all.
-- Business keys that a corrected record must be able to reuse become unique indexes over ACTIVE rows only.

--changeset adetola:120-cols-patients
--comment: Soft-delete columns on JM_PATIENTS: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_patients ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_patients_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_patients_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_patients DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-patient_consents
--comment: Soft-delete columns on JM_PATIENT_CONSENTS: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_patient_consents ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_patient_consents_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_patient_consents_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_patient_consents DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-patient_allergies
--comment: Soft-delete columns on JM_PATIENT_ALLERGIES: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_patient_allergies ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_patient_allergies_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_patient_allergies_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_patient_allergies DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-patient_accounts
--comment: Soft-delete columns on JM_PATIENT_ACCOUNTS: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_patient_accounts ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_patient_accounts_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_patient_accounts_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_patient_accounts DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-doctor_schedules
--comment: Soft-delete columns on JM_DOCTOR_SCHEDULES: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_doctor_schedules ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_doctor_schedules_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_doctor_schedules_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_doctor_schedules DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-appointments
--comment: Soft-delete columns on JM_APPOINTMENTS: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_appointments ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_appointments_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_appointments_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_appointments DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-visits
--comment: Soft-delete columns on JM_VISITS: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_visits ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_visits_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_visits_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_visits DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-vitals
--comment: Soft-delete columns on JM_VITALS: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_vitals ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_vitals_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_vitals_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_vitals DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-visit_diagnoses
--comment: Soft-delete columns on JM_VISIT_DIAGNOSES: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_visit_diagnoses ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_visit_diagnoses_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_visit_diagnoses_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_visit_diagnoses DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-drug_batches
--comment: Soft-delete columns on JM_DRUG_BATCHES: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_drug_batches ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_drug_batches_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_drug_batches_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_drug_batches DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-prescriptions
--comment: Soft-delete columns on JM_PRESCRIPTIONS: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_prescriptions ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_prescriptions_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_prescriptions_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_prescriptions DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-dispenses
--comment: Soft-delete columns on JM_DISPENSES: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_dispenses ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_dispenses_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_dispenses_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_dispenses DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-lab_orders
--comment: Soft-delete columns on JM_LAB_ORDERS: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_lab_orders ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_lab_orders_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_lab_orders_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_lab_orders DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-lab_results
--comment: Soft-delete columns on JM_LAB_RESULTS: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_lab_results ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_lab_results_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_lab_results_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_lab_results DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-invoices
--comment: Soft-delete columns on JM_INVOICES: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_invoices ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_invoices_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_invoices_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_invoices DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-invoice_lines
--comment: Soft-delete columns on JM_INVOICE_LINES: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_invoice_lines ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_invoice_lines_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_invoice_lines_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_invoice_lines DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-cols-payments
--comment: Soft-delete columns on JM_PAYMENTS: RECORD_STATUS, DELETED_ON, DELETED_BY, DELETE_REASON (NFR-PRV-03; DEF-006)
ALTER TABLE jm_payments ADD (
    record_status        VARCHAR2(10 CHAR) DEFAULT 'ACTIVE' NOT NULL,
    deleted_on           TIMESTAMP WITH LOCAL TIME ZONE,
    deleted_by           VARCHAR2(100 CHAR),
    delete_reason        VARCHAR2(300 CHAR),
    CONSTRAINT jm_payments_record_status_ck CHECK (record_status IN ('ACTIVE', 'DELETED')),
    CONSTRAINT jm_payments_deleted_ck CHECK (
        (record_status = 'DELETED' AND deleted_on IS NOT NULL AND deleted_by IS NOT NULL AND delete_reason IS NOT NULL)
        OR (record_status <> 'DELETED' AND deleted_on IS NULL AND deleted_by IS NULL AND delete_reason IS NULL))
);
--rollback ALTER TABLE jm_payments DROP (record_status, deleted_on, deleted_by, delete_reason) CASCADE CONSTRAINTS;

--changeset adetola:120-guard-patients endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_PATIENTS: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_patients_record_guard
FOR UPDATE OR DELETE ON jm_patients
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_PATIENTS records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_PATIENTS record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_patients_record_guard;
/
--rollback DROP TRIGGER jm_patients_record_guard;

--changeset adetola:120-guard-patient_consents endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_PATIENT_CONSENTS: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_patient_consents_record_guard
FOR UPDATE OR DELETE ON jm_patient_consents
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_PATIENT_CONSENTS records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_PATIENT_CONSENTS record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_patient_consents_record_guard;
/
--rollback DROP TRIGGER jm_patient_consents_record_guard;

--changeset adetola:120-guard-patient_allergies endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_PATIENT_ALLERGIES: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_patient_allergies_record_guard
FOR UPDATE OR DELETE ON jm_patient_allergies
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_PATIENT_ALLERGIES records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_PATIENT_ALLERGIES record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_patient_allergies_record_guard;
/
--rollback DROP TRIGGER jm_patient_allergies_record_guard;

--changeset adetola:120-guard-patient_accounts endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_PATIENT_ACCOUNTS: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_patient_accounts_record_guard
FOR UPDATE OR DELETE ON jm_patient_accounts
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_PATIENT_ACCOUNTS records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_PATIENT_ACCOUNTS record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_patient_accounts_record_guard;
/
--rollback DROP TRIGGER jm_patient_accounts_record_guard;

--changeset adetola:120-guard-doctor_schedules endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_DOCTOR_SCHEDULES: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_doctor_schedules_record_guard
FOR UPDATE OR DELETE ON jm_doctor_schedules
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_DOCTOR_SCHEDULES records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_DOCTOR_SCHEDULES record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_doctor_schedules_record_guard;
/
--rollback DROP TRIGGER jm_doctor_schedules_record_guard;

--changeset adetola:120-guard-appointments endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_APPOINTMENTS: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_appointments_record_guard
FOR UPDATE OR DELETE ON jm_appointments
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_APPOINTMENTS records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_APPOINTMENTS record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_appointments_record_guard;
/
--rollback DROP TRIGGER jm_appointments_record_guard;

--changeset adetola:120-guard-visits endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_VISITS: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_visits_record_guard
FOR UPDATE OR DELETE ON jm_visits
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_VISITS records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_VISITS record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_visits_record_guard;
/
--rollback DROP TRIGGER jm_visits_record_guard;

--changeset adetola:120-guard-vitals endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_VITALS: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_vitals_record_guard
FOR UPDATE OR DELETE ON jm_vitals
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_VITALS records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_VITALS record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_vitals_record_guard;
/
--rollback DROP TRIGGER jm_vitals_record_guard;

--changeset adetola:120-guard-visit_diagnoses endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_VISIT_DIAGNOSES: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_visit_diagnoses_record_guard
FOR UPDATE OR DELETE ON jm_visit_diagnoses
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_VISIT_DIAGNOSES records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_VISIT_DIAGNOSES record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_visit_diagnoses_record_guard;
/
--rollback DROP TRIGGER jm_visit_diagnoses_record_guard;

--changeset adetola:120-guard-drug_batches endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_DRUG_BATCHES: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_drug_batches_record_guard
FOR UPDATE OR DELETE ON jm_drug_batches
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_DRUG_BATCHES records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_DRUG_BATCHES record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_drug_batches_record_guard;
/
--rollback DROP TRIGGER jm_drug_batches_record_guard;

--changeset adetola:120-guard-prescriptions endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_PRESCRIPTIONS: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_prescriptions_record_guard
FOR UPDATE OR DELETE ON jm_prescriptions
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_PRESCRIPTIONS records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_PRESCRIPTIONS record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_prescriptions_record_guard;
/
--rollback DROP TRIGGER jm_prescriptions_record_guard;

--changeset adetola:120-guard-dispenses endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_DISPENSES: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_dispenses_record_guard
FOR UPDATE OR DELETE ON jm_dispenses
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_DISPENSES records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_DISPENSES record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_dispenses_record_guard;
/
--rollback DROP TRIGGER jm_dispenses_record_guard;

--changeset adetola:120-guard-lab_orders endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_LAB_ORDERS: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_lab_orders_record_guard
FOR UPDATE OR DELETE ON jm_lab_orders
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_LAB_ORDERS records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_LAB_ORDERS record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_lab_orders_record_guard;
/
--rollback DROP TRIGGER jm_lab_orders_record_guard;

--changeset adetola:120-guard-lab_results endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_LAB_RESULTS: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_lab_results_record_guard
FOR UPDATE OR DELETE ON jm_lab_results
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_LAB_RESULTS records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_LAB_RESULTS record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_lab_results_record_guard;
/
--rollback DROP TRIGGER jm_lab_results_record_guard;

--changeset adetola:120-guard-invoices endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_INVOICES: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_invoices_record_guard
FOR UPDATE OR DELETE ON jm_invoices
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_INVOICES records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_INVOICES record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_invoices_record_guard;
/
--rollback DROP TRIGGER jm_invoices_record_guard;

--changeset adetola:120-guard-invoice_lines endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_INVOICE_LINES: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_invoice_lines_record_guard
FOR UPDATE OR DELETE ON jm_invoice_lines
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_INVOICE_LINES records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_INVOICE_LINES record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_invoice_lines_record_guard;
/
--rollback DROP TRIGGER jm_invoice_lines_record_guard;

--changeset adetola:120-guard-payments endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_PAYMENTS: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_payments_record_guard
FOR UPDATE OR DELETE ON jm_payments
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_PAYMENTS records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_PAYMENTS record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_payments_record_guard;
/
--rollback DROP TRIGGER jm_payments_record_guard;

--changeset adetola:120-guard-hmo_claims endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_HMO_CLAIMS: refuse physical DELETE, stamp soft deletes, freeze deleted records (NFR-PRV-03; DEF-006)
CREATE OR REPLACE TRIGGER jm_hmo_claims_record_guard
FOR UPDATE OR DELETE ON jm_hmo_claims
COMPOUND TRIGGER
    -- A statement trigger fires before every row trigger, so a DELETE always reports this error first.
    BEFORE STATEMENT IS
    BEGIN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20030, 'JM_HMO_CLAIMS records are never deleted. Set RECORD_STATUS = ''DELETED'' with a DELETE_REASON instead.');
        END IF;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF :old.record_status = 'DELETED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'This JM_HMO_CLAIMS record was deleted by ' || :old.deleted_by ||
                                            ' and cannot be changed or restored.');
        ELSIF :new.record_status = 'DELETED' THEN
            :new.deleted_on := SYSTIMESTAMP;
            :new.deleted_by := jm_current_user;
        END IF;
    END BEFORE EACH ROW;
END jm_hmo_claims_record_guard;
/
--rollback DROP TRIGGER jm_hmo_claims_record_guard;

--changeset adetola:120-addenda-no-change endDelimiter:/ runOnChange:true stripComments:false
--comment: JM_VISIT_ADDENDA is insert-only: an addendum is the record of a post-lock change and can never be edited or deleted (FR-CLN-04; DEF-006)
CREATE OR REPLACE TRIGGER jm_visit_addenda_no_change
BEFORE UPDATE OR DELETE ON jm_visit_addenda
BEGIN
    RAISE_APPLICATION_ERROR(-20013, 'Addenda cannot be changed or deleted. Add a further addendum instead.');
END;
/
--rollback DROP TRIGGER jm_visit_addenda_no_change;

--changeset adetola:120-uk-jm_patient_accounts_patient_uk
--comment: JM_PATIENT_ACCOUNTS_PATIENT_UK applies to ACTIVE rows only, so a corrected record can replace a deleted one (DEF-006)
ALTER TABLE jm_patient_accounts DROP CONSTRAINT jm_patient_accounts_patient_uk DROP INDEX;
CREATE UNIQUE INDEX jm_patient_accounts_patient_uk ON jm_patient_accounts (CASE WHEN record_status = 'ACTIVE' THEN patient_id END);
--rollback DROP INDEX jm_patient_accounts_patient_uk;
--rollback ALTER TABLE jm_patient_accounts ADD CONSTRAINT jm_patient_accounts_patient_uk UNIQUE (patient_id);

--changeset adetola:120-ix-patient_accounts-patient_id
--comment: Index foreign key jm_patient_accounts.patient_id, previously covered by JM_PATIENT_ACCOUNTS_PATIENT_UK (created after the constraint is dropped, dropped before it is restored)
CREATE INDEX jm_patient_accounts_patient_ix ON jm_patient_accounts (patient_id);
--rollback DROP INDEX jm_patient_accounts_patient_ix;

--changeset adetola:120-uk-jm_patient_accounts_login_uk
--comment: JM_PATIENT_ACCOUNTS_LOGIN_UK applies to ACTIVE rows only, so a corrected record can replace a deleted one (DEF-006)
ALTER TABLE jm_patient_accounts DROP CONSTRAINT jm_patient_accounts_login_uk DROP INDEX;
CREATE UNIQUE INDEX jm_patient_accounts_login_uk ON jm_patient_accounts (CASE WHEN record_status = 'ACTIVE' THEN login_id END);
--rollback DROP INDEX jm_patient_accounts_login_uk;
--rollback ALTER TABLE jm_patient_accounts ADD CONSTRAINT jm_patient_accounts_login_uk UNIQUE (login_id);

--changeset adetola:120-uk-jm_visits_appointment_uk
--comment: JM_VISITS_APPOINTMENT_UK applies to ACTIVE rows only, so a corrected record can replace a deleted one (DEF-006)
ALTER TABLE jm_visits DROP CONSTRAINT jm_visits_appointment_uk DROP INDEX;
CREATE UNIQUE INDEX jm_visits_appointment_uk ON jm_visits (CASE WHEN record_status = 'ACTIVE' THEN appointment_id END);
--rollback DROP INDEX jm_visits_appointment_uk;
--rollback ALTER TABLE jm_visits ADD CONSTRAINT jm_visits_appointment_uk UNIQUE (appointment_id);

--changeset adetola:120-ix-visits-appointment_id
--comment: Index foreign key jm_visits.appointment_id, previously covered by JM_VISITS_APPOINTMENT_UK (created after the constraint is dropped, dropped before it is restored)
CREATE INDEX jm_visits_appointment_ix ON jm_visits (appointment_id);
--rollback DROP INDEX jm_visits_appointment_ix;

--changeset adetola:120-uk-jm_visit_diagnoses_uk
--comment: JM_VISIT_DIAGNOSES_UK applies to ACTIVE rows only, so a corrected record can replace a deleted one (DEF-006)
ALTER TABLE jm_visit_diagnoses DROP CONSTRAINT jm_visit_diagnoses_uk DROP INDEX;
CREATE UNIQUE INDEX jm_visit_diagnoses_uk ON jm_visit_diagnoses (CASE WHEN record_status = 'ACTIVE' THEN visit_id END, CASE WHEN record_status = 'ACTIVE' THEN icd10_code END);
--rollback DROP INDEX jm_visit_diagnoses_uk;
--rollback ALTER TABLE jm_visit_diagnoses ADD CONSTRAINT jm_visit_diagnoses_uk UNIQUE (visit_id, icd10_code);

--changeset adetola:120-ix-visit_diagnoses-visit_id
--comment: Index foreign key jm_visit_diagnoses.visit_id, previously covered by JM_VISIT_DIAGNOSES_UK
CREATE INDEX jm_visit_diagnoses_visit_ix ON jm_visit_diagnoses (visit_id);
--rollback DROP INDEX jm_visit_diagnoses_visit_ix;

--changeset adetola:120-uk-jm_drug_batches_uk
--comment: JM_DRUG_BATCHES_UK applies to ACTIVE rows only, so a corrected record can replace a deleted one (DEF-006)
ALTER TABLE jm_drug_batches DROP CONSTRAINT jm_drug_batches_uk DROP INDEX;
CREATE UNIQUE INDEX jm_drug_batches_uk ON jm_drug_batches (CASE WHEN record_status = 'ACTIVE' THEN drug_id END, CASE WHEN record_status = 'ACTIVE' THEN batch_no END);
--rollback DROP INDEX jm_drug_batches_uk;
--rollback ALTER TABLE jm_drug_batches ADD CONSTRAINT jm_drug_batches_uk UNIQUE (drug_id, batch_no);

--changeset adetola:120-uk-jm_lab_results_order_uk
--comment: JM_LAB_RESULTS_ORDER_UK applies to ACTIVE rows only, so a corrected record can replace a deleted one (DEF-006)
ALTER TABLE jm_lab_results DROP CONSTRAINT jm_lab_results_order_uk DROP INDEX;
CREATE UNIQUE INDEX jm_lab_results_order_uk ON jm_lab_results (CASE WHEN record_status = 'ACTIVE' THEN lab_order_id END);
--rollback DROP INDEX jm_lab_results_order_uk;
--rollback ALTER TABLE jm_lab_results ADD CONSTRAINT jm_lab_results_order_uk UNIQUE (lab_order_id);

--changeset adetola:120-ix-lab_results-lab_order_id
--comment: Index foreign key jm_lab_results.lab_order_id, previously covered by JM_LAB_RESULTS_ORDER_UK (created after the constraint is dropped, dropped before it is restored)
CREATE INDEX jm_lab_results_order_ix ON jm_lab_results (lab_order_id);
--rollback DROP INDEX jm_lab_results_order_ix;

--changeset adetola:120-uk-jm_invoice_lines_source_uk
--comment: JM_INVOICE_LINES_SOURCE_UK applies to ACTIVE rows only, so a corrected record can replace a deleted one (DEF-006)
ALTER TABLE jm_invoice_lines DROP CONSTRAINT jm_invoice_lines_source_uk DROP INDEX;
CREATE UNIQUE INDEX jm_invoice_lines_source_uk ON jm_invoice_lines (CASE WHEN record_status = 'ACTIVE' THEN source_type END, CASE WHEN record_status = 'ACTIVE' THEN source_id END);
--rollback DROP INDEX jm_invoice_lines_source_uk;
--rollback ALTER TABLE jm_invoice_lines ADD CONSTRAINT jm_invoice_lines_source_uk UNIQUE (source_type, source_id);

--changeset adetola:120-uk-jm_invoices_visit_uk
--comment: One live invoice per visit; a voided or deleted invoice can be replaced (FR-BIL-01; DEF-006)
ALTER TABLE jm_invoices DROP CONSTRAINT jm_invoices_visit_uk DROP INDEX;
CREATE UNIQUE INDEX jm_invoices_visit_uk ON jm_invoices (CASE WHEN record_status = 'ACTIVE' AND status <> 'VOID' THEN visit_id END);
--rollback DROP INDEX jm_invoices_visit_uk;
--rollback ALTER TABLE jm_invoices ADD CONSTRAINT jm_invoices_visit_uk UNIQUE (visit_id);

--changeset adetola:120-ix-invoices-visit_id
--comment: Index foreign key jm_invoices.visit_id, previously covered by JM_INVOICES_VISIT_UK (created after the constraint is dropped, dropped before it is restored)
CREATE INDEX jm_invoices_visit_ix ON jm_invoices (visit_id);
--rollback DROP INDEX jm_invoices_visit_ix;

--changeset adetola:120-uk-jm_appointments_slot_uk
--comment: A doctor's slot is free again when its appointment is cancelled, a no-show or deleted (FR-APT-02; DEF-006)
DROP INDEX jm_appointments_slot_uk;
CREATE UNIQUE INDEX jm_appointments_slot_uk ON jm_appointments (
    CASE WHEN status NOT IN ('CANCELLED','NO_SHOW') AND record_status = 'ACTIVE' THEN staff_id END,
    CASE WHEN status NOT IN ('CANCELLED','NO_SHOW') AND record_status = 'ACTIVE' THEN slot_start END
);
--rollback DROP INDEX jm_appointments_slot_uk;
--rollback CREATE UNIQUE INDEX jm_appointments_slot_uk ON jm_appointments (CASE WHEN status NOT IN ('CANCELLED','NO_SHOW') THEN staff_id END, CASE WHEN status NOT IN ('CANCELLED','NO_SHOW') THEN slot_start END);
