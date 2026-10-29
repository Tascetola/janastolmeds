# CLAUDE.md — JanastolMeds

Context for AI assistants (Claude Code, Claude chat) working in this repository. Read this first; it records what has been decided so it is not re-litigated.

Last updated: 28 Oct 2026 · Owner: Adetola (solution architect / lead developer)

## Project

JanastolMeds is a portfolio-grade **hospital management system** for a small to mid-size Nigerian private hospital, built to demonstrate end-to-end professional delivery: requirements, data modelling, secure REST APIs, web and mobile clients, testing and deployment.

- **Release 1.0 scope (outpatient only):** patient registration and EMR summary, doctor schedules and appointments, consultation (vitals, ICD-10 diagnoses, notes), prescriptions and pharmacy dispensing with stock, laboratory orders and results, billing (cash, transfer, POS, HMO), users/roles/audit, dashboards and reports.
- **Out of scope (future releases):** inpatient/wards/beds, theatre, radiology/PACS, blood bank, live payment gateway (stub only), payroll/HR/GL, telemedicine.
- **Timeline:** 12 weeks in 7 phases. Phase 1 (requirements) done; Phase 2 (design) mostly done; backend build starting.
- **Repo:** https://github.com/Tascetola/janastolmeds (public)

## Architecture

All business rules live in **one PL/SQL API layer** (`JM_*_API` packages). Both clients go through it.

```
APEX web portal (staff)  ──HTTPS──────────────►  APEX engine ─┐
Flutter mobile app (patients) ──HTTPS + bearer──► ORDS /api/v1 ┤
                                                               ▼
                                           JM_*_API PL/SQL packages (rules, RBAC, audit)
                                                               ▼
                                              JMEDS tables  +  JM_AUDIT_LOG
                         (all inside Oracle Autonomous Database, Always Free)
```

| Layer | Technology |
| --- | --- |
| Database | Oracle Autonomous Database (Always Free) |
| Business logic | PL/SQL packages `JM_*_API` |
| REST | ORDS, OAuth2, versioned `/api/v1/` |
| Web | Oracle APEX 24.2, Universal Theme, PWA enabled |
| Mobile | Flutter 3.x (Android 8+, iOS 15+) |
| Migrations | SQLcl Liquibase (formatted SQL changesets) |
| Testing | utPLSQL, Postman/Newman, Flutter test |
| CI/CD | GitHub Actions |

## Naming conventions (decided 27 Oct 2026 — do not change)

| Item | Convention | Example |
| --- | --- | --- |
| Tables, packages, views, sequences, context | Prefix `JM_` | `JM_PATIENTS`, `JM_PATIENT_API`, `JM_CTX` |
| Reporting (masked) views | `JM_V_*` | `JM_V_PATIENTS` |
| Business numbers | `JM-YYYY-NNNNNN` | MRN `JM-2026-000123` |
| Document IDs | `JM-DOC-nn` | `JM-DOC-03` |
| Constraints | `<TABLE>_PK`, `_<COL>_FK`, `_<COL>_UK`, `_<RULE>_CK` | `JM_APPOINTMENTS_SLOT_UK` |
| Indexes | `<TABLE>_<COL>_IX` | `JM_VISITS_PATIENT_IX` |
| Primary keys | Surrogate `<ENTITY>_ID NUMBER` identity | `PATIENT_ID` |
| Strings / money / flags | `VARCHAR2(n CHAR)` / `NUMBER(12,2)` NGN / `VARCHAR2(1)` Y/N | |
| Event times | `TIMESTAMP WITH LOCAL TIME ZONE` | `CHECKED_IN_AT` |
| Requirement IDs | `FR-<MODULE>-nn`, `NFR-<CAT>-nn`; tests `TC-<module>-nn` | `FR-APT-02` |

## Database accounts (confirmed 27 Oct 2026)

| Account | Meaning | Rights |
| --- | --- | --- |
| `JMEDS` | JanastolMeds | Owner: all tables, sequences, packages. Not used by APEX/ORDS directly. |
| `JMEDS_API` | JanastolMeds Application Programming Interface | Parsing schema for APEX and ORDS. EXECUTE on `JM_*_API` only; no table DML. |
| `JMEDS_RO` | JanastolMeds Read-Only | SELECT on masked `JM_V_*` views only. |

`JM_CTX` application context (set only by `JMEDS.JM_CTX_API`) carries actor type, staff/patient ID and roles for every call.

## Data model (JM-DOC-03)

29 tables in 7 modules; **the visit is the hub** (vitals, diagnoses, prescriptions, lab orders and the invoice all belong to a visit).

- **Admin:** `JM_DEPARTMENTS`, `JM_STAFF`, `JM_ROLES`, `JM_STAFF_ROLES`, `JM_LOOKUPS`, `JM_AUDIT_LOG`
- **Patient:** `JM_PATIENTS`, `JM_PATIENT_CONSENTS`, `JM_PATIENT_ALLERGIES`, `JM_HMO_PLANS`, `JM_PATIENT_ACCOUNTS`
- **Appointments:** `JM_DOCTOR_SCHEDULES`, `JM_APPOINTMENTS`
- **Clinical:** `JM_VISITS`, `JM_VITALS`, `JM_ICD10_CODES`, `JM_VISIT_DIAGNOSES`, `JM_VISIT_ADDENDA`
- **Pharmacy:** `JM_DRUGS`, `JM_DRUG_BATCHES`, `JM_PRESCRIPTIONS`, `JM_DISPENSES`
- **Lab:** `JM_LAB_TESTS`, `JM_LAB_ORDERS`, `JM_LAB_RESULTS`
- **Billing:** `JM_SERVICES`, `JM_INVOICES`, `JM_INVOICE_LINES`, `JM_PAYMENTS`

Every table except `JM_AUDIT_LOG` has audit columns `CREATED_BY`, `CREATED_ON`, `UPDATED_BY`, `UPDATED_ON`, `ROW_VERSION` (set by `<table>_BIU` triggers via `JM_CURRENT_USER`; `ROW_VERSION` is for optimistic locking).

Sequences: `JM_MRN_SEQ`, `JM_APPOINTMENT_SEQ`, `JM_VISIT_SEQ`, `JM_LAB_ORDER_SEQ`, `JM_INVOICE_SEQ`, `JM_RECEIPT_SEQ`.

## Business rules and where they are enforced

| Rule | Enforcement |
| --- | --- |
| No double-booking of a doctor slot | Function-based unique index `JM_APPOINTMENTS_SLOT_UK` (ignores CANCELLED/NO_SHOW) |
| Booking fits schedule and capacity | `JM_APPOINTMENT_API.book` with `SELECT … FOR UPDATE` |
| Patients cancel ≥ 2 h before slot | `JM_APPOINTMENT_API.cancel` |
| Duplicate patient warning (name + DOB + phone) | `JM_PATIENT_API.find_duplicates` |
| HMO member number required with HMO plan | Check constraint |
| Visits lock 24 h after completion; changes then go to addenda | Scheduler job `JM_LOCK_COMPLETED_VISITS` + lock-guard triggers |
| Allergy warning before prescribing (override needs reason) | `JM_PHARMACY_API.prescribe` + check constraint |
| Stock never negative; FEFO; no expired dispensing | Check constraint + `JM_PHARMACY_API.dispense` |
| Lab verifier ≠ entrant; patients see only RELEASED results | Check constraint + `JM_LAB_API` / ORDS filters |
| Each charge source billed once | Unique `(SOURCE_TYPE, SOURCE_ID)` on `JM_INVOICE_LINES` |
| Payments ≤ balance | `JM_BILLING_API.record_payment` + check constraint |
| Audit log append-only, hash-chained | Statement trigger blocks UPDATE/DELETE; `PREV_HASH` → `ROW_HASH` |

## Security and privacy (NDPA 2023)

Health data is sensitive personal data. Non-negotiables:

- RBAC enforced in PL/SQL, not only in the UI. A patient token can only ever read that patient's rows (filter on `SYS_CONTEXT('JM_CTX','PATIENT_ID')`).
- OAuth2 on every ORDS module; no anonymous endpoints except login and self-registration. Tokens expire in 60 minutes.
- Passwords salted and hashed; lockout after 5 failed attempts.
- Bind variables only; no dynamic SQL built from user input.
- Every view/change of clinical data written to `JM_AUDIT_LOG`; logs kept 6 years.
- Consent captured and versioned (`JM_PATIENT_CONSENTS`); access export and anonymisation procedures in `JM_PATIENT_API`.
- **Only synthetic data** in dev, test and demo. Never commit wallets, passwords or `.env` files.

## Repository layout

```
janastolmeds/
├── README.md
├── LICENSE                       MIT
├── .gitignore                    wallets, .env, keystores, Flutter build output
├── docs/
│   ├── 01-project-charter-srs.md       JM-DOC-01 (draft v0.1)
│   ├── 03-database-design.md           JM-DOC-03 (draft v0.1)
│   ├── qa/test-data-and-migration.md   JM-DOC-07 Annex A: test data per table, production migration
│   ├── qa/<phase>-<yyyy-mm-dd>.md      QA gate evidence (database-2026-10-28.md)
│   ├── qa/defects.md                   JM-DOC-07 Annex B: defect register (DEF-nnn)
│   └── images/ architecture.png, erd.png
├── database/
│   ├── README.md
│   ├── admin/00_create_accounts.sql    run once as ADMIN (prompts for passwords)
│   ├── admin/01_install_utplsql.md     utPLSQL v3.2.3 into UT3, run once as ADMIN
│   ├── changelogs/controller.xml + 010…100_*.sql
│   ├── seed-data/ 010_roles_departments, 020_lookups, 030_icd10_codes (200 codes)
│   ├── packages/                       JM_*_API (next)
│   ├── tests/                          utPLSQL suites JM_UT_* (context:dev,test): schema, constraints, triggers, reference
│   ├── test-data/                      synthetic demo data, context:dev,test (next)
│   ├── qa/                             schema_columns.sql (design conformance), schema_snapshot.sql (rollback/env compare)
│   └── ords/                           REST modules (next)
├── apex/                         split APEX export (later)
├── mobile/                       Flutter app (later)
└── .github/
    ├── workflows/ci.yml          static checks, secret scan, Liquibase validate/preview; deploy + idempotency + tests on main
    └── scripts/                  check-changesets.sh, run-sql.sh
```

Documentation set: JM-DOC-01 Charter & SRS · 02 Architecture · 03 Database Design · 04 API Specification · 05 UI Wireframes · 06 Coding Standards · 07 Test Plan & Traceability · 08 Deployment Guide · 09 User Manual.

## Liquibase rules

1. Never edit a changeset that has run on a shared database; fix forward with a new one.
2. Changeset id `adetola:<file>-<n>`; every changeset has `--comment:` naming the SRS requirement and a `--rollback`.
3. PL/SQL changesets use `endDelimiter:/`, `runOnChange:true` and `stripComments:false` (Liquibase strips comments by default, which deletes utPLSQL annotations; CI enforces all three). Test packages are named `JM_UT_*`.
4. Reference data (roles, departments, lookups, ICD-10) loads in all environments; synthetic test data lives in `database/test-data/`, uses `context:dev,test` and sets `CREATED_BY = 'JM_TEST_DATA'` (CI enforces the context).
5. **Production always runs `lb update … -contexts prod`.** With no context Liquibase runs every changeset, including synthetic data. Production is a fresh build, never a copy of demo; see `docs/qa/test-data-and-migration.md` for what each table does at migration.

```bash
# first time
sql admin@<db>_high      → @admin/00_create_accounts.sql
cd database/changelogs
sql jmeds@<db>_high      → lb update -changelog-file controller.xml
# everyday
lb status | lb update | lb update-sql | lb rollback-count -count 1   (each with -changelog-file controller.xml)
```

## Status (27 Oct 2026)

- [x] Project charter and SRS (JM-DOC-01)
- [x] Architecture diagram
- [x] Database design, ERD, data dictionary (JM-DOC-03); all open decisions closed
- [x] Liquibase changesets 010–100 and seed data (`database/` v0.1) — **written but not yet run against Oracle; first run is the real test**
- [x] GitHub repo public with README, docs, LICENSE, `.gitignore`
- [x] Run changesets on ADB (28 Oct 2026, CIBSERP `cibserp_high`, schema `JMEDS`): 130 changesets, 29 tables, 33 triggers, 6 sequences, 1 job, all VALID; seed 8 roles, 7 departments, 74 lookups, 200 ICD-10. Deployed without errors.
- [x] Database schema QA gate (28 Oct 2026): **passed**, 85 utPLSQL tests (84 pass, 1 disabled for DEF-005), 2 full rollback tests, schema = JM-DOC-03 v0.2. Open: DEF-005, DEF-008 (deferred), DEF-006, DEF-009 (decision). See docs/qa/database-2026-10-28.md
- [ ] UI wireframes (JM-DOC-05), 5–8 key screens
- [ ] PL/SQL API layer: `JM_CTX_API`, then `JM_PATIENT_API`, other `JM_*_API`; grants to `JMEDS_API`; audit-chain verification job
- [ ] API specification (JM-DOC-04, OpenAPI) and ORDS modules
- [ ] APEX staff portal, Flutter patient app, tests, deployment guide, user manual

## Quality assurance (decided 28 Oct 2026 — production standard)

JanastolMeds is built to production standard. **No phase is "done" until its QA gate passes and the evidence is recorded.** Test design, cases and traceability live in JM-DOC-07; run results go in `docs/qa/<phase>-<yyyy-mm-dd>.md` (what ran, against what commit, pass/fail, defects raised).

Applies to every change:

- Work on a branch and merge to `main` via pull request; CI must be green and the change reviewed before merging.
- No compile errors or warnings (`PLSQL_WARNINGS='ENABLE:ALL'`); no invalid objects after deploy.
- Liquibase: `lb validate` clean; a second `lb update` applies 0 changesets; every changeset's `--rollback` is exercised.
- Secrets scan before commit; synthetic data only.
- Defects get an ID (`DEF-nnn`), a severity (S1–S4), a fix and a regression test.

| Phase | QA gate (all must pass) |
| --- | --- |
| Database schema | Conformance to JM-DOC-03 (every table, column, type, constraint and index present and named per conventions); each check/unique/FK constraint rejects bad data; audit-column, `ROW_VERSION`, visit-lock and audit-log-guard triggers behave; full rollback and re-apply on a scratch schema; seed data counts and values verified |
| PL/SQL API layer | utPLSQL tests for every FR and business rule, positive and negative; ≥ 80% line coverage per package; RBAC and patient-isolation tests (a patient context can never read another patient's rows); audit entries written and hash chain verifies; concurrency test for booking and dispensing |
| ORDS REST API | Newman contract tests against the OpenAPI spec (JM-DOC-04); OAuth2 on every endpoint, expired/invalid/wrong-role tokens rejected; OWASP API Security Top 10 checklist; input validation and error format |
| APEX web portal | Functional test scripts per FR; role-based page and item access; APEX Advisor clean; WCAG 2.1 AA accessibility checks; browser matrix |
| Flutter app | `flutter analyze` clean; unit, widget and integration tests; token storage and session expiry; Android 8+ and iOS 15+ device checks |
| Performance and security | NFR targets met under load; vulnerability scan; NDPA 2023 privacy checklist (consent, access export, anonymisation, 6-year audit retention) |
| Release | Traceability matrix complete (every FR → TC → result); UAT signed off; no open S1/S2 defects; deployment and rollback rehearsed from scratch; test summary report published |

## Working conventions

- Commit messages use conventional prefixes: `docs:`, `feat(db):`, `fix:`, etc.
- Keep requirement IDs in changeset comments, test cases and commit messages for traceability.
- ICD-10 subset is compiled from WHO ICD-10 knowledge; verify against the WHO browser and have a clinician review before any real clinical use.
