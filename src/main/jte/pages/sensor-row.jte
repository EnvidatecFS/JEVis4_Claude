@import org.jevis.model.Sensor
@import java.time.format.DateTimeFormatter

@param Sensor sensor

!{var formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm").withZone(java.time.ZoneId.systemDefault());}

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
