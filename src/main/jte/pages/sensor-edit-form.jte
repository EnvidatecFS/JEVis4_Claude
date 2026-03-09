@import org.jevis.model.Sensor
@import org.jevis.model.MeterType
@import java.util.List

@param Sensor sensor
@param List<String> measurementTypes = java.util.Collections.emptyList()
@param Boolean success = null
@param String message = null
@param java.util.List<org.jevis.model.Sensor> allSensors = java.util.Collections.emptyList()
@param java.util.List<org.jevis.model.MeterType> allMeterTypes = java.util.Collections.emptyList()
@param String defaultMeasurementDate = null

<div class="modal-backdrop"></div>
<div class="modal" style="min-height: 580px;">
    <div class="modal-header">
        <h3>Messpunkt bearbeiten</h3>
        <button class="modal-close" onclick="closeModal()">&times;</button>
    </div>

    <!-- Tab Navigation -->
    <div class="modal-tabs">
        <button type="button" class="modal-tab modal-tab-active" id="tab-settings"
                onclick="switchModalTab('settings')">Einstellungen</button>
        <button type="button" class="modal-tab" id="tab-zaehler"
                onclick="switchModalTab('zaehler')">Zähler</button>
        <button type="button" class="modal-tab" id="tab-measurements"
                onclick="switchModalTab('measurements')">Messwerte</button>
    </div>

    <!-- Tab: Einstellungen -->
    <div id="panel-settings">

    @if(success != null)
        @if(success)
            <div class="alert alert-success">${message}</div>
            <script>
                setTimeout(function() {
                    closeModal();
                    htmx.ajax('GET', '/sensors/table', '#sensors-table-container');
                }, 1500);
            </script>
        @else
            <div class="alert alert-danger">${message}</div>
        @endif
    @endif

    <form hx-put="/sensors/${sensor.getId()}"
          hx-target="#modal-container"
          hx-swap="innerHTML"
          hx-encoding="multipart/form-data">

        <div class="modal-body">
            <div class="form-row">
                <div class="form-group">
                    <label for="sensorCode">Sensor-Code *</label>
                    <input type="text" id="sensorCode" name="sensorCode"
                           value="${sensor.getSensorCode()}" readonly disabled
                           class="input-readonly">
                    <span class="form-help">Der Sensor-Code kann nicht geändert werden</span>
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
                           value="${sensor.getMeasurementType()}" required
                           list="measurementTypeList"
                           placeholder="z.B. power, voltage, temperature">
                    <datalist id="measurementTypeList">
                        @for(String mt : measurementTypes)
                            <option value="${mt}"></option>
                        @endfor
                    </datalist>
                </div>
                <div class="form-group">
                    <label for="unit">Einheit *</label>
                    <input type="text" id="unit" name="unit"
                           value="${sensor.getUnit()}" required
                           placeholder="z.B. kW, V, °C">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="medium">Medium</label>
                    <select id="medium" name="medium">
                        <option value="">-- Bitte wählen --</option>
                        <option value="Strom" selected="${sensor.getMedium() != null && "Strom".equals(sensor.getMedium())}">Strom</option>
                        <option value="Wärme" selected="${sensor.getMedium() != null && "Wärme".equals(sensor.getMedium())}">Wärme</option>
                        <option value="Kälte" selected="${sensor.getMedium() != null && "Kälte".equals(sensor.getMedium())}">Kälte</option>
                        <option value="Gas" selected="${sensor.getMedium() != null && "Gas".equals(sensor.getMedium())}">Gas</option>
                        <option value="Wasser" selected="${sensor.getMedium() != null && "Wasser".equals(sensor.getMedium())}">Wasser</option>
                        <option value="Druckluft" selected="${sensor.getMedium() != null && "Druckluft".equals(sensor.getMedium())}">Druckluft</option>
                        <option value="Dampf" selected="${sensor.getMedium() != null && "Dampf".equals(sensor.getMedium())}">Dampf</option>
                        <option value="Sonstiges" selected="${sensor.getMedium() != null && "Sonstiges".equals(sensor.getMedium())}">Sonstiges</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="sensorTag">Tag</label>
                    <select id="sensorTag" name="sensorTag">
                        <option value="">-- Bitte wählen --</option>
                        <option value="Hauptzähler" selected="${sensor.getSensorTag() != null && "Hauptzähler".equals(sensor.getSensorTag())}">Hauptzähler</option>
                        <option value="Wechselrichter" selected="${sensor.getSensorTag() != null && "Wechselrichter".equals(sensor.getSensorTag())}">Wechselrichter</option>
                        <option value="PV-Modul" selected="${sensor.getSensorTag() != null && "PV-Modul".equals(sensor.getSensorTag())}">PV-Modul</option>
                        <option value="PV-Batteriespeicher" selected="${sensor.getSensorTag() != null && "PV-Batteriespeicher".equals(sensor.getSensorTag())}">PV-Batteriespeicher</option>
                        <option value="Einspeisung" selected="${sensor.getSensorTag() != null && "Einspeisung".equals(sensor.getSensorTag())}">Einspeisung</option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="parentSensorId">Untermessung von</label>
                    <select id="parentSensorId" name="parentSensorId">
                        <option value="">-- Kein übergeordneter Sensor --</option>
                        @for(Sensor s : allSensors)
                            <option value="${s.getId()}" selected="${sensor.getParentSensor() != null && sensor.getParentSensor().getId().equals(s.getId())}">${s.getSensorCode()}${s.getSensorName() != null ? " - " + s.getSensorName() : ""}</option>
                        @endfor
                    </select>
                </div>
                <div class="form-group">
                    <label for="isActive">Status</label>
                    <select id="isActive" name="isActive">
                        <option value="true" selected="${sensor.getIsActive()}">Aktiv</option>
                        <option value="false" selected="${!sensor.getIsActive()}">Inaktiv</option>
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
                    <label for="location">Standort</label>
                    <input type="text" id="location" name="location"
                           value="${sensor.getLocation() != null ? sensor.getLocation() : ""}"
                           placeholder="z.B. Gebäude A, Dach">
                </div>
            </div>

            <div class="form-group">
                <label for="description">Beschreibung</label>
                <textarea id="description" name="description" rows="3"
                          placeholder="Optionale Beschreibung des Messpunkts...">${sensor.getDescription() != null ? sensor.getDescription() : ""}</textarea>
            </div>
        </div>

        <!-- Zähler tab fields (hidden, part of the same form) -->
        <div id="zaehler-form-fields" style="display:none;">
            <div class="modal-body">
                <div class="form-row">
                    <div class="form-group">
                        <label for="deviceNumber">Gerätenummer</label>
                        <input type="text" id="deviceNumber" name="deviceNumber"
                               value="${sensor.getDeviceNumber() != null ? sensor.getDeviceNumber() : ""}">
                    </div>
                    <div class="form-group">
                        <label for="serialNumber">Seriennummer</label>
                        <input type="text" id="serialNumber" name="serialNumber"
                               value="${sensor.getSerialNumber() != null ? sensor.getSerialNumber() : ""}">
                    </div>
                </div>

                <div class="form-group">
                    <label>GPS Position</label>
                    <div class="form-row" style="align-items: flex-end;">
                        <div class="form-group" style="flex:2; position:relative;">
                            <input type="text" id="gpsAddress" placeholder="Adresse suchen..."
                                   onkeydown="if(event.key==='Enter'){event.preventDefault();lookupLocation('gpsAddress','gpsLat','gpsLon','gps-suggestions');}">
                            <button type="button" class="btn btn-outline btn-sm" style="margin-top:4px;"
                                    onclick="lookupLocation('gpsAddress','gpsLat','gpsLon','gps-suggestions')">Suchen</button>
                            <div id="gps-suggestions" style="display:none;"></div>
                        </div>
                        <div class="form-group">
                            <label for="gpsLat">Breitengrad</label>
                            <input type="number" id="gpsLat" name="gpsLat" step="0.0000001"
                                   value="${sensor.getGpsLat() != null ? sensor.getGpsLat().toString() : ""}">
                        </div>
                        <div class="form-group">
                            <label for="gpsLon">Längengrad</label>
                            <input type="number" id="gpsLon" name="gpsLon" step="0.0000001"
                                   value="${sensor.getGpsLon() != null ? sensor.getGpsLon().toString() : ""}">
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label>Installationsort</label>
                    <div class="form-row" style="align-items: flex-end;">
                        <div class="form-group" style="flex:2; position:relative;">
                            <input type="text" id="installAddress" placeholder="Adresse suchen..."
                                   onkeydown="if(event.key==='Enter'){event.preventDefault();lookupLocation('installAddress','installLocationLat','installLocationLon','install-suggestions');}">
                            <button type="button" class="btn btn-outline btn-sm" style="margin-top:4px;"
                                    onclick="lookupLocation('installAddress','installLocationLat','installLocationLon','install-suggestions')">Suchen</button>
                            <div id="install-suggestions" style="display:none;"></div>
                        </div>
                        <div class="form-group">
                            <label for="installLocationLat">Breitengrad</label>
                            <input type="number" id="installLocationLat" name="installationLocationLat" step="0.0000001"
                                   value="${sensor.getInstallationLocationLat() != null ? sensor.getInstallationLocationLat().toString() : ""}">
                        </div>
                        <div class="form-group">
                            <label for="installLocationLon">Längengrad</label>
                            <input type="number" id="installLocationLon" name="installationLocationLon" step="0.0000001"
                                   value="${sensor.getInstallationLocationLon() != null ? sensor.getInstallationLocationLon().toString() : ""}">
                        </div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="costCenter">Kostenstelle</label>
                        <input type="text" id="costCenter" name="costCenter"
                               value="${sensor.getCostCenter() != null ? sensor.getCostCenter() : ""}">
                    </div>
                    <div class="form-group">
                        <label for="meterTypeId">Zählertyp</label>
                        <select id="meterTypeId" name="meterTypeId">
                            <option value="">-- Kein Zählertyp --</option>
                            @for(MeterType mt : allMeterTypes)
                                <option value="${mt.getId()}" selected="${sensor.getMeterType() != null && sensor.getMeterType().getId().equals(mt.getId())}">${mt.getDeviceType() != null ? mt.getDeviceType() : "ID " + mt.getId()}${mt.getManufacturer() != null ? " (" + mt.getManufacturer() + ")" : ""}</option>
                            @endfor
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="ipAddress">IP-Adresse</label>
                        <input type="text" id="ipAddress" name="ipAddress"
                               value="${sensor.getIpAddress() != null ? sensor.getIpAddress() : ""}"
                               placeholder="z.B. 192.168.1.100">
                    </div>
                    <div class="form-group">
                        <label for="installationDate">Einbaudatum</label>
                        <input type="date" id="installationDate" name="installationDate"
                               value="${sensor.getInstallationDate() != null ? sensor.getInstallationDate().toString() : ""}">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="lastInspectionDate">Letztes Prüfdatum</label>
                        <input type="date" id="lastInspectionDate" name="lastInspectionDate"
                               value="${sensor.getLastInspectionDate() != null ? sensor.getLastInspectionDate().toString() : ""}">
                    </div>
                    <div class="form-group">
                        <label for="verificationDocument">Überprüfungsdokument</label>
                        <input type="file" id="verificationDocument" name="verificationDocument" accept=".pdf,.doc,.docx">
                        @if(sensor.getVerificationDocumentPath() != null)
                            <a href="/uploads/${sensor.getVerificationDocumentPath()}" target="_blank" style="font-size:0.8rem;">Aktuelles Dokument</a>
                        @endif
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="sensorImageFile">Bild</label>
                        <input type="file" id="sensorImageFile" name="sensorImage" accept=".jpg,.jpeg,.png">
                        @if(sensor.getSensorImagePath() != null)
                            <img src="/uploads/${sensor.getSensorImagePath()}" style="max-height:60px; display:block; margin-top:4px;">
                        @endif
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="currentTransformer">CT (Stromwandler)</label>
                        <input type="text" id="currentTransformer" name="currentTransformer"
                               value="${sensor.getCurrentTransformer() != null ? sensor.getCurrentTransformer() : ""}">
                    </div>
                    <div class="form-group">
                        <label for="currentTransformerRatio">Stromwandlerverhältnis</label>
                        <input type="text" id="currentTransformerRatio" name="currentTransformerRatio"
                               value="${sensor.getCurrentTransformerRatio() != null ? sensor.getCurrentTransformerRatio() : ""}"
                               placeholder="z.B. 100/5">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="voltageTransformer">VT (Spannungswandler)</label>
                        <input type="text" id="voltageTransformer" name="voltageTransformer"
                               value="${sensor.getVoltageTransformer() != null ? sensor.getVoltageTransformer() : ""}">
                    </div>
                    <div class="form-group">
                        <label for="voltageTransformerRatio">Spannungswandlerverhältnis</label>
                        <input type="text" id="voltageTransformerRatio" name="voltageTransformerRatio"
                               value="${sensor.getVoltageTransformerRatio() != null ? sensor.getVoltageTransformerRatio() : ""}"
                               placeholder="z.B. 10000/100">
                    </div>
                </div>

                <div class="form-group">
                    <label for="notes">Notizen</label>
                    <textarea id="notes" name="notes" rows="3"
                              placeholder="Zusätzliche Notizen...">${sensor.getNotes() != null ? sensor.getNotes() : ""}</textarea>
                </div>
            </div>
        </div>

        <div class="modal-footer">
            <button type="button" class="btn btn-outline" onclick="closeModal()">Abbrechen</button>
            <button type="submit" class="btn btn-primary">Speichern</button>
        </div>
    </form>

    </div><!-- end panel-settings -->

    <!-- Tab: Messwerte -->
    <div id="panel-measurements" style="display:none;">
        <div id="measurements-list"
             hx-get="/sensors/${sensor.getId()}/measurements${defaultMeasurementDate != null ? "?from=" + defaultMeasurementDate + "T00%3A00&to=" + defaultMeasurementDate + "T23%3A59" : ""}"
             hx-trigger="revealed"
             hx-swap="innerHTML">
            <div style="padding: var(--spacing-lg); text-align: center; color: var(--text-secondary);">Lade Messwerte...</div>
        </div>
    </div>

</div>

<style>
    .modal-tabs {
        display: flex;
        border-bottom: 2px solid var(--border-color);
        padding: 0 var(--spacing-lg);
    }
    .modal-tab {
        background: none;
        border: none;
        padding: var(--spacing-md) var(--spacing-lg);
        cursor: pointer;
        font-size: var(--font-size-sm);
        color: var(--text-secondary);
        border-bottom: 2px solid transparent;
        margin-bottom: -2px;
        font-weight: 500;
        transition: all 0.2s;
    }
    .modal-tab:hover { color: var(--primary-color); }
    .modal-tab-active { color: var(--primary-color) !important; border-bottom-color: var(--primary-color) !important; }

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
        max-width: 1200px;
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
    .input-readonly {
        background-color: var(--background) !important;
        color: var(--text-secondary) !important;
    }
    .suggestion-item { display:block; width:100%; text-align:left; padding:6px 10px; background:none; border:none; border-bottom:1px solid var(--border-color); cursor:pointer; font-size:0.82rem; }
    .suggestion-item:hover { background: var(--background); }
    #gps-suggestions, #install-suggestions { position:absolute; z-index:1000; background:var(--surface); border:1px solid var(--border-color); border-radius:var(--radius-sm); max-height:200px; overflow-y:auto; width:100%; }
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
        htmx.trigger('#sensors-table-container', 'htmx:load');
    }

    function switchModalTab(tab) {
        document.getElementById('panel-settings').style.display = (tab === 'settings' || tab === 'zaehler') ? 'block' : 'none';
        document.getElementById('zaehler-form-fields').style.display = tab === 'zaehler' ? 'block' : 'none';
        document.getElementById('panel-measurements').style.display = tab === 'measurements' ? 'block' : 'none';

        // The modal-footer is inside panel-settings, show/hide based on settings/zaehler
        var footerEls = document.querySelectorAll('.modal-footer');
        footerEls.forEach(function(el) {
            el.style.display = tab === 'measurements' ? 'none' : '';
        });

        document.getElementById('tab-settings').className = 'modal-tab' + (tab === 'settings' ? ' modal-tab-active' : '');
        document.getElementById('tab-zaehler').className = 'modal-tab' + (tab === 'zaehler' ? ' modal-tab-active' : '');
        document.getElementById('tab-measurements').className = 'modal-tab' + (tab === 'measurements' ? ' modal-tab-active' : '');
        if (tab === 'measurements') {
            htmx.process(document.getElementById('panel-measurements'));
        }
    }

    function lookupLocation(addressInputId, latFieldId, lonFieldId, suggestionsId) {
        const q = document.getElementById(addressInputId).value.trim();
        if (!q) return;
        fetch('https://nominatim.openstreetmap.org/search?format=json&limit=5&q=' + encodeURIComponent(q))
            .then(r => r.json())
            .then(function(results) {
                const box = document.getElementById(suggestionsId);
                box.innerHTML = '';
                box.style.display = results.length ? 'block' : 'none';
                results.forEach(function(r) {
                    const btn = document.createElement('button');
                    btn.type = 'button';
                    btn.className = 'suggestion-item';
                    btn.textContent = r.display_name;
                    btn.onclick = function() {
                        document.getElementById(latFieldId).value = parseFloat(r.lat).toFixed(7);
                        document.getElementById(lonFieldId).value = parseFloat(r.lon).toFixed(7);
                        document.getElementById(addressInputId).value = r.display_name;
                        box.style.display = 'none';
                    };
                    box.appendChild(btn);
                });
            })
            .catch(function() {});
    }

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeModal();
        }
    });
</script>
