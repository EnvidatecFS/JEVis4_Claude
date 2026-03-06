#!/bin/bash
# =============================================================================
# JEVis 4 Worker - Polling-basierter Job-Worker
#
# Registriert sich am JEVis-System, pollt regelmässig nach verfügbaren Jobs
# und meldet Ergebnisse zurück. Sendet periodisch Heartbeats.
#
# Installation:
#   chmod +x /opt/jevis/deploy/worker.sh
#   sudo cp deploy/jevis-worker.service /etc/systemd/system/
#   sudo systemctl daemon-reload
#   sudo systemctl enable jevis-worker
#   sudo systemctl start jevis-worker
# =============================================================================

set -euo pipefail

# Konfiguration - bei Bedarf anpassen
JEVIS_URL="${JEVIS_URL:-http://localhost:8080}"
POOL_NAME="${POOL_NAME:-data-fetch-pool}"
WORKER_NAME="${WORKER_NAME:-worker-$(hostname)}"
CAPABILITIES="${CAPABILITIES:-DATA_FETCH}"
MAX_CONCURRENT="${MAX_CONCURRENT:-2}"
POLL_INTERVAL="${POLL_INTERVAL:-5}"          # Sekunden zwischen Polls
HEARTBEAT_INTERVAL="${HEARTBEAT_INTERVAL:-60}" # Sekunden zwischen Heartbeats

WORKER_ID=""
API_KEY=""

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Worker am System registrieren
register() {
  log "Registriere Worker '$WORKER_NAME' am Pool '$POOL_NAME'..."

  local IP_ADDR
  IP_ADDR=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "unknown")

  local RESPONSE
  RESPONSE=$(curl -s -f -X POST "$JEVIS_URL/api/workers/register" \
    -H "Content-Type: application/json" \
    -d "{
      \"workerName\": \"$WORKER_NAME\",
      \"poolName\": \"$POOL_NAME\",
      \"capabilities\": \"$CAPABILITIES\",
      \"hostName\": \"$(hostname)\",
      \"ipAddress\": \"$IP_ADDR\",
      \"maxConcurrentJobs\": $MAX_CONCURRENT
    }")

  WORKER_ID=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['workerId'])")
  API_KEY=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['apiKey'])")

  log "Worker registriert: ID=$WORKER_ID"
}

# Heartbeat senden
heartbeat() {
  curl -s -f -X POST "$JEVIS_URL/api/workers/$WORKER_ID/heartbeat" \
    -H "X-Worker-Api-Key: $API_KEY" > /dev/null 2>&1 \
    && log "Heartbeat gesendet" \
    || log "WARNUNG: Heartbeat fehlgeschlagen"
}

# Nächsten Job abholen und verarbeiten
poll_and_process() {
  local HTTP_CODE BODY RESPONSE

  RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$JEVIS_URL/api/workers/$WORKER_ID/poll" \
    -H "X-Worker-Api-Key: $API_KEY")

  HTTP_CODE=$(echo "$RESPONSE" | tail -1)
  BODY=$(echo "$RESPONSE" | sed '$d')

  # 204 = kein Job verfügbar
  if [ "$HTTP_CODE" = "204" ]; then
    return 1
  fi

  if [ "$HTTP_CODE" != "200" ]; then
    log "WARNUNG: Poll fehlgeschlagen (HTTP $HTTP_CODE)"
    return 1
  fi

  local JOB_ID EXEC_ID JOB_TYPE PARAMS
  JOB_ID=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['jobId'])")
  EXEC_ID=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['executionId'])")
  JOB_TYPE=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['jobType'])")
  PARAMS=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('jobParameters','{}'))")

  log "Job erhalten: ID=$JOB_ID, Typ=$JOB_TYPE, Parameter=$PARAMS"

  # Fortschritt melden
  curl -s -X POST "$JEVIS_URL/api/workers/$WORKER_ID/jobs/$JOB_ID/progress" \
    -H "Content-Type: application/json" \
    -H "X-Worker-Api-Key: $API_KEY" \
    -d "{\"executionId\": $EXEC_ID, \"progressPercent\": 50, \"progressMessage\": \"Verarbeite...\"}" \
    > /dev/null 2>&1

  # =========================================================================
  # HIER DIE EIGENTLICHE JOB-VERARBEITUNG EINFÜGEN
  #
  # Beispiel für DATA_FETCH:
  #   - Parameter auslesen (deviceId, scope, etc.)
  #   - Externe API aufrufen
  #   - Daten in die Datenbank importieren
  #
  # Die Variable $PARAMS enthält die Job-Parameter als JSON-String.
  # Die Variable $JOB_TYPE enthält den Job-Typ (DATA_FETCH, CALCULATION, etc.)
  # =========================================================================

  # Job als erledigt melden
  curl -s -f -X POST "$JEVIS_URL/api/workers/$WORKER_ID/jobs/$JOB_ID/complete" \
    -H "Content-Type: application/json" \
    -H "X-Worker-Api-Key: $API_KEY" \
    -d "{\"executionId\": $EXEC_ID, \"result\": \"Erfolgreich verarbeitet\"}" \
    > /dev/null 2>&1

  log "Job $JOB_ID abgeschlossen"
  return 0
}

# Aufräumen bei Beendigung
cleanup() {
  log "Worker wird beendet..."
  if [ -n "$WORKER_ID" ] && [ -n "$API_KEY" ]; then
    curl -s -X POST "$JEVIS_URL/api/workers/$WORKER_ID/deregister" \
      -H "X-Worker-Api-Key: $API_KEY" > /dev/null 2>&1
    log "Worker abgemeldet"
  fi
  exit 0
}

trap cleanup SIGTERM SIGINT

# =============================================================================
# Hauptprogramm
# =============================================================================

# Warte bis JEVis erreichbar ist
log "Warte auf JEVis unter $JEVIS_URL ..."
until curl -s -f "$JEVIS_URL/login" > /dev/null 2>&1; do
  sleep 5
done
log "JEVis erreichbar"

# Registrierung (mit Retry)
until register; do
  log "Registrierung fehlgeschlagen, neuer Versuch in 10s..."
  sleep 10
done

# Worker-Loop
SECONDS_SINCE_HEARTBEAT=0

while true; do
  if poll_and_process; then
    # Job verarbeitet - sofort weiter pollen
    SECONDS_SINCE_HEARTBEAT=$((SECONDS_SINCE_HEARTBEAT + 1))
  else
    # Kein Job - warten
    sleep "$POLL_INTERVAL"
    SECONDS_SINCE_HEARTBEAT=$((SECONDS_SINCE_HEARTBEAT + POLL_INTERVAL))
  fi

  # Periodisch Heartbeat senden
  if [ "$SECONDS_SINCE_HEARTBEAT" -ge "$HEARTBEAT_INTERVAL" ]; then
    heartbeat
    SECONDS_SINCE_HEARTBEAT=0
  fi
done
