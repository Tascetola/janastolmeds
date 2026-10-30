--liquibase formatted sql

--changeset adetola:test-010-fixture-spec endDelimiter:/ runOnChange:true stripComments:false context:dev,test
--comment: Test fixture: one valid, linked row in every table for the database QA suites (NFR-MNT-02). Test environments only.
CREATE OR REPLACE PACKAGE jm_ut_fixture AUTHID DEFINER
IS
    -- Builds the fixture inside the caller's transaction; utPLSQL rolls it back after each suite.
    PROCEDURE build;

    -- Key of the fixture row for a table (or a named extra such as 'LOCKED_VISIT', 'STAFF2', 'STAFF3').
    FUNCTION key (p_name IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION id  (p_name IN VARCHAR2) RETURN NUMBER;

    -- True when the fixture holds a row for the table.
    FUNCTION has_row (p_table IN VARCHAR2) RETURN BOOLEAN;
END jm_ut_fixture;
/
--rollback DROP PACKAGE jm_ut_fixture;

--changeset adetola:test-010-fixture-body endDelimiter:/ runOnChange:true stripComments:false context:dev,test
--comment: Test fixture body, including an HMO claim (NFR-MNT-02; DEF-009). Test environments only.
CREATE OR REPLACE PACKAGE BODY jm_ut_fixture
IS
    TYPE t_keys IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(30);
    g_keys t_keys;

    PROCEDURE put (p_name IN VARCHAR2, p_key IN VARCHAR2)
    IS
    BEGIN
        g_keys(p_name) := p_key;
    END put;

    FUNCTION key (p_name IN VARCHAR2) RETURN VARCHAR2
    IS
    BEGIN
        RETURN g_keys(p_name);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20900, 'jm_ut_fixture has no key ' || p_name || '; call build first');
    END key;

    FUNCTION id (p_name IN VARCHAR2) RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER(key(p_name));
    END id;

    FUNCTION has_row (p_table IN VARCHAR2) RETURN BOOLEAN
    IS
    BEGIN
        RETURN g_keys.EXISTS(p_table);
    END has_row;

    PROCEDURE build
    IS
        l_id        NUMBER;
        l_dept      NUMBER;
        l_s1        NUMBER;
        l_s2        NUMBER;
        l_s3        NUMBER;
        l_hmo       NUMBER;
        l_patient   NUMBER;
        l_drug      NUMBER;
        l_schedule  NUMBER;
        l_appt      NUMBER;
        l_visit     NUMBER;
        l_locked    NUMBER;
        l_batch     NUMBER;
        l_rx        NUMBER;
        l_test      NUMBER;
        l_order     NUMBER;
        l_service   NUMBER;
        l_invoice   NUMBER;
        l_icd10     jm_icd10_codes.icd10_code%TYPE;
    BEGIN
        g_keys.DELETE;

        INSERT INTO jm_departments (dept_code, dept_name) VALUES ('UT-DEPT', 'UT Department')
        RETURNING department_id INTO l_dept;
        put('JM_DEPARTMENTS', l_dept);

        INSERT INTO jm_staff (staff_no, username, first_name, last_name, department_id, specialty)
        VALUES ('UT-S1', 'UT_DOCTOR1', 'Ada', 'Testdoctor', l_dept, 'General Practice')
        RETURNING staff_id INTO l_s1;
        INSERT INTO jm_staff (staff_no, username, first_name, last_name, department_id)
        VALUES ('UT-S2', 'UT_LABSCI1', 'Bola', 'Testlab', l_dept)
        RETURNING staff_id INTO l_s2;
        INSERT INTO jm_staff (staff_no, username, first_name, last_name, department_id)
        VALUES ('UT-S3', 'UT_LABSCI2', 'Chidi', 'Testverifier', l_dept)
        RETURNING staff_id INTO l_s3;
        put('JM_STAFF', l_s1);
        put('STAFF2', l_s2);
        put('STAFF3', l_s3);

        SELECT role_id INTO l_id FROM jm_roles WHERE role_code = 'DOCTOR';
        put('JM_ROLES', l_id);
        INSERT INTO jm_staff_roles (staff_id, role_id) VALUES (l_s1, l_id)
        RETURNING staff_role_id INTO l_id;
        put('JM_STAFF_ROLES', l_id);

        SELECT lookup_id INTO l_id FROM jm_lookups WHERE lookup_type = 'GENDER' AND lookup_code = 'FEMALE';
        put('JM_LOOKUPS', l_id);

        SELECT MIN(icd10_code) INTO l_icd10 FROM jm_icd10_codes;
        put('JM_ICD10_CODES', l_icd10);

        INSERT INTO jm_hmo_plans (hmo_name, plan_name, coverage_pct) VALUES ('UT HMO', 'UT Gold', 80)
        RETURNING hmo_plan_id INTO l_hmo;
        put('JM_HMO_PLANS', l_hmo);

        INSERT INTO jm_patients (mrn, first_name, last_name, date_of_birth, gender, phone, hmo_plan_id, hmo_member_no)
        VALUES ('UT-2026-000001', 'Tola', 'Testpatient', DATE '1990-05-17', 'FEMALE', '08030000000', l_hmo, 'UT-MEM-1')
        RETURNING patient_id INTO l_patient;
        put('JM_PATIENTS', l_patient);

        INSERT INTO jm_patient_consents (patient_id, notice_version, consent_type, granted_flag, granted_at, captured_via)
        VALUES (l_patient, '1.0', 'PROCESSING', 'Y', SYSTIMESTAMP, 'DESK')
        RETURNING consent_id INTO l_id;
        put('JM_PATIENT_CONSENTS', l_id);

        INSERT INTO jm_drugs (drug_code, generic_name, strength, dosage_form, unit_of_issue, unit_price)
        VALUES ('UT-DRUG1', 'Testamol', '500 mg', 'TABLET', 'TAB', 50)
        RETURNING drug_id INTO l_drug;
        put('JM_DRUGS', l_drug);

        INSERT INTO jm_patient_allergies (patient_id, allergen, drug_id, severity)
        VALUES (l_patient, 'Testamol', l_drug, 'MILD')
        RETURNING allergy_id INTO l_id;
        put('JM_PATIENT_ALLERGIES', l_id);

        INSERT INTO jm_patient_accounts (patient_id, login_id, password_hash, password_salt)
        VALUES (l_patient, 'ut.patient@example.test', 'not-a-real-hash', 'not-a-real-salt')
        RETURNING account_id INTO l_id;
        put('JM_PATIENT_ACCOUNTS', l_id);

        INSERT INTO jm_doctor_schedules (staff_id, day_of_week, start_time, end_time, slot_minutes, max_patients, valid_from)
        VALUES (l_s1, 1, '09:00', '12:00', 15, 12, TRUNC(SYSDATE))
        RETURNING schedule_id INTO l_schedule;
        put('JM_DOCTOR_SCHEDULES', l_schedule);

        INSERT INTO jm_appointments (appointment_no, patient_id, staff_id, schedule_id, slot_start, slot_end)
        VALUES ('UT-APT-1', l_patient, l_s1, l_schedule,
                TRUNC(SYSDATE) + 1 + 9/24, TRUNC(SYSDATE) + 1 + 9/24 + 15/1440)
        RETURNING appointment_id INTO l_appt;
        put('JM_APPOINTMENTS', l_appt);

        INSERT INTO jm_visits (visit_no, patient_id, appointment_id, doctor_id, chief_complaint)
        VALUES ('UT-VIS-1', l_patient, l_appt, l_s1, 'Headache')
        RETURNING visit_id INTO l_visit;
        put('JM_VISITS', l_visit);

        INSERT INTO jm_visits (visit_no, patient_id, doctor_id, status, completed_at, locked_at)
        VALUES ('UT-VIS-2', l_patient, l_s1, 'LOCKED', SYSTIMESTAMP - INTERVAL '2' DAY, SYSTIMESTAMP)
        RETURNING visit_id INTO l_locked;
        put('LOCKED_VISIT', l_locked);

        INSERT INTO jm_vitals (visit_id, taken_by, temperature_c, systolic_bp, diastolic_bp, pulse_bpm,
                               resp_rate, spo2_pct, weight_kg, height_cm)
        VALUES (l_visit, l_s1, 37.0, 120, 80, 72, 16, 98, 70, 170)
        RETURNING vitals_id INTO l_id;
        put('JM_VITALS', l_id);

        INSERT INTO jm_visit_diagnoses (visit_id, icd10_code) VALUES (l_visit, l_icd10)
        RETURNING visit_diagnosis_id INTO l_id;
        put('JM_VISIT_DIAGNOSES', l_id);

        INSERT INTO jm_visit_addenda (visit_id, author_id, addendum_text)
        VALUES (l_locked, l_s1, 'UT addendum')
        RETURNING addendum_id INTO l_id;
        put('JM_VISIT_ADDENDA', l_id);

        INSERT INTO jm_drug_batches (drug_id, batch_no, expiry_date, qty_received, qty_on_hand, cost_price)
        VALUES (l_drug, 'UT-BATCH1', ADD_MONTHS(TRUNC(SYSDATE), 12), 100, 100, 30)
        RETURNING batch_id INTO l_batch;
        put('JM_DRUG_BATCHES', l_batch);

        INSERT INTO jm_prescriptions (visit_id, drug_id, prescribed_by, dose, frequency, duration_days, qty_prescribed)
        VALUES (l_visit, l_drug, l_s1, '1 tablet', 'TDS', 5, 15)
        RETURNING prescription_id INTO l_rx;
        put('JM_PRESCRIPTIONS', l_rx);

        INSERT INTO jm_dispenses (prescription_id, batch_id, qty, dispensed_by)
        VALUES (l_rx, l_batch, 5, l_s1)
        RETURNING dispense_id INTO l_id;
        put('JM_DISPENSES', l_id);

        INSERT INTO jm_lab_tests (test_code, test_name, sample_type, unit, ref_low, ref_high, price)
        VALUES ('UT-HB', 'UT Haemoglobin', 'BLOOD', 'g/dL', 12, 16, 1500)
        RETURNING lab_test_id INTO l_test;
        put('JM_LAB_TESTS', l_test);

        INSERT INTO jm_lab_orders (order_no, visit_id, lab_test_id, ordered_by)
        VALUES ('UT-LAB-1', l_visit, l_test, l_s1)
        RETURNING lab_order_id INTO l_order;
        put('JM_LAB_ORDERS', l_order);

        INSERT INTO jm_lab_results (lab_order_id, result_numeric, entered_by, verified_by, verified_at)
        VALUES (l_order, 13.5, l_s2, l_s3, SYSTIMESTAMP)
        RETURNING lab_result_id INTO l_id;
        put('JM_LAB_RESULTS', l_id);

        INSERT INTO jm_services (service_code, service_name, department_id, price)
        VALUES ('UT-CONS', 'UT Consultation', l_dept, 5000)
        RETURNING service_id INTO l_service;
        put('JM_SERVICES', l_service);

        INSERT INTO jm_invoices (invoice_no, visit_id, patient_id, hmo_plan_id, total_amount, hmo_amount,
                                 patient_amount, amount_paid, hmo_amount_paid, status)
        VALUES ('UT-INV-1', l_visit, l_patient, l_hmo, 5000, 4000, 1000, 500, 2000, 'PART_PAID')
        RETURNING invoice_id INTO l_invoice;
        put('JM_INVOICES', l_invoice);

        INSERT INTO jm_hmo_claims (claim_no, invoice_id, hmo_plan_id, claim_amount, approved_amount, paid_amount,
                                   status, submitted_at, decided_at, paid_at, remittance_ref)
        VALUES ('UT-CLM-1', l_invoice, l_hmo, 4000, 4000, 2000,
                'PART_PAID', SYSTIMESTAMP - INTERVAL '3' DAY, SYSTIMESTAMP - INTERVAL '2' DAY, SYSTIMESTAMP, 'UT-REMIT-1')
        RETURNING claim_id INTO l_id;
        put('JM_HMO_CLAIMS', l_id);

        INSERT INTO jm_invoice_lines (invoice_id, source_type, source_id, description, qty, unit_price, hmo_covered)
        VALUES (l_invoice, 'SERVICE', l_service, 'UT Consultation', 1, 5000, 'Y')
        RETURNING invoice_line_id INTO l_id;
        put('JM_INVOICE_LINES', l_id);

        INSERT INTO jm_payments (receipt_no, invoice_id, amount, pay_method, received_by)
        VALUES ('UT-RCP-1', l_invoice, 500, 'CASH', l_s1)
        RETURNING payment_id INTO l_id;
        put('JM_PAYMENTS', l_id);
    END build;
END jm_ut_fixture;
/
--rollback DROP PACKAGE BODY jm_ut_fixture;
