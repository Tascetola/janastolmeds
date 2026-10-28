--liquibase formatted sql

--changeset adetola:080-jm_mrn_seq
--comment: Sequence for patient MRN; formatted in the API as JM-YYYY-NNNNNN
CREATE SEQUENCE jm_mrn_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
--rollback DROP SEQUENCE jm_mrn_seq;

--changeset adetola:080-jm_appointment_seq
--comment: Sequence for appointment numbers; formatted in the API as JM-YYYY-NNNNNN
CREATE SEQUENCE jm_appointment_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
--rollback DROP SEQUENCE jm_appointment_seq;

--changeset adetola:080-jm_visit_seq
--comment: Sequence for visit numbers; formatted in the API as JM-YYYY-NNNNNN
CREATE SEQUENCE jm_visit_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
--rollback DROP SEQUENCE jm_visit_seq;

--changeset adetola:080-jm_lab_order_seq
--comment: Sequence for lab order numbers; formatted in the API as JM-YYYY-NNNNNN
CREATE SEQUENCE jm_lab_order_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
--rollback DROP SEQUENCE jm_lab_order_seq;

--changeset adetola:080-jm_invoice_seq
--comment: Sequence for invoice numbers; formatted in the API as JM-YYYY-NNNNNN
CREATE SEQUENCE jm_invoice_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
--rollback DROP SEQUENCE jm_invoice_seq;

--changeset adetola:080-jm_receipt_seq
--comment: Sequence for receipt numbers; formatted in the API as JM-YYYY-NNNNNN
CREATE SEQUENCE jm_receipt_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
--rollback DROP SEQUENCE jm_receipt_seq;

-- Foreign-key indexes. FKs already leading a unique key are covered and not repeated:
-- jm_staff_roles.staff_id, jm_patient_accounts.patient_id, jm_visits.appointment_id, jm_visit_diagnoses.visit_id,
-- jm_drug_batches.drug_id, jm_lab_results.lab_order_id, jm_invoices.visit_id.

--changeset adetola:080-ix-staff-department_id
--comment: Index foreign key jm_staff.department_id
CREATE INDEX jm_staff_department_ix ON jm_staff (department_id);
--rollback DROP INDEX jm_staff_department_ix;

--changeset adetola:080-ix-staff_roles-role_id
--comment: Index foreign key jm_staff_roles.role_id
CREATE INDEX jm_staff_roles_role_ix ON jm_staff_roles (role_id);
--rollback DROP INDEX jm_staff_roles_role_ix;

--changeset adetola:080-ix-patients-hmo_plan_id
--comment: Index foreign key jm_patients.hmo_plan_id
CREATE INDEX jm_patients_hmo_plan_ix ON jm_patients (hmo_plan_id);
--rollback DROP INDEX jm_patients_hmo_plan_ix;

--changeset adetola:080-ix-patient_consents-patient_id
--comment: Index foreign key jm_patient_consents.patient_id
CREATE INDEX jm_patient_consents_patient_ix ON jm_patient_consents (patient_id);
--rollback DROP INDEX jm_patient_consents_patient_ix;

--changeset adetola:080-ix-patient_allergies-patient_id
--comment: Index foreign key jm_patient_allergies.patient_id
CREATE INDEX jm_patient_allergies_patient_ix ON jm_patient_allergies (patient_id);
--rollback DROP INDEX jm_patient_allergies_patient_ix;

--changeset adetola:080-ix-patient_allergies-drug_id
--comment: Index foreign key jm_patient_allergies.drug_id
CREATE INDEX jm_patient_allergies_drug_ix ON jm_patient_allergies (drug_id);
--rollback DROP INDEX jm_patient_allergies_drug_ix;

--changeset adetola:080-ix-doctor_schedules-staff_id
--comment: Index foreign key jm_doctor_schedules.staff_id
CREATE INDEX jm_doctor_schedules_staff_ix ON jm_doctor_schedules (staff_id);
--rollback DROP INDEX jm_doctor_schedules_staff_ix;

--changeset adetola:080-ix-appointments-patient_id
--comment: Index foreign key jm_appointments.patient_id
CREATE INDEX jm_appointments_patient_ix ON jm_appointments (patient_id);
--rollback DROP INDEX jm_appointments_patient_ix;

--changeset adetola:080-ix-appointments-schedule_id
--comment: Index foreign key jm_appointments.schedule_id
CREATE INDEX jm_appointments_schedule_ix ON jm_appointments (schedule_id);
--rollback DROP INDEX jm_appointments_schedule_ix;

--changeset adetola:080-ix-visits-patient_id
--comment: Index foreign key jm_visits.patient_id
CREATE INDEX jm_visits_patient_ix ON jm_visits (patient_id);
--rollback DROP INDEX jm_visits_patient_ix;

--changeset adetola:080-ix-vitals-visit_id
--comment: Index foreign key jm_vitals.visit_id
CREATE INDEX jm_vitals_visit_ix ON jm_vitals (visit_id);
--rollback DROP INDEX jm_vitals_visit_ix;

--changeset adetola:080-ix-vitals-taken_by
--comment: Index foreign key jm_vitals.taken_by
CREATE INDEX jm_vitals_taken_by_ix ON jm_vitals (taken_by);
--rollback DROP INDEX jm_vitals_taken_by_ix;

--changeset adetola:080-ix-visit_diagnoses-icd10_code
--comment: Index foreign key jm_visit_diagnoses.icd10_code
CREATE INDEX jm_visit_diagnoses_icd10_code_ix ON jm_visit_diagnoses (icd10_code);
--rollback DROP INDEX jm_visit_diagnoses_icd10_code_ix;

--changeset adetola:080-ix-visit_addenda-visit_id
--comment: Index foreign key jm_visit_addenda.visit_id
CREATE INDEX jm_visit_addenda_visit_ix ON jm_visit_addenda (visit_id);
--rollback DROP INDEX jm_visit_addenda_visit_ix;

--changeset adetola:080-ix-visit_addenda-author_id
--comment: Index foreign key jm_visit_addenda.author_id
CREATE INDEX jm_visit_addenda_author_ix ON jm_visit_addenda (author_id);
--rollback DROP INDEX jm_visit_addenda_author_ix;

--changeset adetola:080-ix-prescriptions-visit_id
--comment: Index foreign key jm_prescriptions.visit_id
CREATE INDEX jm_prescriptions_visit_ix ON jm_prescriptions (visit_id);
--rollback DROP INDEX jm_prescriptions_visit_ix;

--changeset adetola:080-ix-prescriptions-drug_id
--comment: Index foreign key jm_prescriptions.drug_id
CREATE INDEX jm_prescriptions_drug_ix ON jm_prescriptions (drug_id);
--rollback DROP INDEX jm_prescriptions_drug_ix;

--changeset adetola:080-ix-prescriptions-prescribed_by
--comment: Index foreign key jm_prescriptions.prescribed_by
CREATE INDEX jm_prescriptions_prescribed_by_ix ON jm_prescriptions (prescribed_by);
--rollback DROP INDEX jm_prescriptions_prescribed_by_ix;

--changeset adetola:080-ix-dispenses-prescription_id
--comment: Index foreign key jm_dispenses.prescription_id
CREATE INDEX jm_dispenses_prescription_ix ON jm_dispenses (prescription_id);
--rollback DROP INDEX jm_dispenses_prescription_ix;

--changeset adetola:080-ix-dispenses-batch_id
--comment: Index foreign key jm_dispenses.batch_id
CREATE INDEX jm_dispenses_batch_ix ON jm_dispenses (batch_id);
--rollback DROP INDEX jm_dispenses_batch_ix;

--changeset adetola:080-ix-dispenses-dispensed_by
--comment: Index foreign key jm_dispenses.dispensed_by
CREATE INDEX jm_dispenses_dispensed_by_ix ON jm_dispenses (dispensed_by);
--rollback DROP INDEX jm_dispenses_dispensed_by_ix;

--changeset adetola:080-ix-lab_orders-visit_id
--comment: Index foreign key jm_lab_orders.visit_id
CREATE INDEX jm_lab_orders_visit_ix ON jm_lab_orders (visit_id);
--rollback DROP INDEX jm_lab_orders_visit_ix;

--changeset adetola:080-ix-lab_orders-lab_test_id
--comment: Index foreign key jm_lab_orders.lab_test_id
CREATE INDEX jm_lab_orders_lab_test_ix ON jm_lab_orders (lab_test_id);
--rollback DROP INDEX jm_lab_orders_lab_test_ix;

--changeset adetola:080-ix-lab_orders-ordered_by
--comment: Index foreign key jm_lab_orders.ordered_by
CREATE INDEX jm_lab_orders_ordered_by_ix ON jm_lab_orders (ordered_by);
--rollback DROP INDEX jm_lab_orders_ordered_by_ix;

--changeset adetola:080-ix-lab_orders-collected_by
--comment: Index foreign key jm_lab_orders.collected_by
CREATE INDEX jm_lab_orders_collected_by_ix ON jm_lab_orders (collected_by);
--rollback DROP INDEX jm_lab_orders_collected_by_ix;

--changeset adetola:080-ix-lab_results-entered_by
--comment: Index foreign key jm_lab_results.entered_by
CREATE INDEX jm_lab_results_entered_by_ix ON jm_lab_results (entered_by);
--rollback DROP INDEX jm_lab_results_entered_by_ix;

--changeset adetola:080-ix-lab_results-verified_by
--comment: Index foreign key jm_lab_results.verified_by
CREATE INDEX jm_lab_results_verified_by_ix ON jm_lab_results (verified_by);
--rollback DROP INDEX jm_lab_results_verified_by_ix;

--changeset adetola:080-ix-services-department_id
--comment: Index foreign key jm_services.department_id
CREATE INDEX jm_services_department_ix ON jm_services (department_id);
--rollback DROP INDEX jm_services_department_ix;

--changeset adetola:080-ix-invoices-patient_id
--comment: Index foreign key jm_invoices.patient_id
CREATE INDEX jm_invoices_patient_ix ON jm_invoices (patient_id);
--rollback DROP INDEX jm_invoices_patient_ix;

--changeset adetola:080-ix-invoices-hmo_plan_id
--comment: Index foreign key jm_invoices.hmo_plan_id
CREATE INDEX jm_invoices_hmo_plan_ix ON jm_invoices (hmo_plan_id);
--rollback DROP INDEX jm_invoices_hmo_plan_ix;

--changeset adetola:080-ix-invoice_lines-invoice_id
--comment: Index foreign key jm_invoice_lines.invoice_id
CREATE INDEX jm_invoice_lines_invoice_ix ON jm_invoice_lines (invoice_id);
--rollback DROP INDEX jm_invoice_lines_invoice_ix;

--changeset adetola:080-ix-payments-invoice_id
--comment: Index foreign key jm_payments.invoice_id
CREATE INDEX jm_payments_invoice_ix ON jm_payments (invoice_id);
--rollback DROP INDEX jm_payments_invoice_ix;

--changeset adetola:080-ix-payments-received_by
--comment: Index foreign key jm_payments.received_by
CREATE INDEX jm_payments_received_by_ix ON jm_payments (received_by);
--rollback DROP INDEX jm_payments_received_by_ix;

--changeset adetola:080-jm_appointments_doctor_day_ix
--comment: Doctor day view and slot lookup
CREATE INDEX jm_appointments_doctor_day_ix ON jm_appointments (staff_id, slot_start);
--rollback DROP INDEX jm_appointments_doctor_day_ix;

--changeset adetola:080-jm_visits_queue_ix
--comment: Live consultation queue (FR-CLN-02)
CREATE INDEX jm_visits_queue_ix ON jm_visits (doctor_id, visit_date, status);
--rollback DROP INDEX jm_visits_queue_ix;

--changeset adetola:080-jm_lab_orders_queue_ix
--comment: Lab work queue
CREATE INDEX jm_lab_orders_queue_ix ON jm_lab_orders (status, ordered_at);
--rollback DROP INDEX jm_lab_orders_queue_ix;

--changeset adetola:080-jm_drug_batches_fefo_ix
--comment: FEFO dispensing and expiry alerts (FR-PHM-04)
CREATE INDEX jm_drug_batches_fefo_ix ON jm_drug_batches (drug_id, expiry_date);
--rollback DROP INDEX jm_drug_batches_fefo_ix;

--changeset adetola:080-jm_patients_dup_ix
--comment: Duplicate-patient check (FR-PAT-02)
CREATE INDEX jm_patients_dup_ix ON jm_patients (date_of_birth, phone);
--rollback DROP INDEX jm_patients_dup_ix;

--changeset adetola:080-jm_patients_name_ix
--comment: Patient search by name
CREATE INDEX jm_patients_name_ix ON jm_patients (UPPER(last_name), UPPER(first_name));
--rollback DROP INDEX jm_patients_name_ix;

--changeset adetola:080-jm_audit_log_patient_ix
--comment: DPO per-patient access report
CREATE INDEX jm_audit_log_patient_ix ON jm_audit_log (patient_id, event_at);
--rollback DROP INDEX jm_audit_log_patient_ix;

--changeset adetola:080-jm_audit_log_actor_ix
--comment: DPO per-user activity report
CREATE INDEX jm_audit_log_actor_ix ON jm_audit_log (actor, event_at);
--rollback DROP INDEX jm_audit_log_actor_ix;
