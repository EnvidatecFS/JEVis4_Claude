# JEVis 4 - Installation auf Raspberry Pi OS

Anleitung zur Installation von JEVis 4 auf einem Raspberry Pi als Dauerbetrieb-System fur Messdatenerfassung und -verwaltung.

## Unterstützte Hardware

| Modell | RAM | Eignung |
|--------|-----|---------|
| Raspberry Pi 5 | 4/8 GB | Empfohlen - volle Leistung |
| Raspberry Pi 4 | 4/8 GB | Empfohlen |
| Raspberry Pi 4 | 2 GB | Geeignet mit eingeschränktem Heap |
| Raspberry Pi 4 | 1 GB | Nur als Worker, nicht als Server |
| Raspberry Pi 3 | 1 GB | Nur als Worker |

**Betriebssystem:** Raspberry Pi OS (64-bit) basierend auf Debian Bookworm oder neuer.

---

## Schnellinstallation (automatisch)

Das Skript [`install-raspi.sh`](install-raspi.sh) installiert und konfiguriert alles automatisch:

```bash
# Repository klonen
git clone <repository-url> /opt/jevis4
cd /opt/jevis4

# Installationsskript ausführen
chmod +x deploy/install-raspi.sh
sudo ./deploy/install-raspi.sh
```

Das Skript erledigt:
1. Swap-Vergrösserung (bei <= 2 GB RAM)
2. Java 17, PostgreSQL, Maven installieren
3. Datenbank und Benutzer anlegen
4. Anwendung bauen
5. Produktions-Konfiguration erstellen
6. Systemd-Services installieren und starten
7. Erster Start mit Datenbank-Schema-Erstellung
8. Automatische Umstellung auf `ddl-auto=update`

Nach der Installation ist JEVis erreichbar unter `http://<pi-ip>:8080` mit Login `admin` / `admin`.

### Optionale Parameter

```bash
# Eigenes Datenbank-Passwort
sudo DB_PASSWORD=meinSicheresPasswort ./deploy/install-raspi.sh

# Java Heap manuell setzen
sudo JAVA_XMX=1g ./deploy/install-raspi.sh

# Ohne Datenbank-Setup (z.B. externe DB)
sudo SKIP_DB=true ./deploy/install-raspi.sh

# Ohne Build (JAR bereits vorhanden)
sudo SKIP_BUILD=true ./deploy/install-raspi.sh
```

---

## Manuelle Installation (Schritt für Schritt)

### 1. System vorbereiten

```bash
sudo apt update && sudo apt upgrade -y

# Bei Raspberry Pi mit <= 2 GB RAM: Swap vergrössern
sudo sed -i 's/^CONF_SWAPSIZE=.*/CONF_SWAPSIZE=1024/' /etc/dphys-swapfile
sudo systemctl restart dphys-swapfile
```

### 2. Pakete installieren

```bash
sudo apt install -y \
    openjdk-17-jdk-headless \
    postgresql \
    maven \
    curl \
    python3 \
    git
```

Prüfen:

```bash
java -version    # openjdk 17.x
psql --version   # psql 15.x+
mvn -version     # Apache Maven 3.x
```

### 3. PostgreSQL einrichten

```bash
sudo systemctl enable postgresql
sudo systemctl start postgresql

sudo -u postgres psql
```

```sql
CREATE USER jevis WITH PASSWORD 'ein_sicheres_passwort';
CREATE DATABASE jevis4 OWNER jevis;
GRANT ALL PRIVILEGES ON DATABASE jevis4 TO jevis;
\q
```

### 4. Repository klonen und bauen

```bash
sudo git clone <repository-url> /opt/jevis4
cd /opt/jevis4

# Build (dauert auf einem Pi 4 ca. 3-5 Minuten)
mvn clean package -DskipTests
```

### 5. Systembenutzer und Verzeichnisse

```bash
sudo useradd -r -s /bin/false jevis
sudo mkdir -p /var/log/jevis4
sudo chown jevis:jevis /var/log/jevis4
sudo chown -R jevis:jevis /opt/jevis4
```

### 6. Konfiguration

```bash
sudo mkdir -p /etc/jevis4
sudo nano /etc/jevis4/application.properties
```

Inhalt - **Passwort und Heap-Grösse anpassen**:

```properties
# Server
server.port=8080

# PostgreSQL
spring.datasource.url=jdbc:postgresql://localhost:5432/jevis4
spring.datasource.username=jevis
spring.datasource.password=ein_sicheres_passwort
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# Schema (nach erstem Start auf "update" ändern!)
spring.jpa.hibernate.ddl-auto=create
spring.jpa.show-sql=false
spring.jpa.defer-datasource-initialization=false
spring.sql.init.mode=never

# H2 deaktivieren
spring.h2.console.enabled=false

# JTE
gg.jte.development-mode=false
gg.jte.use-precompiled-templates=false

# Quartz
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
logging.file.name=/var/log/jevis4/application.log
```

### 7. Services installieren

Die Service-Dateien liegen im Repository. Bei einem Raspberry Pi mit wenig RAM muss der Heap in `jevis4.service` angepasst werden:

```bash
# Service-Dateien kopieren
sudo cp /opt/jevis4/deploy/jevis4.service /etc/systemd/system/
sudo cp /opt/jevis4/deploy/jevis4-worker.service /etc/systemd/system/

# Heap anpassen (Beispiel: Pi 4 mit 2 GB RAM)
sudo sed -i 's/-Xms512m -Xmx2g/-Xms256m -Xmx768m/' /etc/systemd/system/jevis4.service

# Worker-Skript ausführbar machen
chmod +x /opt/jevis4/deploy/worker.sh

# Services aktivieren
sudo systemctl daemon-reload
sudo systemctl enable jevis4
sudo systemctl enable jevis4-worker
```

**Empfohlene Heap-Werte:**

| Pi-Modell | RAM | `-Xms` | `-Xmx` |
|-----------|-----|--------|--------|
| Pi 4/5, 8 GB | 8 GB | 512m | 2g |
| Pi 4/5, 4 GB | 4 GB | 256m | 1g |
| Pi 4, 2 GB | 2 GB | 256m | 768m |
| Pi 4, 1 GB (nur Worker) | 1 GB | 128m | 384m |

### 8. Erster Start

```bash
# Anwendung starten
sudo systemctl start jevis4

# Logs beobachten (warten bis "Started App" erscheint)
sudo journalctl -u jevis4 -f
```

Nach erfolgreichem Start die Schema-Verwaltung umstellen und Worker starten:

```bash
# ddl-auto auf update umstellen
sudo sed -i 's/ddl-auto=create/ddl-auto=update/' /etc/jevis4/application.properties

# Neustart mit neuer Konfiguration
sudo systemctl restart jevis4

# Worker starten
sudo systemctl start jevis4-worker
```

---

## Raspberry Pi als reinen Worker betreiben

Ein Pi kann auch ohne eigene Datenbank als Worker an einem zentralen JEVis-Server arbeiten. Dafür werden nur das Worker-Skript und curl benötigt:

```bash
sudo apt install -y curl python3

# Repository klonen (nur für das Worker-Skript)
git clone <repository-url> /opt/jevis4

# Worker-Skript ausführbar machen
chmod +x /opt/jevis4/deploy/worker.sh

# Service installieren mit Verweis auf den zentralen Server
sudo cp /opt/jevis4/deploy/jevis4-worker.service /etc/systemd/system/
sudo systemctl edit jevis4-worker
```

Server-URL als Umgebungsvariable setzen:

```ini
[Service]
Environment="JEVIS_URL=http://10.0.1.10:8080"
Environment="POOL_NAME=data-fetch-pool"
Environment="WORKER_NAME=pi-worker-keller"
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable jevis4-worker
sudo systemctl start jevis4-worker
```

---

## Dienste verwalten

```bash
# Status
sudo systemctl status jevis4
sudo systemctl status jevis4-worker

# Stoppen / Starten / Neustarten
sudo systemctl stop jevis4
sudo systemctl start jevis4
sudo systemctl restart jevis4

# Logs (live)
sudo journalctl -u jevis4 -f
sudo journalctl -u jevis4-worker -f

# Logs der letzten Stunde
sudo journalctl -u jevis4 --since "1 hour ago"
```

---

## Autostart nach Stromausfall

Die Systemd-Services starten automatisch nach einem Neustart. Um sicherzustellen, dass der Pi nach Stromausfall selbst wieder hochfährt, kein Eingriff nötig - das ist das Standardverhalten.

Falls der Pi an einer USV hängt und sauber herunterfahren soll:

```bash
# Beispiel: GPIO-basiertes Shutdown-Skript
# (abhängig von der USV-Hardware)
```

---

## Performance-Tipps

### GPU-Speicher reduzieren

Der Pi reserviert standardmässig RAM für die GPU. Im Headless-Betrieb kann das auf ein Minimum reduziert werden:

```bash
sudo raspi-config
# -> Performance Options -> GPU Memory -> 16
```

Oder direkt:

```bash
echo "gpu_mem=16" | sudo tee -a /boot/config.txt
sudo reboot
```

### Unnötige Dienste deaktivieren

```bash
# Bluetooth (falls nicht benötigt)
sudo systemctl disable bluetooth
sudo systemctl stop bluetooth

# Avahi/mDNS (falls nicht benötigt)
sudo systemctl disable avahi-daemon
sudo systemctl stop avahi-daemon
```

### SD-Karte schonen

Häufige Schreibzugriffe verkürzen die Lebensdauer der SD-Karte. Empfehlung:

- Log-Level auf `WARN` setzen wenn das System stabil läuft
- PostgreSQL-Daten auf eine externe SSD/USB-Festplatte verlagern
- tmpfs für temporäre Dateien verwenden:

```bash
echo "tmpfs /tmp tmpfs defaults,noatime,nosuid,size=100m 0 0" | sudo tee -a /etc/fstab
```

### PostgreSQL auf USB-SSD (empfohlen)

```bash
# SSD mounten (Beispiel: /dev/sda1 als ext4)
sudo mkdir -p /mnt/ssd
sudo mount /dev/sda1 /mnt/ssd
echo "/dev/ssd1 /mnt/ssd ext4 defaults,noatime 0 2" | sudo tee -a /etc/fstab

# PostgreSQL-Daten verschieben
sudo systemctl stop postgresql
sudo rsync -av /var/lib/postgresql/ /mnt/ssd/postgresql/
sudo mv /var/lib/postgresql /var/lib/postgresql.bak
sudo ln -s /mnt/ssd/postgresql /var/lib/postgresql
sudo systemctl start postgresql
```

---

## Deinstallation

```bash
chmod +x /opt/jevis4/deploy/uninstall-raspi.sh
sudo ./deploy/uninstall-raspi.sh

# Mit Datenbank-Löschung (ACHTUNG: Datenverlust!)
sudo DROP_DB=true ./deploy/uninstall-raspi.sh
```

---

## Fehlerbehebung

### Anwendung startet nicht

```bash
# Logs prüfen
sudo journalctl -u jevis4 -n 100 --no-pager

# Häufige Ursachen:
# - PostgreSQL läuft nicht: sudo systemctl status postgresql
# - Falsches DB-Passwort: /etc/jevis4/application.properties prüfen
# - Zu wenig RAM/Heap: -Xmx in jevis4.service anpassen
# - Port belegt: sudo ss -tlnp | grep 8080
```

### Build bricht ab (Out of Memory)

```bash
# Swap prüfen
free -h

# Swap vergrössern
sudo sed -i 's/^CONF_SWAPSIZE=.*/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile
sudo systemctl restart dphys-swapfile

# Build mit weniger Maven-Speicher
MAVEN_OPTS="-Xmx512m" mvn clean package -DskipTests
```

### Worker verbindet sich nicht

```bash
# Prüfen ob JEVis erreichbar ist
curl -s http://localhost:8080/login

# Worker-Logs
sudo journalctl -u jevis4-worker -f

# Manueller Test der Worker-Registrierung
curl -X POST http://localhost:8080/api/workers/register \
  -H "Content-Type: application/json" \
  -d '{"workerName":"test","poolName":"data-fetch-pool","capabilities":"DATA_FETCH","hostName":"test","ipAddress":"127.0.0.1","maxConcurrentJobs":1}'
```

---

## Dateien in diesem Verzeichnis

| Datei | Beschreibung |
|-------|-------------|
| [`install-raspi.sh`](install-raspi.sh) | Automatisches Installationsskript |
| [`uninstall-raspi.sh`](uninstall-raspi.sh) | Deinstallationsskript |
| [`jevis4.service`](jevis4.service) | Systemd-Service für die Anwendung |
| [`jevis4-worker.service`](jevis4-worker.service) | Systemd-Service für den Worker |
| [`worker.sh`](worker.sh) | Worker-Skript mit Polling-Loop |
