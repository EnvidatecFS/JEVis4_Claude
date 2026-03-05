@import org.jevis.model.NodeRedDevice
@import java.util.List
@import java.time.format.DateTimeFormatter

@param List<NodeRedDevice> devices

!{var formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm").withZone(java.time.ZoneId.systemDefault());}

<div class="table-header">
    <span class="table-info">${devices.size()} Geräte</span>
</div>

<div class="table-responsive">
    <table class="data-table">
        <thead>
            <tr>
                <th>Name</th>
                <th>API-URL</th>
                <th>Status</th>
                <th>Zuletzt erreicht</th>
                <th>Letzter Import</th>
                <th class="actions-col">Aktionen</th>
            </tr>
        </thead>
        <tbody>
            @if(devices.isEmpty())
                <tr>
                    <td colspan="6" class="empty-state">
                        <p>Keine Geräte konfiguriert</p>
                        <p class="text-muted">Erstellen Sie ein neues Gerät, um Daten zu importieren</p>
                    </td>
                </tr>
            @else
                @for(NodeRedDevice device : devices)
                    <tr id="device-row-${device.getId()}">
                        <td>
                            <a href="/devices/${device.getId()}" class="device-link">${device.getDeviceName()}</a>
                        </td>
                        <td><code class="api-url">${device.getApiUrl()}</code></td>
                        <td>
                            @if(device.getIsActive())
                                <span class="status-badge status-active">Aktiv</span>
                            @else
                                <span class="status-badge status-inactive">Inaktiv</span>
                            @endif
                        </td>
                        <td class="date-cell">${device.getLastReachedAt() != null ? formatter.format(device.getLastReachedAt()) : "-"}</td>
                        <td class="date-cell">${device.getLastDataImportAt() != null ? formatter.format(device.getLastDataImportAt()) : "-"}</td>
                        <td class="actions-cell">
                            <button class="btn-icon" title="Details"
                                    onclick="window.location.href='/devices/${device.getId()}'">
                                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                </svg>
                            </button>
                            <button class="btn-icon" title="Bearbeiten"
                                    hx-get="/devices/${device.getId()}/edit"
                                    hx-target="#modal-container"
                                    hx-swap="innerHTML">
                                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                                </svg>
                            </button>
                            <button class="btn-icon btn-icon-danger" title="Löschen"
                                    hx-delete="/devices/${device.getId()}"
                                    hx-target="#device-row-${device.getId()}"
                                    hx-swap="outerHTML"
                                    hx-confirm="Möchten Sie dieses Gerät wirklich löschen? Alle Messpunkt-Zuordnungen werden ebenfalls gelöscht!">
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
    .table-responsive { overflow-x: auto; }
    .data-table { width: 100%; border-collapse: collapse; font-size: var(--font-size-sm); }
    .data-table th, .data-table td { padding: var(--spacing-md); text-align: left; border-bottom: 1px solid var(--border-color); }
    .data-table th { background-color: var(--background); font-weight: 600; color: var(--text-secondary); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; }
    .data-table tbody tr:hover { background-color: var(--background); }
    .device-link { color: var(--primary-color); text-decoration: none; font-weight: 500; }
    .device-link:hover { text-decoration: underline; }
    .api-url { background-color: var(--background); padding: 2px 6px; border-radius: var(--radius-sm); font-family: monospace; font-size: 0.8rem; word-break: break-all; }
    .status-badge { display: inline-block; padding: 4px 10px; border-radius: var(--radius-lg); font-size: 0.75rem; font-weight: 500; }
    .status-active { background-color: #d1fae5; color: #065f46; }
    .status-inactive { background-color: #fee2e2; color: #991b1b; }
    .date-cell { white-space: nowrap; color: var(--text-secondary); }
    .actions-col { width: 120px; text-align: center; }
    .actions-cell { text-align: center; white-space: nowrap; }
    .btn-icon { background: none; border: none; cursor: pointer; padding: var(--spacing-sm); color: var(--text-secondary); border-radius: var(--radius-md); transition: all 0.2s; }
    .btn-icon:hover { background-color: var(--background); color: var(--primary-color); }
    .btn-icon-danger:hover { background-color: #fee2e2; color: var(--danger-color); }
    .empty-state { text-align: center; padding: var(--spacing-2xl) !important; color: var(--text-secondary); }
</style>
