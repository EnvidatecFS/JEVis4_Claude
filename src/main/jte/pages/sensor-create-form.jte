@import org.jevis.model.Sensor
@import java.util.List

@param Sensor sensor = new Sensor()
@param List<String> measurementTypes = java.util.Collections.emptyList()
@param Boolean success = null
@param String message = null

<div class="modal-backdrop" onclick="closeModal()"></div>
<div class="modal">
    <div class="modal-header">
        <h3>Neuer Messpunkt</h3>
        <button class="modal-close" onclick="closeModal()">&times;</button>
    </div>

    @if(success != null)
        @if(success)
            <div class="alert alert-success">
                ${message}
                <script>
                    setTimeout(function() {
                        closeModal();
                        htmx.ajax('GET', '/sensors/table', '#sensors-table-container');
                    }, 1500);
                </script>
            </div>
        @else
            <div class="alert alert-danger">${message}</div>
        @endif
    @endif

    @if(success == null || !success)
    <form hx-post="/sensors"
          hx-target="#modal-container"
          hx-swap="innerHTML">

        <div class="modal-body">
            <div class="form-row">
                <div class="form-group">
                    <label for="sensorCode">Sensor-Code *</label>
                    <input type="text" id="sensorCode" name="sensorCode"
                           value="${sensor.getSensorCode() != null ? sensor.getSensorCode() : ""}"
                           required
                           placeholder="z.B. PV_INV_001">
                    <span class="form-help">Eindeutiger Identifikator für den Sensor</span>
                </div>
                <div class="form-group">
                    <label for="sensorName">Name</label>
                    <input type="text" id="sensorName" name="sensorName"
                           value="${sensor.getSensorName() != null ? sensor.getSensorName() : ""}"
                           placeholder="z.B. Wechselrichter Dach Ost">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="measurementType">Messtyp *</label>
                    <input type="text" id="measurementType" name="measurementType"
                           value="${sensor.getMeasurementType() != null ? sensor.getMeasurementType() : ""}"
                           required
                           list="measurementTypeList"
                           placeholder="z.B. power, voltage, temperature">
                    <datalist id="measurementTypeList">
                        <option value="power"></option>
                        <option value="voltage"></option>
                        <option value="current"></option>
                        <option value="temperature"></option>
                        <option value="irradiance"></option>
                        <option value="energy"></option>
                        @for(String mt : measurementTypes)
                            <option value="${mt}"></option>
                        @endfor
                    </datalist>
                </div>
                <div class="form-group">
                    <label for="unit">Einheit *</label>
                    <input type="text" id="unit" name="unit"
                           value="${sensor.getUnit() != null ? sensor.getUnit() : ""}"
                           required
                           list="unitList"
                           placeholder="z.B. kW, V, °C">
                    <datalist id="unitList">
                        <option value="kW"></option>
                        <option value="W"></option>
                        <option value="kWh"></option>
                        <option value="Wh"></option>
                        <option value="V"></option>
                        <option value="A"></option>
                        <option value="°C"></option>
                        <option value="W/m²"></option>
                        <option value="%"></option>
                    </datalist>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="location">Standort</label>
                    <input type="text" id="location" name="location"
                           value="${sensor.getLocation() != null ? sensor.getLocation() : ""}"
                           placeholder="z.B. Gebäude A, Dach">
                </div>
                <div class="form-group">
                    <label for="isActive">Status</label>
                    <select id="isActive" name="isActive">
                        <option value="true" selected>Aktiv</option>
                        <option value="false">Inaktiv</option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="manufacturer">Hersteller</label>
                    <input type="text" id="manufacturer" name="manufacturer"
                           value="${sensor.getManufacturer() != null ? sensor.getManufacturer() : ""}"
                           placeholder="z.B. SMA, Fronius">
                </div>
                <div class="form-group">
                    <label for="model">Modell</label>
                    <input type="text" id="model" name="model"
                           value="${sensor.getModel() != null ? sensor.getModel() : ""}"
                           placeholder="z.B. Sunny Boy 5.0">
                </div>
            </div>

            <div class="form-group">
                <label for="description">Beschreibung</label>
                <textarea id="description" name="description" rows="3"
                          placeholder="Optionale Beschreibung des Messpunkts...">${sensor.getDescription() != null ? sensor.getDescription() : ""}</textarea>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="calibrationDate">Kalibrierdatum</label>
                    <input type="date" id="calibrationDate" name="calibrationDate"
                           value="">
                </div>
            </div>
        </div>

        <div class="modal-footer">
            <button type="button" class="btn btn-outline" onclick="closeModal()">Abbrechen</button>
            <button type="submit" class="btn btn-primary">Erstellen</button>
        </div>
    </form>
    @endif
</div>

<style>
    .modal-backdrop {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: rgba(0, 0, 0, 0.5);
        z-index: 1000;
    }
    .modal {
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: var(--surface);
        border-radius: var(--radius-xl);
        box-shadow: var(--shadow-lg);
        width: 90%;
        max-width: 600px;
        max-height: 90vh;
        overflow-y: auto;
        z-index: 1001;
    }
    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: var(--spacing-lg);
        border-bottom: 1px solid var(--border-color);
    }
    .modal-header h3 {
        margin: 0;
    }
    .modal-close {
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        color: var(--text-secondary);
        padding: var(--spacing-sm);
        line-height: 1;
    }
    .modal-close:hover {
        color: var(--text-primary);
    }
    .modal-body {
        padding: var(--spacing-lg);
    }
    .modal-footer {
        display: flex;
        justify-content: flex-end;
        gap: var(--spacing-md);
        padding: var(--spacing-lg);
        border-top: 1px solid var(--border-color);
    }
    .form-row {
        display: flex;
        gap: var(--spacing-lg);
    }
    .form-row .form-group {
        flex: 1;
    }
    @media (max-width: 600px) {
        .form-row {
            flex-direction: column;
            gap: 0;
        }
    }
</style>

<script>
    function closeModal() {
        document.getElementById('modal-container').innerHTML = '';
        // Refresh the table
        htmx.ajax('GET', '/sensors/table', '#sensors-table-container');
    }

    // Close modal on escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeModal();
        }
    });
</script>
