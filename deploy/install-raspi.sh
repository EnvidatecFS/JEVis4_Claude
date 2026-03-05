#!/bin/bash
# =============================================================================
# JEVis 4 - Automatische Installation auf Raspberry Pi OS
#
# Dieses Skript installiert und konfiguriert:
#   - Java 17 (OpenJDK)
#   - PostgreSQL
#   - JEVis 4 Anwendung als Systemd-Service
#   - Worker als Systemd-Service
#
# Verwendung:
#   chmod +x deploy/install-raspi.sh
#   sudo ./deploy/install-raspi.sh
#
# Optionale Umgebungsvariablen:
#   DB_PASSWORD=meinPasswort   - PostgreSQL-Passwort (Default: jevis2025)
#   JAVA_XMX=1g               - Max. Java Heap (Default: abhängig vom Pi-Modell)
#   SKIP_DB=true               - PostgreSQL-Setup überspringen
#   SKIP_BUILD=true            - Maven-Build überspringen
# =============================================================================

set -eu pipefail

# --- Konfiguration -----------------------------------------------------------

DB_NAME="jevis"
DB_USER="jevis"
DB_PASSWORD="${DB_PASSWORD:-jevis2025}"
INSTALL_DIR="/opt/jevis"
CONFIG_DIR="/etc/jevis"
LOG_DIR="/var/log/jevis"
SERVICE_USER="jevis"

# Java Heap automatisch nach RAM bestimmen
TOTAL_RAM_MB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
if [ "$TOTAL_RAM_MB" -le 1024 ]; then
    JAVA_XMS="${JAVA_XMS:-128m}"
    JAVA_XMX="${JAVA_XMX:-384m}"
elif [ "$TOTAL_RAM_MB" -le 2048 ]; then
    JAVA_XMS="${JAVA_XMS:-256m}"
    JAVA_XMX="${JAVA_XMX:-768m}"
elif [ "$TOTAL_RAM_MB" -le 4096 ]; then
    JAVA_XMS="${JAVA_XMS:-256m}"
    JAVA_XMX="${JAVA_XMX:-1g}"
else
    JAVA_XMS="${JAVA_XMS:-512m}"
    JAVA_XMX="${JAVA_XMX:-2g}"
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

# --- Systeminfo --------------------------------------------------------------

print_system_info() {
    echo ""
    echo "============================================="
    echo "  JEVis 4 - Raspberry Pi Installation"
    echo "============================================="
    echo ""
    log "System: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
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
        python3 \
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
        log "Datenbank '$DB_NAME' erstellt"
    fi
}

# --- Systembenutzer anlegen --------------------------------------------------

setup_user() {
    if id -u "$SERVICE_USER" >/dev/null 2>&1; then
        warn "Benutzer '$SERVICE_USER' existiert bereits"
    else
        log "Erstelle Systembenutzer '$SERVICE_USER'..."
        useradd -r -s /bin/false "$SERVICE_USER" || { warn "useradd fehlgeschlagen, Benutzer existiert evtl. schon"; }
    fi

    mkdir -p "$LOG_DIR"
    chown "$SERVICE_USER:$SERVICE_USER" "$LOG_DIR"
}

# --- Anwendung bauen --------------------------------------------------------

build_application() {
    if [ "${SKIP_BUILD:-false}" = "true" ]; then
        warn "Build übersprungen (SKIP_BUILD=true)"
        return
    fi

    if [ ! -f "$INSTALL_DIR/pom.xml" ]; then
        error "pom.xml nicht gefunden in $INSTALL_DIR. Repository zuerst klonen!"
    fi

    log "Baue JEVis 4 (das kann auf einem Raspberry Pi einige Minuten dauern)..."
    cd "$INSTALL_DIR"
    sudo -u "$SERVICE_USER" mvn clean package -DskipTests -q 2>&1 || \
        mvn clean package -DskipTests -q 2>&1

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
# JEVis 4 - Produktions-Konfiguration (Raspberry Pi)
# Generiert am $(date '+%Y-%m-%d %H:%M:%S')
# =============================================================================

# Server
server.port=8080

# PostgreSQL Datenbank
spring.datasource.url=jdbc:postgresql://localhost:5432/${DB_NAME}
spring.datasource.username=${DB_USER}
spring.datasource.password=${DB_PASSWORD}
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# Schema-Verwaltung (nach erstem Start auf "update" ändern)
spring.jpa.hibernate.ddl-auto=create
spring.jpa.show-sql=false
spring.jpa.defer-datasource-initialization=false
spring.sql.init.mode=never

# H2 deaktivieren
spring.h2.console.enabled=false

# JTE Templates
gg.jte.development-mode=false
gg.jte.use-precompiled-templates=false

# Quartz Scheduler
spring.quartz.job-store-type=jdbc
spring.quartz.jdbc.initialize-schema=always
spring.quartz.properties.org.quartz.jobStore.driverDelegateClass=org.quartz.impl.jdbcjobstore.PostgreSQLDelegate
spring.quartz.properties.org.quartz.threadPool.threadCount=3

# Job System
jevis.jobs.heartbeat-timeout-minutes=5
jevis.jobs.timeout-check-interval-seconds=30
jevis.jobs.retry-check-interval-seconds=60

# Logging
logging.level.org.jevis=INFO
logging.level.org.hibernate.SQL=WARN
logging.file.name=${LOG_DIR}/application.log
EOF

    chown -R root:root "$CONFIG_DIR"
    chmod 640 "$CONFIG_DIR/application.properties"

    log "Konfiguration erstellt: $CONFIG_DIR/application.properties"
}

# --- Systemd-Services installieren -------------------------------------------

install_services() {
    log "Installiere Systemd-Services..."

    # JEVis4 Service - mit angepasstem Heap
    sed "s/-Xms512m -Xmx2g/-Xms${JAVA_XMS} -Xmx${JAVA_XMX}/" \
        "$INSTALL_DIR/deploy/jevis4.service" \
        > /etc/systemd/system/jevis4.service

    # Worker Service
    cp "$INSTALL_DIR/deploy/jevis4-worker.service" /etc/systemd/system/

    # Worker-Skript ausführbar machen
    chmod +x "$INSTALL_DIR/deploy/worker.sh"

    # Verzeichnis-Berechtigungen
    chown -R "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR"

    systemctl daemon-reload
    systemctl enable jevis4
    systemctl enable jevis4-worker

    log "Services installiert und aktiviert"
}

# --- Swap vergrössern (für Build auf Pi mit wenig RAM) -----------------------

setup_swap() {
    local CURRENT_SWAP
    CURRENT_SWAP=$(free -m | awk '/Swap/ {print $2}')

    if [ "$TOTAL_RAM_MB" -le 2048 ] && [ "$CURRENT_SWAP" -lt 1024 ]; then
        log "Vergrössere Swap auf 1 GB (empfohlen für Raspberry Pi mit <= 2 GB RAM)..."

        if [ -f /etc/dphys-swapfile ]; then
            sed -i 's/^CONF_SWAPSIZE=.*/CONF_SWAPSIZE=1024/' /etc/dphys-swapfile
            systemctl restart dphys-swapfile
            log "Swap auf 1024 MB gesetzt"
        else
            warn "dphys-swapfile nicht gefunden, Swap nicht angepasst"
        fi
    fi
}

# --- Erster Start ------------------------------------------------------------

first_start() {
    log "Starte JEVis 4 zum ersten Mal (Datenbank-Schema wird erstellt)..."
    systemctl start jevis4

    # Warten bis die Anwendung bereit ist
    log "Warte auf Anwendungsstart (kann 30-90 Sekunden dauern)..."
    local ATTEMPTS=0
    local MAX_ATTEMPTS=60
    until curl -s -f http://localhost:8080/login > /dev/null 2>&1; do
        ATTEMPTS=$((ATTEMPTS + 1))
        if [ "$ATTEMPTS" -ge "$MAX_ATTEMPTS" ]; then
            warn "Anwendung nicht innerhalb von ${MAX_ATTEMPTS}s erreichbar"
            warn "Prüfe Logs mit: sudo journalctl -u jevis4 -n 50"
            return 1
        fi
        sleep 2
    done

    log "Anwendung läuft!"

    # ddl-auto auf update umstellen
    log "Stelle Schema-Verwaltung auf 'update' um..."
    sed -i 's/ddl-auto=create/ddl-auto=update/' "$CONFIG_DIR/application.properties"

    # Worker starten
    log "Starte Worker..."
    systemctl start jevis4-worker

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
    echo "    sudo systemctl status jevis4"
    echo "    sudo systemctl status jevis4-worker"
    echo ""
    echo "  Logs:"
    echo "    sudo journalctl -u jevis4 -f"
    echo "    sudo journalctl -u jevis4-worker -f"
    echo ""
    echo "  Datenbank:"
    echo "    sudo -u postgres psql ${DB_NAME}"
    echo ""
    echo "  Konfiguration:"
    echo "    ${CONFIG_DIR}/application.properties"
    echo ""
    echo "============================================="
    echo ""
}

# --- Hauptprogramm -----------------------------------------------------------

check_root
print_system_info
setup_swap
install_packages
setup_database
setup_user
create_config
build_application
install_services
first_start && print_summary
