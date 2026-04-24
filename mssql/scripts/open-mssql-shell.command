#!/bin/zsh

# Doppelklick in Finder oder `open ...` oeffnet ein neues Terminal-Fenster.
# Dieses Skript ist fuer den MSSQL-Datenbank-Container, nicht fuer CloudBeaver.

set -u

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)"

export SERVICE_NAME="mssql"
export AUTO_START="false"
export REQUIRE_PROFILE_HINT="true"

exec "$REPO_ROOT/scripts/_lib/open-db-container-shell.sh"
