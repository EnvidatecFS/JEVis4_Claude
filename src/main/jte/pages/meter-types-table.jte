@import org.jevis.model.MeterType
@import java.util.List

@param List<MeterType> meterTypes

@if(meterTypes.isEmpty())
    <div class="card" style="padding: var(--spacing-xl); text-align: center; color: var(--text-secondary);">
        Keine Zählertypen vorhanden.
        <br><br>
        <button class="btn btn-primary" hx-get="/meter-types/new" hx-target="#modal-container" hx-swap="innerHTML">
            + Ersten Zählertyp anlegen
        </button>
    </div>
@else
    <div class="card">
        <table class="data-table" style="width:100%; border-collapse: collapse;">
            <thead>
                <tr>
                    <th>Gerätetype</th>
                    <th>Hersteller</th>
                    <th>Genauigkeit</th>
                    <th>Dezimalstellen</th>
                    <th>Aktionen</th>
                </tr>
            </thead>
            <tbody>
                @for(MeterType mt : meterTypes)
                    <tr id="meter-type-row-${mt.getId()}">
                        <td>${mt.getDeviceType() != null ? mt.getDeviceType() : "-"}</td>
                        <td>${mt.getManufacturer() != null ? mt.getManufacturer() : "-"}</td>
                        <td>${mt.getAccuracy() != null ? mt.getAccuracy() : "-"}</td>
                        <td>${mt.getDecimalPlaces() != null ? mt.getDecimalPlaces().toString() : "-"}</td>
                        <td>
                            <button class="btn btn-outline btn-sm"
                                    hx-get="/meter-types/${mt.getId()}/edit"
                                    hx-target="#modal-container"
                                    hx-swap="innerHTML">
                                Bearbeiten
                            </button>
                            <button class="btn btn-sm" style="color: var(--error-color);"
                                    hx-delete="/meter-types/${mt.getId()}"
                                    hx-target="#meter-type-row-${mt.getId()}"
                                    hx-swap="outerHTML"
                                    hx-confirm="Zählertyp wirklich löschen?">
                                Löschen
                            </button>
                        </td>
                    </tr>
                @endfor
            </tbody>
        </table>
    </div>
@endif
<style>
    .data-table th, .data-table td { padding: var(--spacing-sm) var(--spacing-md); text-align: left; border-bottom: 1px solid var(--border-color); }
    .data-table th { background: var(--background); font-weight: 600; font-size: 0.75rem; text-transform: uppercase; color: var(--text-secondary); }
    .btn-sm { padding: var(--spacing-sm) var(--spacing-md); font-size: var(--font-size-sm); }
</style>
