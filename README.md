# JEVis 4 - Datenmanagement-Plattform

Web-basierte Plattform zur Erfassung, Speicherung und Visualisierung von Messdaten aus Photovoltaik-Anlagen. Unterstutzt den Import von Node-Red-Geraten, Job-basierte Datenverarbeitung und Echtzeit-Monitoring.

## Technologie-Stack

- **Backend:** Java 17+, Spring Boot 3.2
- **Datenbank:** PostgreSQL 14+
- **Frontend:** htmx, JTE Templates, Apache ECharts
- **Scheduler:** Quartz (JDBC-Store)
- **Build:** Apache Maven

---

## Produktiv-Deployment auf Ubuntu Server

### 1. Voraussetzungen installieren

```bash
sudo apt update && sudo apt upgrade -y

# Java 17+ (OpenJDK)
sudo apt install -y openjdk-17-jdk-headless

# Maven
sudo apt install -y maven

# PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Überprüfen
java -version
mvn -version
psql --version
```

### 2. PostgreSQL einrichten

```bash
# PostgreSQL-Dienst starten und aktivieren
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Datenbank und Benutzer anlegen
sudo -u postgres psql
```

```sql
CREATE USER jevis WITH PASSWORD 'ein_sicheres_passwort';
CREATE DATABASE jevis OWNER jevis;
GRANT ALL PRIVILEGES ON DATABASE jevis TO jevis;
\q
```

PostgreSQL fur Netzwerkzugriff konfigurieren (falls Worker auf anderen Servern laufen):

```bash
# postgresql.conf - Auf alle Interfaces lauschen
sudo nano /etc/postgresql/14/main/postgresql.conf
# listen_addresses = '*'

# pg_hba.conf - Zugriff erlauben (IP-Bereich anpassen!)
sudo nano /etc/postgresql/14/main/pg_hba.conf
# host    jevis    jevis    10.0.0.0/24    scram-sha-256

sudo systemctl restart postgresql
```

### 3. Anwendung bauen

```bash
# Repository klonen
git clone <repository-url> /opt/jevis
cd /opt/jevis

# Produktiv-Build (ohne Tests)
mvn clean package -DskipTests
```

Die ausfuhrbare JAR liegt unter `target/JEVis4_Claude-1.0-SNAPSHOT.jar`.

### 4. application.properties fur Produktion anpassen

```bash
# Erstelle Produktions-Konfiguration
sudo mkdir -p /etc/jevis
sudo nano /etc/jevis/application.properties
```

```properties
# Server
server.port=8080

# PostgreSQL Datenbank
spring.datasource.url=jdbc:postgresql://localhost:5432/jevis
spring.datasource.username=jevis
spring.datasource.password=ein_sicheres_passwort
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# WICHTIG: Bei erstem Start "create", danach auf "update" ändern
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.jpa.defer-datasource-initialization=false
spring.sql.init.mode=never

# H2 deaktivieren
spring.h2.console.enabled=false

# JTE Templates
gg.jte.development-mode=false
gg.jte.use-precompiled-templates=false

# Quartz Scheduler (JDBC-Store fur Persistenz)
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
logging.file.name=/var/log/jevis/application.log
```

### 5. Systemd-Service einrichten

Benutzer fur den Dienst anlegen:

```bash
sudo useradd -r -s /bin/false jevis
sudo mkdir -p /var/log/jevis
sudo chown jevis:jevis /var/log/jevis
```

Die Service-Datei liegt im Repository unter [`deploy/jevis.service`](deploy/jevis.service). Installieren:

```bash
sudo cp /opt/jevis/deploy/jevis.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable jevis
sudo systemctl start jevis

# Status prüfen
sudo systemctl status jevis

# Logs ansehen
sudo journalctl -u jevis -f
```

### 6. Nginx als Reverse Proxy (empfohlen)

```bash
sudo apt install -y nginx
sudo nano /etc/nginx/sites-available/jevis
```

```nginx
server {
    listen 80;
    server_name jevis.example.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeouts für lange laufende Imports
        proxy_read_timeout 300s;
        proxy_connect_timeout 10s;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/jevis /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx
```

Fur HTTPS mit Let's Encrypt:

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d jevis.example.com
```

---

## Worker-Betrieb

Worker sind externe Prozesse, die Jobs aus der Queue abholen und verarbeiten. Sie kommunizieren uber die REST-API mit dem Hauptsystem.

### Worker-API-Übersicht

| Endpoint | Methode | Beschreibung |
|----------|---------|-------------|
| `/api/workers/register` | POST | Worker registrieren |
| `/api/workers/{id}/heartbeat` | POST | Heartbeat senden |
| `/api/workers/{id}/poll` | GET | Nächsten Job abholen |
| `/api/workers/{id}/jobs/{jobId}/progress` | POST | Fortschritt melden |
| `/api/workers/{id}/jobs/{jobId}/complete` | POST | Job als erledigt melden |
| `/api/workers/{id}/jobs/{jobId}/fail` | POST | Job als fehlgeschlagen melden |
| `/api/workers/{id}/deregister` | POST | Worker abmelden |

Alle Endpoints (ausser `/register`) erfordern den Header `X-Worker-Api-Key`.

### Worker registrieren

```bash
curl -X POST http://localhost:8080/api/workers/register \
  -H "Content-Type: application/json" \
  -d '{
    "workerName": "data-fetch-worker-1",
    "poolName": "data-fetch-pool",
    "capabilities": "DATA_FETCH,CALCULATION",
    "hostName": "'$(hostname)'",
    "ipAddress": "'$(hostname -I | awk "{print \$1}")'",
    "maxConcurrentJobs": 3
  }'
```

Die Antwort enthalt `id` und `apiKey` - diese fur den Worker-Loop speichern.

### Worker-Skript und Service installieren

Das Worker-Skript [`deploy/worker.sh`](deploy/worker.sh) implementiert den kompletten Worker-Lebenszyklus:
- Automatische Registrierung am System
- Polling-Loop mit konfigurierbarem Intervall
- Periodische Heartbeats
- Saubere Abmeldung bei SIGTERM/SIGINT
- Wartet beim Start bis JEVis erreichbar ist

Die Konfiguration erfolgt uber Umgebungsvariablen:

| Variable | Default | Beschreibung |
|----------|---------|-------------|
| `JEVIS_URL` | `http://localhost:8080` | URL des JEVis-Servers |
| `POOL_NAME` | `data-fetch-pool` | Worker-Pool |
| `WORKER_NAME` | `worker-$(hostname)` | Name des Workers |
| `CAPABILITIES` | `DATA_FETCH` | Kommagetrennte Fähigkeiten |
| `MAX_CONCURRENT` | `2` | Max. parallele Jobs |
| `POLL_INTERVAL` | `5` | Sekunden zwischen Polls |
| `HEARTBEAT_INTERVAL` | `60` | Sekunden zwischen Heartbeats |

Installation:

```bash
# Skript ausführbar machen
chmod +x /opt/jevis/deploy/worker.sh

# Systemd-Service installieren (siehe deploy/jevis-worker.service)
sudo cp /opt/jevis/deploy/jevis-worker.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable jevis-worker
sudo systemctl start jevis-worker

# Status und Logs
sudo systemctl status jevis-worker
sudo journalctl -u jevis-worker -f
```

Um Umgebungsvariablen fur den Service zu setzen:

```bash
sudo systemctl edit jevis-worker
```

```ini
[Service]
Environment="JEVIS_URL=http://10.0.1.10:8080"
Environment="POOL_NAME=calculation-pool"
Environment="MAX_CONCURRENT=4"
```

---

## Worker-Pools

Das System verwendet Worker-Pools, um Jobs bestimmten Worker-Gruppen zuzuordnen:

| Pool | Beschreibung | Max. parallele Jobs |
|------|-------------|---------------------|
| `default-pool` | Allgemeine Jobs | 10 |
| `data-fetch-pool` | Daten-Import (Node-Red, etc.) | 5 |
| `calculation-pool` | Berechnungs-Jobs | 3 |

Worker melden sich bei der Registrierung an einem Pool an und erhalten nur Jobs aus diesem Pool.

---

## Node-Red Datenimport

### Geräte konfigurieren

1. Im Browser unter `/devices` ein neues Gerät anlegen
2. API-URL des Node-Red Endpoints eintragen (z.B. `http://10.0.1.50:3000/api/data`)
3. Optional Basic Auth Zugangsdaten hinterlegen
4. Messpunkt-Zuordnungen erstellen: Node-Red Remote-ID einem JEVis-Sensor zuordnen

### Manueller Import

- **Ganzes Gerät auslesen:** Button "Jetzt auslesen" auf der Geräte-Detailseite
- **Einzelner Messpunkt:** Auslese-Button in der Messpunkt-Tabelle

### Automatischer Import

Einen wiederkehrenden Job im Job-System anlegen:

1. Unter `/jobs` einen neuen Job erstellen
2. Typ: `Daten-Import`
3. Parameter: `{"deviceId": 1, "scope": "device"}`
4. Als wiederkehrend markieren mit Cron-Ausdruck (z.B. `0 0 * * * ?` fur stundlich)

---

## Erster Start / Datenbank-Schema

Beim **allerersten Start** muss `spring.jpa.hibernate.ddl-auto=create` gesetzt sein, damit Hibernate alle Tabellen anlegt. Der `DataInitializer` erstellt dann automatisch:

- Demo-Sensoren mit 30 Tagen Messdaten
- Worker-Pools (default, data-fetch, calculation)
- Beispiel-Jobs
- Ein Demo-Node-Red-Gerät mit Messpunkt-Zuordnungen

**Nach dem ersten Start** die Einstellung auf `update` ändern und den Dienst neu starten:

```bash
sudo sed -i 's/ddl-auto=create/ddl-auto=update/' /etc/jevis/application.properties
sudo systemctl restart jevis
```

---

## Wartung

### Backup

```bash
# PostgreSQL Backup
sudo -u postgres pg_dump jevis > /backup/jevis_$(date +%Y%m%d).sql

# Wiederherstellen
sudo -u postgres psql jevis < /backup/jevis_20260305.sql
```

### Logs

```bash
# Anwendungs-Logs
sudo journalctl -u jevis -f
sudo journalctl -u jevis-worker -f

# Log-Datei (wenn konfiguriert)
tail -f /var/log/jevis/application.log
```

### Updates

```bash
cd /opt/jevis
git pull
mvn clean package -DskipTests
sudo systemctl restart jevis
sudo systemctl restart jevis-worker
```

---

## Deployment-Dateien

Alle Dateien fur den Produktivbetrieb liegen im Verzeichnis [`deploy/`](deploy/):

| Datei | Beschreibung |
|-------|-------------|
| [`jevis.service`](deploy/jevis.service) | Systemd-Service fur die JEVis-Anwendung |
| [`jevis-worker.service`](deploy/jevis-worker.service) | Systemd-Service fur den Worker |
| [`worker.sh`](deploy/worker.sh) | Worker-Skript mit Polling-Loop und Heartbeat |

---

## Zugangsdaten (Entwicklung)

| Benutzer | Passwort | Rolle |
|----------|----------|-------|
| admin | admin | ADMIN, USER |
| operator | operator | USER |

Fur den Produktivbetrieb sollten diese in `SecurityConfig.java` durch eine datenbankbasierte Benutzerverwaltung ersetzt werden.

---

## Ports und Firewall

| Port | Dienst | Zugriff |
|------|--------|---------|
| 8080 | JEVis (Spring Boot) | Nur lokal (Nginx leitet weiter) |
| 80/443 | Nginx | Extern |
| 5432 | PostgreSQL | Nur intern / Worker-Netz |

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow from 10.0.0.0/24 to any port 5432  # Nur aus Worker-Netz
sudo ufw enable
```

---

## Entwicklung

```bash
# Build und Tests
mvn clean test

# Anwendung starten (H2 In-Memory DB)
mvn spring-boot:run

# Einzelnen Test ausfuhren
mvn test -Dtest=AppTest

# Zugriff
# http://localhost:8080 (Login: admin/admin)
# http://localhost:8080/h2-console (JDBC URL: jdbc:h2:mem:jevis)
```
