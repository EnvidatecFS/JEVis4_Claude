@import org.springframework.security.web.csrf.CsrfToken
@import org.jevis.model.CsrCategory
@import org.jevis.model.CsrStatus

@param String username
@param CsrfToken _csrf = null
@param CsrCategory[] categories = CsrCategory.values()
@param CsrStatus[] statuses = CsrStatus.values()

@template.layout.app(
    title = "CSR Action Plan",
    username = username,
    currentPage = "csr",
    _csrf = _csrf,
    content = @`
        <div class="page-header d-flex justify-between align-center">
            <div>
                <h1 class="page-title">CSR Action Plan</h1>
                <p class="page-description">Verwalten Sie Ihre Corporate Social Responsibility Maßnahmen</p>
            </div>
            <button class="btn btn-primary"
                    hx-get="/csr/new"
                    hx-target="#modal-container"
                    hx-swap="innerHTML">
                + Neue Maßnahme
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
                           placeholder="Titel, Beschreibung oder Verantwortlicher..."
                           hx-get="/csr/table"
                           hx-trigger="keyup changed delay:300ms"
                           hx-target="#csr-table-container"
                           hx-include="[name='category'], [name='status']">
                </div>
                <div class="filter-group">
                    <label for="category">Kategorie</label>
                    <select id="category"
                            name="category"
                            hx-get="/csr/table"
                            hx-trigger="change"
                            hx-target="#csr-table-container"
                            hx-include="[name='search'], [name='status']">
                        <option value="">Alle Kategorien</option>
                        @for(CsrCategory cat : categories)
                            <option value="${cat.name()}">${cat.getDisplayName()}</option>
                        @endfor
                    </select>
                </div>
                <div class="filter-group">
                    <label for="status">Status</label>
                    <select id="status"
                            name="status"
                            hx-get="/csr/table"
                            hx-trigger="change"
                            hx-target="#csr-table-container"
                            hx-include="[name='search'], [name='category']">
                        <option value="">Alle Status</option>
                        @for(CsrStatus st : statuses)
                            <option value="${st.name()}">${st.getDisplayName()}</option>
                        @endfor
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
            <div id="csr-table-container"
                 hx-get="/csr/table"
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
                document.getElementById('category').value = '';
                document.getElementById('status').value = '';
                htmx.trigger('#search', 'keyup');
            }
        </script>
    `
)
