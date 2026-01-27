@import org.springframework.security.web.csrf.CsrfToken

@param String username
@param CsrfToken _csrf = null

@template.layout.app(
    title = "Messpunkte",
    username = username,
    currentPage = "sensors",
    _csrf = _csrf,
    content = @`
        <div class="page-header d-flex justify-between align-center">
            <div>
                <h1 class="page-title">Messpunkte</h1>
                <p class="page-description">Verwalten Sie alle Sensoren und Messpunkte Ihrer PV-Anlagen</p>
            </div>
            <button class="btn btn-primary"
                    hx-get="/sensors/new"
                    hx-target="#modal-container"
                    hx-swap="innerHTML">
                + Neuer Messpunkt
            </button>
        </div>

        <!-- Filter Section -->
        <div class="card mb-3">
            <div class="filter-row">
                <div class="filter-group">
                    <label for="search">Suche</label>
                    <input type="text"
                           id="search"
                           name="search"
                           placeholder="Code, Name oder Standort..."
                           hx-get="/sensors/table"
                           hx-trigger="keyup changed delay:300ms"
                           hx-target="#sensors-table-container"
                           hx-include="[name='type'], [name='status']">
                </div>
                <div class="filter-group">
                    <label for="type">Messtyp</label>
                    <select id="type"
                            name="type"
                            hx-get="/sensors/table"
                            hx-trigger="change"
                            hx-target="#sensors-table-container"
                            hx-include="[name='search'], [name='status']">
                        <option value="">Alle Typen</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label for="status">Status</label>
                    <select id="status"
                            name="status"
                            hx-get="/sensors/table"
                            hx-trigger="change"
                            hx-target="#sensors-table-container"
                            hx-include="[name='search'], [name='type']">
                        <option value="">Alle</option>
                        <option value="active">Aktiv</option>
                        <option value="inactive">Inaktiv</option>
                    </select>
                </div>
                <div class="filter-group filter-actions">
                    <label>&nbsp;</label>
                    <button type="button" class="btn btn-outline" onclick="resetFilters()">
                        Filter zurücksetzen
                    </button>
                </div>
            </div>
        </div>

        <!-- Table Container -->
        <div class="card">
            <div id="sensors-table-container"
                 hx-get="/sensors/table"
                 hx-trigger="load"
                 hx-swap="innerHTML">
                <div class="loading-spinner">Lade Daten...</div>
            </div>
        </div>

        <!-- Modal Container -->
        <div id="modal-container"></div>

        <style>
            .filter-row {
                display: flex;
                gap: var(--spacing-lg);
                flex-wrap: wrap;
                align-items: flex-end;
            }
            .filter-group {
                flex: 1;
                min-width: 200px;
            }
            .filter-group label {
                display: block;
                margin-bottom: var(--spacing-sm);
                font-weight: 500;
                font-size: var(--font-size-sm);
            }
            .filter-actions {
                flex: 0 0 auto;
                min-width: auto;
            }
            .loading-spinner {
                text-align: center;
                padding: var(--spacing-xl);
                color: var(--text-secondary);
            }
        </style>

        <script>
            function resetFilters() {
                document.getElementById('search').value = '';
                document.getElementById('type').value = '';
                document.getElementById('status').value = '';
                htmx.trigger('#search', 'keyup');
            }
        </script>
    `
)
