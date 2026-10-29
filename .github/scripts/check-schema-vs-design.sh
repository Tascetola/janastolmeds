#!/usr/bin/env bash
# JanastolMeds: compare the live JMEDS columns with the JM-DOC-03 data dictionary (section 4).
# Input: a file of TABLE|COLUMN|TYPE|NULL lines produced by database/qa/schema_columns.sql.
# Output: every column that is missing, extra, or differs in type or nullability; exit 1 if any.
# The standard audit and soft-delete columns are excluded on both sides (JM-DOC-03 section 1 covers them).
set -euo pipefail

db_file="${1:?usage: check-schema-vs-design.sh <db-columns-file> [design-doc]}"
doc="${2:-docs/03-database-design.md}"
tmp="$(mktemp -d)"

# Design side: rows of the "**JM_TABLE**" markdown tables in section 4, until section 5 starts.
awk -F'|' '
/^## 5\./ { exit }
/^\*\*JM_[A-Z0-9_]+\*\*/ { match($0, /JM_[A-Z0-9_]+/); tbl = substr($0, RSTART, RLENGTH); next }
tbl != "" && /^\|/ {
    col = $2; type = $3; nul = $4
    gsub(/^[ \t]+|[ \t]+$/, "", col); gsub(/^[ \t]+|[ \t]+$/, "", type); gsub(/^[ \t]+|[ \t]+$/, "", nul)
    gsub(/\\/, "", col); gsub(/\\/, "", type)
    if (col !~ /^[A-Z][A-Z0-9_]*$/ || col == "Column") next
    print tbl "|" col "|" type "|" nul
}' "$doc" | sort -u > "$tmp/design"

# Database side: normalise whitespace and Windows line endings, drop blank lines.
tr -d '\r' < "$db_file" | sed -E 's/[[:space:]]+$//' | grep -E '^JM_[A-Z0-9_]+\|' | sort -u > "$tmp/db"

missing=$(comm -23 <(cut -d'|' -f1,2 "$tmp/design" | sort -u) <(cut -d'|' -f1,2 "$tmp/db" | sort -u) || true)
extra=$(comm -13 <(cut -d'|' -f1,2 "$tmp/design" | sort -u) <(cut -d'|' -f1,2 "$tmp/db" | sort -u) || true)
differs=$(join -t'|' <(awk -F'|' '{print $1"."$2"|"$3"|"$4}' "$tmp/design" | sort) \
                     <(awk -F'|' '{print $1"."$2"|"$3"|"$4}' "$tmp/db" | sort) \
          | awk -F'|' '$2 != $4 || $3 != $5 { printf "%s: design %s %s, database %s %s\n", $1, $2, ($3=="N"?"NOT NULL":"NULL"), $4, ($5=="N"?"NOT NULL":"NULL") }')

problems=0
report() { if [ -n "$2" ]; then echo "$1"; echo "$2" | sed 's/^/  /'; problems=$((problems + $(echo "$2" | wc -l))); fi; }
report "In JM-DOC-03 but not in the database:" "$missing"
report "In the database but not in JM-DOC-03:" "$extra"
report "Type or nullability differs:" "$differs"

echo "Design columns: $(wc -l < "$tmp/design") in $(cut -d'|' -f1 "$tmp/design" | sort -u | wc -l) tables; database columns: $(wc -l < "$tmp/db") in $(cut -d'|' -f1 "$tmp/db" | sort -u | wc -l) tables; differences: $problems"
rm -rf "$tmp"
[ "$problems" -eq 0 ]
