@import org.springframework.security.web.csrf.CsrfToken

@param String username
@param CsrfToken _csrf = null

@template.layout.app(
    title = "Zählerverwaltung",
    username = username,
    currentPage = "meter-types",
    _csrf = _csrf,
    content = @`
        <div class="page-header">
            <div>
                <h1 class="page-title">Zählerverwaltung</h1>
                <p class="page-description">Verwaltung von Zählertypen und Gerätekonfigurationen</p>
            </div>
            <div>
                <button class="btn btn-primary"
                        hx-get="/meter-types/new"
                        hx-target="#modal-container"
                        hx-swap="innerHTML">
                    + Neuer Zählertyp
                </button>
            </div>
        </div>

        <div id="meter-types-table-container"
             hx-get="/meter-types/table"
             hx-trigger="load"
             hx-swap="innerHTML">
            <div style="text-align:center; padding: var(--spacing-xl); color: var(--text-secondary);">Lade...</div>
        </div>

        <div id="modal-container"></div>
    `
)
