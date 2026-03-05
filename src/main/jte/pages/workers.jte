@import org.springframework.security.web.csrf.CsrfToken

@param String username
@param CsrfToken _csrf = null

@template.layout.app(
    title = "Workers",
    username = username,
    currentPage = "workers",
    _csrf = _csrf,
    content = @`
        <div class="page-header">
            <h1 class="page-title">Task Workers</h1>
            <p class="page-description">Registrierte Worker und Pool-Übersicht</p>
        </div>

        <div class="card">
            <div id="workers-table-container"
                 hx-get="/workers/table"
                 hx-trigger="load, every 15s"
                 hx-swap="innerHTML">
                <div class="loading-spinner">Lade Worker-Daten...</div>
            </div>
        </div>

        <style>
            .loading-spinner { text-align: center; padding: var(--spacing-xl); color: var(--text-secondary); }
        </style>
    `
)
