@import org.jevis.model.Sensor
@import java.util.List
@import java.util.Map
@import org.springframework.security.web.csrf.CsrfToken

@param String username
@param List<Sensor> sensors
@param Map<String, List<Sensor>> sensorsByType
@param CsrfToken _csrf = null

@template.layout.app(
    title = "Monitoring",
    username = username,
    currentPage = "monitoring",
    _csrf = _csrf,
    content = @`
    <div class="page-header">
        <div class="page-header-content">
            <h1 class="page-title">Monitoring</h1>
            <p class="page-description">Visualisierung und Analyse der Messdaten</p>
        </div>
        <div class="page-actions">
            <button class="btn btn-primary" onclick="addChart()">
                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                </svg>
                Chart hinzufuegen
            </button>
        </div>
    </div>

    <!-- Time Range Selection -->
    <div class="card" style="margin-bottom: 1.5rem;">
        <div class="card-body">
            <div style="display: flex; gap: 1rem; align-items: center; flex-wrap: wrap;">
                <div class="form-group" style="margin: 0;">
                    <label class="form-label" style="margin-bottom: 0.25rem;">Zeitbereich</label>
                    <div style="display: flex; gap: 0.5rem;">
                        <button class="btn btn-outline time-range-btn active" data-range="24h">24h</button>
                        <button class="btn btn-outline time-range-btn" data-range="7d">7 Tage</button>
                        <button class="btn btn-outline time-range-btn" data-range="30d">30 Tage</button>
                        <button class="btn btn-outline time-range-btn" data-range="custom">Benutzerdefiniert</button>
                    </div>
                </div>
                <div class="form-group custom-range-inputs" style="margin: 0; display: none;">
                    <label class="form-label" style="margin-bottom: 0.25rem;">Von</label>
                    <input type="datetime-local" id="customStart" class="form-control">
                </div>
                <div class="form-group custom-range-inputs" style="margin: 0; display: none;">
                    <label class="form-label" style="margin-bottom: 0.25rem;">Bis</label>
                    <input type="datetime-local" id="customEnd" class="form-control">
                </div>
                <div class="custom-range-inputs" style="display: none; align-self: flex-end;">
                    <button class="btn btn-primary" onclick="applyCustomRange()">Anwenden</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Empty State Template (hidden) -->
    <template id="emptyStateTemplate">
        <div class="empty-state">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
            </svg>
            <h3>Noch keine Charts vorhanden</h3>
            <p>Klicken Sie auf "Chart hinzufuegen" um Messdaten zu visualisieren.</p>
        </div>
    </template>

    <!-- Chart Card Template (hidden) -->
    <template id="chartCardTemplate">
        <div class="chart-card" data-chart-card>
            <div class="chart-header">
                <span class="chart-title" data-chart-title></span>
                <div class="chart-actions">
                    <button data-action="settings" title="Einstellungen">
                        <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                            <circle cx="12" cy="12" r="3"/>
                        </svg>
                    </button>
                    <button data-action="refresh" title="Aktualisieren">
                        <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                        </svg>
                    </button>
                    <button data-action="download" title="Als Bild speichern">
                        <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                        </svg>
                    </button>
                    <button data-action="remove" title="Chart entfernen">
                        <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                        </svg>
                    </button>
                </div>
            </div>
            <div class="chart-container" data-chart-container></div>
        </div>
    </template>

    <!-- Charts Container -->
    <div id="chartsContainer">
        <!-- Charts will be added here dynamically -->
    </div>

    <!-- Add Chart Modal -->
    <div id="addChartModal" class="modal" style="display: none;">
        <div class="modal-backdrop" onclick="closeModal()"></div>
        <div class="modal-content modal-lg">
            <div class="modal-header">
                <h3 class="modal-title">Chart hinzufuegen</h3>
                <button class="modal-close" onclick="closeModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Chart-Titel</label>
                    <input type="text" id="chartTitle" class="form-control" placeholder="z.B. Leistung Wechselrichter">
                </div>

                <div class="form-group">
                    <label class="form-label">Datenquellen (Sensoren)</label>

                    <!-- Filter Section -->
                    <div class="sensor-filters">
                        <div class="filter-row">
                            <div class="filter-group">
                                <label class="filter-label">Suche</label>
                                <input type="text" id="sensorFilterName" class="form-control form-control-sm"
                                       placeholder="Name suchen..." oninput="filterSensors()">
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Typ</label>
                                <select id="sensorFilterType" class="form-control form-control-sm" onchange="filterSensors()">
                                    <option value="">Alle Typen</option>
                                    @for(var entry : sensorsByType.entrySet())
                                        <option value="${entry.getKey()}">${entry.getKey()}</option>
                                    @endfor
                                </select>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Standort</label>
                                <select id="sensorFilterLocation" class="form-control form-control-sm" onchange="filterSensors()">
                                    <option value="">Alle Standorte</option>
                                    !{var locations = new java.util.HashSet<String>();}
                                    @for(Sensor sensor : sensors)
                                        @if(sensor.getLocation() != null && !sensor.getLocation().isEmpty())
                                            !{locations.add(sensor.getLocation());}
                                        @endif
                                    @endfor
                                    @for(String loc : locations)
                                        <option value="${loc}">${loc}</option>
                                    @endfor
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Two Column Layout: Available | Selected -->
                    <div class="sensor-columns">
                        <!-- Available Sensors -->
                        <div class="sensor-column">
                            <div class="sensor-column-header">
                                <span>Verfuegbare Sensoren</span>
                                <span class="sensor-count" id="availableSensorCount">0</span>
                            </div>
                            <div class="sensor-list" id="availableSensorList">
                                @for(Sensor sensor : sensors)
                                    <div class="sensor-item" data-sensor-id="${sensor.getId()}"
                                         data-name="${sensor.getSensorName()}"
                                         data-type="${sensor.getMeasurementType()}"
                                         data-location="${sensor.getLocation() != null ? sensor.getLocation() : ""}"
                                         data-unit="${sensor.getUnit()}"
                                         data-code="${sensor.getSensorCode()}"
                                         onclick="selectSensor(this)">
                                        <div class="sensor-item-info">
                                            <span class="sensor-item-name">${sensor.getSensorName()}</span>
                                            <span class="sensor-item-meta">${sensor.getSensorCode()} - ${sensor.getUnit()}</span>
                                        </div>
                                        <span class="sensor-item-type">${sensor.getMeasurementType()}</span>
                                    </div>
                                @endfor
                            </div>
                        </div>

                        <!-- Selected Sensors -->
                        <div class="sensor-column">
                            <div class="sensor-column-header">
                                <span>Ausgewaehlte Sensoren</span>
                                <span class="sensor-count" id="selectedSensorCount">0</span>
                            </div>
                            <div class="sensor-list" id="selectedSensorList">
                                <div class="sensor-list-empty" id="selectedSensorEmpty">
                                    <svg width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
                                    </svg>
                                    <span>Sensoren aus der linken Liste auswaehlen</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-outline" onclick="closeModal()">Abbrechen</button>
                <button class="btn btn-primary" onclick="createChart()">Chart erstellen</button>
            </div>
        </div>
    </div>

    <!-- Chart Settings Modal -->
    <div id="chartSettingsModal" class="modal" style="display: none;">
        <div class="modal-backdrop" onclick="closeSettingsModal()"></div>
        <div class="modal-content modal-lg">
            <div class="modal-header">
                <h3 class="modal-title">Chart-Einstellungen</h3>
                <button class="modal-close" onclick="closeSettingsModal()">&times;</button>
            </div>

            <!-- Tab Navigation -->
            <div class="settings-tabs">
                <button class="settings-tab active" data-tab="general" onclick="switchSettingsTab('general')">
                    <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                        <circle cx="12" cy="12" r="3"/>
                    </svg>
                    Allgemein
                </button>
                <button class="settings-tab" data-tab="datasources" onclick="switchSettingsTab('datasources')">
                    <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4"/>
                    </svg>
                    Datenquellen
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" id="settingsChartId">

                <!-- Tab: General -->
                <div class="settings-tab-content active" id="tabContentGeneral">
                    <div class="form-group">
                        <label class="form-label">Titel</label>
                        <input type="text" id="settingsTitle" class="form-control" placeholder="Chart-Titel">
                    </div>
                </div>

                <!-- Tab: Datasources -->
                <div class="settings-tab-content" id="tabContentDatasources">
                    <!-- Filter Section -->
                    <div class="sensor-filters">
                        <div class="filter-row">
                            <div class="filter-group">
                                <label class="filter-label">Suche</label>
                                <input type="text" id="settingsSensorFilterName" class="form-control form-control-sm"
                                       placeholder="Name suchen..." oninput="filterSettingsSensors()">
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Typ</label>
                                <select id="settingsSensorFilterType" class="form-control form-control-sm" onchange="filterSettingsSensors()">
                                    <option value="">Alle Typen</option>
                                    @for(var entry : sensorsByType.entrySet())
                                        <option value="${entry.getKey()}">${entry.getKey()}</option>
                                    @endfor
                                </select>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Standort</label>
                                <select id="settingsSensorFilterLocation" class="form-control form-control-sm" onchange="filterSettingsSensors()">
                                    <option value="">Alle Standorte</option>
                                    !{var settingsLocations = new java.util.HashSet<String>();}
                                    @for(Sensor sensor : sensors)
                                        @if(sensor.getLocation() != null && !sensor.getLocation().isEmpty())
                                            !{settingsLocations.add(sensor.getLocation());}
                                        @endif
                                    @endfor
                                    @for(String loc : settingsLocations)
                                        <option value="${loc}">${loc}</option>
                                    @endfor
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Two Column Layout: Available | Selected -->
                    <div class="sensor-columns">
                        <!-- Available Sensors -->
                        <div class="sensor-column">
                            <div class="sensor-column-header">
                                <span>Verfuegbare Sensoren</span>
                                <span class="sensor-count" id="settingsAvailableSensorCount">0</span>
                            </div>
                            <div class="sensor-list" id="settingsAvailableSensorList">
                                @for(Sensor sensor : sensors)
                                    <div class="sensor-item" data-sensor-id="${sensor.getId()}"
                                         data-name="${sensor.getSensorName()}"
                                         data-type="${sensor.getMeasurementType()}"
                                         data-location="${sensor.getLocation() != null ? sensor.getLocation() : ""}"
                                         data-unit="${sensor.getUnit()}"
                                         data-code="${sensor.getSensorCode()}"
                                         onclick="selectSettingsSensor(this)">
                                        <div class="sensor-item-info">
                                            <span class="sensor-item-name">${sensor.getSensorName()}</span>
                                            <span class="sensor-item-meta">${sensor.getSensorCode()} - ${sensor.getUnit()}</span>
                                        </div>
                                        <span class="sensor-item-type">${sensor.getMeasurementType()}</span>
                                    </div>
                                @endfor
                            </div>
                        </div>

                        <!-- Selected Sensors -->
                        <div class="sensor-column">
                            <div class="sensor-column-header">
                                <span>Ausgewaehlte Sensoren</span>
                                <span class="sensor-count" id="settingsSelectedSensorCount">0</span>
                            </div>
                            <div class="sensor-list" id="settingsSelectedSensorList">
                                <div class="sensor-list-empty" id="settingsSelectedSensorEmpty">
                                    <svg width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
                                    </svg>
                                    <span>Sensoren aus der linken Liste auswaehlen</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button class="btn btn-outline" onclick="closeSettingsModal()">Abbrechen</button>
                <button class="btn btn-primary" onclick="saveChartSettings()">Speichern</button>
            </div>
        </div>
    </div>

    <!-- Apache ECharts -->
    <script src="https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js"></script>

    <style>
        .time-range-btn.active {
            background-color: var(--primary-color);
            color: white;
            border-color: var(--primary-color);
        }

        .chart-card {
            background: var(--card-bg);
            border-radius: var(--border-radius-lg);
            box-shadow: var(--shadow-sm);
            margin-bottom: 1.5rem;
            overflow: hidden;
        }

        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 1.5rem;
            border-bottom: 1px solid var(--border-color);
        }

        .chart-title {
            font-weight: 600;
            color: var(--text-color);
        }

        .chart-actions {
            display: flex;
            gap: 0.5rem;
        }

        .chart-actions button {
            padding: 0.25rem 0.5rem;
            background: transparent;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            cursor: pointer;
            color: var(--text-muted);
        }

        .chart-actions button:hover {
            background: var(--hover-color);
            color: var(--text-color);
        }

        .chart-container {
            height: 400px;
            padding: 1rem;
        }

        /* Modal Styles */
        .modal {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 1000;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-backdrop {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
        }

        .modal-content {
            position: relative;
            background: var(--card-bg);
            border-radius: var(--border-radius-lg);
            box-shadow: var(--shadow-lg);
            width: 100%;
            max-width: 600px;
            max-height: 80vh;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 1.5rem;
            border-bottom: 1px solid var(--border-color);
        }

        .modal-title {
            margin: 0;
            font-size: 1.25rem;
        }

        .modal-close {
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: var(--text-muted);
            line-height: 1;
        }

        .modal-body {
            padding: 1.5rem;
            overflow-y: auto;
        }

        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 0.75rem;
            padding: 1rem 1.5rem;
            border-top: 1px solid var(--border-color);
        }

        /* Modal Large */
        .modal-lg {
            max-width: 800px;
        }

        /* Sensor Filters */
        .sensor-filters {
            margin-bottom: 1rem;
            padding: 0.75rem;
            background: var(--hover-color);
            border-radius: var(--border-radius);
        }

        .filter-row {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
        }

        .filter-group {
            flex: 1;
            min-width: 150px;
        }

        .filter-label {
            display: block;
            font-size: 0.75rem;
            font-weight: 500;
            color: var(--text-muted);
            margin-bottom: 0.25rem;
        }

        .form-control-sm {
            padding: 0.35rem 0.5rem;
            font-size: 0.85rem;
        }

        /* Sensor Columns */
        .sensor-columns {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            height: 350px;
        }

        .sensor-column {
            display: flex;
            flex-direction: column;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            overflow: hidden;
        }

        .sensor-column-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.5rem 0.75rem;
            background: var(--hover-color);
            font-weight: 500;
            font-size: 0.85rem;
            border-bottom: 1px solid var(--border-color);
        }

        .sensor-count {
            background: var(--primary-color);
            color: white;
            padding: 0.1rem 0.5rem;
            border-radius: 10px;
            font-size: 0.75rem;
        }

        .sensor-list {
            flex: 1;
            overflow-y: auto;
            padding: 0.25rem;
        }

        .sensor-list-empty {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: var(--text-muted);
            font-size: 0.85rem;
            text-align: center;
            padding: 1rem;
            gap: 0.5rem;
        }

        .sensor-list-empty svg {
            opacity: 0.5;
        }

        /* Sensor Item (Available) */
        .sensor-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.5rem 0.75rem;
            border-radius: var(--border-radius);
            cursor: pointer;
            transition: all 0.15s;
            border: 1px solid transparent;
        }

        .sensor-item:hover {
            background: var(--hover-color);
        }

        .sensor-item.hidden {
            display: none;
        }

        .sensor-item-info {
            display: flex;
            flex-direction: column;
            min-width: 0;
        }

        .sensor-item-name {
            font-size: 0.85rem;
            color: var(--text-color);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .sensor-item-meta {
            font-size: 0.75rem;
            color: var(--text-muted);
        }

        .sensor-item-type {
            font-size: 0.7rem;
            padding: 0.15rem 0.4rem;
            background: var(--border-color);
            color: var(--text-muted);
            border-radius: var(--border-radius);
            white-space: nowrap;
        }

        /* Selected Sensor Item */
        .selected-sensor-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 0.75rem;
            background: var(--hover-color);
            border-radius: var(--border-radius);
            margin-bottom: 0.35rem;
        }

        .selected-sensor-color {
            width: 28px;
            height: 28px;
            padding: 0;
            border: 2px solid var(--border-color);
            border-radius: var(--border-radius);
            cursor: pointer;
            flex-shrink: 0;
        }

        .selected-sensor-color::-webkit-color-swatch-wrapper {
            padding: 0;
        }

        .selected-sensor-color::-webkit-color-swatch {
            border: none;
            border-radius: 2px;
        }

        .selected-sensor-info {
            flex: 1;
            min-width: 0;
        }

        .selected-sensor-name {
            font-size: 0.85rem;
            font-weight: 500;
            color: var(--text-color);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .selected-sensor-meta {
            font-size: 0.75rem;
            color: var(--text-muted);
        }

        .selected-sensor-remove {
            padding: 0.25rem;
            background: none;
            border: none;
            cursor: pointer;
            color: var(--text-muted);
            border-radius: var(--border-radius);
            line-height: 1;
        }

        .selected-sensor-remove:hover {
            background: var(--danger-color);
            color: white;
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: var(--text-muted);
        }

        .empty-state svg {
            width: 64px;
            height: 64px;
            margin-bottom: 1rem;
            opacity: 0.5;
        }

        .empty-state h3 {
            margin-bottom: 0.5rem;
            color: var(--text-color);
        }

        /* Settings Tabs */
        .settings-tabs {
            display: flex;
            border-bottom: 1px solid var(--border-color);
            padding: 0 1rem;
            gap: 0.5rem;
        }

        .settings-tab {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1rem;
            background: none;
            border: none;
            border-bottom: 2px solid transparent;
            cursor: pointer;
            color: var(--text-muted);
            font-size: 0.9rem;
            font-weight: 500;
            transition: all 0.2s;
            margin-bottom: -1px;
        }

        .settings-tab:hover {
            color: var(--text-color);
        }

        .settings-tab.active {
            color: var(--primary-color);
            border-bottom-color: var(--primary-color);
        }

        .settings-tab svg {
            flex-shrink: 0;
        }

        .settings-tab-content {
            display: none;
        }

        .settings-tab-content.active {
            display: block;
        }
    </style>

    <script>
        // State management
        var charts = [];
        var chartCounter = 0;
        var currentTimeRange = {
            start: new Date(Date.now() - 24 * 60 * 60 * 1000),
            end: new Date()
        };
        var selectedSensorsData = []; // Array of {id, name, code, unit, color}

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            initTimeRangeButtons();
            setDefaultDateInputs();
            showEmptyState();
            filterSensors(); // Initialize sensor counts
        });

        function initTimeRangeButtons() {
            document.querySelectorAll('.time-range-btn').forEach(function(btn) {
                btn.addEventListener('click', function() {
                    document.querySelectorAll('.time-range-btn').forEach(function(b) {
                        b.classList.remove('active');
                    });
                    this.classList.add('active');

                    var range = this.dataset.range;
                    var customInputs = document.querySelectorAll('.custom-range-inputs');

                    if (range === 'custom') {
                        customInputs.forEach(function(el) { el.style.display = 'block'; });
                    } else {
                        customInputs.forEach(function(el) { el.style.display = 'none'; });
                        applyPresetRange(range);
                    }
                });
            });
        }

        function setDefaultDateInputs() {
            var now = new Date();
            var yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000);

            document.getElementById('customEnd').value = formatDateTimeLocal(now);
            document.getElementById('customStart').value = formatDateTimeLocal(yesterday);
        }

        function formatDateTimeLocal(date) {
            return date.toISOString().slice(0, 16);
        }

        function applyPresetRange(range) {
            var now = new Date();
            var start;

            switch (range) {
                case '1h':
                    start = new Date(now.getTime() - 60 * 60 * 1000);
                    break;
                case '6h':
                    start = new Date(now.getTime() - 6 * 60 * 60 * 1000);
                    break;
                case '24h':
                    start = new Date(now.getTime() - 24 * 60 * 60 * 1000);
                    break;
                case '7d':
                    start = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
                    break;
                case '30d':
                    start = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
                    break;
                default:
                    start = new Date(now.getTime() - 24 * 60 * 60 * 1000);
            }

            currentTimeRange = { start: start, end: now };
            updateAllCharts();
        }

        function applyCustomRange() {
            var start = new Date(document.getElementById('customStart').value);
            var end = new Date(document.getElementById('customEnd').value);

            if (start >= end) {
                alert('Das Startdatum muss vor dem Enddatum liegen.');
                return;
            }

            currentTimeRange = { start: start, end: end };
            updateAllCharts();
        }

        function showEmptyState() {
            var container = document.getElementById('chartsContainer');
            if (charts.length === 0) {
                var template = document.getElementById('emptyStateTemplate');
                var clone = template.content.cloneNode(true);
                container.appendChild(clone);
            }
        }

        // Modal functions
        function addChart() {
            document.getElementById('addChartModal').style.display = 'flex';
            document.getElementById('chartTitle').value = '';

            // Reset filters
            document.getElementById('sensorFilterName').value = '';
            document.getElementById('sensorFilterType').value = '';
            document.getElementById('sensorFilterLocation').value = '';

            // Reset selected sensors
            selectedSensorsData = [];
            renderSelectedSensors();
            filterSensors();
            updateSensorCounts();
        }

        function closeModal() {
            document.getElementById('addChartModal').style.display = 'none';
        }

        // Sensor Selection Functions
        function filterSensors() {
            var nameFilter = document.getElementById('sensorFilterName').value.toLowerCase();
            var typeFilter = document.getElementById('sensorFilterType').value;
            var locationFilter = document.getElementById('sensorFilterLocation').value;

            var visibleCount = 0;
            document.querySelectorAll('#availableSensorList .sensor-item').forEach(function(item) {
                var name = (item.dataset.name || '').toLowerCase();
                var type = item.dataset.type || '';
                var location = item.dataset.location || '';
                var id = item.dataset.sensorId;

                // Check if already selected
                var isSelected = selectedSensorsData.some(function(s) { return s.id === id; });

                var matchesName = !nameFilter || name.indexOf(nameFilter) !== -1;
                var matchesType = !typeFilter || type === typeFilter;
                var matchesLocation = !locationFilter || location === locationFilter;

                var visible = matchesName && matchesType && matchesLocation && !isSelected;
                item.classList.toggle('hidden', !visible);

                if (visible) visibleCount++;
            });

            document.getElementById('availableSensorCount').textContent = visibleCount;
        }

        function selectSensor(element) {
            var id = element.dataset.sensorId;
            var name = element.dataset.name;
            var code = element.dataset.code;
            var unit = element.dataset.unit;

            // Get next color from theme
            var colorIndex = selectedSensorsData.length;
            var color = JEVisChartTheme.getSeriesColor(colorIndex);

            selectedSensorsData.push({
                id: id,
                name: name,
                code: code,
                unit: unit,
                color: color
            });

            renderSelectedSensors();
            filterSensors();
            updateSensorCounts();
        }

        function removeSensor(sensorId) {
            selectedSensorsData = selectedSensorsData.filter(function(s) {
                return s.id !== sensorId;
            });

            renderSelectedSensors();
            filterSensors();
            updateSensorCounts();
        }

        function updateSensorColor(sensorId, newColor) {
            var sensor = selectedSensorsData.find(function(s) { return s.id === sensorId; });
            if (sensor) {
                sensor.color = newColor;
            }
        }

        function renderSelectedSensors() {
            var container = document.getElementById('selectedSensorList');
            var emptyState = document.getElementById('selectedSensorEmpty');

            // Clear existing items except empty state
            container.querySelectorAll('.selected-sensor-item').forEach(function(item) {
                item.remove();
            });

            if (selectedSensorsData.length === 0) {
                emptyState.style.display = 'flex';
                return;
            }

            emptyState.style.display = 'none';

            selectedSensorsData.forEach(function(sensor) {
                var item = document.createElement('div');
                item.className = 'selected-sensor-item';
                item.dataset.sensorId = sensor.id;

                item.innerHTML =
                    '<input type="color" class="selected-sensor-color" value="' + sensor.color + '" ' +
                           'onchange="updateSensorColor(\'' + sensor.id + '\', this.value)" title="Farbe aendern">' +
                    '<div class="selected-sensor-info">' +
                        '<span class="selected-sensor-name">' + sensor.name + '</span>' +
                        '<span class="selected-sensor-meta">' + sensor.code + ' - ' + sensor.unit + '</span>' +
                    '</div>' +
                    '<button class="selected-sensor-remove" onclick="removeSensor(\'' + sensor.id + '\')" title="Entfernen">' +
                        '<svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>' +
                        '</svg>' +
                    '</button>';

                container.appendChild(item);
            });
        }

        function updateSensorCounts() {
            document.getElementById('selectedSensorCount').textContent = selectedSensorsData.length;
        }

        function createChart() {
            var title = document.getElementById('chartTitle').value || 'Neuer Chart';

            if (selectedSensorsData.length === 0) {
                alert('Bitte waehlen Sie mindestens einen Sensor aus.');
                return;
            }

            // Collect unique units
            var sensorUnits = [];
            selectedSensorsData.forEach(function(sensor) {
                if (sensorUnits.indexOf(sensor.unit) === -1) {
                    sensorUnits.push(sensor.unit);
                }
            });

            var chartId = 'chart_' + (++chartCounter);
            var chartConfig = {
                id: chartId,
                title: title,
                sensorConfigs: selectedSensorsData.map(function(s) {
                    return {
                        id: s.id,
                        name: s.name,
                        code: s.code,
                        unit: s.unit,
                        color: s.color
                    };
                }),
                sensorIds: selectedSensorsData.map(function(s) { return s.id; }),
                unit: sensorUnits.join(', '),
                instance: null
            };

            charts.push(chartConfig);
            renderChartCard(chartConfig);
            loadChartData(chartConfig);
            closeModal();
        }

        function renderChartCard(chartConfig) {
            var container = document.getElementById('chartsContainer');

            // Remove empty state if present
            var emptyState = container.querySelector('.empty-state');
            if (emptyState) {
                emptyState.remove();
            }

            // Clone template
            var template = document.getElementById('chartCardTemplate');
            var clone = template.content.cloneNode(true);

            // Set IDs and content
            var card = clone.querySelector('[data-chart-card]');
            card.id = chartConfig.id + '_card';

            var titleEl = clone.querySelector('[data-chart-title]');
            titleEl.textContent = chartConfig.title;

            var chartContainer = clone.querySelector('[data-chart-container]');
            chartContainer.id = chartConfig.id;

            // Set up button actions
            var settingsBtn = clone.querySelector('[data-action="settings"]');
            settingsBtn.onclick = function() { openChartSettings(chartConfig.id); };

            var refreshBtn = clone.querySelector('[data-action="refresh"]');
            refreshBtn.onclick = function() { refreshChart(chartConfig.id); };

            var downloadBtn = clone.querySelector('[data-action="download"]');
            downloadBtn.onclick = function() { downloadChart(chartConfig.id); };

            var removeBtn = clone.querySelector('[data-action="remove"]');
            removeBtn.onclick = function() { removeChart(chartConfig.id); };

            container.appendChild(clone);

            // Initialize ECharts instance with theme
            var chartDom = document.getElementById(chartConfig.id);
            chartConfig.instance = JEVisChartTheme.initChart(chartDom);

            // Handle resize
            window.addEventListener('resize', function() {
                if (chartConfig.instance) {
                    chartConfig.instance.resize();
                }
            });
        }

        function loadChartData(chartConfig) {
            var params = new URLSearchParams();
            chartConfig.sensorIds.forEach(function(id) {
                params.append('sensorIds', id);
            });
            params.append('start', currentTimeRange.start.toISOString());
            params.append('end', currentTimeRange.end.toISOString());

            chartConfig.instance.showLoading();

            // Build color map from sensorConfigs
            var colorMap = {};
            if (chartConfig.sensorConfigs && chartConfig.sensorConfigs.length > 0) {
                chartConfig.sensorConfigs.forEach(function(config) {
                    colorMap[config.id] = config.color;
                });
            }

            fetch('/monitoring/api/measurements?' + params.toString())
                .then(function(response) { return response.json(); })
                .then(function(data) {
                    var palette = JEVisChartTheme.getPalette();

                    var series = data.series.map(function(s, index) {
                        // Use color from colorMap if available, otherwise from palette
                        var color = (colorMap && colorMap[s.sensorId]) || palette[index % palette.length];

                        return {
                            name: s.sensorName,
                            type: 'line',
                            smooth: true,
                            symbol: 'none',
                            data: s.data,
                            itemStyle: {
                                color: color
                            },
                            lineStyle: {
                                color: color
                            },
                            emphasis: {
                                focus: 'series'
                            }
                        };
                    });

                    var option = {
                        tooltip: {
                            trigger: 'axis',
                            formatter: function(params) {
                                var date = new Date(params[0].data[0]);
                                var html = '<strong>' + date.toLocaleString('de-DE') + '</strong><br/>';
                                params.forEach(function(p) {
                                    html += '<span style="display:inline-block;margin-right:4px;border-radius:10px;width:10px;height:10px;background-color:' + p.color + ';"></span>';
                                    html += p.seriesName + ': <strong>' + p.data[1].toFixed(2) + '</strong><br/>';
                                });
                                return html;
                            }
                        },
                        legend: {
                            data: data.series.map(function(s) { return s.sensorName; }),
                            bottom: 60
                        },
                        grid: {
                            left: '3%',
                            right: '4%',
                            bottom: 120,
                            top: 40,
                            containLabel: true
                        },
                        xAxis: {
                            type: 'time',
                            axisLabel: {
                                formatter: function(value) {
                                    var date = new Date(value);
                                    return date.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit' }) +
                                           '\n' + date.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
                                }
                            }
                        },
                        yAxis: {
                            type: 'value',
                            name: chartConfig.unit,
                            axisLabel: {
                                formatter: '{value}'
                            }
                        },
                        dataZoom: [
                            {
                                type: 'slider',
                                xAxisIndex: 0,
                                filterMode: 'none',
                                bottom: 10,
                                height: 30,
                                borderColor: 'transparent',
                                backgroundColor: JEVisChartTheme.getUIColors().gridLine,
                                fillerColor: 'rgba(100, 100, 100, 0.15)',
                                handleStyle: {
                                    color: JEVisChartTheme.getSeriesColor(0)
                                },
                                textStyle: {
                                    color: JEVisChartTheme.getUIColors().axisLabel
                                }
                            },
                            {
                                type: 'inside',
                                xAxisIndex: 0,
                                filterMode: 'none'
                            }
                        ],
                        series: series
                    };

                    chartConfig.instance.hideLoading();
                    chartConfig.instance.setOption(option, true);
                })
                .catch(function(error) {
                    console.error('Error loading chart data:', error);
                    chartConfig.instance.hideLoading();
                });
        }

        function updateAllCharts() {
            charts.forEach(function(chart) {
                loadChartData(chart);
            });
        }

        function refreshChart(chartId) {
            var chart = charts.find(function(c) { return c.id === chartId; });
            if (chart) {
                loadChartData(chart);
            }
        }

        function downloadChart(chartId) {
            var chart = charts.find(function(c) { return c.id === chartId; });
            if (chart && chart.instance) {
                var url = chart.instance.getDataURL({
                    type: 'png',
                    pixelRatio: 2,
                    backgroundColor: '#fff'
                });
                var link = document.createElement('a');
                link.download = chart.title.replace(/\s+/g, '_') + '.png';
                link.href = url;
                link.click();
            }
        }

        function removeChart(chartId) {
            var chartIndex = charts.findIndex(function(c) { return c.id === chartId; });
            if (chartIndex > -1) {
                var chart = charts[chartIndex];
                if (chart.instance) {
                    chart.instance.dispose();
                }
                document.getElementById(chartId + '_card').remove();
                charts.splice(chartIndex, 1);

                if (charts.length === 0) {
                    showEmptyState();
                }
            }
        }

        // Chart Settings Modal Functions
        var settingsSelectedSensorsData = []; // Array of {id, name, code, unit, color}

        function openChartSettings(chartId) {
            var chart = charts.find(function(c) { return c.id === chartId; });
            if (!chart) return;

            document.getElementById('settingsChartId').value = chartId;
            document.getElementById('settingsTitle').value = chart.title;

            // Reset filters
            document.getElementById('settingsSensorFilterName').value = '';
            document.getElementById('settingsSensorFilterType').value = '';
            document.getElementById('settingsSensorFilterLocation').value = '';

            // Load saved sensor configurations
            settingsSelectedSensorsData = [];
            if (chart.sensorConfigs && chart.sensorConfigs.length > 0) {
                chart.sensorConfigs.forEach(function(config) {
                    settingsSelectedSensorsData.push({
                        id: config.id,
                        name: config.name,
                        code: config.code || '',
                        unit: config.unit || '',
                        color: config.color
                    });
                });
            } else if (chart.sensorIds && chart.sensorIds.length > 0) {
                // Migrate from old format
                chart.sensorIds.forEach(function(sensorId, index) {
                    var sensorEl = document.querySelector('#settingsAvailableSensorList .sensor-item[data-sensor-id="' + sensorId + '"]');
                    if (sensorEl) {
                        settingsSelectedSensorsData.push({
                            id: sensorId,
                            name: sensorEl.dataset.name,
                            code: sensorEl.dataset.code,
                            unit: sensorEl.dataset.unit,
                            color: JEVisChartTheme.getSeriesColor(index)
                        });
                    }
                });
            }

            // Render selected sensors and update available list
            renderSettingsSelectedSensors();
            filterSettingsSensors();
            updateSettingsSensorCounts();

            // Switch to general tab
            switchSettingsTab('general');

            document.getElementById('chartSettingsModal').style.display = 'flex';
        }

        function closeSettingsModal() {
            document.getElementById('chartSettingsModal').style.display = 'none';
        }

        function switchSettingsTab(tabName) {
            // Update tab buttons
            document.querySelectorAll('#chartSettingsModal .settings-tab').forEach(function(tab) {
                tab.classList.toggle('active', tab.dataset.tab === tabName);
            });

            // Update tab content
            document.querySelectorAll('#chartSettingsModal .settings-tab-content').forEach(function(content) {
                content.classList.remove('active');
            });

            if (tabName === 'general') {
                document.getElementById('tabContentGeneral').classList.add('active');
            } else if (tabName === 'datasources') {
                document.getElementById('tabContentDatasources').classList.add('active');
            }
        }

        function filterSettingsSensors() {
            var nameFilter = document.getElementById('settingsSensorFilterName').value.toLowerCase();
            var typeFilter = document.getElementById('settingsSensorFilterType').value;
            var locationFilter = document.getElementById('settingsSensorFilterLocation').value;

            var visibleCount = 0;
            document.querySelectorAll('#settingsAvailableSensorList .sensor-item').forEach(function(item) {
                var name = (item.dataset.name || '').toLowerCase();
                var type = item.dataset.type || '';
                var location = item.dataset.location || '';
                var id = item.dataset.sensorId;

                // Check if already selected
                var isSelected = settingsSelectedSensorsData.some(function(s) { return s.id === id; });

                var matchesName = !nameFilter || name.indexOf(nameFilter) !== -1;
                var matchesType = !typeFilter || type === typeFilter;
                var matchesLocation = !locationFilter || location === locationFilter;

                var visible = matchesName && matchesType && matchesLocation && !isSelected;
                item.classList.toggle('hidden', !visible);

                if (visible) visibleCount++;
            });

            document.getElementById('settingsAvailableSensorCount').textContent = visibleCount;
        }

        function selectSettingsSensor(element) {
            var id = element.dataset.sensorId;
            var name = element.dataset.name;
            var code = element.dataset.code;
            var unit = element.dataset.unit;

            // Get next color from theme
            var colorIndex = settingsSelectedSensorsData.length;
            var color = JEVisChartTheme.getSeriesColor(colorIndex);

            settingsSelectedSensorsData.push({
                id: id,
                name: name,
                code: code,
                unit: unit,
                color: color
            });

            renderSettingsSelectedSensors();
            filterSettingsSensors();
            updateSettingsSensorCounts();
        }

        function removeSettingsSensor(sensorId) {
            settingsSelectedSensorsData = settingsSelectedSensorsData.filter(function(s) {
                return s.id !== sensorId;
            });

            renderSettingsSelectedSensors();
            filterSettingsSensors();
            updateSettingsSensorCounts();
        }

        function updateSettingsSensorColor(sensorId, newColor) {
            var sensor = settingsSelectedSensorsData.find(function(s) { return s.id === sensorId; });
            if (sensor) {
                sensor.color = newColor;
            }
        }

        function renderSettingsSelectedSensors() {
            var container = document.getElementById('settingsSelectedSensorList');
            var emptyState = document.getElementById('settingsSelectedSensorEmpty');

            // Clear existing items except empty state
            container.querySelectorAll('.selected-sensor-item').forEach(function(item) {
                item.remove();
            });

            if (settingsSelectedSensorsData.length === 0) {
                emptyState.style.display = 'flex';
                return;
            }

            emptyState.style.display = 'none';

            settingsSelectedSensorsData.forEach(function(sensor) {
                var item = document.createElement('div');
                item.className = 'selected-sensor-item';
                item.dataset.sensorId = sensor.id;

                item.innerHTML =
                    '<input type="color" class="selected-sensor-color" value="' + sensor.color + '" ' +
                           'onchange="updateSettingsSensorColor(\'' + sensor.id + '\', this.value)" title="Farbe aendern">' +
                    '<div class="selected-sensor-info">' +
                        '<span class="selected-sensor-name">' + sensor.name + '</span>' +
                        '<span class="selected-sensor-meta">' + sensor.code + ' - ' + sensor.unit + '</span>' +
                    '</div>' +
                    '<button class="selected-sensor-remove" onclick="removeSettingsSensor(\'' + sensor.id + '\')" title="Entfernen">' +
                        '<svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>' +
                        '</svg>' +
                    '</button>';

                container.appendChild(item);
            });
        }

        function updateSettingsSensorCounts() {
            document.getElementById('settingsSelectedSensorCount').textContent = settingsSelectedSensorsData.length;
        }

        function saveChartSettings() {
            var chartId = document.getElementById('settingsChartId').value;
            var chart = charts.find(function(c) { return c.id === chartId; });
            if (!chart) return;

            if (settingsSelectedSensorsData.length === 0) {
                alert('Bitte waehlen Sie mindestens einen Sensor aus.');
                return;
            }

            // Update title
            var newTitle = document.getElementById('settingsTitle').value.trim() || 'Chart';
            chart.title = newTitle;

            // Update DOM title
            var titleEl = document.querySelector('#' + chartId + '_card [data-chart-title]');
            if (titleEl) titleEl.textContent = newTitle;

            // Collect unique units
            var sensorUnits = [];
            settingsSelectedSensorsData.forEach(function(sensor) {
                if (sensorUnits.indexOf(sensor.unit) === -1) {
                    sensorUnits.push(sensor.unit);
                }
            });

            // Update sensor configurations
            chart.sensorConfigs = settingsSelectedSensorsData.map(function(s) {
                return {
                    id: s.id,
                    name: s.name,
                    code: s.code,
                    unit: s.unit,
                    color: s.color
                };
            });

            // Also update sensorIds for backward compatibility
            chart.sensorIds = settingsSelectedSensorsData.map(function(s) { return s.id; });
            chart.unit = sensorUnits.join(', ');

            // Reload chart with new settings
            loadChartData(chart);

            closeSettingsModal();
        }
    </script>
    `
)
