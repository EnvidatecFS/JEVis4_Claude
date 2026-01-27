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
            <button class="btn btn-outline" onclick="toggleEditMode()">
                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                </svg>
                <span id="editModeText">Bearbeiten</span>
            </button>
            <button class="btn btn-primary" onclick="openAddWidgetModal()">
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
                disableResize: false,
                disableDrag: false,
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
                        createWidget(item.type, item.x, item.y, item.w, item.h, item.title);
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

            if (editMode) {
                container.classList.add('edit-mode');
                text.textContent = 'Fertig';
                grid.enable();
            } else {
                container.classList.remove('edit-mode');
                text.textContent = 'Bearbeiten';
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

        function createWidget(type, x, y, w, h, title) {
            widgetCounter++;
            var id = 'widget_' + widgetCounter;

            var content = document.createElement('div');
            content.innerHTML =
                '<div class="widget-header">' +
                    '<h4 class="widget-title">' + title + '</h4>' +
                    '<div class="widget-actions">' +
                        '<button onclick="refreshWidget(\'' + id + '\')" title="Aktualisieren">' +
                            '<svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>' +
                            '</svg>' +
                        '</button>' +
                        '<button onclick="removeWidget(\'' + id + '\')" title="Entfernen">' +
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
                var chart = echarts.init(chartDom);
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
            var chart = widgets[id].chart;
            if (!chart) return;

            chart.showLoading();

            var endpoint = '/dashboard/api/widget/' + (type === 'area' ? 'line' : type);

            fetch(endpoint)
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    chart.hideLoading();
                    var option = getChartOption(type, data);
                    chart.setOption(option);
                })
                .catch(function(err) {
                    chart.hideLoading();
                    console.error('Error loading widget data:', err);
                });
        }

        function getChartOption(type, data) {
            switch(type) {
                case 'line':
                    return getLineOption(data, false);
                case 'area':
                    return getLineOption(data, true);
                case 'bar':
                    return getBarOption(data);
                case 'radial':
                    return getRadialOption(data);
                case 'pie':
                    return getPieOption(data);
                case 'gauge':
                    return getGaugeOption(data);
                default:
                    return {};
            }
        }

        function getLineOption(data, isArea) {
            var series = data.series.map(function(s) {
                return {
                    name: s.name,
                    type: 'line',
                    smooth: true,
                    symbol: 'none',
                    data: s.data,
                    areaStyle: isArea ? { opacity: 0.3 } : null
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

        function getBarOption(data) {
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
                        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                            { offset: 0, color: '#3b82f6' },
                            { offset: 1, color: '#1d4ed8' }
                        ])
                    }
                }]
            };
        }

        function getRadialOption(data) {
            var angleData = data.data.map(function(d) { return d.name; });
            var radiusData = data.data.map(function(d) { return d.value; });

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
                            var colors = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];
                            return colors[params.dataIndex % colors.length];
                        }
                    }
                }]
            };
        }

        function getPieOption(data) {
            return {
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

        function getGaugeOption(data) {
            return {
                series: [{
                    type: 'gauge',
                    startAngle: 200,
                    endAngle: -20,
                    min: data.min || 0,
                    max: data.max || 100,
                    splitNumber: 5,
                    itemStyle: {
                        color: '#3b82f6'
                    },
                    progress: {
                        show: true,
                        width: 20
                    },
                    pointer: { show: false },
                    axisLine: {
                        lineStyle: { width: 20 }
                    },
                    axisTick: { show: false },
                    splitLine: { show: false },
                    axisLabel: { show: false },
                    title: {
                        offsetCenter: [0, '30%'],
                        fontSize: 14,
                        color: '#666'
                    },
                    detail: {
                        valueAnimation: true,
                        fontSize: 28,
                        fontWeight: 'bold',
                        offsetCenter: [0, '-10%'],
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
                        var color = loc.status === 'online' ? '#10b981' : '#f59e0b';
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
    </script>
    `
)
