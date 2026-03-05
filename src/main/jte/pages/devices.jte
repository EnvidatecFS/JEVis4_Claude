@import org.springframework.security.web.csrf.CsrfToken

@param String username
@param CsrfToken _csrf = null

@template.layout.app(
    title = "Geräte",
    username = username,
    currentPage = "devices",
    _csrf = _csrf,
    content = @`
        <div class="page-header d-flex justify-between align-center">
            <div>
                <h1 class="page-title">Node-Red Geräte</h1>
                <p class="page-description">Verwalten Sie Ihre Node-Red Geräte und deren Messpunkt-Zuordnungen</p>
            </div>
            <button class="btn btn-primary"
                    hx-get="/devices/new"
                    hx-target="#modal-container"
                    hx-swap="innerHTML">
                + Neues Gerät
            </button>
        </div>

        <!-- Table Container -->
        <div class="card">
            <div id="devices-table-container"
                 hx-get="/devices/table"
                 hx-trigger="load"
                 hx-swap="innerHTML">
                <div class="loading-spinner">Lade Geräte...</div>
            </div>
        </div>

        <!-- Modal Container -->
        <div id="modal-container"></div>
        <!-- Fetch Result Container -->
        <div id="fetch-result"></div>

        <style>
            .loading-spinner {
                text-align: center;
                padding: var(--spacing-xl);
                color: var(--text-secondary);
            }
        </style>
    `
)
