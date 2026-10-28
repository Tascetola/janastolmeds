# Install utPLSQL (one-off, as ADMIN)

utPLSQL is the unit-test framework for the PL/SQL API layer (QA gate "PL/SQL API layer" in `CLAUDE.md`). It is installed once per database into its own schema, `UT3`, and is not part of the Liquibase changelog because it is a third-party tool, not JanastolMeds code.

| Item | Value |
| --- | --- |
| Version | **v3.2.3** (released 10 Jul 2026), pinned; upgrade deliberately, not automatically |
| Owner schema | `UT3` |
| Tablespace | `DATA` (Autonomous Database has no `USERS`) |
| Installer | `install_headless.sql` (no DDL trigger, so nothing fires on other CIBSERP schemas' DDL) |
| Run as | `ADMIN` (ADB has no SYSDBA; ADMIN holds the grants the installer needs) |

The headless installer grants utPLSQL to `PUBLIC` and creates public synonyms (`ut`, `ut_runner`, reporters), so any schema on the database can run tests. On the shared CIBSERP database that is harmless: the framework only runs tests in schemas that contain test packages.

## Steps

Run in **your own** PowerShell terminal (the installer needs the ADMIN connection).

```powershell
# 1. Download v3.2.3 and verify the checksum
$dir = "$env:USERPROFILE\Downloads\utplsql-3.2.3"
New-Item -ItemType Directory -Force $dir | Out-Null
$base = "https://github.com/utPLSQL/utPLSQL/releases/download/v.3.2.3"
Invoke-WebRequest "$base/utPLSQL.zip"        -OutFile "$dir\utPLSQL.zip"
Invoke-WebRequest "$base/utPLSQL.zip.sha256" -OutFile "$dir\utPLSQL.zip.sha256"
(Get-FileHash "$dir\utPLSQL.zip" -Algorithm SHA256).Hash.ToLower()
Get-Content "$dir\utPLSQL.zip.sha256"          # the two hashes must match
Expand-Archive "$dir\utPLSQL.zip" -DestinationPath $dir

# 2. Install as ADMIN from the source folder
$env:TNS_ADMIN = "C:\Users\OLUMADE\AppData\Roaming\DBTools\connections\7iEK6pals2eII5Gtk4TFCg"
cd "$dir\utPLSQL\source"
sql -name ADMIN_CIBSERP
```

At the `SQL>` prompt (choose a strong UT3 password, 12–30 characters with upper, lower and a digit; you will rarely need it again, nobody logs in as UT3):

```sql
@install_headless.sql ut3 "<UT3 password>" DATA
exit
```

## Verify

```sql
-- as JMEDS (sql -name JMHMS_JMEDS)
select ut.version() from dual;          -- expect v3.2.3...
exec ut.run();                           -- expect "0 tests, 0 failed" until test packages exist
```

CI picks it up automatically: the "utPLSQL unit tests" step stops skipping once `UT3` exists.

## If something fails

- **ORA-01031 insufficient privileges** on a grant: paste the full output; ADMIN on ADB can grant almost everything, but a missing grant is fixed by granting it explicitly, never by running as another user.
- **Tablespace USERS does not exist**: the third parameter (`DATA`) was left out.
- **`source` folder not found**: the zip's top-level folder name can differ between releases; `cd` into whichever folder contains `install_headless.sql`.
- To remove and reinstall: use the uninstall script in the same `source` folder, as ADMIN (see `docs/userguide/install.md` in the download).
