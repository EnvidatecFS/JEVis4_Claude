#!/bin/bash
# =============================================================================
# JEVis 4 - Deinstallation auf Raspberry Pi OS
#
# Stoppt alle Services und entfernt die JEVis-Installation.
# PostgreSQL und Java werden NICHT deinstalliert.
#
# Verwendung:
#   sudo ./deploy/uninstall-raspi.sh
#
# Optionale Umgebungsvariablen:
#   DROP_DB=true   - Datenbank ebenfalls löschen (ACHTUNG: Datenverlust!)
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()   { echo -e "${GREEN}[UNINSTALL]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARNUNG]${NC} $1"; }

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Bitte als root ausführen: sudo $0${NC}"
    exit 1
fi

echo ""
echo "============================================="
echo "  JEVis 4 - Deinstallation"
echo "============================================="
echo ""

# Services stoppen
log "Stoppe Services..."
systemctl stop jevis-worker 2>/dev/null || true
systemctl stop jevis 2>/dev/null || true
systemctl disable jevis-worker 2>/dev/null || true
systemctl disable jevis 2>/dev/null || true

# Service-Dateien entfernen
log "Entferne Service-Dateien..."
rm -f /etc/systemd/system/jevis.service
rm -f /etc/systemd/system/jevis-worker.service
systemctl daemon-reload

# Konfiguration entfernen
log "Entferne Konfiguration..."
rm -rf /etc/jevis

# Logs entfernen
log "Entferne Logs..."
rm -rf /var/log/jevis

# Benutzer entfernen
if id jevis &>/dev/null; then
    log "Entferne Benutzer 'jevis'..."
    userdel jevis 2>/dev/null || true
fi

# Datenbank löschen (nur wenn explizit gewünscht)
if [ "${DROP_DB:-false}" = "true" ]; then
    warn "Lösche Datenbank 'jevis'..."
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS jevis;" 2>/dev/null || true
    sudo -u postgres psql -c "DROP USER IF EXISTS jevis;" 2>/dev/null || true
    log "Datenbank gelöscht"
else
    warn "Datenbank 'jevis' bleibt erhalten (DROP_DB=true zum Löschen)"
fi

echo ""
log "Deinstallation abgeschlossen."
warn "Das Verzeichnis /opt/jevis wurde NICHT gelöscht (enthält Quellcode)."
echo ""
