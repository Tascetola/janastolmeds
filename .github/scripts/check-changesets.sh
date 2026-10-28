#!/usr/bin/env bash
# JanastolMeds: enforce the Liquibase changeset rules in CLAUDE.md before anything reaches the database.
#   - every file is "--liquibase formatted sql"
#   - every changeset id is adetola:<id> and unique across the changelog
#   - every changeset has a --comment: and a --rollback
#   - CREATE OR REPLACE (PL/SQL, views) changesets use runOnChange:true; any changeset with a "/" line uses endDelimiter:/
#   - synthetic data (database/test-data) uses context:dev,test so it never reaches production
#   - comments should name an SRS requirement (FR-/NFR-); missing ones are counted as warnings (VERBOSE=1 lists them)
#     because supporting changesets (FK indexes, audit triggers, lookups) have no single requirement
set -euo pipefail

root="${1:-database}"
mapfile -t files < <(find "$root/changelogs" "$root/seed-data" "$root/packages" "$root/ords" "$root/tests" "$root/test-data" -name '*.sql' 2>/dev/null | sort)

awk -v verbose="${VERBOSE:-0}" '
function finish() {
    if (id == "") return
    if (!has_comment)  { printf "ERROR %s: changeset %s has no --comment:\n", FILENAME_OF_ID, id; errors++ }
    if (!has_rollback) { printf "ERROR %s: changeset %s has no --rollback\n", FILENAME_OF_ID, id; errors++ }
    if (has_cor && header !~ /runOnChange:true/) { printf "ERROR %s: changeset %s creates PL/SQL or a view but lacks runOnChange:true\n", FILENAME_OF_ID, id; errors++ }
    if (has_slash && header !~ /endDelimiter:\//) { printf "ERROR %s: changeset %s uses \"/\" but lacks endDelimiter:/\n", FILENAME_OF_ID, id; errors++ }
    if (FILENAME_OF_ID ~ /\/test-data\// && header !~ /context:dev,test/) { printf "ERROR %s: synthetic-data changeset %s must have context:dev,test\n", FILENAME_OF_ID, id; errors++ }
    if (has_comment && comment !~ /(FR|NFR)-[A-Z]+-[0-9]+/) {
        if (verbose) printf "WARN  %s: changeset %s comment names no requirement ID\n", FILENAME_OF_ID, id
        warnings++
    }
    id = ""
}
FNR == 1 {
    finish()
    if ($0 !~ /^--liquibase formatted sql/) { printf "ERROR %s: first line must be --liquibase formatted sql\n", FILENAME; errors++ }
}
/^--changeset / {
    finish()
    header = $0
    split($2, parts, ":")
    if (parts[1] != "adetola" || parts[2] == "") { printf "ERROR %s: changeset id \"%s\" must be adetola:<id>\n", FILENAME, $2; errors++ }
    id = $2; FILENAME_OF_ID = FILENAME
    if (id in seen) { printf "ERROR %s: changeset id %s already used in %s\n", FILENAME, id, seen[id]; errors++ }
    seen[id] = FILENAME
    has_comment = has_rollback = has_cor = has_slash = 0; comment = ""
    total++
    next
}
id != "" && /^--comment:/           { has_comment = 1; comment = $0 }
id != "" && /^--rollback/           { has_rollback = 1 }
id != "" && toupper($0) ~ /^[[:space:]]*CREATE[[:space:]]+OR[[:space:]]+REPLACE/ { has_cor = 1 }
id != "" && /^\/[[:space:]]*$/      { has_slash = 1 }
END {
    finish()
    printf "%d changesets checked in %d files: %d errors, %d without a requirement ID\n", total, ARGC - 1, errors, warnings
    exit errors > 0
}
' "${files[@]}"
