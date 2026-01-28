@import org.jevis.model.Sensor
@import java.util.List
@import java.util.Map
@import org.springframework.security.web.csrf.CsrfToken

@param String username
@param List<Sensor> sensors = null
@param Map<String, List<Sensor>> sensorsByType = null
@param CsrfToken _csrf = null

@template.layout.app(
    title = "Dashboard",
    username = username,
    currentPage = "dashboard",
    _csrf = _csrf,
    content = @`
    <div class="page-header">
        <div class="page-header-content">
            <h1 class="page-title">Dashboard</h1>
            <p class="page-description">Konfigurierbare Widgets fuer Ihre PV-Anlagen</p>
        </div>
        <div class="page-actions">
            <button class="btn btn-outline" onclick="toggleEditMode()" id="editModeBtn">
                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                </svg>
                <span id="editModeText">Bearbeiten</span>
            </button>
            <button class="btn btn-primary" onclick="openAddWidgetModal()" id="addWidgetBtn" style="display: none;">
                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                </svg>
                Widget hinzufuegen
            </button>
        </div>
    </div>

    <!-- GridStack Container -->
    <div class="grid-stack" id="dashboardGrid"></div>

    <!-- Add Widget Modal -->
    <div id="addWidgetModal" class="modal" style="display: none;">
        <div class="modal-backdrop" onclick="closeAddWidgetModal()"></div>
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
                <h3 class="modal-title">Widget hinzufuegen</h3>
                <button class="modal-close" onclick="closeAddWidgetModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="widget-type-grid">
                    <div class="widget-type-card" onclick="addWidget('line')">
                        <div class="widget-type-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
                            </svg>
                        </div>
                        <div class="widget-type-name">Liniendiagramm</div>
                        <div class="widget-type-desc">Zeitreihen visualisieren</div>
                    </div>
                    <div class="widget-type-card" onclick="addWidget('area')">
                        <div class="widget-type-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M3 18L9 12L13 16L21 8"/>
                                <path d="M21 8V18H3" fill="currentColor" opacity="0.2"/>
                            </svg>
                        </div>
                        <div class="widget-type-name">Flaechendiagramm</div>
                        <div class="widget-type-desc">Grosse Datenmengen</div>
                    </div>
                    <div class="widget-type-card" onclick="addWidget('bar')">
                        <div class="widget-type-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="12" width="4" height="8"/>
                                <rect x="10" y="8" width="4" height="12"/>
                                <rect x="17" y="4" width="4" height="16"/>
                            </svg>
                        </div>
                        <div class="widget-type-name">Balkendiagramm</div>
                        <div class="widget-type-desc">Vergleiche darstellen</div>
                    </div>
                    <div class="widget-type-card" onclick="addWidget('radial')">
                        <div class="widget-type-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="10"/>
                                <path d="M12 6v6l4 2"/>
                            </svg>
                        </div>
                        <div class="widget-type-name">Radiales Diagramm</div>
                        <div class="widget-type-desc">Polar Koordinaten</div>
                    </div>
                    <div class="widget-type-card" onclick="addWidget('pie')">
                        <div class="widget-type-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="10"/>
                                <path d="M12 2a10 10 0 0 1 10 10h-10z" fill="currentColor" opacity="0.3"/>
                            </svg>
                        </div>
                        <div class="widget-type-name">Kreisdiagramm</div>
                        <div class="widget-type-desc">Anteile visualisieren</div>
                    </div>
                    <div class="widget-type-card" onclick="addWidget('gauge')">
                        <div class="widget-type-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12"/>
                                <path d="M12 12L8 8" stroke-width="3"/>
                            </svg>
                        </div>
                        <div class="widget-type-name">Tachometer</div>
                        <div class="widget-type-desc">Aktuelle Werte</div>
                    </div>
                    <div class="widget-type-card" onclick="addWidget('map')">
                        <div class="widget-type-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
                                <circle cx="12" cy="10" r="3"/>
                            </svg>
                        </div>
                        <div class="widget-type-name">Karte</div>
                        <div class="widget-type-desc">Standorte anzeigen</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Widget Settings Modal -->
    <div id="widgetSettingsModal" class="modal" style="display: none;">
        <div class="modal-backdrop" onclick="closeWidgetSettingsModal()"></div>
        <div class="modal-content modal-lg">
            <div class="modal-header">
                <h3 class="modal-title">Widget-Einstellungen</h3>
                <button class="modal-close" onclick="closeWidgetSettingsModal()">&times;</button>
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
                <button class="settings-tab" data-tab="datasources" onclick="switchSettingsTab('datasources')" id="tabDatasources">
                    <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4"/>
                    </svg>
                    Datenquellen
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" id="settingsWidgetId">

                <!-- Tab: General -->
                <div class="settings-tab-content active" id="tabContentGeneral">
                    <div class="form-group">
                        <label class="form-label">Titel</label>
                        <input type="text" id="settingsTitle" class="form-control" placeholder="Widget-Titel">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Widget-Typ</label>
                        <input type="text" id="settingsWidgetType" class="form-control" readonly disabled>
                    </div>
                </div>

                <!-- Tab: Datasources -->
                <div class="settings-tab-content" id="tabContentDatasources">
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
                                    @if(sensorsByType != null)
                                        @for(var entry : sensorsByType.entrySet())
                                            <option value="${entry.getKey()}">${entry.getKey()}</option>
                                        @endfor
                                    @endif
                                </select>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Standort</label>
                                <select id="sensorFilterLocation" class="form-control form-control-sm" onchange="filterSensors()">
                                    <option value="">Alle Standorte</option>
                                    @if(sensors != null)
                                        !{var locations = new java.util.HashSet<String>();}
                                        @for(Sensor sensor : sensors)
                                            @if(sensor.getLocation() != null && !sensor.getLocation().isEmpty())
                                                !{locations.add(sensor.getLocation());}
                                            @endif
                                        @endfor
                                        @for(String loc : locations)
                                            <option value="${loc}">${loc}</option>
                                        @endfor
                                    @endif
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
                                @if(sensors != null)
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
                                @else
                                    <p class="text-muted" style="padding: 1rem;">Keine Sensoren verfuegbar</p>
                                @endif
                            </div>
                        </div>

                        <!-- Selected Sensors -->
                        <div class="sensor-column">
                            <div class="sensor-column-header">
                                <span>Ausgewaehlte Sensoren</span>
                                <span class="sensor-count" id="selectedSensorCount">0</span>
                            </div>
                            <div class="sensor-list" id="selectedSensorList">
                                <!-- Selected sensors will be added here dynamically -->
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
                <button class="btn btn-outline" onclick="closeWidgetSettingsModal()">Abbrechen</button>
                <button class="btn btn-primary" onclick="saveWidgetSettings()">Speichern</button>
            </div>
        </div>
    </div>

    <!-- GridStack CSS -->
    <link href="https://cdn.jsdelivr.net/npm/gridstack@10.0.0/dist/gridstack.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/gridstack@10.0.0/dist/gridstack-extra.min.css" rel="stylesheet"/>

    <!-- Leaflet CSS for Map -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>

    <style>
        /* GridStack Customization */
        .grid-stack {
            background: transparent;
            min-height: 600px;
        }

        .grid-stack-item-content {
            background: var(--card-bg);
            border-radius: var(--border-radius-lg);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .grid-stack > .grid-stack-item > .grid-stack-item-content {
            inset: 4px;
        }

        .gs-id-placeholder > .placeholder-content {
            background-color: var(--primary-color);
            opacity: 0.2;
            border-radius: var(--border-radius-lg);
        }

        /* Widget Styles */
        .widget-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border-color);
            background: var(--card-bg);
            cursor: move;
        }

        .widget-title {
            font-weight: 600;
            font-size: 0.9rem;
            color: var(--text-color);
            margin: 0;
        }

        .widget-actions {
            display: flex;
            gap: 0.25rem;
            opacity: 0;
            transition: opacity 0.2s;
        }

        .grid-stack-item:hover .widget-actions,
        .edit-mode .widget-actions {
            opacity: 1;
        }

        .widget-actions button {
            padding: 0.25rem;
            background: transparent;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            color: var(--text-muted);
            line-height: 1;
        }

        .widget-actions button:hover {
            background: var(--hover-color);
            color: var(--text-color);
        }

        .widget-body {
            flex: 1;
            padding: 0.5rem;
            min-height: 0;
            position: relative;
        }

        .widget-chart {
            width: 100%;
            height: 100%;
            min-height: 200px;
        }

        /* Widget Type Selection Modal */
        .widget-type-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 1rem;
        }

        .widget-type-card {
            padding: 1.5rem 1rem;
            border: 2px solid var(--border-color);
            border-radius: var(--border-radius-lg);
            text-align: center;
            cursor: pointer;
            transition: all 0.2s;
        }

        .widget-type-card:hover {
            border-color: var(--primary-color);
            background: rgba(59, 130, 246, 0.05);
            transform: translateY(-2px);
        }

        .widget-type-icon {
            width: 48px;
            height: 48px;
            margin: 0 auto 0.75rem;
            color: var(--primary-color);
        }

        .widget-type-icon svg {
            width: 100%;
            height: 100%;
        }

        .widget-type-name {
            font-weight: 600;
            color: var(--text-color);
            margin-bottom: 0.25rem;
        }

        .widget-type-desc {
            font-size: 0.8rem;
            color: var(--text-muted);
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
            max-width: 500px;
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

        /* Edit Mode Indicator */
        .edit-mode .grid-stack-item-content {
            outline: 2px dashed var(--primary-color);
            outline-offset: -2px;
        }

        /* Edit Mode Only Actions */
        .widget-actions .edit-only {
            display: none;
        }

        .edit-mode .widget-actions .edit-only {
            display: inline-flex;
        }

        /* Modal Footer */
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

        .btn-sm {
            padding: 0.25rem 0.5rem;
            font-size: 0.8rem;
        }

        /* Form Controls */
        .form-group {
            margin-bottom: 1rem;
        }

        .form-label {
            display: block;
            font-weight: 500;
            margin-bottom: 0.4rem;
            color: var(--text-color);
            font-size: 0.9rem;
        }

        .form-control {
            width: 100%;
            padding: 0.5rem 0.75rem;
            font-size: 0.9rem;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            background: var(--card-bg);
            color: var(--text-color);
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.2);
        }

        /* Leaflet Map fixes */
        .leaflet-container {
            width: 100%;
            height: 100%;
            border-radius: var(--border-radius);
        }
    </style>

    <!-- GridStack JS -->
    <script src="https://cdn.jsdelivr.net/npm/gridstack@10.0.0/dist/gridstack-all.min.js"></script>

    <!-- Apache ECharts -->
    <script src="https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js"></script>

    <!-- Leaflet JS for Map -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

    <script>
        var grid;
        var widgets = {};
        var widgetCounter = 0;
        var editMode = false;

        document.addEventListener('DOMContentLoaded', function() {
            initGrid();
            loadDefaultWidgets();
        });

        function initGrid() {
            grid = GridStack.init({
                column: 12,
                cellHeight: 80,
                margin: 8,
                float: true,
                disableResize: true,
                disableDrag: true,
                animate: true
            });

            grid.on('change', function(event, items) {
                saveLayout();
            });
        }

        function loadDefaultWidgets() {
            // Load saved layout or create default
            var savedLayout = localStorage.getItem('dashboardLayout');
            if (savedLayout) {
                try {
                    var layout = JSON.parse(savedLayout);
                    layout.forEach(function(item) {
                        createWidget(item.type, item.x, item.y, item.w, item.h, item.title, {
                            sensorConfigs: item.sensorConfigs || [],
                            sensorIds: item.sensorIds || []
                        });
                    });
                    return;
                } catch(e) {
                    console.error('Error loading layout:', e);
                }
            }

            // Default layout
            createWidget('line', 0, 0, 6, 4, 'Leistungsverlauf');
            createWidget('gauge', 6, 0, 3, 4, 'Aktueller Wirkungsgrad');
            createWidget('pie', 9, 0, 3, 4, 'Sensorverteilung');
            createWidget('bar', 0, 4, 4, 4, 'Monatsvergleich');
            createWidget('area', 4, 4, 5, 4, 'Tagesproduktion');
            createWidget('map', 9, 4, 3, 4, 'Anlagenstandorte');
        }

        function saveLayout() {
            var layout = [];
            Object.keys(widgets).forEach(function(id) {
                var w = widgets[id];
                var node = grid.engine.nodes.find(function(n) { return n.el && n.el.id === id; });
                if (node) {
                    layout.push({
                        type: w.type,
                        title: w.title,
                        sensorConfigs: w.sensorConfigs || [],
                        sensorIds: w.sensorIds || [],
                        x: node.x,
                        y: node.y,
                        w: node.w,
                        h: node.h
                    });
                }
            });
            localStorage.setItem('dashboardLayout', JSON.stringify(layout));
        }

        function toggleEditMode() {
            editMode = !editMode;
            var container = document.getElementById('dashboardGrid');
            var text = document.getElementById('editModeText');
            var addBtn = document.getElementById('addWidgetBtn');
            var editBtn = document.getElementById('editModeBtn');

            if (editMode) {
                container.classList.add('edit-mode');
                text.textContent = 'Fertig';
                editBtn.classList.remove('btn-outline');
                editBtn.classList.add('btn-primary');
                addBtn.style.display = 'inline-flex';
                grid.enableMove(true);
                grid.enableResize(true);
            } else {
                container.classList.remove('edit-mode');
                text.textContent = 'Bearbeiten';
                editBtn.classList.remove('btn-primary');
                editBtn.classList.add('btn-outline');
                addBtn.style.display = 'none';
                grid.enableMove(false);
                grid.enableResize(false);
                saveLayout();
            }
        }

        function openAddWidgetModal() {
            document.getElementById('addWidgetModal').style.display = 'flex';
        }

        function closeAddWidgetModal() {
            document.getElementById('addWidgetModal').style.display = 'none';
        }

        function addWidget(type) {
            closeAddWidgetModal();
            var titles = {
                'line': 'Liniendiagramm',
                'area': 'Flaechendiagramm',
                'bar': 'Balkendiagramm',
                'radial': 'Radiales Diagramm',
                'pie': 'Kreisdiagramm',
                'gauge': 'Tachometer',
                'map': 'Standortkarte'
            };
            createWidget(type, 0, 0, 4, 4, titles[type] || 'Widget');
        }

        function createWidget(type, x, y, w, h, title, config) {
            widgetCounter++;
            var id = 'widget_' + widgetCounter;

            // Default config
            config = config || {};
            var sensorConfigs = config.sensorConfigs || [];
            var sensorIds = config.sensorIds || [];

            var content = document.createElement('div');
            content.innerHTML =
                '<div class="widget-header">' +
                    '<h4 class="widget-title" data-widget-title>' + title + '</h4>' +
                    '<div class="widget-actions">' +
                        '<button class="edit-only" onclick="openWidgetSettings(\'' + id + '\')" title="Einstellungen">' +
                            '<svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>' +
                                '<circle cx="12" cy="12" r="3"/>' +
                            '</svg>' +
                        '</button>' +
                        '<button onclick="refreshWidget(\'' + id + '\')" title="Aktualisieren">' +
                            '<svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>' +
                            '</svg>' +
                        '</button>' +
                        '<button class="edit-only" onclick="removeWidget(\'' + id + '\')" title="Entfernen">' +
                            '<svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>' +
                            '</svg>' +
                        '</button>' +
                    '</div>' +
                '</div>' +
                '<div class="widget-body">' +
                    '<div id="' + id + '_chart" class="widget-chart"></div>' +
                '</div>';

            grid.addWidget({
                id: id,
                x: x,
                y: y,
                w: w,
                h: h,
                content: content.innerHTML
            });

            widgets[id] = {
                type: type,
                title: title,
                sensorConfigs: sensorConfigs,
                sensorIds: sensorIds,
                chart: null,
                map: null
            };

            // Initialize chart after DOM is ready
            setTimeout(function() {
                initWidgetChart(id, type);
            }, 100);
        }

        function initWidgetChart(id, type) {
            var chartDom = document.getElementById(id + '_chart');
            if (!chartDom) return;

            if (type === 'map') {
                initMapWidget(id, chartDom);
            } else {
                var chart = JEVisChartTheme.initChart(chartDom);
                widgets[id].chart = chart;
                loadWidgetData(id, type);

                // Handle resize
                var resizeObserver = new ResizeObserver(function() {
                    chart.resize();
                });
                resizeObserver.observe(chartDom);
            }
        }

        function loadWidgetData(id, type) {
            var w = widgets[id];
            var chart = w.chart;
            if (!chart) return;

            chart.showLoading();

            var endpoint = '/dashboard/api/widget/' + (type === 'area' ? 'line' : type);

            // Add sensor IDs to request if available
            if (w.sensorIds && w.sensorIds.length > 0) {
                var params = new URLSearchParams();
                w.sensorIds.forEach(function(sensorId) {
                    params.append('sensorIds', sensorId);
                });
                endpoint += '?' + params.toString();
            }

            // Build color map from sensorConfigs
            var colorMap = {};
            if (w.sensorConfigs && w.sensorConfigs.length > 0) {
                w.sensorConfigs.forEach(function(config) {
                    colorMap[config.id] = config.color;
                });
            }

            fetch(endpoint)
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    chart.hideLoading();
                    var option = getChartOption(type, data, colorMap);
                    chart.setOption(option, true);
                })
                .catch(function(err) {
                    chart.hideLoading();
                    console.error('Error loading widget data:', err);
                });
        }

        function getChartOption(type, data, colorMap) {
            switch(type) {
                case 'line':
                    return getLineOption(data, false, colorMap);
                case 'area':
                    return getLineOption(data, true, colorMap);
                case 'bar':
                    return getBarOption(data, colorMap);
                case 'radial':
                    return getRadialOption(data, colorMap);
                case 'pie':
                    return getPieOption(data, colorMap);
                case 'gauge':
                    return getGaugeOption(data, colorMap);
                default:
                    return {};
            }
        }

        function getLineOption(data, isArea, colorMap) {
            var palette = JEVisChartTheme.getPalette();

            var series = data.series.map(function(s, index) {
                // Use color from colorMap if available, otherwise from palette
                var color = (colorMap && colorMap[s.sensorId]) || palette[index % palette.length];

                return {
                    name: s.name,
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
                    areaStyle: isArea ? { opacity: 0.3, color: color } : null
                };
            });

            return {
                tooltip: { trigger: 'axis' },
                grid: { left: 50, right: 20, top: 20, bottom: 30 },
                xAxis: {
                    type: 'time',
                    axisLabel: {
                        formatter: function(v) {
                            var d = new Date(v);
                            return d.getHours() + ':00';
                        }
                    }
                },
                yAxis: { type: 'value' },
                series: series
            };
        }

        function getBarOption(data, colorMap) {
            var palette = JEVisChartTheme.getPalette();

            // If we have colorMap with values, use them for bar coloring
            var hasCustomColors = colorMap && Object.keys(colorMap).length > 0;
            var customColors = hasCustomColors ? Object.values(colorMap) : null;

            return {
                tooltip: { trigger: 'axis' },
                grid: { left: 50, right: 20, top: 20, bottom: 40 },
                xAxis: {
                    type: 'category',
                    data: data.categories,
                    axisLabel: { rotate: 30 }
                },
                yAxis: { type: 'value' },
                series: [{
                    type: 'bar',
                    data: data.values,
                    itemStyle: {
                        color: customColors ? customColors[0] : JEVisChartTheme.createBarGradient()
                    }
                }]
            };
        }

        function getRadialOption(data, colorMap) {
            var angleData = data.data.map(function(d) { return d.name; });
            var radiusData = data.data.map(function(d) { return d.value; });
            var palette = JEVisChartTheme.getPalette();

            // Use custom colors if available
            var customColors = (colorMap && Object.keys(colorMap).length > 0) ? Object.values(colorMap) : null;
            var useColors = customColors || palette;

            return {
                polar: { radius: [30, '70%'] },
                angleAxis: {
                    type: 'category',
                    data: angleData,
                    startAngle: 90
                },
                radiusAxis: { max: data.max || 100 },
                tooltip: {},
                series: [{
                    type: 'bar',
                    data: radiusData,
                    coordinateSystem: 'polar',
                    itemStyle: {
                        color: function(params) {
                            return useColors[params.dataIndex % useColors.length];
                        }
                    }
                }]
            };
        }

        function getPieOption(data, colorMap) {
            var palette = JEVisChartTheme.getPalette();
            var customColors = (colorMap && Object.keys(colorMap).length > 0) ? Object.values(colorMap) : null;
            var useColors = customColors || palette;

            return {
                color: useColors,
                tooltip: { trigger: 'item' },
                legend: { bottom: 10, left: 'center' },
                series: [{
                    type: 'pie',
                    radius: ['35%', '60%'],
                    center: ['50%', '45%'],
                    avoidLabelOverlap: true,
                    itemStyle: {
                        borderRadius: 4,
                        borderColor: '#fff',
                        borderWidth: 2
                    },
                    label: { show: false },
                    emphasis: {
                        label: { show: true, fontWeight: 'bold' }
                    },
                    data: data.data
                }]
            };
        }

        function getGaugeOption(data, colorMap) {
            var ui = JEVisChartTheme.getUIColors();
            var customColors = (colorMap && Object.keys(colorMap).length > 0) ? Object.values(colorMap) : null;
            var gaugeColor = (customColors && customColors[0]) || ui.gaugeProgress;

            return {
                series: [{
                    type: 'gauge',
                    startAngle: 200,
                    endAngle: -20,
                    min: data.min || 0,
                    max: data.max || 100,
                    splitNumber: 5,
                    itemStyle: {
                        color: gaugeColor
                    },
                    progress: {
                        show: true,
                        width: 20
                    },
                    pointer: { show: false },
                    axisLine: {
                        lineStyle: {
                            width: 20,
                            color: [[1, ui.gaugeTrack]]
                        }
                    },
                    axisTick: { show: false },
                    splitLine: { show: false },
                    axisLabel: { show: false },
                    title: {
                        offsetCenter: [0, '30%'],
                        fontSize: 14,
                        color: ui.legendText
                    },
                    detail: {
                        valueAnimation: true,
                        fontSize: 28,
                        fontWeight: 'bold',
                        offsetCenter: [0, '-10%'],
                        color: ui.tooltipText,
                        formatter: function(v) {
                            return v.toFixed(1) + (data.unit ? ' ' + data.unit : '');
                        }
                    },
                    data: [{ value: data.value, name: data.name }]
                }]
            };
        }

        function initMapWidget(id, container) {
            fetch('/dashboard/api/widget/map')
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    var map = L.map(container).setView(data.center, data.zoom);

                    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                        attribution: '&copy; OpenStreetMap'
                    }).addTo(map);

                    data.locations.forEach(function(loc) {
                        var semantic = JEVisChartTheme.getSemanticColors();
                        var color = loc.status === 'online' ? semantic.statusOnline : semantic.statusWarning;
                        var marker = L.circleMarker([loc.lat, loc.lng], {
                            radius: 10,
                            fillColor: color,
                            color: '#fff',
                            weight: 2,
                            fillOpacity: 0.8
                        }).addTo(map);

                        marker.bindPopup(
                            '<strong>' + loc.name + '</strong><br/>' +
                            'Leistung: ' + loc.power + '<br/>' +
                            'Status: ' + loc.status
                        );
                    });

                    widgets[id].map = map;

                    // Handle resize
                    var resizeObserver = new ResizeObserver(function() {
                        map.invalidateSize();
                    });
                    resizeObserver.observe(container);
                });
        }

        function refreshWidget(id) {
            var w = widgets[id];
            if (!w) return;

            if (w.type === 'map' && w.map) {
                w.map.invalidateSize();
            } else if (w.chart) {
                loadWidgetData(id, w.type);
            }
        }

        function removeWidget(id) {
            var el = document.getElementById(id);
            if (el) {
                grid.removeWidget(el);
            }

            var w = widgets[id];
            if (w) {
                if (w.chart) w.chart.dispose();
                if (w.map) w.map.remove();
                delete widgets[id];
            }

            saveLayout();
        }

        // Widget Settings Functions
        var selectedSensorsData = []; // Array of {id, name, code, unit, color}

        function openWidgetSettings(id) {
            var w = widgets[id];
            if (!w) return;

            document.getElementById('settingsWidgetId').value = id;
            document.getElementById('settingsTitle').value = w.title;

            // Set widget type display
            var typeNames = {
                'line': 'Liniendiagramm',
                'area': 'Flaechendiagramm',
                'bar': 'Balkendiagramm',
                'radial': 'Radiales Diagramm',
                'pie': 'Kreisdiagramm',
                'gauge': 'Tachometer',
                'map': 'Karte'
            };
            document.getElementById('settingsWidgetType').value = typeNames[w.type] || w.type;

            // Show/hide datasources tab based on widget type
            var supportsSensors = ['line', 'area', 'bar', 'radial'].indexOf(w.type) !== -1;
            document.getElementById('tabDatasources').style.display = supportsSensors ? 'flex' : 'none';

            // Reset filters
            document.getElementById('sensorFilterName').value = '';
            document.getElementById('sensorFilterType').value = '';
            document.getElementById('sensorFilterLocation').value = '';

            // Reset selected sensors
            selectedSensorsData = [];

            // Load saved sensor configurations
            if (w.sensorConfigs && w.sensorConfigs.length > 0) {
                w.sensorConfigs.forEach(function(config) {
                    selectedSensorsData.push({
                        id: config.id,
                        name: config.name,
                        code: config.code || '',
                        unit: config.unit || '',
                        color: config.color
                    });
                });
            } else if (w.sensorIds && w.sensorIds.length > 0) {
                // Migrate from old format
                w.sensorIds.forEach(function(sensorId, index) {
                    var sensorEl = document.querySelector('#availableSensorList .sensor-item[data-sensor-id="' + sensorId + '"]');
                    if (sensorEl) {
                        selectedSensorsData.push({
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
            renderSelectedSensors();
            filterSensors();
            updateSensorCounts();

            // Switch to general tab
            switchSettingsTab('general');

            document.getElementById('widgetSettingsModal').style.display = 'flex';
        }

        function closeWidgetSettingsModal() {
            document.getElementById('widgetSettingsModal').style.display = 'none';
        }

        function switchSettingsTab(tabName) {
            // Update tab buttons
            document.querySelectorAll('.settings-tab').forEach(function(tab) {
                tab.classList.toggle('active', tab.dataset.tab === tabName);
            });

            // Update tab content
            document.querySelectorAll('.settings-tab-content').forEach(function(content) {
                content.classList.remove('active');
            });

            if (tabName === 'general') {
                document.getElementById('tabContentGeneral').classList.add('active');
            } else if (tabName === 'datasources') {
                document.getElementById('tabContentDatasources').classList.add('active');
            }
        }

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

        function saveWidgetSettings() {
            var id = document.getElementById('settingsWidgetId').value;
            var w = widgets[id];
            if (!w) return;

            // Update title
            var newTitle = document.getElementById('settingsTitle').value.trim() || 'Widget';
            w.title = newTitle;

            // Update DOM title
            var el = document.getElementById(id);
            if (el) {
                var titleEl = el.querySelector('[data-widget-title]');
                if (titleEl) titleEl.textContent = newTitle;
            }

            // Update sensor configurations (with individual colors)
            w.sensorConfigs = selectedSensorsData.map(function(s) {
                return {
                    id: s.id,
                    name: s.name,
                    code: s.code,
                    unit: s.unit,
                    color: s.color
                };
            });

            // Also keep sensorIds for backward compatibility
            w.sensorIds = selectedSensorsData.map(function(s) { return s.id; });

            // Reload chart with new settings
            if (w.chart && w.type !== 'map') {
                loadWidgetData(id, w.type);
            }

            saveLayout();
            closeWidgetSettingsModal();
        }
    </script>
    `
)
