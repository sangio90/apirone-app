#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Database migration runner
# Runs pending SQL files from resources/db/ddl/ in alphabetical order.
# Each migration is wrapped in a transaction; on success the name is recorded
# in the migrations table.
#
# Connection defaults match docker-compose.yml. Override via env vars:
#   DB_HOST DB_PORT DB_NAME DB_USER DB_PASSWORD
# ---------------------------------------------------------------------------

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-15432}"
DB_NAME="${DB_NAME:-apironedb}"
DB_USER="${DB_USER:-apiruser}"
export PGPASSWORD="${DB_PASSWORD:-apirpassword}"

DDL_DIR="$(cd "$(dirname "$0")" && pwd)/resources/db/ddl"
SETUP_SQL="$(cd "$(dirname "$0")" && pwd)/resources/db/create_migrations_table.sql"

PSQL="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME"

# Ensure migrations table exists (suppress NOTICE if table already exists)
$PSQL -q -c "SET client_min_messages = warning" -f "$SETUP_SQL"

pending=0
applied=0
failed=0

# Use glob (not ls) to avoid word-splitting on filenames with spaces
for filepath in "$DDL_DIR"/*.sql; do
    [ -e "$filepath" ] || continue

    filename="$(basename "$filepath")"
    # Strip .sql and trim any trailing whitespace (guards against filenames like "name .sql")
    migration_name="$(printf '%s' "${filename%.sql}" | sed 's/[[:space:]]*$//')"

    # Check if already applied
    exists=$($PSQL -tAc "SELECT COUNT(1) FROM migrations WHERE name = '$migration_name'")
    if [ "$exists" -gt 0 ]; then
        continue
    fi

    pending=$((pending + 1))
    echo "→ Running: $migration_name"

    # Wrap in a transaction: run migration then record it
    if $PSQL -v ON_ERROR_STOP=1 <<EOF
BEGIN;
\i $filepath
INSERT INTO migrations (name) VALUES ('$migration_name');
COMMIT;
EOF
    then
        echo "  ✓ Applied"
        applied=$((applied + 1))
    else
        echo "  ✗ Failed — rolled back" >&2
        failed=$((failed + 1))
        break
    fi
done

if [ "$pending" -eq 0 ]; then
    echo "Nothing to migrate."
else
    echo ""
    echo "Done: $applied applied, $failed failed."
fi
