--liquibase formatted sql

--changeset adetola:seed-roles-001
--comment: Application roles (FR-ADM-01, NFR-SEC-02). Reference data for all environments.
INSERT INTO jm_roles (role_code, role_name) VALUES ('ADMIN',      'System Administrator');
INSERT INTO jm_roles (role_code, role_name) VALUES ('FRONTDESK',  'Front Desk / Records');
INSERT INTO jm_roles (role_code, role_name) VALUES ('DOCTOR',     'Doctor');
INSERT INTO jm_roles (role_code, role_name) VALUES ('NURSE',      'Nurse');
INSERT INTO jm_roles (role_code, role_name) VALUES ('PHARMACIST', 'Pharmacist');
INSERT INTO jm_roles (role_code, role_name) VALUES ('LABSCI',     'Lab Scientist');
INSERT INTO jm_roles (role_code, role_name) VALUES ('CASHIER',    'Cashier / Billing Officer');
INSERT INTO jm_roles (role_code, role_name) VALUES ('MANAGER',    'Hospital Manager');
--rollback DELETE FROM jm_roles WHERE role_code IN ('ADMIN','FRONTDESK','DOCTOR','NURSE','PHARMACIST','LABSCI','CASHIER','MANAGER');

--changeset adetola:seed-departments-001
--comment: Departments (FR-ADM-01). Reference data for all environments.
INSERT INTO jm_departments (dept_code, dept_name) VALUES ('ADM', 'Administration');
INSERT INTO jm_departments (dept_code, dept_name) VALUES ('REC', 'Records / Front Desk');
INSERT INTO jm_departments (dept_code, dept_name) VALUES ('OPD', 'Outpatient Department');
INSERT INTO jm_departments (dept_code, dept_name) VALUES ('NUR', 'Nursing');
INSERT INTO jm_departments (dept_code, dept_name) VALUES ('PHM', 'Pharmacy');
INSERT INTO jm_departments (dept_code, dept_name) VALUES ('LAB', 'Laboratory');
INSERT INTO jm_departments (dept_code, dept_name) VALUES ('BIL', 'Billing and Accounts');
--rollback DELETE FROM jm_departments WHERE dept_code IN ('ADM','REC','OPD','NUR','PHM','LAB','BIL');
