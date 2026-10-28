#!/usr/bin/env bash
# JanastolMeds CI: run SQLcl commands read from stdin as JMEDS on the Autonomous Database.
# The password goes in through stdin (never the command line); the step fails on a non-zero exit
# or on any Oracle/SQLcl/Liquibase error text in the output, because some lb errors still exit 0.
#
# Needs: sql on PATH, WALLET_ZIP, DB_SERVICE, JMEDS_PASSWORD.  Usage: run-sql.sh <log-file> <<'SQL' ... SQL
set -uo pipefail

log="${1:?log file}"
{
    printf 'set cloudconfig %s\n' "$WALLET_ZIP"
    printf 'whenever sqlerror exit failure\n'
    printf 'connect jmeds/"%s"@%s\n' "$JMEDS_PASSWORD" "$DB_SERVICE"
    cat
    printf '\nexit\n'
} | sql -S /nolog > "$log" 2>&1
status=$?
cat "$log"

if [ "$status" -ne 0 ]; then
    echo "::error::SQLcl exited with status $status"
    exit 1
fi
if grep -Eq '^(ORA|SP2|PLS)-[0-9]+|Error report|Error starting at line|Connection failed|Validation Failed|Liquibase.*(failed|FAILED)' "$log"; then
    echo "::error::SQLcl reported an error (see log above)"
    exit 1
fi
