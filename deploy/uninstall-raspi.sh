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
# Fragt interaktiv ob die Datenbank gelöscht werden soll.
# Für nicht-interaktive Nutzung: DROP_DB=true sudo ./deploy/uninstall-raspi.sh
# =============================================================================

set -eu

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

# Datenbank löschen
if [ "${DROP_DB:-}" = "true" ]; then
    # Non-interaktiv via Umgebungsvariable
    DROP_CONFIRMED=true
else
    echo ""
    echo -e "${YELLOW}Soll die PostgreSQL-Datenbank 'jevis' ebenfalls gelöscht werden?${NC}"
    echo -e "${RED}ACHTUNG: Alle Messdaten gehen dabei unwiderruflich verloren!${NC}"
    printf "Datenbank löschen? [j/N]: "
    read -r ANSWER
    case "$ANSWER" in
        j|J|ja|Ja|JA) DROP_CONFIRMED=true ;;
        *) DROP_CONFIRMED=false ;;
    esac
fi

if [ "$DROP_CONFIRMED" = "true" ]; then
    warn "Lösche Datenbank 'jevis'..."
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS jevis;" 2>/dev/null || true
    sudo -u postgres psql -c "DROP USER IF EXISTS jevis;" 2>/dev/null || true
    log "Datenbank gelöscht"
else
    log "Datenbank 'jevis' bleibt erhalten"
fi

echo ""
log "Deinstallation abgeschlossen."
warn "Das Verzeichnis /opt/jevis wurde NICHT gelöscht (enthält Quellcode)."
echo ""
