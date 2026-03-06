@import org.jevis.model.NodeRedDataPoint
@import java.util.List
@import java.time.format.DateTimeFormatter

@param List<NodeRedDataPoint> dataPoints
@param Long deviceId

!{var formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm:ss").withZone(java.time.ZoneId.systemDefault());}

<div class="table-header">
    <span class="table-info">${dataPoints.size()} Zuordnungen</span>
</div>

<div class="table-responsive">
    <table class="data-table">
        <thead>
            <tr>
                <th>Remote-ID</th>
                <th>Remote-Name</th>
                <th>Sensor</th>
                <th>Status</th>
                <th>Letzter Erfolg</th>
                <th>Letzter Zeitstempel</th>
                <th>Importiert</th>
                <th>Intervall</th>
                <th class="actions-col">Aktionen</th>
            </tr>
        </thead>
        <tbody>
            @if(dataPoints.isEmpty())
                <tr>
                    <td colspan="9" class="empty-state">
                        <p>Keine Messpunkt-Zuordnungen vorhanden</p>
                        <p class="text-muted">Fügen Sie eine Zuordnung hinzu, um Daten zu importieren</p>
                    </td>
                </tr>
            @else
                @for(NodeRedDataPoint dp : dataPoints)
                    <tr id="dp-row-${dp.getId()}">
                        <td><code class="remote-id">${dp.getRemoteId()}</code></td>
                        <td>${dp.getRemoteName() != null ? dp.getRemoteName() : "-"}</td>
                        <td>
                            <span class="sensor-info">
                                ${dp.getSensor().getSensorName() != null ? dp.getSensor().getSensorName() : dp.getSensor().getSensorCode()}
                                <small class="text-muted">(${dp.getSensor().getSensorCode()})</small>
                            </span>
                        </td>
                        <td>
                            @if(dp.getIsActive())
                                <span class="status-badge status-active">Aktiv</span>
                            @else
                                <span class="status-badge status-inactive">Inaktiv</span>
                            @endif
                        </td>
                        <td class="date-cell">${dp.getLastSuccessAt() != null ? formatter.format(dp.getLastSuccessAt()) : "-"}</td>
                        <td class="date-cell">${dp.getLastDataTimestamp() != null ? formatter.format(dp.getLastDataTimestamp()) : "-"}</td>
                        <td>${dp.getLastImportCount() != null ? dp.getLastImportCount().toString() : "-"}</td>
                        <td class="date-cell">
                            !{var mins = dp.getFetchIntervalMinutes() != null ? dp.getFetchIntervalMinutes() : 15;}
                            @if(mins < 60)
                                ${mins} min
                            @elseif(mins == 60)
                                1 h
                            @elseif(mins == 1440)
                                24 h
                            @else
                                ${mins / 60} h
                            @endif
                        </td>
                        <td class="actions-cell">
                            <button class="btn-icon btn-icon-fetch" title="Jetzt auslesen"
                                    hx-post="/devices/${deviceId}/datapoints/${dp.getId()}/fetch"
                                    hx-target="#fetch-result"
                                    hx-swap="innerHTML">
                                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                                </svg>
                            </button>
                            <button class="btn-icon" title="Bearbeiten"
                                    hx-get="/devices/${deviceId}/datapoints/${dp.getId()}/edit"
                                    hx-target="#modal-container"
                                    hx-swap="innerHTML">
                                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                                </svg>
                            </button>
                            <button class="btn-icon btn-icon-danger" title="Zuordnung löschen"
                                    hx-delete="/devices/${deviceId}/datapoints/${dp.getId()}"
                                    hx-target="#dp-row-${dp.getId()}"
                                    hx-swap="outerHTML"
                                    hx-confirm="Möchten Sie diese Messpunkt-Zuordnung wirklich löschen?">
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

<style>
    .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--spacing-md); }
    .table-info { color: var(--text-secondary); font-size: var(--font-size-sm); }
    .table-responsive { overflow-x: auto; }
    .data-table { width: 100%; border-collapse: collapse; font-size: var(--font-size-sm); }
    .data-table th, .data-table td { padding: var(--spacing-md); text-align: left; border-bottom: 1px solid var(--border-color); }
    .data-table th { background-color: var(--background); font-weight: 600; color: var(--text-secondary); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; }
    .data-table tbody tr:hover { background-color: var(--background); }
    .remote-id { background-color: var(--background); padding: 2px 6px; border-radius: var(--radius-sm); font-family: monospace; font-size: 0.85rem; }
    .sensor-info small { display: block; }
    .status-badge { display: inline-block; padding: 4px 10px; border-radius: var(--radius-lg); font-size: 0.75rem; font-weight: 500; }
    .status-active { background-color: #d1fae5; color: #065f46; }
    .status-inactive { background-color: #fee2e2; color: #991b1b; }
    .date-cell { white-space: nowrap; color: var(--text-secondary); font-size: 0.8rem; }
    .actions-col { width: 130px; text-align: center; }
    .actions-cell { text-align: center; white-space: nowrap; }
    .btn-icon { background: none; border: none; cursor: pointer; padding: var(--spacing-sm); color: var(--text-secondary); border-radius: var(--radius-md); transition: all 0.2s; }
    .btn-icon:hover { background-color: var(--background); color: var(--primary-color); }
    .btn-icon-fetch:hover { background-color: #dbeafe; color: #1e40af; }
    .btn-icon-danger:hover { background-color: #fee2e2; color: var(--danger-color); }
    .empty-state { text-align: center; padding: var(--spacing-2xl) !important; color: var(--text-secondary); }
    .text-muted { color: var(--text-secondary); font-size: var(--font-size-sm); }
</style>
