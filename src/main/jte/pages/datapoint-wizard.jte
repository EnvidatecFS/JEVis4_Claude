@import org.jevis.model.NodeRedDevice
@import org.jevis.model.Sensor
@import java.util.List

@param NodeRedDevice device
@param int step
@param String remoteId = ""
@param String remoteName = ""
@param List<Sensor> sensors = java.util.Collections.emptyList()
@param List<String> measurementTypes = java.util.Collections.emptyList()
@param String message = ""
@param boolean success = false

<div class="modal-overlay" onclick="if(event.target===this) this.remove()">
    <div class="modal-content">

        <!-- Header -->
        <div class="modal-header">
            <div>
                <h2 class="modal-title">Messpunkt-Zuordnung anlegen</h2>
                <p class="modal-subtitle">Gerät: <strong>${device.getDeviceName()}</strong></p>
            </div>
            <button class="modal-close" onclick="this.closest('.modal-overlay').remove()">&times;</button>
        </div>

        <!-- Step Indicator -->
        <div class="wizard-steps">
            <div class="wizard-step ${step >= 1 ? "wizard-step-active" : ""}">
                <div class="step-circle">${step > 1 ? "✓" : "1"}</div>
                <span class="step-label">Remote-Details</span>
            </div>
            <div class="wizard-step-line ${step >= 2 ? "wizard-step-line-active" : ""}"></div>
            <div class="wizard-step ${step >= 2 ? "wizard-step-active" : ""}">
                <div class="step-circle">2</div>
                <span class="step-label">Sensor</span>
            </div>
        </div>

        @if(!message.isEmpty())
            <div class="alert ${success ? "alert-success" : "alert-danger"}">${message}</div>
        @endif

        <!-- ===== STEP 1: Remote-Details ===== -->
        @if(step == 1)
        <form hx-post="/devices/${device.getId()}/datapoints/wizard/step2"
              hx-target="#modal-container"
              hx-swap="innerHTML">

            <div class="form-group">
                <label for="remoteId">Remote-ID *</label>
                <input type="text" id="remoteId" name="remoteId" required
                       placeholder="z.B. fbf2f46773a02bbf">
                <small class="form-help">Die ID des Messpunkts in Node-RED (zu finden in der Node-RED Oberfläche)</small>
            </div>

            <div class="form-group">
                <label for="remoteName">Remote-Name</label>
                <input type="text" id="remoteName" name="remoteName"
                       placeholder="z.B. Hauptzähler2Energy">
                <small class="form-help">Optionaler Name zur Identifikation</small>
            </div>

            <div class="form-actions">
                <button type="button" class="btn btn-outline"
                        onclick="this.closest('.modal-overlay').remove()">Abbrechen</button>
                <button type="submit" class="btn btn-primary">
                    Weiter
                    <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="margin-left:4px;vertical-align:middle;">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                    </svg>
                </button>
            </div>
        </form>

        <!-- ===== STEP 2: Sensor-Auswahl ===== -->
        @elseif(step == 2)

        <div class="sensor-mode-tabs" id="sensorModeTabs">
            <button type="button" class="tab-btn tab-active" id="tabExisting"
                    onclick="switchTab('existing')">Bestehenden Sensor verwenden</button>
            <button type="button" class="tab-btn" id="tabNew"
                    onclick="switchTab('new')">Neuen Sensor anlegen</button>
        </div>

        <!-- Tab: Bestehender Sensor -->
        <div id="panelExisting">
            <form hx-post="/devices/${device.getId()}/datapoints/wizard/create"
                  hx-target="#modal-container"
                  hx-swap="innerHTML">
                <input type="hidden" name="remoteId" value="${remoteId}">
                <input type="hidden" name="remoteName" value="${remoteName}">
                <input type="hidden" name="sensorMode" value="existing">

                <div class="form-group" style="margin-top: var(--spacing-lg);">
                    <label for="sensorId">Sensor *</label>
                    <select id="sensorId" name="sensorId" required>
                        <option value="">-- Sensor auswählen --</option>
                        @for(Sensor s : sensors)
                            <option value="${s.getId()}">
                                ${s.getSensorName() != null ? s.getSensorName() : s.getSensorCode()}
                                (${s.getSensorCode()} · ${s.getMeasurementType()} · ${s.getUnit()})
                            </option>
                        @endfor
                    </select>
                </div>

                <div class="form-actions">
                    <button type="button" class="btn btn-outline"
                            hx-get="/devices/${device.getId()}/datapoints/wizard"
                            hx-target="#modal-container"
                            hx-swap="innerHTML">
                        <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="margin-right:4px;vertical-align:middle;">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                        </svg>
                        Zurück
                    </button>
                    <button type="submit" class="btn btn-primary">Zuordnung erstellen</button>
                </div>
            </form>
        </div>

        <!-- Tab: Neuer Sensor -->
        <div id="panelNew" style="display:none;">
            <form hx-post="/devices/${device.getId()}/datapoints/wizard/create"
                  hx-target="#modal-container"
                  hx-swap="innerHTML">
                <input type="hidden" name="remoteId" value="${remoteId}">
                <input type="hidden" name="remoteName" value="${remoteName}">
                <input type="hidden" name="sensorMode" value="new">

                <div class="form-row" style="margin-top: var(--spacing-lg);">
                    <div class="form-group">
                        <label for="sensorCode">Sensor-Code *</label>
                        <input type="text" id="sensorCode" name="sensorCode" required
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
                        <input type="text" id="measurementType" name="measurementType" required
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
                        <input type="text" id="unit" name="unit" required
                               placeholder="z.B. kW, kWh, °C, V">
                    </div>
                </div>

                <div class="form-group">
                    <label for="location">Standort</label>
                    <input type="text" id="location" name="location"
                           placeholder="z.B. Dach Süd, Halle A">
                </div>

                <div class="form-actions">
                    <button type="button" class="btn btn-outline"
                            hx-get="/devices/${device.getId()}/datapoints/wizard"
                            hx-target="#modal-container"
                            hx-swap="innerHTML">
                        <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="margin-right:4px;vertical-align:middle;">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                        </svg>
                        Zurück
                    </button>
                    <button type="submit" class="btn btn-primary">Sensor anlegen &amp; verknüpfen</button>
                </div>
            </form>
        </div>

        @endif

    </div>
</div>

<script>
function switchTab(mode) {
    document.getElementById('panelExisting').style.display = mode === 'existing' ? 'block' : 'none';
    document.getElementById('panelNew').style.display = mode === 'new' ? 'block' : 'none';
    document.getElementById('tabExisting').className = 'tab-btn' + (mode === 'existing' ? ' tab-active' : '');
    document.getElementById('tabNew').className = 'tab-btn' + (mode === 'new' ? ' tab-active' : '');
}
</script>

<style>
    .modal-overlay {
        position: fixed; top: 0; left: 0; right: 0; bottom: 0;
        background: rgba(0,0,0,0.5); display: flex; align-items: center;
        justify-content: center; z-index: 1000;
    }
    .modal-content {
        background: var(--card-background); border-radius: var(--radius-lg);
        padding: var(--spacing-xl); width: 90%; max-width: 600px;
        box-shadow: var(--shadow-lg); max-height: 90vh; overflow-y: auto;
    }
    .modal-header {
        display: flex; justify-content: space-between; align-items: flex-start;
        margin-bottom: var(--spacing-lg);
    }
    .modal-title { margin: 0 0 4px 0; font-size: 1.25rem; }
    .modal-subtitle { color: var(--text-secondary); margin: 0; font-size: var(--font-size-sm); }
    .modal-close {
        background: none; border: none; font-size: 1.5rem;
        cursor: pointer; color: var(--text-secondary); padding: 4px 8px;
        border-radius: var(--radius-md); flex-shrink: 0;
    }
    .modal-close:hover { background: var(--background); }

    /* Step Indicator */
    .wizard-steps {
        display: flex; align-items: center; margin-bottom: var(--spacing-xl);
        padding: var(--spacing-md) 0;
    }
    .wizard-step { display: flex; align-items: center; gap: var(--spacing-sm); }
    .step-circle {
        width: 32px; height: 32px; border-radius: 50%; border: 2px solid var(--border-color);
        display: flex; align-items: center; justify-content: center;
        font-weight: 600; font-size: 0.85rem; color: var(--text-secondary);
        background: var(--card-background); flex-shrink: 0;
    }
    .wizard-step-active .step-circle {
        border-color: var(--primary-color); background: var(--primary-color); color: white;
    }
    .step-label { font-size: var(--font-size-sm); color: var(--text-secondary); white-space: nowrap; }
    .wizard-step-active .step-label { color: var(--text-primary); font-weight: 500; }
    .wizard-step-line {
        flex: 1; height: 2px; background: var(--border-color); margin: 0 var(--spacing-md);
    }
    .wizard-step-line-active { background: var(--primary-color); }

    /* Tabs */
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

    /* Form */
    .form-group { margin-bottom: var(--spacing-md); }
    .form-group label { display: block; margin-bottom: var(--spacing-sm); font-weight: 500; font-size: var(--font-size-sm); }
    .form-group input, .form-group select {
        width: 100%; padding: var(--spacing-md); border: 1px solid var(--border-color);
        border-radius: var(--radius-md); font-size: var(--font-size-base);
        background: var(--card-background); color: var(--text-primary); box-sizing: border-box;
    }
    .form-group input:focus, .form-group select:focus {
        outline: none; border-color: var(--primary-color); box-shadow: 0 0 0 3px rgba(59,130,246,0.1);
    }
    .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: var(--spacing-md); }
    .form-help { display: block; margin-top: 4px; color: var(--text-secondary); font-size: 0.75rem; }
    .form-actions { display: flex; justify-content: flex-end; gap: var(--spacing-md); margin-top: var(--spacing-xl); padding-top: var(--spacing-md); border-top: 1px solid var(--border-color); }

    .alert { padding: var(--spacing-md); border-radius: var(--radius-md); margin-bottom: var(--spacing-md); }
    .alert-success { background-color: #d1fae5; color: #065f46; }
    .alert-danger { background-color: #fee2e2; color: #991b1b; }
</style>
