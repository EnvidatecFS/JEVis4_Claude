@import org.jevis.model.Measurement
@import java.util.List
@import java.time.format.DateTimeFormatter
@import java.time.ZoneId

@param Long sensorId
@param List<Measurement> measurements
@param int currentPage
@param int totalPages
@param long filteredCount
@param long totalCount
@param int pageSize = 25
@param String from = ""
@param String to = ""
@param String sourceType = ""

!{var fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").withZone(ZoneId.systemDefault());}
!{boolean isFiltered = !from.isEmpty() || !to.isEmpty() || !sourceType.isEmpty();}

<div class="m-filter-bar">
    <div class="m-filter-row"
         hx-get="/sensors/${sensorId}/measurements"
         hx-trigger="keyup changed delay:400ms from:#m-from, keyup changed delay:400ms from:#m-to, change from:#m-source-type"
         hx-target="#measurements-list"
         hx-swap="innerHTML"
         hx-include="#m-from, #m-to, #m-source-type">
        <div class="m-filter-group">
            <label for="m-from">Von</label>
            <input type="datetime-local" id="m-from" name="from"
                   value="${from}" class="m-filter-input">
        </div>
        <div class="m-filter-group">
            <label for="m-to">Bis</label>
            <input type="datetime-local" id="m-to" name="to"
                   value="${to}" class="m-filter-input">
        </div>
        <div class="m-filter-group">
            <label for="m-source-type">Typ</label>
            <select id="m-source-type" name="sourceType" class="m-filter-input">
                <option value=""         selected="${sourceType.isEmpty()}">Alle Typen</option>
                <option value="automatic" selected="${sourceType.equals("automatic")}">Automatisch</option>
                <option value="manual"    selected="${sourceType.equals("manual")}">Manuell</option>
                <option value="corrected" selected="${sourceType.equals("corrected")}">Korrigiert</option>
                <option value="validated" selected="${sourceType.equals("validated")}">Validiert</option>
            </select>
        </div>
        @if(isFiltered)
        <a class="m-filter-clear"
           hx-get="/sensors/${sensorId}/measurements"
           hx-target="#measurements-list"
           hx-swap="innerHTML">
            &times; Filter zurücksetzen
        </a>
        @endif
    </div>

    <div class="m-filter-meta">
        @if(isFiltered)
            <span>${filteredCount} von ${totalCount} Messwerten</span>
        @else
            <span>${totalCount} Messwerte gesamt</span>
        @endif
        <div style="display:flex; gap: var(--spacing-sm);">
            @if(isFiltered && filteredCount > 0)
            <button class="btn-delete-all"
                    hx-delete="/sensors/${sensorId}/measurements/filtered?from=${from}&to=${to}&sourceType=${sourceType}"
                    hx-target="#measurements-list"
                    hx-swap="innerHTML"
                    hx-confirm="Alle ${filteredCount} angezeigten Messwerte löschen?">
                Angezeigte löschen (${filteredCount})
            </button>
            @endif
            @if(totalCount > 0)
            <button class="btn-delete-all"
                    hx-get="/sensors/${sensorId}/measurements/confirm-delete-all"
                    hx-target="#delete-all-confirm-area"
                    hx-swap="innerHTML">
                Alle löschen
            </button>
            @endif
        </div>
    </div>
</div>

<div id="delete-all-confirm-area"></div>

@if(measurements.isEmpty())
    <div class="m-empty">
        @if(isFiltered)
            Keine Messwerte für diesen Filter gefunden.
        @else
            Keine Messwerte vorhanden.
        @endif
    </div>
@else
    <div class="m-table-wrap">
        <table class="m-table">
            <thead>
                <tr>
                    <th class="col-ts">Zeitstempel</th>
                    <th class="col-val">Wert</th>
                    <th class="col-type">Typ</th>
                    <th class="col-prio">Prio</th>
                    <th class="col-user">Erstellt von</th>
                    <th class="col-comment">Kommentar</th>
                    <th class="col-act"></th>
                </tr>
            </thead>
            <tbody>
                @for(Measurement m : measurements)
                !{var rowId = "mrow-" + m.getId().getSensorId() + "-" + m.getId().getMeasuredAt().toEpochMilli() + "-" + m.getId().getPriority();}
                <tr id="${rowId}">
                    <td class="col-ts mono">${fmt.format(m.getId().getMeasuredAt())}</td>
                    <td class="col-val mono val-bold">${m.getMeasurementValue().stripTrailingZeros().toPlainString()}</td>
                    <td class="col-type">
                        <span class="src-badge src-${m.getSourceType()}">${m.getSourceType()}</span>
                    </td>
                    <td class="col-prio">${m.getId().getPriority()}</td>
                    <td class="col-user">${m.getCreatedBy() != null ? m.getCreatedBy() : ""}</td>
                    <td class="col-comment">${m.getComment() != null ? m.getComment() : ""}</td>
                    <td class="col-act">
                        <button class="m-del-btn"
                                title="Messwert löschen"
                                hx-delete="/sensors/${sensorId}/measurements/single?t=${m.getId().getMeasuredAt().toEpochMilli()}&p=${m.getId().getPriority()}"
                                hx-target="#${rowId}"
                                hx-swap="outerHTML"
                                hx-confirm="Diesen Messwert löschen?">
                            <svg width="13" height="13" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                      d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                            </svg>
                        </button>
                    </td>
                </tr>
                @endfor
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <div class="m-pagination">
        <span class="m-page-info">
            Seite ${currentPage + 1} von ${totalPages}
            &nbsp;&middot;&nbsp;
            ${pageSize} pro Seite
        </span>
        <div class="m-page-btns">
            @if(currentPage > 0)
            <button class="btn btn-outline m-page-btn"
                    hx-get="/sensors/${sensorId}/measurements?page=${currentPage - 1}&size=${pageSize}&from=${from}&to=${to}&sourceType=${sourceType}"
                    hx-target="#measurements-list"
                    hx-swap="innerHTML">&laquo; Zurück</button>
            @endif
            @if(currentPage < totalPages - 1)
            <button class="btn btn-outline m-page-btn"
                    hx-get="/sensors/${sensorId}/measurements?page=${currentPage + 1}&size=${pageSize}&from=${from}&to=${to}&sourceType=${sourceType}"
                    hx-target="#measurements-list"
                    hx-swap="innerHTML">Weiter &raquo;</button>
            @endif
        </div>
    </div>
@endif

<style>
    /* Filter bar */
    .m-filter-bar {
        padding: var(--spacing-md) var(--spacing-lg) 0;
        border-bottom: 1px solid var(--border-color);
        margin-bottom: var(--spacing-sm);
    }
    .m-filter-row {
        display: flex;
        flex-wrap: wrap;
        gap: var(--spacing-md);
        align-items: flex-end;
        margin-bottom: var(--spacing-md);
    }
    .m-filter-group {
        display: flex;
        flex-direction: column;
        gap: 4px;
    }
    .m-filter-group label {
        font-size: 0.7rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: var(--text-secondary);
    }
    .m-filter-input {
        padding: 5px 8px;
        border: 1px solid var(--border-color);
        border-radius: var(--radius-md);
        font-size: var(--font-size-sm);
        background: var(--surface);
        color: var(--text-primary);
        height: 32px;
        box-sizing: border-box;
    }
    .m-filter-input:focus {
        outline: none;
        border-color: var(--primary-color);
        box-shadow: 0 0 0 2px rgba(59,130,246,0.15);
    }
    input[type="datetime-local"].m-filter-input { min-width: 170px; }
    select.m-filter-input { min-width: 130px; }
    .m-filter-clear {
        font-size: var(--font-size-sm);
        color: var(--text-secondary);
        cursor: pointer;
        padding: 5px 8px;
        align-self: flex-end;
        border-radius: var(--radius-md);
        border: 1px solid var(--border-color);
        height: 32px;
        display: inline-flex;
        align-items: center;
        text-decoration: none;
        white-space: nowrap;
    }
    .m-filter-clear:hover { color: var(--text-primary); background: var(--background); }
    .m-filter-meta {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding-bottom: var(--spacing-md);
        font-size: var(--font-size-sm);
        color: var(--text-secondary);
    }
    .btn-delete-all {
        background: none;
        border: 1px solid #fca5a5;
        color: #991b1b;
        border-radius: var(--radius-md);
        padding: 4px 10px;
        font-size: var(--font-size-sm);
        cursor: pointer;
        font-weight: 500;
    }
    .btn-delete-all:hover { background: #fee2e2; }

    /* Table */
    .m-table-wrap {
        overflow-x: auto;
        padding: 0 var(--spacing-lg);
    }
    .m-table {
        width: 100%;
        border-collapse: collapse;
        font-size: var(--font-size-sm);
    }
    .m-table th {
        padding: 8px 10px;
        text-align: left;
        font-size: 0.7rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: var(--text-secondary);
        background: var(--background);
        border-bottom: 2px solid var(--border-color);
        white-space: nowrap;
    }
    .m-table td {
        padding: 7px 10px;
        border-bottom: 1px solid var(--border-color);
        vertical-align: middle;
    }
    .m-table tbody tr:hover { background: var(--background); }
    .m-table tbody tr:last-child td { border-bottom: none; }

    .col-ts      { min-width: 150px; }
    .col-val     { min-width: 90px; }
    .col-type    { width: 90px; }
    .col-prio    { width: 50px; text-align: center; }
    .col-user    { min-width: 90px; }
    .col-comment { color: var(--text-secondary); font-size: 0.78rem; }
    .col-act     { width: 36px; text-align: right; }

    .mono { font-family: monospace; }
    .val-bold { font-weight: 600; }

    /* Source type badges */
    .src-badge {
        display: inline-block;
        padding: 2px 7px;
        border-radius: 9999px;
        font-size: 0.68rem;
        font-weight: 600;
        white-space: nowrap;
    }
    .src-automatic { background: #dbeafe; color: #1e40af; }
    .src-manual    { background: #fef9c3; color: #854d0e; }
    .src-corrected { background: #ffedd5; color: #9a3412; }
    .src-validated { background: #d1fae5; color: #065f46; }

    /* Delete button */
    .m-del-btn {
        background: none;
        border: none;
        cursor: pointer;
        padding: 3px;
        color: var(--text-secondary);
        border-radius: var(--radius-sm);
        display: inline-flex;
        align-items: center;
        opacity: 0.4;
        transition: all 0.15s;
    }
    .m-table tr:hover .m-del-btn { opacity: 1; }
    .m-del-btn:hover { color: #dc2626; background: #fee2e2; }

    /* Empty state */
    .m-empty {
        text-align: center;
        padding: var(--spacing-xl) var(--spacing-lg);
        color: var(--text-secondary);
        font-size: var(--font-size-sm);
    }

    /* Pagination */
    .m-pagination {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: var(--spacing-md) var(--spacing-lg);
        border-top: 1px solid var(--border-color);
        margin-top: var(--spacing-sm);
    }
    .m-page-info { font-size: var(--font-size-sm); color: var(--text-secondary); }
    .m-page-btns { display: flex; gap: var(--spacing-sm); }
    .m-page-btn  { padding: 4px 12px; font-size: var(--font-size-sm); }
</style>
