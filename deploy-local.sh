#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-4173}"
PID_FILE=".netizen-local.pid"
LOG_FILE=".netizen-local.log"

usage() {
  cat <<USAGE
Usage:
  ./deploy-local.sh start [port]
  ./deploy-local.sh stop
  ./deploy-local.sh status
  ./deploy-local.sh logs

Examples:
  ./deploy-local.sh start
  ./deploy-local.sh start 8080
USAGE
}

is_running() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid="$(cat "$PID_FILE")"
    if ps -p "$pid" >/dev/null 2>&1; then
      return 0
    fi
  fi
  return 1
}

start_server() {
  local port="${1:-$PORT}"

  if ! command -v python >/dev/null 2>&1; then
    echo "Error: python is required to run the local server."
    exit 1
  fi

  if is_running; then
    echo "Server is already running (PID $(cat "$PID_FILE"))."
    echo "URL: http://127.0.0.1:${port}"
    exit 0
  fi

  nohup python -m http.server "$port" >"$LOG_FILE" 2>&1 &
  local pid=$!
  echo "$pid" >"$PID_FILE"

  sleep 0.2
  if ps -p "$pid" >/dev/null 2>&1; then
    echo "Netizen Watch deployed locally."
    echo "PID: $pid"
    echo "URL: http://127.0.0.1:${port}"
    echo "Logs: $LOG_FILE"
  else
    echo "Failed to start local server. Check $LOG_FILE"
    rm -f "$PID_FILE"
    exit 1
  fi
}

stop_server() {
  if ! is_running; then
    echo "Server is not running."
    rm -f "$PID_FILE"
    exit 0
  fi

  local pid
  pid="$(cat "$PID_FILE")"
  kill "$pid"
  rm -f "$PID_FILE"
  echo "Stopped local server (PID $pid)."
}

status_server() {
  if is_running; then
    local pid
    pid="$(cat "$PID_FILE")"
    echo "Server is running (PID $pid)."
  else
    echo "Server is not running."
  fi
}

show_logs() {
  if [[ -f "$LOG_FILE" ]]; then
    tail -n 30 "$LOG_FILE"
  else
    echo "No logs found yet."
  fi
}

COMMAND="${1:-start}"
case "$COMMAND" in
  start)
    start_server "${2:-$PORT}"
    ;;
  stop)
    stop_server
    ;;
  status)
    status_server
    ;;
  logs)
    show_logs
    ;;
  *)
    usage
    exit 1
    ;;
esac
