--liquibase formatted sql

--changeset adetola:seed-lookups-gender-001
--comment: Lookup values for GENDER. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('GENDER', 'MALE', 'Male', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('GENDER', 'FEMALE', 'Female', 20);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'GENDER';

--changeset adetola:seed-lookups-blood-group-001
--comment: Lookup values for BLOOD_GROUP. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('BLOOD_GROUP', 'A+', 'A+', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('BLOOD_GROUP', 'A-', 'A-', 20);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('BLOOD_GROUP', 'B+', 'B+', 30);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('BLOOD_GROUP', 'B-', 'B-', 40);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('BLOOD_GROUP', 'AB+', 'AB+', 50);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('BLOOD_GROUP', 'AB-', 'AB-', 60);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('BLOOD_GROUP', 'O+', 'O+', 70);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('BLOOD_GROUP', 'O-', 'O-', 80);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'BLOOD_GROUP';

--changeset adetola:seed-lookups-genotype-001
--comment: Lookup values for GENOTYPE. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('GENOTYPE', 'AA', 'AA', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('GENOTYPE', 'AS', 'AS', 20);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('GENOTYPE', 'AC', 'AC', 30);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('GENOTYPE', 'SS', 'SS', 40);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('GENOTYPE', 'SC', 'SC', 50);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'GENOTYPE';

--changeset adetola:seed-lookups-relationship-001
--comment: Lookup values for RELATIONSHIP. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('RELATIONSHIP', 'SPOUSE', 'Spouse', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('RELATIONSHIP', 'PARENT', 'Parent', 20);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('RELATIONSHIP', 'CHILD', 'Child', 30);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('RELATIONSHIP', 'SIBLING', 'Sibling', 40);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('RELATIONSHIP', 'GUARDIAN', 'Guardian', 50);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('RELATIONSHIP', 'OTHER', 'Other', 60);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'RELATIONSHIP';

--changeset adetola:seed-lookups-apt-status-001
--comment: Lookup values for APT_STATUS. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('APT_STATUS', 'BOOKED', 'Booked', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('APT_STATUS', 'CHECKED_IN', 'Checked in', 20);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('APT_STATUS', 'IN_CONSULT', 'In consultation', 30);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('APT_STATUS', 'COMPLETED', 'Completed', 40);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('APT_STATUS', 'CANCELLED', 'Cancelled', 50);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('APT_STATUS', 'NO_SHOW', 'No-show', 60);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'APT_STATUS';

--changeset adetola:seed-lookups-visit-status-001
--comment: Lookup values for VISIT_STATUS. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('VISIT_STATUS', 'OPEN', 'Open', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('VISIT_STATUS', 'COMPLETED', 'Completed', 20);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('VISIT_STATUS', 'LOCKED', 'Locked', 30);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'VISIT_STATUS';

--changeset adetola:seed-lookups-triage-001
--comment: Lookup values for TRIAGE. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('TRIAGE', '1', '1 - Emergency', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('TRIAGE', '2', '2 - Urgent', 20);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('TRIAGE', '3', '3 - Semi-urgent', 30);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('TRIAGE', '4', '4 - Routine', 40);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'TRIAGE';

--changeset adetola:seed-lookups-frequency-001
--comment: Lookup values for FREQUENCY. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('FREQUENCY', 'OD', 'Once daily', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('FREQUENCY', 'BD', 'Twice daily', 20);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('FREQUENCY', 'TDS', 'Three times daily', 30);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('FREQUENCY', 'QDS', 'Four times daily', 40);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('FREQUENCY', 'NOCTE', 'At night', 50);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('FREQUENCY', 'STAT', 'Immediately, once', 60);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('FREQUENCY', 'PRN', 'When required', 70);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('FREQUENCY', 'WEEKLY', 'Once weekly', 80);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'FREQUENCY';

--changeset adetola:seed-lookups-dosage-form-001
--comment: Lookup values for DOSAGE_FORM. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DOSAGE_FORM', 'TABLET', 'Tablet', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DOSAGE_FORM', 'CAPSULE', 'Capsule', 20);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DOSAGE_FORM', 'SYRUP', 'Syrup', 30);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DOSAGE_FORM', 'SUSPENSION', 'Suspension', 40);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DOSAGE_FORM', 'INJECTION', 'Injection', 50);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DOSAGE_FORM', 'INFUSION', 'Infusion', 60);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DOSAGE_FORM', 'CREAM', 'Cream', 70);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DOSAGE_FORM', 'OINTMENT', 'Ointment', 80);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DOSAGE_FORM', 'DROPS', 'Drops', 90);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DOSAGE_FORM', 'INHALER', 'Inhaler', 100);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DOSAGE_FORM', 'SUPPOSITORY', 'Suppository', 110);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'DOSAGE_FORM';

--changeset adetola:seed-lookups-sample-type-001
--comment: Lookup values for SAMPLE_TYPE. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('SAMPLE_TYPE', 'BLOOD', 'Blood', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('SAMPLE_TYPE', 'URINE', 'Urine', 20);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('SAMPLE_TYPE', 'STOOL', 'Stool', 30);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('SAMPLE_TYPE', 'SPUTUM', 'Sputum', 40);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('SAMPLE_TYPE', 'SWAB', 'Swab', 50);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('SAMPLE_TYPE', 'CSF', 'Cerebrospinal fluid', 60);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'SAMPLE_TYPE';

--changeset adetola:seed-lookups-pay-method-001
--comment: Lookup values for PAY_METHOD. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('PAY_METHOD', 'CASH', 'Cash', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('PAY_METHOD', 'TRANSFER', 'Bank transfer', 20);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('PAY_METHOD', 'POS', 'POS / card', 30);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('PAY_METHOD', 'HMO', 'HMO', 40);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('PAY_METHOD', 'GATEWAY', 'Online payment', 50);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'PAY_METHOD';

--changeset adetola:seed-lookups-invoice-status-001
--comment: Lookup values for INVOICE_STATUS. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('INVOICE_STATUS', 'OPEN', 'Open', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('INVOICE_STATUS', 'PART_PAID', 'Part paid', 20);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('INVOICE_STATUS', 'PAID', 'Paid', 30);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('INVOICE_STATUS', 'VOID', 'Void', 40);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'INVOICE_STATUS';

--changeset adetola:seed-lookups-allergy-severity-001
--comment: Lookup values for ALLERGY_SEVERITY. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('ALLERGY_SEVERITY', 'MILD', 'Mild', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('ALLERGY_SEVERITY', 'MODERATE', 'Moderate', 20);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('ALLERGY_SEVERITY', 'SEVERE', 'Severe', 30);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'ALLERGY_SEVERITY';

--changeset adetola:seed-lookups-diagnosis-type-001
--comment: Lookup values for DIAGNOSIS_TYPE. Reference data for all environments.
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DIAGNOSIS_TYPE', 'PRIMARY', 'Primary', 10);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DIAGNOSIS_TYPE', 'SECONDARY', 'Secondary', 20);
INSERT INTO jm_lookups (lookup_type, lookup_code, meaning, display_seq) VALUES ('DIAGNOSIS_TYPE', 'PROVISIONAL', 'Provisional', 30);
--rollback DELETE FROM jm_lookups WHERE lookup_type = 'DIAGNOSIS_TYPE';
