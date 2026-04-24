#!/bin/sh

# Linux-Mint-taugliches Skript fuer genau den MySQL-Container.
# Startet den Compose-Service bei Bedarf und oeffnet danach eine Shell im Container.

set -u

SERVICE_NAME="mysql"
WAIT_SECONDS=90

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)

print_line() {
  printf '%s\n' "$1"
}

fail() {
  print_line ""
  print_line "Fehler: $1"
  exit 1
}

get_container_id() {
  docker compose ps -q "$SERVICE_NAME" 2>/dev/null || true
}

is_container_running() {
  container_id=$1

  if [ -z "$container_id" ]; then
    return 1
  fi

  running=$(docker inspect -f '{{.State.Running}}' "$container_id" 2>/dev/null || printf 'false')
  [ "$running" = "true" ]
}

get_health_status() {
  container_id=$1
  docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$container_id" 2>/dev/null || printf 'missing'
}

wait_for_mysql() {
  waited_seconds=0

  while [ "$waited_seconds" -lt "$WAIT_SECONDS" ]; do
    container_id=$(get_container_id)

    if [ -n "$container_id" ]; then
      status=$(get_health_status "$container_id")

      case "$status" in
        healthy|running)
          return 0
          ;;
        unhealthy)
          print_line "Der MySQL-Container wurde als 'unhealthy' markiert."
          return 1
          ;;
      esac
    fi

    sleep 2
    waited_seconds=$((waited_seconds + 2))
  done

  print_line "Der MySQL-Container wurde innerhalb von ${WAIT_SECONDS}s nicht bereit."
  return 1
}

if ! cd "$REPO_ROOT"; then
  fail "Repository-Ordner konnte nicht geoeffnet werden: $REPO_ROOT"
fi

if ! command -v docker >/dev/null 2>&1; then
  fail "Docker wurde nicht gefunden. Bitte Docker Engine installieren."
fi

if ! docker compose version >/dev/null 2>&1; then
  fail "Docker Compose ist nicht verfuegbar."
fi

container_id=$(get_container_id)

if ! is_container_running "$container_id"; then
  print_line "Starte Docker-Compose-Service '$SERVICE_NAME'..."
  if ! docker compose up -d "$SERVICE_NAME"; then
    fail "Service '$SERVICE_NAME' konnte nicht gestartet werden."
  fi
fi

print_line "Warte auf einen bereiten MySQL-Container..."
if ! wait_for_mysql; then
  fail "MySQL ist nicht bereit fuer eine interaktive Shell."
fi

print_line ""
print_line "Oeffne Container-Shell fuer '$SERVICE_NAME'. Mit 'exit' kommst du wieder heraus."
print_line ""

docker compose exec "$SERVICE_NAME" sh -lc 'if command -v bash >/dev/null 2>&1; then exec bash -l; else exec sh; fi'
