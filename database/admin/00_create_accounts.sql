--------------------------------------------------------------------------------
-- JanastolMeds | 00_create_accounts.sql
-- Creates the three database accounts and the application context.
--
-- Run ONCE as ADMIN in SQLcl, before the first Liquibase update:
--     sql admin@<your_adb>_high
--     SQL> @admin/00_create_accounts.sql
--
-- Passwords are prompted for and never stored in Git.
-- Autonomous Database rule: 12-30 characters, with upper case, lower case and a number.
--
--   JMEDS      JanastolMeds owner schema: tables, sequences, packages
--   JMEDS_API  JanastolMeds Application Programming Interface account:
--              parsing schema for APEX and ORDS, EXECUTE on JM_*_API only
--   JMEDS_RO   JanastolMeds Read-Only account: SELECT on masked views only
--------------------------------------------------------------------------------
SET VERIFY OFF
WHENEVER SQLERROR EXIT FAILURE

ACCEPT jmeds_pw CHAR PROMPT 'Password for JMEDS: '     HIDE
ACCEPT api_pw   CHAR PROMPT 'Password for JMEDS_API: ' HIDE
ACCEPT ro_pw    CHAR PROMPT 'Password for JMEDS_RO: '  HIDE

-- Owner schema
CREATE USER jmeds IDENTIFIED BY "&jmeds_pw" QUOTA UNLIMITED ON data;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE,
      CREATE PROCEDURE, CREATE TRIGGER, CREATE TYPE, CREATE JOB
   TO jmeds;
GRANT EXECUTE ON sys.dbms_crypto TO jmeds;   -- password and audit-chain hashing

-- API account: no tables, no quota; gets EXECUTE on packages in a later changeset
CREATE USER jmeds_api IDENTIFIED BY "&api_pw";
GRANT CREATE SESSION, CREATE SYNONYM TO jmeds_api;

-- Read-only reporting account
CREATE USER jmeds_ro IDENTIFIED BY "&ro_pw";
GRANT CREATE SESSION, CREATE SYNONYM TO jmeds_ro;

-- Application context: only JMEDS.JM_CTX_API (created in the packages phase) can set it
CREATE OR REPLACE CONTEXT jm_ctx USING jmeds.jm_ctx_api;

UNDEFINE jmeds_pw
UNDEFINE api_pw
UNDEFINE ro_pw

PROMPT Accounts JMEDS, JMEDS_API, JMEDS_RO and context JM_CTX created.
PROMPT Next: connect as JMEDS and run Liquibase (see database/README.md).
