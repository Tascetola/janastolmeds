# Test Data and Production Migration Register

JM-DOC-07 Annex A · 28 Oct 2026 · Owner: Adetola · Status: v0.1, maintained with every phase

This register records where test and demo data lives in the `JMEDS` schema, how to recognise it, and what happens to each of the 29 tables when JanastolMeds moves to a production database. Update it whenever a test or data load starts writing to a table it did not write to before.

## 1. Decisions

| # | Decision | Consequence |
| --- | --- | --- |
| D1 | Tests and demo data run in the same `JMEDS` schema on CIBSERP (`cibserp_high`); this environment is the **demo** environment (decided 28 Oct 2026). | Every transactional row in the demo database is non-production by definition. |
| D2 | **Production is a fresh build, never a copy of demo.** It is created with the same Liquibase changelog plus real hospital data loaded at go-live. | No export/import from demo to production, so no test row can leak across. Only *definitions* (reference data, and reviewed catalogues) move. |
| D3 | Only synthetic data in demo (NFR-PRV-05, NDPA 2023). Names, phones, addresses and HMO member numbers are invented; no real patient may ever be entered here. | The demo database never becomes subject to patient-data obligations. |
| D4 | Synthetic data loaded by Liquibase carries `CREATED_BY = 'JM_TEST_DATA'` and `context:dev,test`. | It can be counted, purged within demo, and proved absent in production. |

## 2. Where test data comes from

| Source | Writes to | Leaves data behind? | How to recognise it |
| --- | --- | --- | --- |
| **utPLSQL unit tests** (`database/tests/`, API phase onwards) | Any table the code under test touches, including `JM_AUDIT_LOG` | **No.** utPLSQL wraps each test in a savepoint and rolls back automatically. Only sequence and identity numbers are consumed (gaps). | Not visible after the run |
| **Synthetic demo dataset** (`database/test-data/`, loaded by Liquibase, `context:dev,test`; to be written with the API phase) | Configuration, patient and transactional tables (see section 3) | Yes, by design: it is the demo | `CREATED_BY = 'JM_TEST_DATA'` |
| **Manual testing and demos** through APEX and the mobile app (UAT, walkthroughs) | Patient and transactional tables, `JM_AUDIT_LOG` | Yes | `CREATED_BY` = the demo staff or patient user who did it |
| **CI** (GitHub Actions) | Liquibase tracking tables only (`DATABASECHANGELOG*`) | Deploy history only | — |

Rules that keep the first row true (enforced by code review and the API-layer QA gate):

1. API packages never `COMMIT`; the caller (APEX page, ORDS handler, job) commits. A test therefore owns the whole transaction and its rollback removes everything.
2. Audit rows are written in the same transaction as the change (no autonomous transactions), so they roll back with the test too.
3. A test that must commit (for example testing the scheduler job) is marked `--%rollback(manual)`, cleans up after itself, and is listed in section 6.

## 3. Table register

Categories: **R** reference · **C** hospital configuration · **O** opening balance · **P** patient master · **T** transactional · **A** audit.

| Table | Cat. | Test / demo data in this table | Production: what happens |
| --- | --- | --- | --- |
| `JM_ROLES` | R | 8 roles from `seed-data/010` (same in every environment) | Created automatically by `lb update`. New roles only by new changeset. |
| `JM_DEPARTMENTS` | R | 7 departments from `seed-data/010` | Created automatically. Tailor to the hospital by a new changeset, not by editing. |
| `JM_LOOKUPS` | R | 74 code-list values from `seed-data/020` | Created automatically. |
| `JM_ICD10_CODES` | R | 200 outpatient codes from `seed-data/030` | Created automatically. Clinician review of the subset before go-live (see CLAUDE.md). |
| `JM_STAFF` | C | Synthetic doctors, nurses, pharmacists, lab scientists, cashiers for each role | **Not migrated.** Real staff loaded at go-live (HR list, verified licence numbers). |
| `JM_STAFF_ROLES` | C | Role assignments for the synthetic staff | **Not migrated.** Assigned for real staff at go-live; reviewed by the hospital manager. |
| `JM_DOCTOR_SCHEDULES` | C | Weekly clinic sessions for synthetic doctors | **Not migrated.** Entered from the real clinic timetable. |
| `JM_HMO_PLANS` | C | Synthetic HMOs and plans with coverage % | **Not migrated.** Real HMO contracts entered by billing (coverage % from signed agreements). |
| `JM_SERVICES` | C | Price list (consultation, registration, procedures) | **Template only.** May be promoted after finance confirms every price; loaded as a reviewed changeset with `context:prod`. |
| `JM_DRUGS` | C | Formulary (generic name, strength, form, price) | **Template only.** Promote after the pharmacist confirms items, NAFDAC numbers and prices. |
| `JM_LAB_TESTS` | C | Test catalogue with reference ranges and prices | **Template only.** Promote after the lab head confirms ranges and units. |
| `JM_DRUG_BATCHES` | O | Synthetic batches, including deliberately expired and low-stock ones for FEFO and expiry tests | **Not migrated.** Opening stock from a physical stock count on go-live day. |
| `JM_PATIENTS` | P | Synthetic patients, including deliberate near-duplicates (FR-PAT-02) and HMO members | **Never migrated from demo.** Production starts empty, or real patients come from the hospital's legacy system under a separate migration plan (cleansing, duplicate check, MRN mapping). |
| `JM_PATIENT_CONSENTS` | P | Consents for synthetic patients | **Never migrated.** Consent is recaptured against the production privacy-notice version. |
| `JM_PATIENT_ALLERGIES` | P | Allergies, some linked to drugs, to exercise the prescribing warning (FR-PHM-02) | **Never migrated from demo.** From legacy only, clinically verified. |
| `JM_PATIENT_ACCOUNTS` | P | Mobile logins for synthetic patients | **Never migrated.** Patients self-register in production; password hashes are never copied between systems. |
| `JM_APPOINTMENTS` | T | Bookings in every status, including slot clashes for the double-booking test | **Never migrated.** |
| `JM_VISITS` | T | Visits in OPEN, COMPLETED and LOCKED states | **Never migrated.** |
| `JM_VITALS` | T | Vital signs, including boundary values | **Never migrated.** |
| `JM_VISIT_DIAGNOSES` | T | ICD-10 diagnoses on synthetic visits | **Never migrated.** |
| `JM_VISIT_ADDENDA` | T | Addenda on locked visits | **Never migrated.** |
| `JM_PRESCRIPTIONS` | T | Prescriptions, including allergy overrides | **Never migrated.** |
| `JM_DISPENSES` | T | Dispensing against synthetic batches | **Never migrated.** |
| `JM_LAB_ORDERS` | T | Orders through every workflow status | **Never migrated.** |
| `JM_LAB_RESULTS` | T | Results, normal and abnormal, verified and unverified | **Never migrated.** |
| `JM_INVOICES` | T | Cash and HMO invoices, open, part-paid, paid, void | **Never migrated.** Financial history starts at go-live. |
| `JM_INVOICE_LINES` | T | Charges from services, lab and drugs | **Never migrated.** |
| `JM_PAYMENTS` | T | Payments by every method, including reversals | **Never migrated.** |
| `JM_AUDIT_LOG` | A | Every view and change made during demos and manual tests | **Never migrated.** Starts empty; the hash chain begins at its first production row. Demo rows cannot be deleted (append-only by design), which is another reason production is a fresh build. |

Summary: 4 reference tables move automatically; 3 catalogues (`JM_SERVICES`, `JM_DRUGS`, `JM_LAB_TESTS`) may be promoted after review; the other 22 tables start empty in production or are loaded from real sources.

## 4. Sequences and business numbers

Sequences (`JM_MRN_SEQ`, `JM_APPOINTMENT_SEQ`, `JM_VISIT_SEQ`, `JM_LAB_ORDER_SEQ`, `JM_INVOICE_SEQ`, `JM_RECEIPT_SEQ`) and identity columns start at 1 in production because the schema is built fresh. Gaps in demo numbering caused by rolled-back tests are expected and harmless.

**Open decision for legacy migration** (only if the hospital has an existing system): keep legacy MRNs in a separate column, or issue new `JM-YYYY-NNNNNN` MRNs and keep a mapping table. Decide before any legacy load is designed.

## 5. Production build procedure (data view)

1. `ADMIN`: run `database/admin/00_create_accounts.sql` on the production database.
2. `JMEDS`: `lb update -changelog-file controller.xml -contexts prod`. **Always pass `-contexts prod` in production.** Liquibase runs *every* changeset when no context is given, which would load the synthetic dataset.
3. Load configuration (C) and the promoted catalogues, each signed off by its owner (HR, clinic, finance, pharmacy, lab).
4. Load opening stock (O) from the go-live stock count.
5. Patients (P): start empty, or run the separately approved legacy migration.
6. Verify, and keep the output as release evidence:

```sql
-- Must return 0 in production
select count(*) from (
  select created_by from jm_staff        union all select created_by from jm_patients
  union all select created_by from jm_drugs   union all select created_by from jm_hmo_plans
  -- extend to every table with audit columns
) where created_by = 'JM_TEST_DATA';

-- Must return no rows in production
select id, author, filename from databasechangelog where contexts like '%test%' or contexts like '%dev%';
```

7. Confirm `JM_AUDIT_LOG` is empty before go-live and that the chain verification job passes after the first day.

## 6. Residue register

Anything a test leaves behind on purpose (`--%rollback(manual)` tests, scheduler tests) is listed here with its clean-up.

| Test | Tables | Residue | Clean-up |
| --- | --- | --- | --- |
| *(none yet)* | | | |

## 7. Change log

| Date | Change |
| --- | --- |
| 28 Oct 2026 | v0.1: decisions D1–D4, table register for all 29 tables, production procedure. |
