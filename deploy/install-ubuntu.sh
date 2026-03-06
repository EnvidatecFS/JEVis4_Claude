#!/bin/bash
# =============================================================================
# JEVis 4 - Automatische Installation auf Ubuntu 22.04/24.04 und WSL2
#
# Dieses Skript installiert und konfiguriert:
#   - Java 17 (OpenJDK)
#   - PostgreSQL
#   - JEVis 4 Anwendung als Systemd-Service
#   - Worker als Systemd-Service
#
# Verwendung:
#   chmod +x deploy/install-ubuntu.sh
#   sudo ./deploy/install-ubuntu.sh
#
# Optionale Umgebungsvariablen:
#   DB_PASSWORD=meinPasswort   - PostgreSQL-Passwort (Default: jevis2025)
#   JAVA_XMX=4g               - Max. Java Heap (Default: automatisch nach RAM)
#   SKIP_DB=true               - PostgreSQL-Setup überspringen
#   SKIP_BUILD=true            - Maven-Build überspringen
#
# WSL2-Voraussetzung (einmalig, als Administrator in PowerShell):
#   Füge folgendes in /etc/wsl.conf ein, dann: wsl --shutdown
#   [boot]
#   systemd=true
# =============================================================================

set -eu

# --- Konfiguration -----------------------------------------------------------

DB_NAME="jevis"
DB_USER="jevis"
DB_PASSWORD="${DB_PASSWORD:-jevis2025}"
INSTALL_DIR="/opt/jevis"
CONFIG_DIR="/etc/jevis"
LOG_DIR="/var/log/jevis"
SERVICE_USER="jevis"

# Source directory: the repository root (parent of deploy/ where this script lives).
# Works regardless of where the repo is cloned (e.g. /root/..., /home/..., /opt/...).
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SOURCE_DIR=$(dirname "$SCRIPT_DIR")

# Java Heap nach RAM bestimmen (Ubuntu/Server hat typisch mehr RAM als Pi)
TOTAL_RAM_MB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
if [ "$TOTAL_RAM_MB" -le 2048 ]; then
    JAVA_XMS="${JAVA_XMS:-256m}"
    JAVA_XMX="${JAVA_XMX:-1g}"
elif [ "$TOTAL_RAM_MB" -le 8192 ]; then
    JAVA_XMS="${JAVA_XMS:-512m}"
    JAVA_XMX="${JAVA_XMX:-2g}"
elif [ "$TOTAL_RAM_MB" -le 16384 ]; then
    JAVA_XMS="${JAVA_XMS:-1g}"
    JAVA_XMX="${JAVA_XMX:-4g}"
else
    JAVA_XMS="${JAVA_XMS:-2g}"
    JAVA_XMX="${JAVA_XMX:-8g}"
fi

# --- Hilfsfunktionen ---------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()   { echo -e "${GREEN}[INSTALL]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARNUNG]${NC} $1"; }
error() { echo -e "${RED}[FEHLER]${NC} $1"; exit 1; }

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "Dieses Skript muss als root ausgeführt werden: sudo $0"
    fi
}

# --- WSL2 Systemd-Prüfung ----------------------------------------------------

check_systemd() {
    if ! systemctl is-system-running --quiet 2>/dev/null; then
        # Prüfen ob wir in WSL ohne Systemd sind
        if grep -qi microsoft /proc/version 2>/dev/null; then
            echo ""
            echo -e "${RED}============================================================${NC}"
            echo -e "${RED}  FEHLER: Systemd ist in WSL nicht aktiv!${NC}"
            echo -e "${RED}============================================================${NC}"
            echo ""
            echo "  WSL2 benötigt Systemd für den JEVis-Service."
            echo "  Aktiviere Systemd einmalig so:"
            echo ""
            echo "  1. Öffne /etc/wsl.conf in WSL als root:"
            echo "     sudo nano /etc/wsl.conf"
            echo ""
            echo "  2. Füge folgendes ein:"
            echo "     [boot]"
            echo "     systemd=true"
            echo ""
            echo "  3. Starte WSL neu (in PowerShell):"
            echo "     wsl --shutdown"
            echo "     wsl"
            echo ""
            echo "  4. Führe dieses Skript erneut aus."
            echo ""
            exit 1
        fi
        # Nicht-WSL-System: Warnung, aber weitermachen (z.B. systemd in init-Phase)
        warn "Systemd meldet nicht 'running' - Services werden ggf. nicht gestartet"
    fi
}

# --- Systeminfo --------------------------------------------------------------

print_system_info() {
    local IS_WSL=""
    grep -qi microsoft /proc/version 2>/dev/null && IS_WSL=" (WSL2)"

    echo ""
    echo "============================================="
    echo "  JEVis 4 - Ubuntu${IS_WSL} Installation"
    echo "============================================="
    echo ""
    log "System: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')${IS_WSL}"
    log "Architektur: $(uname -m)"
    log "RAM: ${TOTAL_RAM_MB} MB"
    log "Java Heap: ${JAVA_XMS} - ${JAVA_XMX}"
    log "Installationsverzeichnis: ${INSTALL_DIR}"
    echo ""
}

# --- Pakete installieren -----------------------------------------------------

install_packages() {
    log "Aktualisiere Paketlisten..."
    apt-get update -qq

    log "Installiere Abhängigkeiten..."
    apt-get install -y -qq \
        openjdk-17-jdk-headless \
        postgresql \
        maven \
        curl \
        git \
        > /dev/null 2>&1

    log "Java-Version: $(java -version 2>&1 | head -1)"
    log "PostgreSQL-Version: $(psql --version)"
}

# --- PostgreSQL einrichten ---------------------------------------------------

setup_database() {
    if [ "${SKIP_DB:-false}" = "true" ]; then
        warn "Datenbank-Setup übersprungen (SKIP_DB=true)"
        return
    fi

    log "Konfiguriere PostgreSQL..."

    systemctl enable postgresql
    systemctl start postgresql

    # Prüfen ob Datenbank bereits existiert
    if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
        warn "Datenbank '$DB_NAME' existiert bereits, überspringe Erstellung"
    else
        log "Erstelle Datenbank und Benutzer..."
        sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';" 2>/dev/null || true
        sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
        sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
        sudo -u postgres psql -d "$DB_NAME" -c "GRANT ALL ON SCHEMA public TO $DB_USER;"
        log "Datenbank '$DB_NAME' erstellt"
    fi
}

# --- Systembenutzer anlegen --------------------------------------------------

setup_user() {
    if id -u "$SERVICE_USER" >/dev/null 2>&1; then
        warn "Benutzer '$SERVICE_USER' existiert bereits"
    else
        log "Erstelle Systembenutzer '$SERVICE_USER'..."
        if getent group "$SERVICE_USER" >/dev/null 2>&1; then
            useradd -r -m -s /bin/false -g "$SERVICE_USER" "$SERVICE_USER"
        else
            useradd -r -m -s /bin/false "$SERVICE_USER"
        fi
    fi

    if ! id -u "$SERVICE_USER" >/dev/null 2>&1; then
        error "Benutzer '$SERVICE_USER' konnte nicht angelegt werden"
    fi

    local JEVIS_HOME
    JEVIS_HOME=$(eval echo "~$SERVICE_USER")
    mkdir -p "$JEVIS_HOME/.m2"
    chown -R "$SERVICE_USER:$SERVICE_USER" "$JEVIS_HOME/.m2"

    mkdir -p "$LOG_DIR"
    chown "$SERVICE_USER:$SERVICE_USER" "$LOG_DIR"
}

# --- Anwendung bauen --------------------------------------------------------

build_application() {
    if [ "${SKIP_BUILD:-false}" = "true" ]; then
        warn "Build übersprungen (SKIP_BUILD=true)"
        return
    fi

    if [ ! -f "$SOURCE_DIR/pom.xml" ]; then
        error "pom.xml nicht gefunden in $SOURCE_DIR."
    fi

    log "Baue JEVis 4 aus $SOURCE_DIR ..."
    cd "$SOURCE_DIR"
    # Build as root; jevis user may not have read access to the source tree
    mvn clean package -DskipTests -q

    local JAR="$SOURCE_DIR/target/JEVis4_Claude-1.0-SNAPSHOT.jar"
    if [ ! -f "$JAR" ]; then
        error "Build fehlgeschlagen - JAR-Datei nicht gefunden"
    fi

    # Copy built artifacts to INSTALL_DIR so the jevis user can access them
    log "Kopiere JAR, Templates und Deploy-Skripte nach $INSTALL_DIR ..."
    # Replace symlink with real directory if needed
    if [ -L "$INSTALL_DIR" ]; then
        rm "$INSTALL_DIR"
    fi
    mkdir -p "$INSTALL_DIR/target"
    cp "$JAR" "$INSTALL_DIR/target/"
    cp -r "$SOURCE_DIR/deploy" "$INSTALL_DIR/"
    # JTE development mode looks for templates at src/main/jte/ relative to WorkingDirectory
    mkdir -p "$INSTALL_DIR/src/main"
    cp -r "$SOURCE_DIR/src/main/jte" "$INSTALL_DIR/src/main/"
    chown -R "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR"

    if [ ! -f "$INSTALL_DIR/target/JEVis4_Claude-1.0-SNAPSHOT.jar" ]; then
        error "Build fehlgeschlagen - JAR-Datei nicht gefunden"
    fi

    log "Build erfolgreich"
}

# --- Konfiguration erstellen ------------------------------------------------

create_config() {
    mkdir -p "$CONFIG_DIR"

    if [ -f "$CONFIG_DIR/application.properties" ]; then
        warn "Konfiguration existiert bereits, überspringe ($CONFIG_DIR/application.properties)"
        return
    fi

    log "Erstelle Produktions-Konfiguration..."

    cat > "$CONFIG_DIR/application.properties" << EOF
# =============================================================================
# JEVis 4 - Produktions-Konfiguration (Ubuntu/WSL2)
# Generiert am $(date '+%Y-%m-%d %H:%M:%S')
# =============================================================================

# Server
server.port=8080

# PostgreSQL Datenbank
spring.datasource.url=jdbc:postgresql://localhost:5432/${DB_NAME}
spring.datasource.username=${DB_USER}
spring.datasource.password=${DB_PASSWORD}
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# Schema-Verwaltung via Flyway
spring.jpa.hibernate.ddl-auto=validate
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=true
spring.jpa.show-sql=false
spring.jpa.defer-datasource-initialization=false
spring.sql.init.mode=never

# H2 deaktivieren
spring.h2.console.enabled=false

# JTE Templates - use precompiled templates bundled in the JAR
gg.jte.developmentMode=false
gg.jte.usePrecompiledTemplates=true

# Quartz Scheduler
spring.quartz.job-store-type=jdbc
spring.quartz.jdbc.initialize-schema=always
spring.quartz.properties.org.quartz.jobStore.driverDelegateClass=org.quartz.impl.jdbcjobstore.PostgreSQLDelegate
spring.quartz.properties.org.quartz.threadPool.threadCount=5

# Job System
jevis.jobs.heartbeat-timeout-minutes=5
jevis.jobs.timeout-check-interval-seconds=30
jevis.jobs.retry-check-interval-seconds=60

# Logging
logging.level.org.jevis=INFO
logging.level.org.hibernate.SQL=WARN
logging.file.name=${LOG_DIR}/application.log
EOF

    chown -R root:"$SERVICE_USER" "$CONFIG_DIR"
    chmod 640 "$CONFIG_DIR/application.properties"

    log "Konfiguration erstellt: $CONFIG_DIR/application.properties"
}

# --- Systemd-Services installieren -------------------------------------------

install_services() {
    log "Installiere Systemd-Services..."

    sed "s/-Xms512m -Xmx2g/-Xms${JAVA_XMS} -Xmx${JAVA_XMX}/" \
        "$INSTALL_DIR/deploy/jevis.service" \
        > /etc/systemd/system/jevis.service

    cp "$INSTALL_DIR/deploy/jevis-worker.service" /etc/systemd/system/
    chmod +x "$INSTALL_DIR/deploy/worker.sh"
    chown -R "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR"

    systemctl daemon-reload
    systemctl enable jevis
    systemctl enable jevis-worker

    log "Services installiert und aktiviert"
}

# --- Erster Start ------------------------------------------------------------

first_start() {
    log "Starte JEVis 4 (Flyway migriert das Schema automatisch)..."
    systemctl start jevis

    log "Warte auf Anwendungsstart (kann 30-60 Sekunden dauern)..."
    local ATTEMPTS=0
    local MAX_ATTEMPTS=60
    until curl -s -f http://localhost:8080/login > /dev/null 2>&1; do
        ATTEMPTS=$((ATTEMPTS + 1))
        if [ "$ATTEMPTS" -ge "$MAX_ATTEMPTS" ]; then
            warn "Anwendung nicht innerhalb von ${MAX_ATTEMPTS}s erreichbar"
            warn "Prüfe Logs mit: sudo journalctl -u jevis -n 50"
            return 1
        fi
        sleep 2
    done

    log "Anwendung läuft!"

    log "Starte Worker..."
    systemctl start jevis-worker

    return 0
}

# --- Zusammenfassung ---------------------------------------------------------

print_summary() {
    local IP_ADDR
    IP_ADDR=$(hostname -I | awk '{print $1}')

    echo ""
    echo "============================================="
    echo "  Installation abgeschlossen!"
    echo "============================================="
    echo ""
    echo "  Web-Oberfläche:  http://${IP_ADDR}:8080"
    echo "  Login:           admin / admin"
    echo ""
    echo "  Services:"
    echo "    sudo systemctl status jevis"
    echo "    sudo systemctl status jevis-worker"
    echo ""
    echo "  Logs:"
    echo "    sudo journalctl -u jevis -f"
    echo "    sudo journalctl -u jevis-worker -f"
    echo ""
    echo "  Datenbank:"
    echo "    sudo -u postgres psql ${DB_NAME}"
    echo ""
    echo "  Konfiguration:"
    echo "    ${CONFIG_DIR}/application.properties"
    echo ""
    echo "  Schema zurücksetzen (Entwicklung):"
    echo "    sudo ${INSTALL_DIR}/deploy/db-reset.sh"
    echo ""
    echo "============================================="
    echo ""
}

# --- Hauptprogramm -----------------------------------------------------------

check_root
check_systemd
print_system_info
install_packages
setup_database
setup_user
create_config
build_application
install_services
first_start && print_summary
