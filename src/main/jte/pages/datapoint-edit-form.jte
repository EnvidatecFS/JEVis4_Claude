@import org.jevis.model.NodeRedDataPoint
@import org.jevis.model.Sensor
@import java.util.List

@param NodeRedDataPoint dataPoint
@param List<Sensor> sensors
@param List<String> measurementTypes
@param String message = ""
@param boolean success = false

<div class="modal-overlay" onclick="if(event.target===this) closeDpModal()">
    <div class="modal-content">

        <div class="modal-header">
            <div>
                <h2 class="modal-title">Messpunkt-Zuordnung bearbeiten</h2>
                <p class="modal-subtitle">
                    Remote-ID: <strong>${dataPoint.getRemoteId()}</strong>
                </p>
            </div>
            <button class="modal-close" onclick="closeDpModal()">&times;</button>
        </div>

        @if(!message.isEmpty())
            <div class="alert ${success ? "alert-success" : "alert-danger"}" style="margin: 0 var(--spacing-xl);">${message}</div>
        @endif

        <form hx-post="/devices/${dataPoint.getDevice().getId()}/datapoints/${dataPoint.getId()}"
              hx-target="#modal-container"
              hx-swap="innerHTML">
            <input type="hidden" name="_method" value="PUT">

            <div class="dp-modal-body">

                <!-- Zuordnungs-Details -->
                <div class="section-title">Zuordnung</div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="remoteId">Remote-ID *</label>
                        <input type="text" id="remoteId" name="remoteId" required
                               value="${dataPoint.getRemoteId()}"
                               placeholder="z.B. fbf2f46773a02bbf">
                        <small class="form-help">Die ID des Messpunkts in Node-RED</small>
                    </div>
                    <div class="form-group">
                        <label for="remoteName">Remote-Name</label>
                        <input type="text" id="remoteName" name="remoteName"
                               value="${dataPoint.getRemoteName() != null ? dataPoint.getRemoteName() : ""}"
                               placeholder="z.B. Hauptzähler2Energy">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="isActive">Status</label>
                        <select id="isActive" name="isActive">
                            <option value="true" selected="${dataPoint.getIsActive()}">Aktiv</option>
                            <option value="false" selected="${!dataPoint.getIsActive()}">Inaktiv</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="fetchIntervalMinutes">Abruf-Intervall</label>
                        <select id="fetchIntervalMinutes" name="fetchIntervalMinutes">
                            <option value="5"   selected="${dataPoint.getFetchIntervalMinutes() != null && dataPoint.getFetchIntervalMinutes() == 5}">Alle 5 Minuten</option>
                            <option value="10"  selected="${dataPoint.getFetchIntervalMinutes() != null && dataPoint.getFetchIntervalMinutes() == 10}">Alle 10 Minuten</option>
                            <option value="15"  selected="${dataPoint.getFetchIntervalMinutes() == null || dataPoint.getFetchIntervalMinutes() == 15}">Alle 15 Minuten (Standard)</option>
                            <option value="30"  selected="${dataPoint.getFetchIntervalMinutes() != null && dataPoint.getFetchIntervalMinutes() == 30}">Alle 30 Minuten</option>
                            <option value="60"  selected="${dataPoint.getFetchIntervalMinutes() != null && dataPoint.getFetchIntervalMinutes() == 60}">Stündlich</option>
                            <option value="120" selected="${dataPoint.getFetchIntervalMinutes() != null && dataPoint.getFetchIntervalMinutes() == 120}">Alle 2 Stunden</option>
                            <option value="360" selected="${dataPoint.getFetchIntervalMinutes() != null && dataPoint.getFetchIntervalMinutes() == 360}">Alle 6 Stunden</option>
                            <option value="720" selected="${dataPoint.getFetchIntervalMinutes() != null && dataPoint.getFetchIntervalMinutes() == 720}">Alle 12 Stunden</option>
                            <option value="1440" selected="${dataPoint.getFetchIntervalMinutes() != null && dataPoint.getFetchIntervalMinutes() == 1440}">Täglich</option>
                        </select>
                        <small class="form-help">Wie häufig Daten per Job abgerufen werden</small>
                    </div>
                </div>

                <!-- Sensor-Zuordnung -->
                <div class="section-title" style="margin-top: var(--spacing-lg);">Sensor-Zuordnung</div>

                <div class="sensor-mode-tabs" id="dpSensorModeTabs">
                    <button type="button" class="tab-btn tab-active" id="dpTabExisting"
                            onclick="dpSwitchTab('existing')">Bestehenden Sensor verwenden</button>
                    <button type="button" class="tab-btn" id="dpTabNew"
                            onclick="dpSwitchTab('new')">Neuen Sensor anlegen</button>
                </div>

                <!-- Tab: Bestehender Sensor -->
                <div id="dpPanelExisting">
                    <div class="form-group">
                        <label for="sensorId">Sensor *</label>
                        <select id="sensorId" name="sensorId">
                            <option value="">-- Sensor auswählen --</option>
                            @for(Sensor s : sensors)
                                <option value="${s.getId()}"
                                        selected="${s.getId() != null && s.getId().equals(dataPoint.getSensor().getId())}">
                                    ${s.getSensorName() != null ? s.getSensorName() : s.getSensorCode()}
                                    (${s.getSensorCode()} · ${s.getMeasurementType()} · ${s.getUnit()})
                                </option>
                            @endfor
                        </select>
                    </div>
                    <input type="hidden" name="sensorMode" id="sensorModeHidden" value="existing">
                </div>

                <!-- Tab: Neuer Sensor -->
                <div id="dpPanelNew" style="display:none;">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="sensorCode">Sensor-Code *</label>
                            <input type="text" id="sensorCode" name="sensorCode"
                                   placeholder="z.B. PV-ANLAGE-01-POWER">
                            <small class="form-help">Eindeutiger technischer Bezeichner</small>
                        </div>
                        <div class="form-group">
                            <label for="sensorName">Anzeigename</label>
                            <input type="text" id="sensorName" name="sensorName"
                                   placeholder="z.B. PV Anlage 1 - Leistung">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="measurementType">Messtyp *</label>
                            <input type="text" id="measurementType" name="measurementType"
                                   list="measurementTypeList"
                                   placeholder="z.B. power, energy, temperature">
                            <datalist id="measurementTypeList">
                                @for(String mt : measurementTypes)
                                    <option value="${mt}"></option>
                                @endfor
                            </datalist>
                        </div>
                        <div class="form-group">
                            <label for="unit">Einheit *</label>
                            <input type="text" id="unit" name="unit"
                                   placeholder="z.B. kW, kWh, °C, V">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="location">Standort</label>
                        <input type="text" id="location" name="location"
                               placeholder="z.B. Dach Süd, Halle A">
                    </div>
                </div>

            </div><!-- end dp-modal-body -->

            <div class="form-actions">
                <button type="button" class="btn btn-outline" onclick="closeDpModal()">Abbrechen</button>
                <button type="submit" class="btn btn-primary">Speichern</button>
            </div>
        </form>

    </div>
</div>

<script>
function closeDpModal() {
    document.getElementById('modal-container').innerHTML = '';
    htmx.trigger('#datapoints-table-container', 'load');
}

function dpSwitchTab(mode) {
    document.getElementById('dpPanelExisting').style.display = mode === 'existing' ? 'block' : 'none';
    document.getElementById('dpPanelNew').style.display = mode === 'new' ? 'block' : 'none';
    document.getElementById('dpTabExisting').className = 'tab-btn' + (mode === 'existing' ? ' tab-active' : '');
    document.getElementById('dpTabNew').className = 'tab-btn' + (mode === 'new' ? ' tab-active' : '');
    document.getElementById('sensorModeHidden').value = mode;

    // Toggle required on new-sensor fields
    var newRequired = mode === 'new';
    ['sensorCode', 'measurementType', 'unit'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el) el.required = newRequired;
    });
    var sensorIdEl = document.getElementById('sensorId');
    if (sensorIdEl) sensorIdEl.required = !newRequired;
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeDpModal();
});
</script>

<style>
    .modal-overlay {
        position: fixed; top: 0; left: 0; right: 0; bottom: 0;
        background: rgba(0,0,0,0.5); display: flex; align-items: center;
        justify-content: center; z-index: 1000;
    }
    .modal-content {
        background: var(--surface); border-radius: var(--radius-lg);
        width: 90%; max-width: 620px;
        box-shadow: var(--shadow-lg); max-height: 90vh; overflow-y: auto;
    }
    .modal-header {
        display: flex; justify-content: space-between; align-items: flex-start;
        padding: var(--spacing-xl);
        border-bottom: 1px solid var(--border-color);
    }
    .modal-title { margin: 0 0 4px 0; font-size: 1.2rem; }
    .modal-subtitle { color: var(--text-secondary); margin: 0; font-size: var(--font-size-sm); }
    .modal-close {
        background: none; border: none; font-size: 1.5rem;
        cursor: pointer; color: var(--text-secondary); padding: 4px 8px;
        border-radius: var(--radius-md); flex-shrink: 0;
    }
    .modal-close:hover { background: var(--background); }
    .dp-modal-body { padding: var(--spacing-xl); }
    .section-title {
        font-size: var(--font-size-sm); font-weight: 600;
        color: var(--text-secondary); text-transform: uppercase;
        letter-spacing: 0.05em; margin-bottom: var(--spacing-md);
        padding-bottom: var(--spacing-sm);
        border-bottom: 1px solid var(--border-color);
    }
    .sensor-mode-tabs {
        display: flex; border-bottom: 2px solid var(--border-color);
        margin-bottom: var(--spacing-lg);
    }
    .tab-btn {
        background: none; border: none; padding: var(--spacing-md) var(--spacing-lg);
        cursor: pointer; font-size: var(--font-size-sm); color: var(--text-secondary);
        border-bottom: 2px solid transparent; margin-bottom: -2px;
        transition: all 0.2s; font-weight: 500;
    }
    .tab-btn:hover { color: var(--primary-color); }
    .tab-active { color: var(--primary-color) !important; border-bottom-color: var(--primary-color) !important; }
    .form-group { margin-bottom: var(--spacing-md); }
    .form-group label { display: block; margin-bottom: var(--spacing-sm); font-weight: 500; font-size: var(--font-size-sm); }
    .form-group input, .form-group select {
        width: 100%; padding: var(--spacing-md); border: 1px solid var(--border-color);
        border-radius: var(--radius-md); font-size: var(--font-size-base);
        background: var(--surface); color: var(--text-primary); box-sizing: border-box;
    }
    .form-group input:focus, .form-group select:focus {
        outline: none; border-color: var(--primary-color); box-shadow: 0 0 0 3px rgba(59,130,246,0.1);
    }
    .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: var(--spacing-md); }
    .form-help { display: block; margin-top: 4px; color: var(--text-secondary); font-size: 0.75rem; }
    .form-actions {
        display: flex; justify-content: flex-end; gap: var(--spacing-md);
        padding: var(--spacing-lg) var(--spacing-xl);
        border-top: 1px solid var(--border-color);
    }
    .alert { padding: var(--spacing-md); border-radius: var(--radius-md); margin-bottom: var(--spacing-md); }
    .alert-success { background-color: #d1fae5; color: #065f46; }
    .alert-danger { background-color: #fee2e2; color: #991b1b; }
</style>
