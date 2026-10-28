# JanastolMeds database

Everything in the `JMEDS` schema is built from this folder by SQLcl Liquibase, so any environment can be rebuilt identically. Design reference: [JM-DOC-03 Database Design](../docs/03-database-design.md).

## Folder layout

| Folder | Contents |
| --- | --- |
| `admin/` | One-off steps run as ADMIN: create the accounts and `JM_CTX` context; install utPLSQL |
| `changelogs/` | `controller.xml` plus numbered changesets: tables, indexes, triggers, jobs |
| `seed-data/` | Reference data for all environments: roles, departments, lookups, ICD-10 codes |
| `packages/` | `JM_*_API` PL/SQL packages (next phase) |
| `ords/` | ORDS REST module definitions (next phase) |

## Accounts

| Account | Meaning | Purpose |
| --- | --- | --- |
| `JMEDS` | JanastolMeds | Owner schema: all tables, sequences, packages |
| `JMEDS_API` | JanastolMeds Application Programming Interface | Parsing schema for APEX and ORDS; EXECUTE on packages only |
| `JMEDS_RO` | JanastolMeds Read-Only | Reporting through masked views only |

## First-time setup

Prerequisites: an Oracle Autonomous Database (Always Free is enough), its wallet, and SQLcl 23.x or later.

```bash
# 1. As ADMIN: create accounts and context (prompts for three passwords)
sql admin@<db_name>_high
SQL> @admin/00_create_accounts.sql
SQL> exit

# 2. As JMEDS: build the schema
cd changelogs
sql jmeds@<db_name>_high
SQL> lb update -changelog-file controller.xml
```

## Everyday commands (run in `changelogs/` as JMEDS)

| Task | Command |
| --- | --- |
| See what would run | `lb status -changelog-file controller.xml` |
| Apply new changesets | `lb update -changelog-file controller.xml` |
| Undo the last changeset | `lb rollback-count -changelog-file controller.xml -count 1` |
| Preview the SQL | `lb update-sql -changelog-file controller.xml` |

## Rules

1. Never edit a changeset that has run on a shared database. Fix forward with a new changeset.
2. Each changeset has an id (`adetola:<file>-<n>`), a `--comment:` naming the SRS requirement, and a `--rollback`.
3. PL/SQL changesets use `endDelimiter:/` and `runOnChange:true`.
4. Synthetic test data lives in `test-data/`, uses `context:dev,test` and sets `CREATED_BY = 'JM_TEST_DATA'`. Never load real patient data outside production.
5. Wallets and passwords never go in Git (see `.gitignore`).
6. Production always runs `lb update -changelog-file controller.xml -contexts prod`; without a context Liquibase also runs the synthetic data. See [Test Data and Production Migration Register](../docs/qa/test-data-and-migration.md).

## Object summary (Release 1.0)

- 29 tables with the `JM_` prefix; 28 carry the standard audit columns, `JM_AUDIT_LOG` is append-only.
- 6 sequences for business numbers (`JM-YYYY-NNNNNN` formats).
- 42 indexes: foreign keys, work queues, duplicate check, audit reports and the double-booking unique index.
- Triggers: audit columns on every table, visit lock guards, append-only audit log.
- Scheduler job `JM_LOCK_COMPLETED_VISITS`: locks visits 24 hours after completion.
