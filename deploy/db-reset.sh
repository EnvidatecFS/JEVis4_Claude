#!/bin/bash
# =============================================================================
# db-reset.sh - Entwicklungswerkzeug: Datenbank zurücksetzen
#
# Löscht das komplette Schema und lässt Flyway beim nächsten App-Start
# alle Migrationen neu ausführen. Demo-Daten werden von DataInitializer.java
# beim Start automatisch neu angelegt.
#
# WARNUNG: Alle Daten gehen verloren! Nur für Entwicklung verwenden.
#
# Verwendung:
#   chmod +x deploy/db-reset.sh
#   ./deploy/db-reset.sh
#
# Optionale Umgebungsvariablen:
#   DB_NAME=jevis       - Datenbankname (Default: jevis)
#   DB_USER=jevis       - Datenbankbenutzer (Default: jevis)
#   DB_PASSWORD=...     - Passwort (Default: jevis2025)
#   PGHOST=localhost    - PostgreSQL-Host (Default: localhost)
#   PGPORT=5432         - PostgreSQL-Port (Default: 5432)
# =============================================================================

set -eu

DB_NAME="${DB_NAME:-jevis}"
DB_USER="${DB_USER:-jevis}"
DB_PASSWORD="${DB_PASSWORD:-jevis2025}"
PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()   { echo -e "${GREEN}[DB-RESET]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARNUNG]${NC} $1"; }
error() { echo -e "${RED}[FEHLER]${NC} $1"; exit 1; }

# --- Sicherheitsabfrage ------------------------------------------------------

echo ""
echo -e "${RED}============================================================${NC}"
echo -e "${RED}  WARNUNG: Alle Daten in '${DB_NAME}' werden gelöscht!${NC}"
echo -e "${RED}============================================================${NC}"
echo ""
echo "  Host:     ${PGHOST}:${PGPORT}"
echo "  Datenbank: ${DB_NAME}"
echo "  Benutzer:  ${DB_USER}"
echo ""
read -r -p "Wirklich fortfahren? [j/N] " CONFIRM
if [[ ! "$CONFIRM" =~ ^[jJyY]$ ]]; then
    echo "Abgebrochen."
    exit 0
fi

# --- Schema löschen und neu erstellen ----------------------------------------

log "Verbinde mit PostgreSQL..."

export PGPASSWORD="$DB_PASSWORD"

psql -h "$PGHOST" -p "$PGPORT" -U "$DB_USER" -d "$DB_NAME" << 'SQL'
-- Alle Verbindungen zur DB trennen (außer der eigenen)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = current_database()
  AND pid <> pg_backend_pid();

-- Schema löschen und neu erstellen (entfernt alle Tabellen, Sequenzen, Views)
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO PUBLIC;
SQL

log "Schema wurde zurückgesetzt."

# --- Flyway-History löschen (falls noch vorhanden) ---------------------------
# Nach DROP SCHEMA CASCADE ist flyway_schema_history automatisch weg.
# Dieser Block ist nur zur Dokumentation - nichts zu tun.

log "Flyway-Migrationshistorie wurde ebenfalls entfernt."

# --- Fertig ------------------------------------------------------------------

echo ""
echo "============================================="
echo "  Datenbank zurückgesetzt!"
echo "============================================="
echo ""
echo "  Nächste Schritte:"
echo "  1. Starte die Anwendung neu:"
echo "     sudo systemctl restart jevis"
echo "     # oder im Entwicklungsmodus:"
echo "     mvn spring-boot:run"
echo ""
echo "  Flyway führt V1__initial_schema.sql automatisch aus."
echo "  DataInitializer.java legt Demo-Daten neu an."
echo ""
