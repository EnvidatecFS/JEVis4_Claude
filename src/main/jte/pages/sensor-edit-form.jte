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

    @if(success != null)
        @if(success)
            <div class="alert alert-success" style="margin: var(--spacing-md) var(--spacing-lg) 0;">${message}</div>
            <script>
                setTimeout(function() {
                    closeModal();
                    htmx.ajax('GET', '/sensors/table', '#sensors-table-container');
                }, 1500);
            </script>
        @else
            <div class="alert alert-danger" style="margin: var(--spacing-md) var(--spacing-lg) 0;">${message}</div>
        @endif
    @endif

    <!-- Single form wrapping both Einstellungen and Zähler tab content -->
    <form hx-put="/sensors/${sensor.getId()}"
          hx-target="#modal-container"
          hx-swap="innerHTML"
          hx-encoding="multipart/form-data">

        <!-- ── Tab: Einstellungen ────────────────────────────────────── -->
        <div id="settings-only-fields">
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
                            <option value="Strom"               selected="${"Strom".equals(sensor.getMedium())}">Strom</option>
                            <option value="Wärme"               selected="${"Wärme".equals(sensor.getMedium())}">Wärme</option>
                            <option value="Kälte"               selected="${"Kälte".equals(sensor.getMedium())}">Kälte</option>
                            <option value="Gas"                 selected="${"Gas".equals(sensor.getMedium())}">Gas</option>
                            <option value="Wasser"              selected="${"Wasser".equals(sensor.getMedium())}">Wasser</option>
                            <option value="Druckluft"           selected="${"Druckluft".equals(sensor.getMedium())}">Druckluft</option>
                            <option value="Dampf"               selected="${"Dampf".equals(sensor.getMedium())}">Dampf</option>
                            <option value="Öl"                  selected="${"Öl".equals(sensor.getMedium())}">Öl</option>
                            <option value="Erneuerbare Energie" selected="${"Erneuerbare Energie".equals(sensor.getMedium())}">Erneuerbare Energie</option>
                            <option value="Sonstiges"           selected="${"Sonstiges".equals(sensor.getMedium())}">Sonstiges</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="sensorTag">Tag</label>
                        <select id="sensorTag" name="sensorTag">
                            <option value="">-- Bitte wählen --</option>
                            <option value="Hauptzähler"          selected="${"Hauptzähler".equals(sensor.getSensorTag())}">Hauptzähler</option>
                            <option value="Wechselrichter"       selected="${"Wechselrichter".equals(sensor.getSensorTag())}">Wechselrichter</option>
                            <option value="PV-Modul"             selected="${"PV-Modul".equals(sensor.getSensorTag())}">PV-Modul</option>
                            <option value="PV-Batteriespeicher"  selected="${"PV-Batteriespeicher".equals(sensor.getSensorTag())}">PV-Batteriespeicher</option>
                            <option value="Einspeisung"          selected="${"Einspeisung".equals(sensor.getSensorTag())}">Einspeisung</option>
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
                            <option value="true"  selected="${sensor.getIsActive()}">Aktiv</option>
                            <option value="false" selected="${!sensor.getIsActive()}">Inaktiv</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label for="description">Beschreibung</label>
                    <textarea id="description" name="description" rows="3"
                              placeholder="Optionale Beschreibung des Messpunkts...">${sensor.getDescription() != null ? sensor.getDescription() : ""}</textarea>
                </div>
            </div>
        </div><!-- end settings-only-fields -->

        <!-- ── Tab: Zähler ──────────────────────────────────────────── -->
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

                <!-- Installationsort with inline search button -->
                <div class="form-group">
                    <label>Installationsort</label>
                    <div style="position: relative;">
                        <div style="display: flex; gap: 8px; align-items: center;">
                            <input type="text" id="installAddress"
                                   placeholder="Adresse suchen..."
                                   style="flex: 1;"
                                   onkeydown="if(event.key==='Enter'){event.preventDefault();lookupLocation('installAddress','installLocationLat','installLocationLon','install-suggestions');}">
                            <button type="button" class="btn btn-outline btn-sm"
                                    onclick="lookupLocation('installAddress','installLocationLat','installLocationLon','install-suggestions')">Suchen</button>
                        </div>
                        <div id="install-suggestions" class="location-suggestions"></div>
                    </div>
                    <div class="form-row" style="margin-top: var(--spacing-sm);">
                        <div class="form-group">
                            <label for="installLocationLat" class="label-sm">Breitengrad</label>
                            <input type="number" id="installLocationLat" name="installationLocationLat" step="0.0000001"
                                   value="${sensor.getInstallationLocationLat() != null ? sensor.getInstallationLocationLat().toString() : ""}">
                        </div>
                        <div class="form-group">
                            <label for="installLocationLon" class="label-sm">Längengrad</label>
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
                            <a href="/uploads/${sensor.getVerificationDocumentPath()}" target="_blank"
                               style="font-size: 0.8rem; display: block; margin-top: 4px;">Aktuelles Dokument anzeigen</a>
                        @endif
                    </div>
                </div>

                <!-- CT and VT: double values only -->
                <div class="form-row">
                    <div class="form-group">
                        <label for="currentTransformer">CT</label>
                        <input type="number" id="currentTransformer" name="currentTransformer" step="any"
                               value="${sensor.getCurrentTransformer() != null ? sensor.getCurrentTransformer().toString() : ""}"
                               placeholder="z.B. 80.0">
                    </div>
                    <div class="form-group">
                        <label for="currentTransformerRatio">Stromwandler</label>
                        <input type="text" id="currentTransformerRatio" name="currentTransformerRatio"
                               value="${sensor.getCurrentTransformerRatio() != null ? sensor.getCurrentTransformerRatio() : ""}"
                               placeholder="z.B. 400/5">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="voltageTransformer">VT</label>
                        <input type="number" id="voltageTransformer" name="voltageTransformer" step="any"
                               value="${sensor.getVoltageTransformer() != null ? sensor.getVoltageTransformer().toString() : ""}"
                               placeholder="z.B. 100.0">
                    </div>
                    <div class="form-group">
                        <label for="voltageTransformerRatio">Spannungswandler</label>
                        <input type="text" id="voltageTransformerRatio" name="voltageTransformerRatio"
                               value="${sensor.getVoltageTransformerRatio() != null ? sensor.getVoltageTransformerRatio() : ""}"
                               placeholder="z.B. 10000/100">
                    </div>
                </div>

                <!-- Bild: thumbnail with link to open full size -->
                <div class="form-group">
                    <label for="sensorImageFile">Bild</label>
                    <input type="file" id="sensorImageFile" name="sensorImage" accept=".jpg,.jpeg,.png">
                    @if(sensor.getSensorImagePath() != null)
                        <div style="margin-top: 8px;">
                            <a href="/uploads/${sensor.getSensorImagePath()}" target="_blank" title="Bild in neuem Fenster öffnen">
                                <img src="/uploads/${sensor.getSensorImagePath()}"
                                     style="max-height: 90px; max-width: 140px; border-radius: var(--radius-sm); border: 1px solid var(--border-color); object-fit: cover; display: block;">
                            </a>
                            <span style="font-size: 0.75rem; color: var(--text-secondary); margin-top: 4px; display: block;">Klicken zum Vergrößern</span>
                        </div>
                    @endif
                </div>

                <div class="form-group">
                    <label for="notes">Notizen</label>
                    <textarea id="notes" name="notes" rows="3"
                              placeholder="Zusätzliche Notizen...">${sensor.getNotes() != null ? sensor.getNotes() : ""}</textarea>
                </div>

            </div>
        </div><!-- end zaehler-form-fields -->

        <div class="modal-footer">
            <button type="button" class="btn btn-outline" onclick="closeModal()">Abbrechen</button>
            <button type="submit" class="btn btn-primary">Speichern</button>
        </div>
    </form>

    <!-- ── Tab: Messwerte ───────────────────────────────────────────── -->
    <div id="panel-measurements" style="display:none;">
        <div id="measurements-list"
             hx-get="/sensors/${sensor.getId()}/measurements${defaultMeasurementDate != null ? "?from=" + defaultMeasurementDate + "T00%3A00&to=" + defaultMeasurementDate + "T23%3A59" : ""}"
             hx-trigger="revealed"
             hx-swap="innerHTML">
            <div style="padding: var(--spacing-lg); text-align: center; color: var(--text-secondary);">Lade Messwerte...</div>
        </div>
    </div>

</div><!-- end .modal -->

<style>
    .modal-tabs { display: flex; border-bottom: 2px solid var(--border-color); padding: 0 var(--spacing-lg); }
    .modal-tab { background: none; border: none; padding: var(--spacing-md) var(--spacing-lg); cursor: pointer; font-size: var(--font-size-sm); color: var(--text-secondary); border-bottom: 2px solid transparent; margin-bottom: -2px; font-weight: 500; transition: all 0.2s; }
    .modal-tab:hover { color: var(--primary-color); }
    .modal-tab-active { color: var(--primary-color) !important; border-bottom-color: var(--primary-color) !important; }

    .modal-backdrop { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background-color: rgba(0,0,0,0.5); z-index: 1000; }
    .modal { position: fixed; top: 50%; left: 50%; transform: translate(-50%,-50%); background: var(--surface); border-radius: var(--radius-xl); box-shadow: var(--shadow-lg); width: 90%; max-width: 1200px; max-height: 90vh; overflow-y: auto; z-index: 1001; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; padding: var(--spacing-lg); border-bottom: 1px solid var(--border-color); }
    .modal-header h3 { margin: 0; }
    .modal-close { background: none; border: none; font-size: 1.5rem; cursor: pointer; color: var(--text-secondary); padding: var(--spacing-sm); line-height: 1; }
    .modal-close:hover { color: var(--text-primary); }
    .modal-body { padding: var(--spacing-lg); }
    .modal-footer { display: flex; justify-content: flex-end; gap: var(--spacing-md); padding: var(--spacing-lg); border-top: 1px solid var(--border-color); }
    .form-row { display: flex; gap: var(--spacing-lg); }
    .form-row .form-group { flex: 1; }
    .input-readonly { background-color: var(--background) !important; color: var(--text-secondary) !important; }
    .label-sm { font-size: 0.8rem; }

    /* Location suggestion dropdown */
    .location-suggestions { position: absolute; z-index: 1000; background: var(--surface); border: 1px solid var(--border-color); border-radius: var(--radius-sm); max-height: 200px; overflow-y: auto; width: 100%; box-shadow: var(--shadow-md); }
    .suggestion-item { display: block; width: 100%; text-align: left; padding: 7px 12px; background: none; border: none; border-bottom: 1px solid var(--border-color); cursor: pointer; font-size: 0.82rem; color: var(--text-primary); }
    .suggestion-item:hover { background: var(--background); }
    .suggestion-item:last-child { border-bottom: none; }
    .btn-sm { padding: var(--spacing-sm) var(--spacing-md); font-size: var(--font-size-sm); }

    @media (max-width: 600px) { .form-row { flex-direction: column; gap: 0; } }
</style>

<script>
    function closeModal() {
        document.getElementById('modal-container').innerHTML = '';
        htmx.trigger('#sensors-table-container', 'htmx:load');
    }

    function switchModalTab(tab) {
        // Show/hide tab content areas
        var isZaehler     = tab === 'zaehler';
        var isSettings    = tab === 'settings';
        var isMeasurements = tab === 'measurements';

        document.getElementById('settings-only-fields').style.display   = isSettings ? 'block' : 'none';
        document.getElementById('zaehler-form-fields').style.display     = isZaehler  ? 'block' : 'none';
        document.getElementById('panel-measurements').style.display      = isMeasurements ? 'block' : 'none';

        // Footer is part of the form — show it for Einstellungen and Zähler, hide for Messwerte
        document.querySelector('.modal-footer').style.display = isMeasurements ? 'none' : '';

        // Update tab button styles
        ['settings','zaehler','measurements'].forEach(function(t) {
            document.getElementById('tab-' + t).className =
                'modal-tab' + (t === tab ? ' modal-tab-active' : '');
        });

        if (isMeasurements) {
            htmx.process(document.getElementById('panel-measurements'));
        }
    }

    function lookupLocation(addressInputId, latFieldId, lonFieldId, suggestionsId) {
        const q = document.getElementById(addressInputId).value.trim();
        if (!q) return;
        fetch('https://nominatim.openstreetmap.org/search?format=json&limit=5&q=' + encodeURIComponent(q))
            .then(function(r) { return r.json(); })
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
                        document.getElementById(latFieldId).value  = parseFloat(r.lat).toFixed(7);
                        document.getElementById(lonFieldId).value  = parseFloat(r.lon).toFixed(7);
                        document.getElementById(addressInputId).value = r.display_name;
                        box.style.display = 'none';
                    };
                    box.appendChild(btn);
                });
            })
            .catch(function() {});
    }

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeModal();
    });
</script>
