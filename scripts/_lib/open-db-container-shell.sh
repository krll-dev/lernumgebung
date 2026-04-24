#!/bin/sh

# Shared helper for opening an interactive shell inside a DB container.
# Wrapper scripts set SERVICE_NAME, AUTO_START and REQUIRE_PROFILE_HINT.

set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
LOCAL_SHELL="/bin/zsh"

if [ ! -x "$LOCAL_SHELL" ]; then
  LOCAL_SHELL="/bin/sh"
fi

print_line() {
  printf '%s\n' "$1"
}

print_blank() {
  printf '\n'
}

open_local_shell() {
  print_blank
  print_line "Lokale Shell bleibt offen. Mit 'exit' kannst du das Fenster schliessen."
  exec "$LOCAL_SHELL" -l
}

fail_and_stay_open() {
  print_blank
  print_line "Fehler: $1"
  open_local_shell
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

wait_for_healthy_service() {
  timeout_seconds=90
  waited_seconds=0

  while [ "$waited_seconds" -lt "$timeout_seconds" ]; do
    container_id=$(get_container_id)

    if [ -n "$container_id" ]; then
      status=$(get_health_status "$container_id")

      case "$status" in
        healthy|running)
          return 0
          ;;
        unhealthy)
          print_line "Service '$SERVICE_NAME' wurde als 'unhealthy' markiert."
          return 1
          ;;
      esac
    fi

    sleep 2
    waited_seconds=$((waited_seconds + 2))
  done

  print_line "Service '$SERVICE_NAME' wurde innerhalb von ${timeout_seconds}s nicht bereit."
  return 1
}

if [ -z "${SERVICE_NAME:-}" ]; then
  fail_and_stay_open "SERVICE_NAME ist nicht gesetzt."
fi

AUTO_START=${AUTO_START:-false}
REQUIRE_PROFILE_HINT=${REQUIRE_PROFILE_HINT:-false}

if ! cd "$REPO_ROOT"; then
  fail_and_stay_open "Repository-Ordner konnte nicht geoeffnet werden: $REPO_ROOT"
fi

if ! command -v docker >/dev/null 2>&1; then
  fail_and_stay_open "Docker wurde nicht gefunden. Bitte Docker Desktop bzw. Docker CLI installieren."
fi

if ! docker compose version >/dev/null 2>&1; then
  fail_and_stay_open "Docker Compose ist nicht verfuegbar."
fi

HOST_ARCH=$(uname -m 2>/dev/null || printf 'unknown')
IS_ARM64=false

case "$HOST_ARCH" in
  arm64|aarch64)
    IS_ARM64=true
    ;;
esac

if [ "$SERVICE_NAME" = "mssql" ] && [ "$IS_ARM64" = "true" ]; then
  print_line "Hinweis: MSSQL-Container sind auf diesem Host ($HOST_ARCH) nicht offiziell unterstuetzt."
  print_line "Microsoft dokumentiert MSSQL-Container fuer x86-64 Linux-Hosts."
  print_blank
fi

container_id=$(get_container_id)

if ! is_container_running "$container_id"; then
  if [ "$AUTO_START" = "true" ]; then
    print_line "Starte Docker-Compose-Service '$SERVICE_NAME'..."
    if ! docker compose up -d "$SERVICE_NAME"; then
      fail_and_stay_open "Service '$SERVICE_NAME' konnte nicht gestartet werden."
    fi
    container_id=$(get_container_id)
  else
    print_line "Der Service '$SERVICE_NAME' laeuft aktuell nicht."
    if [ "$REQUIRE_PROFILE_HINT" = "true" ]; then
      print_line "Starte ihn zuerst mit:"
      print_line "  docker compose --profile mssql up -d mssql"
    else
      print_line "Starte ihn zuerst mit:"
      print_line "  docker compose up -d $SERVICE_NAME"
    fi
    open_local_shell
  fi
fi

print_line "Warte auf einen bereiten Container fuer '$SERVICE_NAME'..."
if ! wait_for_healthy_service; then
  fail_and_stay_open "Service '$SERVICE_NAME' ist nicht bereit fuer eine interaktive Shell."
fi

print_blank
print_line "Oeffne jetzt die Container-Shell fuer '$SERVICE_NAME'..."
print_line "Wenn du die Container-Shell mit 'exit' verlaesst, bleibst du in einer lokalen Shell."
print_blank

if ! docker compose exec "$SERVICE_NAME" sh -lc 'if command -v bash >/dev/null 2>&1; then exec bash -l; else exec sh; fi'; then
  fail_and_stay_open "Die interaktive Shell fuer '$SERVICE_NAME' konnte nicht geoeffnet werden."
fi

print_blank
print_line "Die Container-Shell wurde beendet."
open_local_shell
