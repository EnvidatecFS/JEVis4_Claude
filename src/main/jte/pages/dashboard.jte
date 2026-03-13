@import org.jevis.model.Sensor
@import java.util.List
@import java.util.Map
@import org.springframework.security.web.csrf.CsrfToken
@import org.jevis.model.Tenant

@param String username
@param List<Sensor> sensors = null
@param Map<String, List<Sensor>> sensorsByType = null
@param CsrfToken _csrf = null
@param boolean isAdmin = false
@param List<Tenant> userTenants = java.util.Collections.emptyList()
@param Tenant activeTenant = null

@template.layout.app(
    title = "Dashboard",
    username = username,
    currentPage = "dashboard",
    _csrf = _csrf,
    isAdmin = isAdmin,
    userTenants = userTenants,
    activeTenant = activeTenant,
    content = @`
    <!-- Dashboard Toolbar (single row) -->
    <div class="dashboard-toolbar">
        <!-- View Selector -->
        <div class="view-selector-wrapper" id="viewSelectorWrapper">
            <button class="btn btn-outline view-selector-btn" onclick="toggleViewDropdown()" id="viewSelectorBtn">
                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
                </svg>
                <span id="viewSelectorLabel">Ansichten</span>
                <svg width="12" height="12" fill="none" stroke="currentColor" viewBox="0 0 24 24" class="chevron-icon">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                </svg>
            </button>
            <div class="view-dropdown" id="viewDropdown">
                <div class="view-dropdown-list" id="viewDropdownList" tabindex="-1">
                    <!-- Populated dynamically -->
                </div>
                <div class="view-dropdown-footer">
                    <button class="btn btn-sm btn-primary" onclick="openSaveViewModal()" style="width: 100%;">
                        <svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                        </svg>
                        Neue Ansicht speichern
                    </button>
                </div>
            </div>
        </div>

        <!-- Save Button (floppy icon only) -->
        <div class="split-btn-wrapper" id="saveSplitWrapper">
            <button class="btn btn-outline split-btn-main" onclick="saveCurrentView()" id="saveViewBtn" title="Aktuelle Ansicht speichern">
                <!-- Floppy disk icon -->
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>
                    <polyline points="17 21 17 13 7 13 7 21"/>
                    <polyline points="7 3 7 8 15 8"/>
                </svg>
            </button>
            <button class="btn btn-outline split-btn-toggle" onclick="toggleSaveDropdown()" title="Weitere Speicheroptionen">
                <svg width="12" height="12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                </svg>
            </button>
            <div class="split-btn-dropdown" id="saveDropdown">
                <div class="split-btn-dropdown-item" onclick="saveCurrentView(); closeSaveDropdown();">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>
                        <polyline points="17 21 17 13 7 13 7 21"/>
                        <polyline points="7 3 7 8 15 8"/>
                    </svg>
                    Speichern
                </div>
                <div class="split-btn-dropdown-item" onclick="openSaveViewModal(); closeSaveDropdown();">
                    <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                    </svg>
                    Speichern als...
                </div>
            </div>
        </div>

        <!-- Edit Mode Button (lock icon) -->
        <button class="btn btn-outline toolbar-icon-btn" onclick="toggleEditMode()" id="editModeBtn" title="Bearbeiten">
            <!-- Closed lock = view mode -->
            <svg id="lockIconClosed" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
            </svg>
            <!-- Open lock = edit mode -->
            <svg id="lockIconOpen" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="display:none;">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                <path d="M7 11V7a5 5 0 0 1 9.9-1"/>
            </svg>
        </button>

        <!-- Toolbar separator -->
        <div class="toolbar-separator"></div>

        <!-- Interval buttons -->
        <div class="time-interval-group">
            <button class="interval-btn" data-interval="hour" onclick="setInterval_('hour')">Stunde</button>
            <button class="interval-btn" data-interval="day" onclick="setInterval_('day')">Tag</button>
            <button class="interval-btn" data-interval="workweek" onclick="setInterval_('workweek')">Arbeitswoche</button>
            <button class="interval-btn" data-interval="week" onclick="setInterval_('week')">Woche</button>
            <button class="interval-btn" data-interval="month" onclick="setInterval_('month')">Monat</button>
            <button class="interval-btn" data-interval="year" onclick="setInterval_('year')">Jahr</button>
        </div>

        <!-- Time navigation -->
        <div class="time-nav-group">
            <button class="icon-button time-nav-btn" onclick="navigateTime(-1)" title="Zurück">
                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7"/>
                </svg>
            </button>
            <span class="time-range-label" id="timeRangeLabel">—</span>
            <button class="icon-button time-nav-btn" onclick="navigateTime(1)" title="Vorwärts">
                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7"/>
                </svg>
            </button>
            <button class="btn btn-sm btn-secondary" onclick="goToNow()" style="margin-left:4px;">Heute</button>
        </div>

        <!-- Add Widget (visible only in edit mode) -->
        <button class="btn btn-primary" onclick="openAddWidgetModal()" id="addWidgetBtn" style="display: none;">
            <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
            </svg>
            Widget hinzufuegen
        </button>
    </div>

    <!-- Migration Banner -->
    <div class="migration-banner" id="migrationBanner" style="display: none;">
        <div class="migration-banner-content">
            <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            <span>Sie haben ein gespeichertes Layout im Browser. Moechten Sie es als Ansicht auf dem Server speichern?</span>
            <button class="btn btn-sm btn-primary" onclick="migrateLocalStorage()">Jetzt speichern</button>
            <button class="btn btn-sm btn-outline" onclick="dismissMigrationBanner()">Spaeter</button>
        </div>
    </div>

    <!-- GridStack Container -->
    <div class="grid-stack" id="dashboardGrid"></div>

    <!-- Save View Modal -->
    <div id="saveViewModal" class="modal" style="display: none;">
        <div class="modal-backdrop" onclick="closeSaveViewModal()"></div>
        <div class="modal-content" style="max-width: 420px;">
            <div class="modal-header">
                <h3 class="modal-title">Ansicht speichern</h3>
                <button class="modal-close" onclick="closeSaveViewModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Name der Ansicht</label>
                    <input type="text" id="saveViewName" class="form-control" placeholder="z.B. Hauptansicht, Monitoring...">
                </div>
                <div class="form-group" style="margin-bottom: 0;">
                    <label style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
                        <input type="checkbox" id="saveViewDefault">
                        <span class="form-label" style="margin-bottom: 0;">Als Standard-Ansicht festlegen</span>
                    </label>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-outline" onclick="closeSaveViewModal()">Abbrechen</button>
                <button class="btn btn-primary" onclick="saveViewAs()">Speichern</button>
            </div>
        </div>
    </div>

    <!-- Rename View Modal -->
    <div id="renameViewModal" class="modal" style="display: none;">
        <div class="modal-backdrop" onclick="closeRenameViewModal()"></div>
        <div class="modal-content" style="max-width: 420px;">
            <div class="modal-header">
                <h3 class="modal-title">Ansicht umbenennen</h3>
                <button class="modal-close" onclick="closeRenameViewModal()">&times;</button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="renameViewId">
                <div class="form-group" style="margin-bottom: 0;">
                    <label class="form-label">Neuer Name</label>
                    <input type="text" id="renameViewName" class="form-control" placeholder="Name der Ansicht">
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-outline" onclick="closeRenameViewModal()">Abbrechen</button>
                <button class="btn btn-primary" onclick="confirmRenameView()">Umbenennen</button>
            </div>
        </div>
    </div>

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
                    <div class="widget-type-card" onclick="addWidget('treemap')">
                        <div class="widget-type-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="2" y="2" width="9" height="11"/>
                                <rect x="13" y="2" width="9" height="6"/>
                                <rect x="13" y="10" width="9" height="3"/>
                                <rect x="2" y="15" width="6" height="7"/>
                                <rect x="10" y="15" width="12" height="7"/>
                            </svg>
                        </div>
                        <div class="widget-type-name">Treemap</div>
                        <div class="widget-type-desc">Hierarchische Summen</div>
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
                    <div class="widget-type-card" onclick="addWidget('sankey')">
                        <div class="widget-type-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M2 5h6v4H2z" fill="currentColor" opacity="0.3"/>
                                <path d="M2 15h6v4H2z" fill="currentColor" opacity="0.3"/>
                                <path d="M16 8h6v8h-6z" fill="currentColor" opacity="0.3"/>
                                <path d="M8 7 Q14 7 16 10" stroke-width="2.5"/>
                                <path d="M8 17 Q14 17 16 14" stroke-width="2.5"/>
                            </svg>
                        </div>
                        <div class="widget-type-name">Sankey-Diagramm</div>
                        <div class="widget-type-desc">Energiefluss-Hierarchie</div>
                    </div>
                    <div class="widget-type-card" onclick="addWidget('scada')">
                        <div class="widget-type-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="2" y="3" width="20" height="14" rx="1"/>
                                <circle cx="8" cy="10" r="2"/>
                                <circle cx="16" cy="10" r="2"/>
                                <path d="M8 10h8M12 8v4" stroke-width="1.5"/>
                                <path d="M7 21h10M12 17v4" stroke-width="2"/>
                            </svg>
                        </div>
                        <div class="widget-type-name">SCADA-Ansicht</div>
                        <div class="widget-type-desc">Bild mit Live-Werten</div>
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
                <button class="settings-tab" data-tab="sankey" onclick="switchSettingsTab('sankey')" id="tabSankey" style="display:none;">
                    <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"/>
                    </svg>
                    Sankey
                </button>
                <button class="settings-tab" data-tab="scada" onclick="switchSettingsTab('scada')" id="tabScada" style="display:none;">
                    <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <rect x="2" y="3" width="20" height="14" rx="1" stroke-width="2"/>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 21h8M12 17v4"/>
                    </svg>
                    SCADA
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

                <!-- Tab: Sankey Configuration -->
                <div class="settings-tab-content" id="tabContentSankey"
                     hx-get="/sankey/config/panel" hx-trigger="intersect once">
                    <div style="padding:20px; text-align:center; color:var(--text-secondary);">Lädt...</div>
                </div>

                <!-- Tab: SCADA Layout -->
                <div class="settings-tab-content" id="tabContentScada">
                    <div class="form-group">
                        <label class="form-label">Hintergrundbild</label>
                        <select id="scadaSettingsImage" class="form-control" onchange="scadaSettingsImageChanged(this.value)">
                            <option value="">-- Kein Bild --</option>
                        </select>
                    </div>
                    <div class="form-group" style="display:flex;gap:0.5rem;align-items:center;">
                        <button class="btn btn-outline btn-sm" onclick="document.getElementById('scadaSettingsUploadInput').click()">
                            + Neues Bild hochladen
                        </button>
                        <input type="file" id="scadaSettingsUploadInput" accept="image/*" style="display:none" onchange="scadaSettingsUploadImage(this)">
                        <span id="scadaUploadStatus" style="font-size:0.8rem;color:var(--text-muted);"></span>
                    </div>
                    <div style="margin-top:0.5rem;border-top:1px solid var(--border-color);padding-top:1rem;">
                        <button class="btn btn-primary" onclick="openScadaEditorFromSettings()">
                            <svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/>
                            </svg>
                            Layout bearbeiten
                        </button>
                        <p style="margin-top:0.5rem;font-size:0.8rem;color:var(--text-muted);">Felder positionieren, Sensoren zuordnen, Darstellung anpassen.</p>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button class="btn btn-outline" onclick="closeWidgetSettingsModal()">Abbrechen</button>
                <button class="btn btn-primary" onclick="saveWidgetSettings()">Speichern</button>
            </div>
        </div>
    </div>

    <!-- SCADA Editor Overlay -->
    <div id="scadaEditorOverlay" style="display:none;position:fixed;inset:0;z-index:2000;background:var(--bg-color,#f5f7fa);flex-direction:column;">
        <!-- Header -->
        <div class="scada-editor-header">
            <span class="scada-editor-title" id="scadaEditorTitle">SCADA Layout Editor</span>
            <div style="display:flex;gap:0.5rem;">
                <button class="btn btn-primary btn-sm" onclick="saveScadaEditor()">Speichern</button>
                <button class="btn btn-outline btn-sm" onclick="closeScadaEditor()">Abbrechen</button>
            </div>
        </div>
        <!-- Body: Palette | Canvas | Properties -->
        <div class="scada-editor-body">
            <!-- Left: Palette + Field List -->
            <div class="scada-editor-palette">
                <div style="padding:0.75rem;border-bottom:1px solid var(--border-color);">
                    <button class="btn btn-outline btn-sm" style="width:100%;margin-bottom:0.4rem;" onclick="addScadaTextField()">+ Text-Feld</button>
                    <button class="btn btn-outline btn-sm" style="width:100%;" onclick="addScadaValueField()">+ Wert-Feld</button>
                </div>
                <div style="padding:0.5rem 0.75rem;font-size:0.75rem;font-weight:600;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.05em;">Felder</div>
                <div id="scadaEditorFieldList" style="flex:1;overflow-y:auto;padding:0 0.5rem;"></div>
            </div>
            <!-- Center: Canvas -->
            <div class="scada-editor-center">
                <div class="scada-editor-toolbar">
                    <div style="display:flex;align-items:center;gap:0.5rem;flex-wrap:wrap;">
                        <label style="font-size:0.8rem;color:var(--text-muted);">Bild:</label>
                        <select id="scadaImageSelect" class="form-control form-control-sm" style="width:220px;" onchange="scadaImageChanged(this.value)">
                            <option value="">-- Kein Bild --</option>
                        </select>
                        <label style="font-size:0.8rem;color:var(--text-muted);">Design:</label>
                        <input type="number" id="scadaDesignWidth" class="form-control form-control-sm" style="width:70px;" value="800" onchange="scadaDesignSizeChanged()">
                        <span style="font-size:0.8rem;color:var(--text-muted);">×</span>
                        <input type="number" id="scadaDesignHeight" class="form-control form-control-sm" style="width:70px;" value="450" onchange="scadaDesignSizeChanged()">
                        <button class="btn btn-outline btn-sm" onclick="document.getElementById('scadaEditorUploadInput').click()">Bild hochladen</button>
                        <input type="file" id="scadaEditorUploadInput" accept="image/*" style="display:none" onchange="scadaEditorUploadImage(this)">
                    </div>
                    <div style="display:flex;align-items:center;gap:0.5rem;margin-top:0.4rem;border-top:1px solid var(--border-color);padding-top:0.4rem;">
                        <label style="display:flex;align-items:center;gap:0.35rem;font-size:0.8rem;color:var(--text-color);cursor:pointer;user-select:none;">
                            <input type="checkbox" id="scadaSnapEnabled" checked onchange="scadaSnapToggle()">
                            Raster
                        </label>
                        <input type="number" id="scadaSnapSize" class="form-control form-control-sm" style="width:60px;" value="10" min="1" max="200" title="Rastergröße in Pixeln">
                        <span style="font-size:0.8rem;color:var(--text-muted);">px</span>
                        <span style="font-size:0.75rem;color:var(--text-muted);margin-left:0.25rem;" id="scadaSnapHint">Felder rasten beim Ablegen ein</span>
                    </div>
                </div>
                <div id="scadaEditorCanvasWrapper" class="scada-editor-canvas-wrapper"
                     ondragover="scadaEditorCanvasDragOver(event)"
                     ondrop="scadaEditorCanvasDrop(event)">
                    <div id="scadaEditorCanvas" class="scada-editor-canvas"></div>
                </div>
            </div>
            <!-- Right: Properties -->
            <div class="scada-editor-properties">
                <div style="padding:0.75rem;border-bottom:1px solid var(--border-color);font-size:0.85rem;font-weight:600;color:var(--text-color);">Eigenschaften</div>
                <div id="scadaEditorProperties" style="overflow-y:auto;flex:1;">
                    <p style="color:var(--text-muted);padding:1rem;font-size:0.85rem;">Feld auswählen</p>
                </div>
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

        /* Dashboard Toolbar - single row */
        .dashboard-toolbar {
            display: flex;
            align-items: center;
            justify-content: flex-start;
            gap: 0.375rem;
            margin-bottom: 1rem;
            flex-wrap: wrap;
            padding-left: 0;
        }
        /* Compact padding for all buttons inside the toolbar */
        .dashboard-toolbar .btn {
            padding: 0.375rem 0.5rem;
            font-size: 0.875rem;
        }
        .toolbar-icon-btn {
            padding: 0.375rem 0.5rem !important;
            display: inline-flex;
            align-items: center;
        }
        .toolbar-separator {
            width: 1px;
            height: 24px;
            background: var(--border-color);
            margin: 0 0.125rem;
        }

        /* View Selector */
        .view-selector-wrapper {
            position: relative;
        }

        .view-selector-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
        }

        /* View dropdown item keyboard focus */
        .view-dropdown-item:focus,
        .view-dropdown-item.focused {
            background: var(--hover-color);
            outline: none;
        }

        /* Split Button */
        .split-btn-wrapper {
            position: relative;
            display: inline-flex;
        }

        .split-btn-main {
            border-top-right-radius: 0;
            border-bottom-right-radius: 0;
            border-right: none;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
        }

        .split-btn-toggle {
            border-top-left-radius: 0;
            border-bottom-left-radius: 0;
            padding-left: 0.4rem;
            padding-right: 0.4rem;
            display: inline-flex;
            align-items: center;
        }

        .split-btn-dropdown {
            display: none;
            position: absolute;
            top: calc(100% + 4px);
            right: 0;
            min-width: 200px;
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius-lg);
            box-shadow: var(--shadow-lg);
            z-index: 100;
            overflow: hidden;
            padding: 0.25rem;
        }

        .split-btn-dropdown.show {
            display: block;
        }

        .split-btn-dropdown-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 0.75rem;
            border-radius: var(--border-radius);
            cursor: pointer;
            transition: background 0.15s;
            font-size: 0.9rem;
            color: var(--text-color);
        }

        .split-btn-dropdown-item:hover {
            background: var(--hover-color);
        }

        .view-dropdown {
            display: none;
            position: absolute;
            top: calc(100% + 4px);
            left: 0;
            min-width: 280px;
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius-lg);
            box-shadow: var(--shadow-lg);
            z-index: 100;
            overflow: hidden;
        }

        .view-dropdown.show {
            display: block;
        }

        .view-dropdown-list {
            max-height: 300px;
            overflow-y: auto;
            padding: 0.25rem;
        }

        .view-dropdown-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0.5rem 0.75rem;
            border-radius: var(--border-radius);
            cursor: pointer;
            transition: background 0.15s;
        }

        .view-dropdown-item:hover {
            background: var(--hover-color);
        }

        .view-dropdown-item.active {
            background: rgba(59, 130, 246, 0.1);
            border-left: 3px solid var(--primary-color);
        }

        .view-dropdown-item-info {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex: 1;
            min-width: 0;
        }

        .view-dropdown-item-name {
            font-size: 0.9rem;
            color: var(--text-color);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .view-badge-default {
            font-size: 0.65rem;
            padding: 0.1rem 0.35rem;
            background: var(--success-color);
            color: white;
            border-radius: 8px;
            white-space: nowrap;
        }

        .view-dropdown-item-actions {
            display: flex;
            gap: 0.15rem;
            opacity: 0;
            transition: opacity 0.15s;
        }

        .view-dropdown-item:hover .view-dropdown-item-actions {
            opacity: 1;
        }

        .view-dropdown-item-actions button {
            padding: 0.2rem;
            background: transparent;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            color: var(--text-muted);
            line-height: 1;
        }

        .view-dropdown-item-actions button:hover {
            background: var(--hover-color);
            color: var(--text-color);
        }

        .view-dropdown-item-actions button.danger:hover {
            background: var(--danger-color);
            color: white;
        }

        .view-dropdown-footer {
            padding: 0.5rem;
            border-top: 1px solid var(--border-color);
        }

        .view-dropdown-empty {
            padding: 1rem;
            text-align: center;
            color: var(--text-muted);
            font-size: 0.85rem;
        }

        /* Migration Banner */
        .migration-banner {
            margin-bottom: 1rem;
            background: rgba(59, 130, 246, 0.08);
            border: 1px solid rgba(59, 130, 246, 0.2);
            border-radius: var(--border-radius-lg);
            padding: 0.75rem 1rem;
        }

        .migration-banner-content {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            flex-wrap: wrap;
        }

        .migration-banner-content svg {
            color: var(--primary-color);
            flex-shrink: 0;
        }

        .migration-banner-content span {
            flex: 1;
            font-size: 0.9rem;
            color: var(--text-color);
        }

        /* Interval group (inside toolbar) */
        .time-interval-group {
            display: flex;
            gap: 2px;
            background: transparent;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: 2px;
        }
        .interval-btn {
            padding: 4px 10px;
            border: none;
            border-radius: calc(var(--radius-md) - 2px);
            background: none;
            cursor: pointer;
            font-size: 0.875rem;
            color: var(--text-color);
            font-family: inherit;
            transition: background 0.15s, color 0.15s;
            white-space: nowrap;
        }
        .interval-btn:hover {
            background: var(--primary-color);
            color: white;
        }
        .interval-btn.active {
            background: var(--primary-color);
            color: white;
            font-weight: 600;
        }
        .time-nav-group {
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
        }
        .time-nav-btn {
            width: 28px;
            height: 28px;
        }
        .time-range-label {
            min-width: 200px;
            text-align: center;
            font-size: 13px;
            font-weight: 500;
            color: var(--text-primary);
        }

        /* ── SCADA Widget ─────────────────────────────────────────────────────── */
        .scada-outer {
            position: relative;
            overflow: hidden;
            width: 100%;
            border-radius: var(--border-radius);
        }

        .scada-placeholder {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
            min-height: 120px;
            color: var(--text-muted);
            font-size: 0.85rem;
            text-align: center;
            padding: 1rem;
            flex-direction: column;
            gap: 0.5rem;
        }

        /* ── SCADA Editor Overlay ─────────────────────────────────────────────── */
        .scada-editor-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.75rem 1.25rem;
            background: var(--card-bg);
            border-bottom: 1px solid var(--border-color);
            flex-shrink: 0;
        }

        .scada-editor-title {
            font-size: 1rem;
            font-weight: 600;
            color: var(--text-color);
        }

        .scada-editor-body {
            display: flex;
            flex: 1;
            overflow: hidden;
        }

        .scada-editor-palette {
            width: 200px;
            flex-shrink: 0;
            border-right: 1px solid var(--border-color);
            background: var(--card-bg);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .scada-editor-center {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            background: var(--hover-color);
        }

        .scada-editor-toolbar {
            padding: 0.5rem 0.75rem;
            background: var(--card-bg);
            border-bottom: 1px solid var(--border-color);
            flex-shrink: 0;
        }

        .scada-editor-canvas-wrapper {
            flex: 1;
            overflow: auto;
            padding: 1rem;
            position: relative;
        }

        .scada-editor-canvas {
            position: relative;
            background: #1a1a2e;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }

        .scada-editor-properties {
            width: 260px;
            flex-shrink: 0;
            border-left: 1px solid var(--border-color);
            background: var(--card-bg);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .scada-editor-field {
            position: absolute;
            cursor: grab;
            border: 1px dashed transparent;
            padding: 2px 6px;
            white-space: nowrap;
            user-select: none;
        }

        .scada-editor-field:hover {
            border-color: rgba(59, 130, 246, 0.6);
        }

        .scada-editor-field.selected {
            border-color: var(--primary-color);
            outline: 1px solid var(--primary-color);
        }

        .scada-field-list-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.35rem 0.5rem;
            border-radius: var(--border-radius);
            cursor: pointer;
            font-size: 0.82rem;
            color: var(--text-color);
            transition: background 0.15s;
        }

        .scada-field-list-item:hover {
            background: var(--hover-color);
        }

        .scada-field-list-item.active {
            background: rgba(59, 130, 246, 0.12);
            color: var(--primary-color);
        }

        .scada-field-del-btn {
            background: none;
            border: none;
            cursor: pointer;
            color: var(--text-muted);
            font-size: 1rem;
            line-height: 1;
            padding: 0 2px;
            border-radius: 3px;
        }

        .scada-field-del-btn:hover {
            background: var(--danger-color);
            color: white;
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

        // View management state
        var currentViewId = null;
        var currentViewName = null;
        var viewsList = [];
        var saveLayoutTimer = null;

        document.addEventListener('DOMContentLoaded', function() {
            initGrid();
            loadDefaultWidgets();
            updateTimeToolbar();
        });

        // Close view dropdown when clicking outside
        document.addEventListener('click', function(event) {
            var wrapper = document.getElementById('viewSelectorWrapper');
            var dropdown = document.getElementById('viewDropdown');
            if (wrapper && !wrapper.contains(event.target)) {
                dropdown.classList.remove('show');
            }
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

        // === CSRF Helper ===
        function fetchWithCsrf(url, options) {
            options = options || {};
            options.headers = options.headers || {};
            var csrfToken = document.querySelector('meta[name="csrf-token"]');
            var csrfHeader = document.querySelector('meta[name="csrf-header"]');
            if (csrfToken && csrfHeader) {
                options.headers[csrfHeader.content] = csrfToken.content;
            }
            if (!options.headers['Content-Type'] && options.body) {
                options.headers['Content-Type'] = 'application/json';
            }
            return fetch(url, options);
        }

        // === View Management ===

        function loadDefaultWidgets() {
            // First check server for saved views
            fetch('/dashboard/api/views')
                .then(function(r) { return r.json(); })
                .then(function(views) {
                    viewsList = views;
                    renderViewSelector();

                    if (views.length > 0) {
                        // Load default view or first view
                        var defaultView = views.find(function(v) { return v.isDefault; });
                        var viewToLoad = defaultView || views[0];
                        loadView(viewToLoad.id);
                    } else {
                        // No server views - check localStorage
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
                                // Show migration banner
                                showMigrationBanner();
                                return;
                            } catch(e) {
                                console.error('Error loading layout:', e);
                            }
                        }

                        // Default layout
                        createDefaultWidgets();
                    }
                })
                .catch(function(err) {
                    console.error('Error loading views:', err);
                    // Fallback to localStorage
                    var savedLayout = localStorage.getItem('dashboardLayout');
                    if (savedLayout) {
                        try {
                            var layout = JSON.parse(savedLayout);
                            layout.forEach(function(item) {
                                createWidget(item.type, item.x, item.y, item.w, item.h, item.title, {
                                    sensorConfigs: item.sensorConfigs || [],
                                    sensorIds: item.sensorIds || [],
                                    config: item.config || null
                                });
                            });
                            return;
                        } catch(e) { /* ignore */ }
                    }
                    createDefaultWidgets();
                });
        }

        function createDefaultWidgets() {
            createWidget('line', 0, 0, 6, 4, 'Leistungsverlauf');
            createWidget('gauge', 6, 0, 3, 4, 'Aktueller Wirkungsgrad');
            createWidget('pie', 9, 0, 3, 4, 'Sensorverteilung');
            createWidget('bar', 0, 4, 4, 4, 'Monatsvergleich');
            createWidget('area', 4, 4, 5, 4, 'Tagesproduktion');
            createWidget('map', 9, 4, 3, 4, 'Anlagenstandorte');
        }

        function loadViewsList() {
            fetch('/dashboard/api/views')
                .then(function(r) { return r.json(); })
                .then(function(views) {
                    viewsList = views;
                    renderViewSelector();
                });
        }

        function renderViewSelector() {
            var list = document.getElementById('viewDropdownList');
            var label = document.getElementById('viewSelectorLabel');
            var saveSplit = document.getElementById('saveSplitWrapper');

            // Update label and save button visibility
            if (currentViewId && currentViewName) {
                label.textContent = currentViewName;
                saveSplit.style.display = 'inline-flex';
            } else {
                label.textContent = 'Ansichten';
                saveSplit.style.display = 'none';
            }

            // Build dropdown list
            if (viewsList.length === 0) {
                list.innerHTML = '<div class="view-dropdown-empty">Keine gespeicherten Ansichten</div>';
                return;
            }

            var html = '';
            viewsList.forEach(function(view) {
                var isActive = view.id === currentViewId;
                html += '<div class="view-dropdown-item' + (isActive ? ' active' : '') + '" onclick="loadView(' + view.id + ')">';
                html += '  <div class="view-dropdown-item-info">';
                html += '    <span class="view-dropdown-item-name">' + escapeHtml(view.name) + '</span>';
                if (view.isDefault) {
                    html += '    <span class="view-badge-default">Standard</span>';
                }
                html += '  </div>';
                html += '  <div class="view-dropdown-item-actions">';
                // Set as default button
                if (!view.isDefault) {
                    html += '    <button onclick="event.stopPropagation(); setViewAsDefault(' + view.id + ')" title="Als Standard festlegen">';
                    html += '      <svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"/></svg>';
                    html += '    </button>';
                }
                // Rename button
                html += '    <button onclick="event.stopPropagation(); openRenameView(' + view.id + ', \'' + escapeHtml(view.name).replace(/'/g, "\\'") + '\')" title="Umbenennen">';
                html += '      <svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/></svg>';
                html += '    </button>';
                // Delete button
                html += '    <button class="danger" onclick="event.stopPropagation(); deleteView(' + view.id + ', \'' + escapeHtml(view.name).replace(/'/g, "\\'") + '\')" title="Loeschen">';
                html += '      <svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>';
                html += '    </button>';
                html += '  </div>';
                html += '</div>';
            });

            list.innerHTML = html;
        }

        function escapeHtml(text) {
            var div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        var viewDropdownFocusIndex = -1;

        function toggleViewDropdown() {
            var dropdown = document.getElementById('viewDropdown');
            dropdown.classList.toggle('show');
            if (dropdown.classList.contains('show')) {
                viewDropdownFocusIndex = -1;
                // Focus the list for keyboard events
                document.getElementById('viewDropdownList').focus();
            }
        }

        // Keyboard navigation for view dropdown
        document.addEventListener('keydown', function(e) {
            var dropdown = document.getElementById('viewDropdown');
            if (!dropdown || !dropdown.classList.contains('show')) return;

            var items = dropdown.querySelectorAll('.view-dropdown-item');
            if (items.length === 0) return;

            if (e.key === 'ArrowDown') {
                e.preventDefault();
                viewDropdownFocusIndex = Math.min(viewDropdownFocusIndex + 1, items.length - 1);
                updateViewDropdownFocus(items);
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                viewDropdownFocusIndex = Math.max(viewDropdownFocusIndex - 1, 0);
                updateViewDropdownFocus(items);
            } else if (e.key === 'Enter' && viewDropdownFocusIndex >= 0) {
                e.preventDefault();
                items[viewDropdownFocusIndex].click();
            } else if (e.key === 'Escape') {
                dropdown.classList.remove('show');
                viewDropdownFocusIndex = -1;
            }
        });

        function updateViewDropdownFocus(items) {
            items.forEach(function(item, i) {
                if (i === viewDropdownFocusIndex) {
                    item.classList.add('focused');
                    item.scrollIntoView({ block: 'nearest' });
                } else {
                    item.classList.remove('focused');
                }
            });
        }

        // Save split-button dropdown
        function toggleSaveDropdown() {
            document.getElementById('saveDropdown').classList.toggle('show');
        }

        function closeSaveDropdown() {
            document.getElementById('saveDropdown').classList.remove('show');
        }

        // Close dropdowns when clicking outside
        document.addEventListener('click', function(e) {
            var viewWrapper = document.getElementById('viewSelectorWrapper');
            var viewDropdown = document.getElementById('viewDropdown');
            if (viewWrapper && !viewWrapper.contains(e.target)) {
                viewDropdown.classList.remove('show');
            }
            var saveWrapper = document.getElementById('saveSplitWrapper');
            var saveDropdown = document.getElementById('saveDropdown');
            if (saveWrapper && !saveWrapper.contains(e.target)) {
                saveDropdown.classList.remove('show');
            }
        });

        function loadView(id) {
            document.getElementById('viewDropdown').classList.remove('show');

            fetch('/dashboard/api/views/' + id)
                .then(function(r) { return r.json(); })
                .then(function(view) {
                    currentViewId = view.id;
                    currentViewName = view.name;

                    // Clear existing widgets
                    clearAllWidgets();

                    // Load layout from view
                    if (view.layoutJson) {
                        try {
                            var layout = JSON.parse(view.layoutJson);
                            layout.forEach(function(item) {
                                createWidget(item.type, item.x, item.y, item.w, item.h, item.title, {
                                    sensorConfigs: item.sensorConfigs || [],
                                    sensorIds: item.sensorIds || [],
                                    config: item.config || null
                                });
                            });
                        } catch(e) {
                            console.error('Error parsing view layout:', e);
                            createDefaultWidgets();
                        }
                    } else {
                        createDefaultWidgets();
                    }

                    renderViewSelector();
                    hideMigrationBanner();
                })
                .catch(function(err) {
                    console.error('Error loading view:', err);
                });
        }

        function clearAllWidgets() {
            Object.keys(widgets).forEach(function(id) {
                var w = widgets[id];
                if (w.chart) w.chart.dispose();
                if (w.map) w.map.remove();
                if (w.scadaResizeObserver) w.scadaResizeObserver.disconnect();
            });
            widgets = {};
            widgetCounter = 0;
            grid.removeAll();
        }

        function getLayoutJson() {
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
                        config: w.scadaConfig || null,
                        x: node.x,
                        y: node.y,
                        w: node.w,
                        h: node.h
                    });
                }
            });
            return JSON.stringify(layout);
        }

        function saveLayout() {
            var layoutJson = getLayoutJson();
            // Always save to localStorage as fallback
            localStorage.setItem('dashboardLayout', layoutJson);

            // If a view is active, debounce save to server
            if (currentViewId) {
                if (saveLayoutTimer) clearTimeout(saveLayoutTimer);
                saveLayoutTimer = setTimeout(function() {
                    fetchWithCsrf('/dashboard/api/views/' + currentViewId + '/layout', {
                        method: 'PUT',
                        body: JSON.stringify({ layoutJson: layoutJson })
                    }).catch(function(err) {
                        console.error('Error saving layout to server:', err);
                    });
                }, 1000);
            }
        }

        // === Save / Create View ===

        function openSaveViewModal() {
            document.getElementById('viewDropdown').classList.remove('show');
            document.getElementById('saveViewName').value = '';
            document.getElementById('saveViewDefault').checked = false;
            document.getElementById('saveViewModal').style.display = 'flex';
            setTimeout(function() {
                document.getElementById('saveViewName').focus();
            }, 100);
        }

        function closeSaveViewModal() {
            document.getElementById('saveViewModal').style.display = 'none';
        }

        function saveViewAs() {
            var name = document.getElementById('saveViewName').value.trim();
            if (!name) {
                document.getElementById('saveViewName').focus();
                return;
            }

            var setAsDefault = document.getElementById('saveViewDefault').checked;
            var layoutJson = getLayoutJson();

            fetchWithCsrf('/dashboard/api/views', {
                method: 'POST',
                body: JSON.stringify({
                    name: name,
                    layoutJson: layoutJson,
                    setAsDefault: setAsDefault
                })
            })
            .then(function(r) { return r.json(); })
            .then(function(view) {
                currentViewId = view.id;
                currentViewName = view.name;
                closeSaveViewModal();
                loadViewsList();
                hideMigrationBanner();
            })
            .catch(function(err) {
                console.error('Error saving view:', err);
            });
        }

        function saveCurrentView() {
            if (!currentViewId) return;
            var layoutJson = getLayoutJson();

            fetchWithCsrf('/dashboard/api/views/' + currentViewId + '/layout', {
                method: 'PUT',
                body: JSON.stringify({ layoutJson: layoutJson })
            })
            .then(function() {
                // Brief visual feedback
                var btn = document.getElementById('saveViewBtn');
                var origText = btn.innerHTML;
                btn.innerHTML = '<svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg> Gespeichert';
                setTimeout(function() { btn.innerHTML = origText; }, 1500);
            })
            .catch(function(err) {
                console.error('Error saving view:', err);
            });
        }

        // === Rename View ===

        function openRenameView(id, name) {
            document.getElementById('renameViewId').value = id;
            document.getElementById('renameViewName').value = name;
            document.getElementById('renameViewModal').style.display = 'flex';
            document.getElementById('viewDropdown').classList.remove('show');
            setTimeout(function() {
                document.getElementById('renameViewName').focus();
                document.getElementById('renameViewName').select();
            }, 100);
        }

        function closeRenameViewModal() {
            document.getElementById('renameViewModal').style.display = 'none';
        }

        function confirmRenameView() {
            var id = parseInt(document.getElementById('renameViewId').value);
            var newName = document.getElementById('renameViewName').value.trim();
            if (!newName) return;

            fetchWithCsrf('/dashboard/api/views/' + id, {
                method: 'PUT',
                body: JSON.stringify({ name: newName })
            })
            .then(function(r) { return r.json(); })
            .then(function(view) {
                if (currentViewId === id) {
                    currentViewName = view.name;
                }
                closeRenameViewModal();
                loadViewsList();
            })
            .catch(function(err) {
                console.error('Error renaming view:', err);
            });
        }

        // === Delete View ===

        function deleteView(id, name) {
            if (!confirm('Ansicht "' + name + '" wirklich loeschen?')) return;

            document.getElementById('viewDropdown').classList.remove('show');

            fetchWithCsrf('/dashboard/api/views/' + id, {
                method: 'DELETE'
            })
            .then(function() {
                if (currentViewId === id) {
                    currentViewId = null;
                    currentViewName = null;
                }
                loadViewsList();
            })
            .catch(function(err) {
                console.error('Error deleting view:', err);
            });
        }

        // === Set Default ===

        function setViewAsDefault(id) {
            fetchWithCsrf('/dashboard/api/views/' + id + '/default', {
                method: 'PUT'
            })
            .then(function() {
                document.getElementById('viewDropdown').classList.remove('show');
                loadViewsList();
            })
            .catch(function(err) {
                console.error('Error setting default view:', err);
            });
        }

        // === Migration ===

        function showMigrationBanner() {
            document.getElementById('migrationBanner').style.display = 'block';
        }

        function hideMigrationBanner() {
            document.getElementById('migrationBanner').style.display = 'none';
        }

        function dismissMigrationBanner() {
            hideMigrationBanner();
        }

        function migrateLocalStorage() {
            var savedLayout = localStorage.getItem('dashboardLayout');
            if (!savedLayout) return;

            fetchWithCsrf('/dashboard/api/views', {
                method: 'POST',
                body: JSON.stringify({
                    name: 'Meine Ansicht',
                    layoutJson: savedLayout,
                    setAsDefault: true
                })
            })
            .then(function(r) { return r.json(); })
            .then(function(view) {
                currentViewId = view.id;
                currentViewName = view.name;
                hideMigrationBanner();
                loadViewsList();
            })
            .catch(function(err) {
                console.error('Error migrating layout:', err);
            });
        }

        function toggleEditMode() {
            editMode = !editMode;
            var container = document.getElementById('dashboardGrid');
            var addBtn = document.getElementById('addWidgetBtn');
            var editBtn = document.getElementById('editModeBtn');
            var lockClosed = document.getElementById('lockIconClosed');
            var lockOpen = document.getElementById('lockIconOpen');

            if (editMode) {
                container.classList.add('edit-mode');
                editBtn.classList.remove('btn-outline');
                editBtn.classList.add('btn-primary');
                lockClosed.style.display = 'none';
                lockOpen.style.display = '';
                addBtn.style.display = 'inline-flex';
                grid.enableMove(true);
                grid.enableResize(true);
            } else {
                container.classList.remove('edit-mode');
                editBtn.classList.remove('btn-primary');
                editBtn.classList.add('btn-outline');
                lockClosed.style.display = '';
                lockOpen.style.display = 'none';
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
                'treemap': 'Treemap',
                'map': 'Standortkarte',
                'sankey': 'Sankey-Diagramm',
                'scada': 'SCADA-Ansicht'
            };
            // Type-specific default sizes [w, h]
            var sizes = { 'sankey': [10, 6], 'map': [6, 4], 'treemap': [6, 4], 'scada': [8, 6] };
            var s = sizes[type] || [4, 4];
            createWidget(type, 0, 0, s[0], s[1], titles[type] || 'Widget');
        }

        function createWidget(type, x, y, w, h, title, config) {
            widgetCounter++;
            var id = 'widget_' + widgetCounter;

            // Default config
            config = config || {};
            var sensorConfigs = config.sensorConfigs || [];
            var sensorIds = config.sensorIds || [];
            var scadaConfig = config.config || null;

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

            var addedEl = grid.addWidget({
                id: id,
                x: x,
                y: y,
                w: w,
                h: h,
                content: content.innerHTML
            });
            addedEl.id = id;

            widgets[id] = {
                type: type,
                title: title,
                sensorConfigs: sensorConfigs,
                sensorIds: sensorIds,
                scadaConfig: scadaConfig,
                scadaResizeObserver: null,
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
            } else if (type === 'scada') {
                initScadaWidget(id, chartDom);
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

        // ─── Time Range State ────────────────────────────────────────────────────────
        var timeState = {
            interval: localStorage.getItem('dashboardInterval') || 'day',
            offset: 0
        };

        function getTimeRange() {
            var now = new Date();
            var from, to;
            var interval = timeState.interval;
            var offset = timeState.offset;
            switch (interval) {
                case 'hour':
                    from = new Date(now); from.setMinutes(0, 0, 0);
                    from.setHours(from.getHours() + offset);
                    to = new Date(from); to.setHours(to.getHours() + 1);
                    break;
                case 'day':
                    from = new Date(now); from.setHours(0, 0, 0, 0);
                    from.setDate(from.getDate() + offset);
                    to = new Date(from); to.setDate(to.getDate() + 1);
                    break;
                case 'workweek':
                    var wd = now.getDay(); var dMon = wd === 0 ? -6 : 1 - wd;
                    from = new Date(now); from.setHours(0, 0, 0, 0);
                    from.setDate(from.getDate() + dMon + offset * 7);
                    to = new Date(from); to.setDate(to.getDate() + 5);
                    break;
                case 'week':
                    var wd2 = now.getDay(); var dMon2 = wd2 === 0 ? -6 : 1 - wd2;
                    from = new Date(now); from.setHours(0, 0, 0, 0);
                    from.setDate(from.getDate() + dMon2 + offset * 7);
                    to = new Date(from); to.setDate(to.getDate() + 7);
                    break;
                case 'month':
                    from = new Date(now.getFullYear(), now.getMonth() + offset, 1);
                    to = new Date(now.getFullYear(), now.getMonth() + offset + 1, 1);
                    break;
                case 'year':
                    from = new Date(now.getFullYear() + offset, 0, 1);
                    to = new Date(now.getFullYear() + offset + 1, 0, 1);
                    break;
                default:
                    from = new Date(now); from.setHours(0, 0, 0, 0);
                    to = new Date(from); to.setDate(to.getDate() + 1);
            }
            return { from: from.toISOString(), to: to.toISOString() };
        }

        function getTimeRangeLabel() {
            var tr = getTimeRange();
            var f = new Date(tr.from);
            var interval = timeState.interval;
            var de = 'de-DE';
            if (interval === 'hour') {
                return f.toLocaleDateString(de, {day:'numeric', month:'long'}) + ', ' +
                       f.toLocaleTimeString(de, {hour:'2-digit', minute:'2-digit'}) + ' – ' +
                       new Date(tr.to).toLocaleTimeString(de, {hour:'2-digit', minute:'2-digit'});
            } else if (interval === 'day') {
                return f.toLocaleDateString(de, {weekday:'long', day:'numeric', month:'long', year:'numeric'});
            } else if (interval === 'workweek' || interval === 'week') {
                var t = new Date(tr.to); t.setDate(t.getDate() - 1);
                return f.toLocaleDateString(de, {day:'numeric', month:'short'}) + ' – ' +
                       t.toLocaleDateString(de, {day:'numeric', month:'short', year:'numeric'});
            } else if (interval === 'month') {
                return f.toLocaleDateString(de, {month:'long', year:'numeric'});
            } else if (interval === 'year') {
                return String(f.getFullYear());
            }
            return '';
        }

        function updateTimeToolbar() {
            document.querySelectorAll('.interval-btn').forEach(function(btn) {
                btn.classList.toggle('active', btn.dataset.interval === timeState.interval);
            });
            document.getElementById('timeRangeLabel').textContent = getTimeRangeLabel();
        }

        function setInterval_(interval) {
            timeState.interval = interval;
            timeState.offset = 0;
            localStorage.setItem('dashboardInterval', interval);
            updateTimeToolbar();
            refreshAllWidgets();
        }

        function navigateTime(dir) {
            timeState.offset += dir;
            updateTimeToolbar();
            refreshAllWidgets();
        }

        function goToNow() {
            timeState.offset = 0;
            updateTimeToolbar();
            refreshAllWidgets();
        }

        function refreshAllWidgets() {
            Object.keys(widgets).forEach(function(id) {
                loadWidgetData(id, widgets[id].type);
            });
        }
        // ─────────────────────────────────────────────────────────────────────────────

        function loadWidgetData(id, type) {
            var w = widgets[id];

            if (type === 'scada') {
                loadScadaValues(id);
                return;
            }

            var chart = w.chart;
            if (!chart) return;

            chart.showLoading();

            var endpoint = '/dashboard/api/widget/' + (type === 'area' ? 'line' : type);

            var params = new URLSearchParams();

            // Add sensor IDs
            if (w.sensorIds && w.sensorIds.length > 0) {
                w.sensorIds.forEach(function(sensorId) {
                    params.append('sensorIds', sensorId);
                });
            }

            // Add time range for time-sensitive widgets
            var timeWidgets = ['line', 'area', 'bar', 'radial', 'treemap'];
            if (timeWidgets.indexOf(type) !== -1) {
                var tr = getTimeRange();
                params.set('from', tr.from);
                params.set('to', tr.to);
            }

            var qs = params.toString();
            if (qs) endpoint += '?' + qs;

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
                case 'treemap':
                    return getTreemapOption(data, colorMap);
                case 'sankey':
                    return getSankeyOption(data);
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

        function getTreemapOption(data, colorMap) {
            var palette = JEVisChartTheme.getPalette();
            var hasCustomColors = colorMap && Object.keys(colorMap).length > 0;

            // Get unit from first data item (if available)
            var unit = (data.data && data.data.length > 0 && data.data[0].unit) ? data.data[0].unit : 'kWh';

            // Calculate total for percentage display
            var total = data.data.reduce(function(sum, item) {
                return sum + (parseFloat(item.value) || 0);
            }, 0);

            // Format value with unit
            function formatValue(value) {
                if (value >= 1000000) {
                    return (value / 1000000).toFixed(2) + ' M' + unit;
                } else if (value >= 1000) {
                    return (value / 1000).toFixed(2) + ' k' + unit;
                } else {
                    return value.toFixed(1) + ' ' + unit;
                }
            }

            // Map sensor colors to data items if available
            var treemapData = data.data.map(function(item, index) {
                var itemData = {
                    name: item.name,
                    value: item.value,
                    unit: item.unit || unit
                };

                // Use custom color if available for this sensor
                if (hasCustomColors && item.sensorId && colorMap[item.sensorId]) {
                    itemData.itemStyle = { color: colorMap[item.sensorId] };
                } else if (hasCustomColors) {
                    var customColors = Object.values(colorMap);
                    if (index < customColors.length) {
                        itemData.itemStyle = { color: customColors[index] };
                    }
                }

                return itemData;
            });

            return {
                color: palette,
                tooltip: {
                    trigger: 'item',
                    backgroundColor: 'rgba(50, 50, 50, 0.9)',
                    borderColor: 'transparent',
                    textStyle: { color: '#fff' },
                    formatter: function(params) {
                        var value = params.value;
                        var percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0;
                        return '<div style="font-weight: 600; margin-bottom: 4px;">' + params.name + '</div>' +
                               '<div style="font-size: 16px; font-weight: bold;">' + formatValue(value) + '</div>' +
                               '<div style="color: #aaa; font-size: 12px;">' + percentage + '% des Gesamten</div>';
                    }
                },
                series: [{
                    type: 'treemap',
                    width: '100%',
                    height: '100%',
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    roam: false,
                    nodeClick: false,
                    breadcrumb: { show: false },
                    label: {
                        show: true,
                        formatter: function(params) {
                            var value = params.value;
                            var itemUnit = params.data.unit || unit;
                            var formattedValue;
                            if (value >= 1000000) {
                                formattedValue = (value / 1000000).toFixed(1) + ' M' + itemUnit;
                            } else if (value >= 1000) {
                                formattedValue = (value / 1000).toFixed(1) + ' k' + itemUnit;
                            } else {
                                formattedValue = value.toFixed(0) + ' ' + itemUnit;
                            }
                            return '{name|' + params.name + '}\n{value|' + formattedValue + '}';
                        },
                        rich: {
                            name: {
                                fontSize: 14,
                                fontWeight: 'bold',
                                color: '#fff',
                                textShadowColor: 'rgba(0,0,0,0.3)',
                                textShadowBlur: 3,
                                lineHeight: 22
                            },
                            value: {
                                fontSize: 12,
                                color: 'rgba(255,255,255,0.85)',
                                textShadowColor: 'rgba(0,0,0,0.3)',
                                textShadowBlur: 2
                            }
                        },
                        position: 'insideTopLeft',
                        padding: [8, 10]
                    },
                    upperLabel: {
                        show: false
                    },
                    itemStyle: {
                        borderColor: 'rgba(255,255,255,0.8)',
                        borderWidth: 2,
                        gapWidth: 2,
                        borderRadius: 4
                    },
                    levels: [
                        {
                            itemStyle: {
                                borderColor: 'rgba(255,255,255,0.9)',
                                borderWidth: 3,
                                gapWidth: 3
                            },
                            upperLabel: {
                                show: false
                            }
                        }
                    ],
                    data: treemapData
                }]
            };
        }

        function getSankeyOption(data) {
            if (!data.nodes || data.nodes.length === 0) {
                return {
                    title: {
                        text: 'Keine Daten',
                        subtext: 'Keine Hauptzähler mit Untermessungen gefunden.\nMesspunkte mit sensorTag "Hauptzähler" und Untermessungen anlegen.',
                        left: 'center', top: 'center',
                        textStyle: { fontSize: 14 },
                        subtextStyle: { fontSize: 12 }
                    }
                };
            }

            return {
                tooltip: {
                    trigger: 'item',
                    backgroundColor: 'rgba(30,30,30,0.92)',
                    borderColor: 'transparent',
                    textStyle: { color: '#fff', fontSize: 13 },
                    formatter: function(params) {
                        if (params.dataType === 'edge') {
                            var val = typeof params.data.value === 'number'
                                ? params.data.value.toLocaleString('de-DE', {maximumFractionDigits: 1})
                                : params.data.value;
                            return '<strong>' + params.data.source + '</strong>'
                                + ' &rarr; <strong>' + params.data.target + '</strong>'
                                + '<br/>'
                                + '<span style="font-size:16px;font-weight:700;">'
                                + val + ' ' + (params.data.unit || '') + '</span>';
                        }
                        // node
                        var d = params.data;
                        var name = d.displayName || params.name;
                        var html = '<strong>' + name + '</strong>';
                        if (d.medium) html += '<br/><span style="color:#aaa;">Medium: ' + d.medium + '</span>';
                        if (d.value != null) {
                            var nval = Number(d.value).toLocaleString('de-DE', {maximumFractionDigits: 1});
                            html += '<br/><span style="font-size:15px;font-weight:700;">'
                                + nval + ' ' + (d.unit || '') + '</span>';
                        }
                        return html;
                    }
                },
                series: [{
                    type: 'sankey',
                    layout: 'none',
                    orient: 'horizontal',
                    nodeWidth: 20,
                    nodeGap: 14,
                    top: '5%', bottom: '5%', left: '1%', right: '22%',
                    emphasis: { focus: 'adjacency' },
                    data: data.nodes,
                    links: data.links,
                    label: {
                        show: true,
                        position: 'right',
                        fontSize: 12,
                        color: JEVisChartTheme.getUIColors().axisLabel,
                        formatter: function(params) {
                            var d = params.data;
                            var name = d.displayName || params.name;
                            if (d.value != null) {
                                var val = Number(d.value).toLocaleString('de-DE', {maximumFractionDigits: 1});
                                return name + '\n' + val + ' ' + (d.unit || '');
                            }
                            return name;
                        }
                    },
                    lineStyle: {
                        color: 'source',
                        opacity: 0.4,
                        curveness: 0.5
                    },
                    itemStyle: {
                        borderRadius: 3
                    }
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
            } else if (w.type === 'scada') {
                loadScadaValues(id);
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
                'treemap': 'Treemap',
                'map': 'Karte',
                'scada': 'SCADA-Ansicht'
            };
            document.getElementById('settingsWidgetType').value = typeNames[w.type] || w.type;

            // Show/hide datasources tab based on widget type
            var supportsSensors = ['line', 'area', 'bar', 'radial', 'treemap'].indexOf(w.type) !== -1;
            document.getElementById('tabDatasources').style.display = supportsSensors ? 'flex' : 'none';

            var isSankey = w.type === 'sankey';
            document.getElementById('tabSankey').style.display = isSankey ? 'flex' : 'none';

            var isScada = w.type === 'scada';
            document.getElementById('tabScada').style.display = isScada ? 'flex' : 'none';
            if (isScada) {
                // Initialize working copy of scadaConfig
                scadaEditorWidgetId = id;
                scadaEditorConfig = JSON.parse(JSON.stringify(w.scadaConfig || {
                    backgroundImagePath: null,
                    designWidth: 800,
                    designHeight: 450,
                    fields: []
                }));
                // Load images for this tenant
                fetch('/scada/images')
                    .then(function(r) { return r.json(); })
                    .then(function(images) {
                        scadaEditorImages = images;
                        var sel = document.getElementById('scadaSettingsImage');
                        sel.innerHTML = '<option value="">-- Kein Bild --</option>';
                        images.forEach(function(img) {
                            var opt = document.createElement('option');
                            opt.value = img.filePath;
                            opt.textContent = img.originalName || img.filePath;
                            if (scadaEditorConfig.backgroundImagePath === img.filePath) opt.selected = true;
                            sel.appendChild(opt);
                        });
                    });
            }

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
            } else if (tabName === 'sankey') {
                document.getElementById('tabContentSankey').classList.add('active');
            } else if (tabName === 'scada') {
                document.getElementById('tabContentScada').classList.add('active');
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

            // Save scada config if scada widget
            if (w.type === 'scada' && scadaEditorWidgetId === id) {
                // Apply background image from settings select
                var sel = document.getElementById('scadaSettingsImage');
                if (sel) scadaEditorConfig.backgroundImagePath = sel.value || null;

                w.scadaConfig = JSON.parse(JSON.stringify(scadaEditorConfig));
                // Re-render the widget
                var chartDom = document.getElementById(id + '_chart');
                if (chartDom) {
                    chartDom.innerHTML = '';
                    initScadaWidget(id, chartDom);
                }
            }

            // Also keep sensorIds for backward compatibility
            w.sensorIds = selectedSensorsData.map(function(s) { return s.id; });

            // Reload chart with new settings
            if (w.chart && w.type !== 'map') {
                loadWidgetData(id, w.type);
            }

            saveLayout();
            closeWidgetSettingsModal();
        }

        // ─── SCADA Widget Rendering ───────────────────────────────────────────────

        function initScadaWidget(id, container) {
            var outer = document.createElement('div');
            outer.id = id + '_scada_outer';
            outer.className = 'scada-outer';
            container.style.padding = '0';
            container.appendChild(outer);

            var inner = document.createElement('div');
            inner.id = id + '_scada_inner';
            inner.style.position = 'relative';
            outer.appendChild(inner);

            renderScadaCanvas(id);

            var ro = new ResizeObserver(function() { scaleScadaCanvas(id); });
            ro.observe(container);
            widgets[id].scadaResizeObserver = ro;
        }

        function renderScadaCanvas(id) {
            var w = widgets[id];
            var inner = document.getElementById(id + '_scada_inner');
            if (!inner) return;

            var cfg = w.scadaConfig;
            if (!cfg) {
                inner.innerHTML = '<div class="scada-placeholder">' +
                    '<svg width="32" height="32" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="opacity:0.4;">' +
                    '<rect x="2" y="3" width="20" height="14" rx="1" stroke-width="1.5"/><circle cx="8" cy="10" r="2" stroke-width="1.5"/>' +
                    '</svg>' +
                    '<span>SCADA-Layout konfigurieren<br><small>(Bearbeiten → Einstellungen)</small></span></div>';
                return;
            }

            var dw = cfg.designWidth || 800;
            var dh = cfg.designHeight || 450;
            inner.style.width = dw + 'px';
            inner.style.height = dh + 'px';

            if (cfg.backgroundImagePath) {
                inner.style.backgroundImage = 'url(/uploads/' + cfg.backgroundImagePath + ')';
                inner.style.backgroundSize = 'cover';
                inner.style.backgroundPosition = 'center';
                inner.style.backgroundColor = '#1a1a2e';
            } else {
                inner.style.backgroundImage = 'none';
                inner.style.backgroundColor = '#1a1a2e';
            }

            inner.innerHTML = '';
            (cfg.fields || []).forEach(function(f) {
                var el = document.createElement('div');
                el.style.cssText = 'position:absolute;left:' + (f.x || 0) + 'px;top:' + (f.y || 0) + 'px;' +
                    'font-size:' + (f.fontSize || 16) + 'px;color:' + (f.color || '#ffffff') + ';' +
                    'font-weight:' + (f.fontWeight || 'normal') + ';' +
                    'background:' + (f.bgColor || 'transparent') + ';' +
                    'border:1px solid ' + (f.borderColor || 'transparent') + ';' +
                    'padding:2px 6px;white-space:nowrap;' +
                    (f.width ? 'width:' + f.width + 'px;overflow:hidden;' : '');

                if (f.type === 'TEXT') {
                    el.textContent = f.text || '';
                } else {
                    el.innerHTML = '<span id="scada_val_' + id + '_' + f.id + '">—</span>' +
                        (f.unit ? ' ' + escapeHtml(f.unit) : '');
                }
                inner.appendChild(el);
            });

            scaleScadaCanvas(id);
        }

        function scaleScadaCanvas(id) {
            var w = widgets[id];
            if (!w || !w.scadaConfig) return;
            var outer = document.getElementById(id + '_scada_outer');
            var inner = document.getElementById(id + '_scada_inner');
            if (!outer || !inner) return;
            var dw = w.scadaConfig.designWidth || 800;
            var dh = w.scadaConfig.designHeight || 450;
            var containerW = outer.clientWidth || dw;
            var scale = containerW / dw;
            inner.style.transform = 'scale(' + scale + ')';
            inner.style.transformOrigin = 'top left';
            outer.style.height = (dh * scale) + 'px';
        }

        function loadScadaValues(id) {
            var w = widgets[id];
            if (!w || !w.scadaConfig || !w.scadaConfig.fields) return;
            var valueSensorIds = w.scadaConfig.fields
                .filter(function(f) { return f.type === 'VALUE' && f.sensorId; })
                .map(function(f) { return f.sensorId; });
            if (valueSensorIds.length === 0) return;
            var params = new URLSearchParams();
            valueSensorIds.forEach(function(sid) { params.append('sensorIds', sid); });
            fetch('/scada/values?' + params.toString())
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    w.scadaConfig.fields.forEach(function(f) {
                        if (f.type !== 'VALUE' || !f.sensorId) return;
                        var span = document.getElementById('scada_val_' + id + '_' + f.id);
                        if (!span) return;
                        var val = data[String(f.sensorId)];
                        if (val !== undefined && val !== null) {
                            var dp = (f.decimalPlaces !== undefined) ? f.decimalPlaces : 1;
                            var num = parseFloat(val);
                            span.textContent = isNaN(num) ? String(val) : num.toFixed(dp);
                        }
                    });
                })
                .catch(function(err) { console.error('SCADA values error:', err); });
        }

        // ─── SCADA Settings Tab helpers ───────────────────────────────────────────

        function scadaSettingsImageChanged(value) {
            if (scadaEditorConfig) scadaEditorConfig.backgroundImagePath = value || null;
        }

        function scadaSettingsUploadImage(input) {
            if (!input.files || !input.files[0]) return;
            var statusEl = document.getElementById('scadaUploadStatus');
            statusEl.textContent = 'Hochladen...';

            var formData = new FormData();
            formData.append('file', input.files[0]);
            var csrfToken = document.querySelector('meta[name="csrf-token"]');
            var csrfHeader = document.querySelector('meta[name="csrf-header"]');
            var headers = {};
            if (csrfToken && csrfHeader) headers[csrfHeader.content] = csrfToken.content;

            fetch('/scada/images/upload', { method: 'POST', headers: headers, body: formData })
                .then(function(r) { return r.json(); })
                .then(function(img) {
                    scadaEditorImages.push(img);
                    var sel = document.getElementById('scadaSettingsImage');
                    var opt = document.createElement('option');
                    opt.value = img.filePath;
                    opt.textContent = img.originalName || img.filePath;
                    opt.selected = true;
                    sel.appendChild(opt);
                    scadaEditorConfig.backgroundImagePath = img.filePath;
                    statusEl.textContent = 'Hochgeladen!';
                    setTimeout(function() { statusEl.textContent = ''; }, 2000);
                    input.value = '';
                })
                .catch(function() { statusEl.textContent = 'Fehler beim Hochladen'; });
        }

        function openScadaEditorFromSettings() {
            // Sync background image from settings select before opening
            var sel = document.getElementById('scadaSettingsImage');
            if (sel && scadaEditorConfig) scadaEditorConfig.backgroundImagePath = sel.value || null;
            openScadaEditor(scadaEditorWidgetId);
        }

        // ─── SCADA Editor ─────────────────────────────────────────────────────────

        var scadaEditorWidgetId = null;
        var scadaEditorConfig = null;
        var scadaEditorSelectedFieldId = null;
        var scadaEditorImages = [];
        var scadaSnapEnabled = true;

        function snapCoord(v) {
            if (!scadaSnapEnabled) return Math.round(v);
            var size = parseInt(document.getElementById('scadaSnapSize').value) || 10;
            return Math.round(v / size) * size;
        }

        function scadaSnapToggle() {
            scadaSnapEnabled = document.getElementById('scadaSnapEnabled').checked;
            var hint = document.getElementById('scadaSnapHint');
            hint.textContent = scadaSnapEnabled ? 'Felder rasten beim Ablegen ein' : 'Freie Positionierung aktiv';
        }

        function openScadaEditor(widgetId) {
            scadaEditorWidgetId = widgetId;
            var w = widgets[widgetId];
            if (!scadaEditorConfig) {
                scadaEditorConfig = JSON.parse(JSON.stringify(w.scadaConfig || {
                    backgroundImagePath: null, designWidth: 800, designHeight: 450, fields: []
                }));
            }
            scadaEditorSelectedFieldId = null;

            document.getElementById('scadaEditorTitle').textContent =
                'SCADA Layout Editor: ' + (w.title || 'Widget');
            document.getElementById('scadaDesignWidth').value = scadaEditorConfig.designWidth || 800;
            document.getElementById('scadaDesignHeight').value = scadaEditorConfig.designHeight || 450;

            renderScadaEditorImageSelect();
            renderScadaEditorCanvas();
            renderScadaEditorFieldList();
            renderScadaEditorProperties();

            document.getElementById('scadaEditorOverlay').style.display = 'flex';
        }

        function closeScadaEditor() {
            document.getElementById('scadaEditorOverlay').style.display = 'none';
        }

        function saveScadaEditor() {
            if (!scadaEditorWidgetId) return;
            var w = widgets[scadaEditorWidgetId];
            w.scadaConfig = JSON.parse(JSON.stringify(scadaEditorConfig));
            // Update sensorIds list from scada fields
            w.sensorIds = (scadaEditorConfig.fields || [])
                .filter(function(f) { return f.type === 'VALUE' && f.sensorId; })
                .map(function(f) { return f.sensorId; });

            var chartDom = document.getElementById(scadaEditorWidgetId + '_chart');
            if (chartDom) {
                chartDom.innerHTML = '';
                initScadaWidget(scadaEditorWidgetId, chartDom);
            }
            saveLayout();
            closeScadaEditor();
        }

        function renderScadaEditorImageSelect() {
            var sel = document.getElementById('scadaImageSelect');
            if (!sel) return;
            sel.innerHTML = '<option value="">-- Kein Bild --</option>';
            scadaEditorImages.forEach(function(img) {
                var opt = document.createElement('option');
                opt.value = img.filePath;
                opt.textContent = img.originalName || img.filePath;
                if (scadaEditorConfig.backgroundImagePath === img.filePath) opt.selected = true;
                sel.appendChild(opt);
            });
        }

        function scadaImageChanged(value) {
            scadaEditorConfig.backgroundImagePath = value || null;
            renderScadaEditorCanvas();
        }

        function scadaDesignSizeChanged() {
            scadaEditorConfig.designWidth = parseInt(document.getElementById('scadaDesignWidth').value) || 800;
            scadaEditorConfig.designHeight = parseInt(document.getElementById('scadaDesignHeight').value) || 450;
            renderScadaEditorCanvas();
        }

        function addScadaTextField() {
            var f = {
                id: 'f' + Date.now(), type: 'TEXT',
                x: 50, y: 50, width: null, text: 'Label', fontSize: 18,
                color: '#ffffff', fontWeight: 'normal',
                bgColor: 'rgba(0,0,0,0)', borderColor: 'transparent'
            };
            scadaEditorConfig.fields.push(f);
            renderScadaEditorCanvas();
            renderScadaEditorFieldList();
            selectScadaField(f.id);
        }

        function addScadaValueField() {
            var f = {
                id: 'f' + Date.now(), type: 'VALUE',
                x: 100, y: 100, width: null, sensorId: null, unit: '', decimalPlaces: 1,
                fontSize: 18, color: '#ffffff', fontWeight: 'bold',
                bgColor: 'rgba(0,0,0,0.4)', borderColor: 'transparent'
            };
            scadaEditorConfig.fields.push(f);
            renderScadaEditorCanvas();
            renderScadaEditorFieldList();
            selectScadaField(f.id);
        }

        function removeScadaField(fieldId) {
            scadaEditorConfig.fields = scadaEditorConfig.fields.filter(function(f) { return f.id !== fieldId; });
            if (scadaEditorSelectedFieldId === fieldId) scadaEditorSelectedFieldId = null;
            renderScadaEditorCanvas();
            renderScadaEditorFieldList();
            renderScadaEditorProperties();
        }

        function selectScadaField(fieldId) {
            scadaEditorSelectedFieldId = fieldId;
            renderScadaEditorFieldList();
            renderScadaEditorProperties();
            document.querySelectorAll('.scada-editor-field').forEach(function(el) {
                el.classList.toggle('selected', el.dataset.fieldId === fieldId);
            });
        }

        function renderScadaEditorFieldList() {
            var ul = document.getElementById('scadaEditorFieldList');
            if (!ul) return;
            ul.innerHTML = '';
            (scadaEditorConfig.fields || []).forEach(function(f) {
                var li = document.createElement('div');
                li.className = 'scada-field-list-item' + (f.id === scadaEditorSelectedFieldId ? ' active' : '');
                var label = f.type === 'TEXT' ? 'T: ' + (f.text || '—') : 'V: sensor ' + (f.sensorId || '—');
                li.textContent = label;
                li.onclick = function() { selectScadaField(f.id); };
                var del = document.createElement('button');
                del.className = 'scada-field-del-btn';
                del.innerHTML = '&times;';
                del.onclick = function(e) { e.stopPropagation(); removeScadaField(f.id); };
                li.appendChild(del);
                ul.appendChild(li);
            });
        }

        function renderScadaEditorCanvas() {
            var canvas = document.getElementById('scadaEditorCanvas');
            if (!canvas) return;
            var dw = scadaEditorConfig.designWidth || 800;
            var dh = scadaEditorConfig.designHeight || 450;
            canvas.style.width = dw + 'px';
            canvas.style.height = dh + 'px';

            if (scadaEditorConfig.backgroundImagePath) {
                canvas.style.backgroundImage = 'url(/uploads/' + scadaEditorConfig.backgroundImagePath + ')';
                canvas.style.backgroundSize = 'cover';
                canvas.style.backgroundPosition = 'center';
            } else {
                canvas.style.backgroundImage = 'none';
                canvas.style.backgroundColor = '#1a1a2e';
            }

            canvas.querySelectorAll('.scada-editor-field').forEach(function(el) { el.remove(); });

            (scadaEditorConfig.fields || []).forEach(function(f) {
                var el = document.createElement('div');
                el.className = 'scada-editor-field' + (f.id === scadaEditorSelectedFieldId ? ' selected' : '');
                el.dataset.fieldId = f.id;
                el.style.left = (f.x || 0) + 'px';
                el.style.top = (f.y || 0) + 'px';
                el.style.fontSize = (f.fontSize || 16) + 'px';
                el.style.color = f.color || '#ffffff';
                el.style.fontWeight = f.fontWeight || 'normal';
                el.style.background = f.bgColor || 'transparent';
                el.style.border = '1px dashed ' + (f.id === scadaEditorSelectedFieldId ? 'var(--primary-color)' : 'transparent');
                el.style.padding = '2px 6px';
                if (f.width) { el.style.width = f.width + 'px'; el.style.overflow = 'hidden'; el.style.whiteSpace = 'nowrap'; }
                el.textContent = f.type === 'TEXT' ? (f.text || 'Label') : ('42.3 ' + (f.unit || ''));
                el.draggable = true;
                el.onclick = function(e) { e.stopPropagation(); selectScadaField(f.id); };
                el.ondragstart = function(e) {
                    e.dataTransfer.setData('fieldId', f.id);
                    e.dataTransfer.setData('offsetX', String(e.offsetX));
                    e.dataTransfer.setData('offsetY', String(e.offsetY));
                };
                canvas.appendChild(el);
            });

            // Scale canvas to fit wrapper
            var wrapper = document.getElementById('scadaEditorCanvasWrapper');
            if (wrapper && wrapper.clientWidth > 0) {
                var scale = Math.min(1, (wrapper.clientWidth - 32) / dw);
                canvas.style.transform = 'scale(' + scale + ')';
                canvas.style.transformOrigin = 'top left';
                wrapper.style.minHeight = (dh * scale + 32) + 'px';
            }
        }

        function renderScadaEditorProperties() {
            var panel = document.getElementById('scadaEditorProperties');
            if (!panel) return;
            if (!scadaEditorSelectedFieldId) {
                panel.innerHTML = '<p style="color:var(--text-muted);padding:1rem;font-size:0.85rem;">Feld auswählen oder hinzufügen</p>';
                return;
            }
            var f = (scadaEditorConfig.fields || []).find(function(x) { return x.id === scadaEditorSelectedFieldId; });
            if (!f) { panel.innerHTML = ''; return; }

            var sensorOptions = '<option value="">-- Kein Sensor --</option>';
            document.querySelectorAll('#availableSensorList .sensor-item').forEach(function(sEl) {
                var sid = sEl.dataset.sensorId;
                var sname = escapeHtml(sEl.dataset.name || sid);
                sensorOptions += '<option value="' + sid + '"' + (String(f.sensorId) === sid ? ' selected' : '') + '>' + sname + '</option>';
            });

            var html = '<div style="padding:0.75rem;display:flex;flex-direction:column;gap:0.6rem;">';
            html += prop('X-Position', 'number', f.x || 0, 'updateScadaField(\'' + f.id + '\',\'x\',snapCoord(parseInt(this.value)||0))');
            html += prop('Y-Position', 'number', f.y || 0, 'updateScadaField(\'' + f.id + '\',\'y\',snapCoord(parseInt(this.value)||0))');
            html += '<div class="form-group" style="margin:0;">' +
                '<label class="filter-label">Breite (px)</label>' +
                '<input type="number" class="form-control form-control-sm" value="' + (f.width || '') + '" min="20" placeholder="auto"' +
                ' onchange="updateScadaField(\'' + f.id + '\',\'width\',this.value?parseInt(this.value):null)"></div>';
            if (f.type === 'TEXT') {
                html += prop('Text', 'text', escapeHtml(f.text || ''), 'updateScadaField(\'' + f.id + '\',\'text\',this.value)');
            } else {
                html += '<div class="form-group" style="margin:0;"><label class="filter-label">Sensor</label>' +
                    '<select class="form-control form-control-sm" onchange="updateScadaField(\'' + f.id + '\',\'sensorId\',this.value?parseInt(this.value):null)">' +
                    sensorOptions + '</select></div>';
                html += prop('Einheit', 'text', escapeHtml(f.unit || ''), 'updateScadaField(\'' + f.id + '\',\'unit\',this.value)', 'z.B. kW');
                html += prop('Dezimalstellen', 'number', f.decimalPlaces !== undefined ? f.decimalPlaces : 1, 'updateScadaField(\'' + f.id + '\',\'decimalPlaces\',parseInt(this.value)||0)');
            }
            html += prop('Schriftgröße', 'number', f.fontSize || 16, 'updateScadaField(\'' + f.id + '\',\'fontSize\',parseInt(this.value)||16)');
            html += '<div class="form-group" style="margin:0;"><label class="filter-label">Textfarbe</label>' +
                '<input type="color" class="selected-sensor-color" style="width:100%;height:32px;" value="' + (f.color || '#ffffff') + '" onchange="updateScadaField(\'' + f.id + '\',\'color\',this.value)"></div>';
            html += '<div class="form-group" style="margin:0;"><label class="filter-label">Schriftgewicht</label>' +
                '<select class="form-control form-control-sm" onchange="updateScadaField(\'' + f.id + '\',\'fontWeight\',this.value)">' +
                '<option value="normal"' + (f.fontWeight === 'normal' ? ' selected' : '') + '>Normal</option>' +
                '<option value="bold"' + (f.fontWeight === 'bold' ? ' selected' : '') + '>Fett</option>' +
                '</select></div>';
            var bgParsed = parseBgColor(f.bgColor || 'rgba(0,0,0,0)');
            var bgHexId   = 'bg_hex_'   + f.id;
            var bgAlphaId = 'bg_alpha_' + f.id;
            html += '<div class="form-group" style="margin:0;">' +
                '<label class="filter-label">Hintergrundfarbe</label>' +
                '<div style="display:flex;gap:0.5rem;align-items:center;">' +
                    '<input type="color" class="selected-sensor-color" style="width:36px;height:32px;flex-shrink:0;" id="' + bgHexId + '" value="' + bgParsed.hex + '"' +
                        ' onchange="updateScadaBgColor(\'' + f.id + '\',\'' + bgHexId + '\',\'' + bgAlphaId + '\')">' +
                    '<div style="flex:1;display:flex;flex-direction:column;gap:2px;">' +
                        '<input type="range" id="' + bgAlphaId + '" min="0" max="100" value="' + Math.round(bgParsed.alpha * 100) + '"' +
                            ' style="width:100%;cursor:pointer;"' +
                            ' oninput="updateScadaBgColor(\'' + f.id + '\',\'' + bgHexId + '\',\'' + bgAlphaId + '\');document.getElementById(\'bg_pct_' + f.id + '\').textContent=this.value+\'%\'">' +
                        '<span id="bg_pct_' + f.id + '" style="font-size:0.75rem;color:var(--text-muted);">' + Math.round(bgParsed.alpha * 100) + '% Deckkraft</span>' +
                    '</div>' +
                '</div>' +
                '</div>';
            html += '<button class="btn btn-sm" style="background:var(--danger-color);color:white;border:none;margin-top:0.25rem;" onclick="removeScadaField(\'' + f.id + '\')">Feld entfernen</button>';
            html += '</div>';
            panel.innerHTML = html;
        }

        function prop(label, type, value, onchange, placeholder) {
            return '<div class="form-group" style="margin:0;">' +
                '<label class="filter-label">' + label + '</label>' +
                '<input type="' + type + '" class="form-control form-control-sm" value="' + value + '"' +
                (placeholder ? ' placeholder="' + placeholder + '"' : '') +
                ' onchange="' + onchange + '"></div>';
        }

        function parseBgColor(colorStr) {
            if (!colorStr || colorStr === 'transparent') return { hex: '#000000', alpha: 0 };
            var m = colorStr.match(/rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+))?\s*\)/);
            if (m) {
                var r = parseInt(m[1]), g = parseInt(m[2]), b = parseInt(m[3]);
                var a = m[4] !== undefined ? parseFloat(m[4]) : 1;
                return {
                    hex: '#' + r.toString(16).padStart(2,'0') + g.toString(16).padStart(2,'0') + b.toString(16).padStart(2,'0'),
                    alpha: a
                };
            }
            if (colorStr.startsWith('#')) return { hex: colorStr, alpha: 1 };
            return { hex: '#000000', alpha: 0 };
        }

        function updateScadaBgColor(fieldId, hexInputId, alphaInputId) {
            var hex   = document.getElementById(hexInputId).value;
            var alpha = parseInt(document.getElementById(alphaInputId).value) / 100;
            var r = parseInt(hex.slice(1,3),16), g = parseInt(hex.slice(3,5),16), b = parseInt(hex.slice(5,7),16);
            var bgColor = alpha <= 0 ? 'rgba(0,0,0,0)'
                        : alpha >= 1 ? hex
                        : 'rgba(' + r + ',' + g + ',' + b + ',' + alpha.toFixed(2) + ')';
            updateScadaField(fieldId, 'bgColor', bgColor);
        }

        function updateScadaField(fieldId, prop, value) {
            var f = (scadaEditorConfig.fields || []).find(function(x) { return x.id === fieldId; });
            if (!f) return;
            f[prop] = value;
            renderScadaEditorCanvas();
            renderScadaEditorFieldList();
        }

        function scadaEditorCanvasDragOver(e) { e.preventDefault(); }

        function scadaEditorCanvasDrop(e) {
            e.preventDefault();
            var fieldId = e.dataTransfer.getData('fieldId');
            var offX = parseInt(e.dataTransfer.getData('offsetX')) || 0;
            var offY = parseInt(e.dataTransfer.getData('offsetY')) || 0;
            var canvas = document.getElementById('scadaEditorCanvas');
            if (!canvas) return;
            var rect = canvas.getBoundingClientRect();
            var scaleStr = canvas.style.transform.replace('scale(', '').replace(')', '');
            var scale = parseFloat(scaleStr) || 1;
            var x = Math.max(0, snapCoord((e.clientX - rect.left) / scale - offX));
            var y = Math.max(0, snapCoord((e.clientY - rect.top) / scale - offY));
            updateScadaField(fieldId, 'x', x);
            updateScadaField(fieldId, 'y', y);
            selectScadaField(fieldId);
            renderScadaEditorProperties();
        }

        function scadaEditorUploadImage(input) {
            if (!input.files || !input.files[0]) return;
            var formData = new FormData();
            formData.append('file', input.files[0]);
            var csrfToken = document.querySelector('meta[name="csrf-token"]');
            var csrfHeader = document.querySelector('meta[name="csrf-header"]');
            var headers = {};
            if (csrfToken && csrfHeader) headers[csrfHeader.content] = csrfToken.content;
            fetch('/scada/images/upload', { method: 'POST', headers: headers, body: formData })
                .then(function(r) { return r.json(); })
                .then(function(img) {
                    scadaEditorImages.push(img);
                    scadaEditorConfig.backgroundImagePath = img.filePath;
                    renderScadaEditorImageSelect();
                    renderScadaEditorCanvas();
                    input.value = '';
                })
                .catch(function(err) { console.error('Upload failed:', err); });
        }
    </script>
    `
)
