# JanastolMeds

**A hospital management system for web and mobile, built on Oracle APEX, ORDS and Flutter.**

JanastolMeds digitises the outpatient journey of a small to mid-size hospital: patient registration, appointments, consultation, pharmacy, laboratory and billing. Staff work in an Oracle APEX web portal; patients use a Flutter mobile app to book appointments and view prescriptions, lab results and invoices. Both clients share one Oracle database through a secured ORDS REST API.

> **Project status:** Phase 1 – Requirements complete. Phase 2 – Design in progress.

## Architecture

![JanastolMeds architecture](docs/images/architecture.png)

All business rules live in a single PL/SQL API layer. APEX calls it inside the database; the mobile app reaches it only through ORDS endpoints secured with OAuth2. A rule such as "no double-booking" or "patients see only their own records" is written once and enforced for every client.

## Tech stack

| Layer | Technology |
| --- | --- |
| Database | Oracle Autonomous Database (Always Free) |
| Business logic | PL/SQL packages (`JM_*_API`) |
| REST API | Oracle REST Data Services (ORDS), OAuth2 |
| Web client | Oracle APEX 24.2, Universal Theme, PWA |
| Mobile client | Flutter 3.x (Android and iOS) |
| DB migrations | SQLcl + Liquibase |
| Testing | utPLSQL, Postman/Newman, Flutter test |
| CI/CD | GitHub Actions |

## Release 1.0 modules

- Patient registration and medical record summary
- Doctor schedules and appointment booking
- Outpatient consultation: vitals, diagnosis (ICD-10), notes
- Pharmacy: prescriptions, dispensing, stock and expiry
- Laboratory: orders, results, two-step verification
- Billing: invoices, payments, HMO split
- Administration: users, roles, audit log, dashboards

## Documentation

| ID | Document | Status |
| --- | --- | --- |
| JM-DOC-01 | [Project Charter & SRS](docs/01-project-charter-srs.md) | Draft v0.1 |
| JM-DOC-02 | Architecture | Planned |
| JM-DOC-03 | [Database Design (ERD, data dictionary)](docs/03-database-design.md) | Draft v0.1 |
| JM-DOC-04 | API Specification (OpenAPI) | Planned |
| JM-DOC-05 | UI Wireframes | Planned |
| JM-DOC-06 | Coding Standards | Planned |
| JM-DOC-07 | Test Plan & Traceability Matrix | Planned |
| JM-DOC-08 | Deployment Guide | Planned |
| JM-DOC-09 | User Manual | Planned |

## Repository structure

```
janastolmeds/
├── docs/          Project documentation and diagrams
├── database/      Liquibase changelogs, PL/SQL packages, ORDS modules, seed data
├── apex/          APEX application (split export)
├── mobile/        Flutter patient app
└── .github/       CI workflows
```

## Data protection

JanastolMeds is designed for compliance with the Nigeria Data Protection Act 2023: consent capture, role-based access, field-level minimisation and a full audit trail of access to clinical records. **Only synthetic data is used** in this repository and in all demo environments.

## Author

**Adetola** – Oracle Developer / DBA (APEX, ORDS, Oracle EBS, Autonomous Database)

## License

[MIT](LICENSE)
