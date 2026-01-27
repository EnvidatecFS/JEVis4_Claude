@import org.jevis.model.Sensor
@import java.util.List
@import java.time.format.DateTimeFormatter

@param List<Sensor> sensors
@param int currentPage
@param int totalPages
@param long totalElements
@param String search = ""
@param String type = ""
@param String status = ""
@param String sortBy = "createdAt"
@param String sortDir = "desc"
@param List<String> measurementTypes = java.util.Collections.emptyList()

!{var formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm").withZone(java.time.ZoneId.systemDefault());}

<!-- Update filter dropdowns with measurement types -->
<script>
    (function() {
        var typeSelect = document.getElementById('type');
        if (typeSelect) {
            var currentValue = '${type}';
            typeSelect.innerHTML = '<option value="">Alle Typen</option>';
            @for(String mt : measurementTypes)
                typeSelect.innerHTML += '<option value="${mt}" ${type.equals(mt) ? "selected" : ""}>${mt}</option>';
            @endfor
            typeSelect.value = currentValue;
        }
    })();
</script>

<div class="table-header">
    <span class="table-info">${totalElements} Messpunkte gefunden</span>
</div>

<div class="table-responsive">
    <table class="data-table">
        <thead>
            <tr>
                <th class="sortable"
                    hx-get="/sensors/table?sortBy=sensorCode&sortDir=${sortBy.equals("sensorCode") && sortDir.equals("asc") ? "desc" : "asc"}&search=${search}&type=${type}&status=${status}"
                    hx-target="#sensors-table-container">
                    Code
                    @if(sortBy.equals("sensorCode"))
                        <span class="sort-icon">${sortDir.equals("asc") ? "^" : "v"}</span>
                    @endif
                </th>
                <th class="sortable"
                    hx-get="/sensors/table?sortBy=sensorName&sortDir=${sortBy.equals("sensorName") && sortDir.equals("asc") ? "desc" : "asc"}&search=${search}&type=${type}&status=${status}"
                    hx-target="#sensors-table-container">
                    Name
                    @if(sortBy.equals("sensorName"))
                        <span class="sort-icon">${sortDir.equals("asc") ? "^" : "v"}</span>
                    @endif
                </th>
                <th class="sortable"
                    hx-get="/sensors/table?sortBy=measurementType&sortDir=${sortBy.equals("measurementType") && sortDir.equals("asc") ? "desc" : "asc"}&search=${search}&type=${type}&status=${status}"
                    hx-target="#sensors-table-container">
                    Typ
                    @if(sortBy.equals("measurementType"))
                        <span class="sort-icon">${sortDir.equals("asc") ? "^" : "v"}</span>
                    @endif
                </th>
                <th>Einheit</th>
                <th>Standort</th>
                <th class="sortable"
                    hx-get="/sensors/table?sortBy=isActive&sortDir=${sortBy.equals("isActive") && sortDir.equals("asc") ? "desc" : "asc"}&search=${search}&type=${type}&status=${status}"
                    hx-target="#sensors-table-container">
                    Status
                    @if(sortBy.equals("isActive"))
                        <span class="sort-icon">${sortDir.equals("asc") ? "^" : "v"}</span>
                    @endif
                </th>
                <th class="sortable"
                    hx-get="/sensors/table?sortBy=createdAt&sortDir=${sortBy.equals("createdAt") && sortDir.equals("asc") ? "desc" : "asc"}&search=${search}&type=${type}&status=${status}"
                    hx-target="#sensors-table-container">
                    Erstellt
                    @if(sortBy.equals("createdAt"))
                        <span class="sort-icon">${sortDir.equals("asc") ? "^" : "v"}</span>
                    @endif
                </th>
                <th class="actions-col">Aktionen</th>
            </tr>
        </thead>
        <tbody>
            @if(sensors.isEmpty())
                <tr>
                    <td colspan="8" class="empty-state">
                        <div class="empty-icon">
                            <svg width="48" height="48" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z"/>
                            </svg>
                        </div>
                        <p>Keine Messpunkte gefunden</p>
                        @if(!search.isEmpty() || !type.isEmpty() || !status.isEmpty())
                            <p class="text-muted">Versuchen Sie, die Filter anzupassen</p>
                        @endif
                    </td>
                </tr>
            @else
                @for(Sensor sensor : sensors)
                    <tr id="sensor-row-${sensor.getId()}">
                        <td><code class="sensor-code">${sensor.getSensorCode()}</code></td>
                        <td>${sensor.getSensorName() != null ? sensor.getSensorName() : "-"}</td>
                        <td><span class="badge badge-type">${sensor.getMeasurementType()}</span></td>
                        <td>${sensor.getUnit()}</td>
                        <td>${sensor.getLocation() != null ? sensor.getLocation() : "-"}</td>
                        <td>
                            @if(sensor.getIsActive())
                                <span class="status-badge status-active">Aktiv</span>
                            @else
                                <span class="status-badge status-inactive">Inaktiv</span>
                            @endif
                        </td>
                        <td class="date-cell">${sensor.getCreatedAt() != null ? formatter.format(sensor.getCreatedAt()) : "-"}</td>
                        <td class="actions-cell">
                            <button class="btn-icon" title="Bearbeiten"
                                    hx-get="/sensors/${sensor.getId()}/edit"
                                    hx-target="#modal-container"
                                    hx-swap="innerHTML">
                                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                                </svg>
                            </button>
                            <button class="btn-icon btn-icon-danger" title="Löschen"
                                    hx-delete="/sensors/${sensor.getId()}"
                                    hx-target="#sensor-row-${sensor.getId()}"
                                    hx-swap="outerHTML"
                                    hx-confirm="Möchten Sie diesen Messpunkt wirklich löschen? Alle zugehörigen Messdaten werden ebenfalls gelöscht!">
                                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                                </svg>
                            </button>
                        </td>
                    </tr>
                @endfor
            @endif
        </tbody>
    </table>
</div>

<!-- Pagination -->
@if(totalPages > 1)
    <div class="pagination">
        <button class="btn btn-outline btn-sm"
                disabled="${currentPage == 0}"
                hx-get="/sensors/table?page=${currentPage - 1}&search=${search}&type=${type}&status=${status}&sortBy=${sortBy}&sortDir=${sortDir}"
                hx-target="#sensors-table-container">
            Zurück
        </button>
        <span class="pagination-info">Seite ${currentPage + 1} von ${totalPages}</span>
        <button class="btn btn-outline btn-sm"
                disabled="${currentPage >= totalPages - 1}"
                hx-get="/sensors/table?page=${currentPage + 1}&search=${search}&type=${type}&status=${status}&sortBy=${sortBy}&sortDir=${sortDir}"
                hx-target="#sensors-table-container">
            Weiter
        </button>
    </div>
@endif

<style>
    .table-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: var(--spacing-md);
    }
    .table-info {
        color: var(--text-secondary);
        font-size: var(--font-size-sm);
    }
    .table-responsive {
        overflow-x: auto;
    }
    .data-table {
        width: 100%;
        border-collapse: collapse;
        font-size: var(--font-size-sm);
    }
    .data-table th,
    .data-table td {
        padding: var(--spacing-md);
        text-align: left;
        border-bottom: 1px solid var(--border-color);
    }
    .data-table th {
        background-color: var(--background);
        font-weight: 600;
        color: var(--text-secondary);
        font-size: 0.75rem;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    .data-table th.sortable {
        cursor: pointer;
        user-select: none;
    }
    .data-table th.sortable:hover {
        background-color: var(--border-color);
    }
    .sort-icon {
        margin-left: var(--spacing-sm);
        font-size: 0.7rem;
    }
    .data-table tbody tr:hover {
        background-color: var(--background);
    }
    .sensor-code {
        background-color: var(--background);
        padding: 2px 6px;
        border-radius: var(--radius-sm);
        font-family: monospace;
        font-size: 0.85rem;
    }
    .badge {
        display: inline-block;
        padding: 2px 8px;
        border-radius: var(--radius-sm);
        font-size: 0.75rem;
        font-weight: 500;
    }
    .badge-type {
        background-color: #dbeafe;
        color: #1e40af;
    }
    .status-badge {
        display: inline-block;
        padding: 4px 10px;
        border-radius: var(--radius-lg);
        font-size: 0.75rem;
        font-weight: 500;
    }
    .status-active {
        background-color: #d1fae5;
        color: #065f46;
    }
    .status-inactive {
        background-color: #fee2e2;
        color: #991b1b;
    }
    .date-cell {
        white-space: nowrap;
        color: var(--text-secondary);
    }
    .actions-col {
        width: 100px;
        text-align: center;
    }
    .actions-cell {
        text-align: center;
        white-space: nowrap;
    }
    .btn-icon {
        background: none;
        border: none;
        cursor: pointer;
        padding: var(--spacing-sm);
        color: var(--text-secondary);
        border-radius: var(--radius-md);
        transition: all 0.2s;
    }
    .btn-icon:hover {
        background-color: var(--background);
        color: var(--primary-color);
    }
    .btn-icon-danger:hover {
        background-color: #fee2e2;
        color: var(--danger-color);
    }
    .empty-state {
        text-align: center;
        padding: var(--spacing-2xl) !important;
        color: var(--text-secondary);
    }
    .empty-icon {
        margin-bottom: var(--spacing-md);
        opacity: 0.5;
    }
    .pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: var(--spacing-md);
        margin-top: var(--spacing-lg);
        padding-top: var(--spacing-lg);
        border-top: 1px solid var(--border-color);
    }
    .pagination-info {
        color: var(--text-secondary);
        font-size: var(--font-size-sm);
    }
    .btn-sm {
        padding: var(--spacing-sm) var(--spacing-md);
        font-size: var(--font-size-sm);
    }
</style>
