@import org.jevis.model.NodeRedDevice
@import org.jevis.model.NodeRedDataPoint
@import org.springframework.security.web.csrf.CsrfToken
@import java.util.List
@import java.time.format.DateTimeFormatter

@param String username
@param NodeRedDevice device
@param List<NodeRedDataPoint> dataPoints
@param CsrfToken _csrf = null

!{var formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm:ss").withZone(java.time.ZoneId.systemDefault());}

@template.layout.app(
    title = device.getDeviceName(),
    username = username,
    currentPage = "devices",
    _csrf = _csrf,
    content = @`
        <div class="page-header">
            <div class="d-flex justify-between align-center">
                <div>
                    <a href="/devices" class="back-link">&larr; Zurück zur Übersicht</a>
                    <h1 class="page-title">${device.getDeviceName()}</h1>
                    <p class="page-description">${device.getApiUrl()}</p>
                </div>
                <div class="header-actions">
                    <button class="btn btn-primary"
                            hx-post="/devices/${device.getId()}/fetch"
                            hx-target="#fetch-result"
                            hx-swap="innerHTML"
                            hx-indicator="#fetch-spinner">
                        Jetzt auslesen
                    </button>
                    <span id="fetch-spinner" class="htmx-indicator">Lädt...</span>
                </div>
            </div>
        </div>

        <!-- Fetch Result -->
        <div id="fetch-result" style="margin-bottom: var(--spacing-md);"></div>

        <!-- Device Info Cards -->
        <div class="info-grid">
            <div class="card info-card">
                <div class="info-label">Status</div>
                <div class="info-value">
                    @if(device.getIsActive())
                        <span class="status-badge status-active">Aktiv</span>
                    @else
                        <span class="status-badge status-inactive">Inaktiv</span>
                    @endif
                </div>
            </div>
            <div class="card info-card">
                <div class="info-label">Zuletzt erreicht</div>
                <div class="info-value">${device.getLastReachedAt() != null ? formatter.format(device.getLastReachedAt()) : "Noch nie"}</div>
            </div>
            <div class="card info-card">
                <div class="info-label">Letzter Import</div>
                <div class="info-value">${device.getLastDataImportAt() != null ? formatter.format(device.getLastDataImportAt()) : "Noch nie"}</div>
            </div>
            <div class="card info-card">
                <div class="info-label">Default Limit</div>
                <div class="info-value">${device.getDefaultLimit()}</div>
            </div>
        </div>

        <!-- DataPoints Section -->
        <div class="card" style="margin-top: var(--spacing-lg);">
            <div class="d-flex justify-between align-center" style="margin-bottom: var(--spacing-md);">
                <h2 style="margin: 0;">Messpunkt-Zuordnungen</h2>
                <button class="btn btn-outline"
                        hx-get="/devices/${device.getId()}/datapoints/new"
                        hx-target="#modal-container"
                        hx-swap="innerHTML">
                    + Zuordnung hinzufügen
                </button>
            </div>

            <div id="datapoints-table-container"
                 hx-get="/devices/${device.getId()}/datapoints/table"
                 hx-trigger="load"
                 hx-swap="innerHTML">
                <div class="loading-spinner">Lade Messpunkte...</div>
            </div>
        </div>

        <!-- Modal Container -->
        <div id="modal-container"></div>

        <style>
            .back-link {
                color: var(--text-secondary);
                text-decoration: none;
                font-size: var(--font-size-sm);
                display: inline-block;
                margin-bottom: var(--spacing-sm);
            }
            .back-link:hover { color: var(--primary-color); }
            .header-actions { display: flex; align-items: center; gap: var(--spacing-md); }
            .info-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: var(--spacing-md);
            }
            .info-card { padding: var(--spacing-lg); }
            .info-label { font-size: var(--font-size-sm); color: var(--text-secondary); margin-bottom: var(--spacing-sm); }
            .info-value { font-size: 1.1rem; font-weight: 600; }
            .status-badge { display: inline-block; padding: 4px 10px; border-radius: var(--radius-lg); font-size: 0.75rem; font-weight: 500; }
            .status-active { background-color: #d1fae5; color: #065f46; }
            .status-inactive { background-color: #fee2e2; color: #991b1b; }
            .loading-spinner { text-align: center; padding: var(--spacing-xl); color: var(--text-secondary); }
            .htmx-indicator { display: none; color: var(--text-secondary); font-size: var(--font-size-sm); }
            .htmx-request .htmx-indicator { display: inline; }
        </style>
    `
)
