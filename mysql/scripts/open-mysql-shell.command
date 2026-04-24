#!/bin/zsh

# Doppelklick in Finder oder `open ...` oeffnet ein neues Terminal-Fenster.
# Dieses Skript ist fuer den MySQL-Datenbank-Container.

set -u

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)"

export SERVICE_NAME="mysql"
export AUTO_START="true"

exec "$REPO_ROOT/scripts/_lib/open-db-container-shell.sh"
