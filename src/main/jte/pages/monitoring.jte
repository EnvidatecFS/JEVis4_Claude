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
        <div class="modal-content">
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
                    <label class="form-label">Sensoren auswaehlen</label>
                    <div class="sensor-selection">
                        @for(var entry : sensorsByType.entrySet())
                            <div class="sensor-group">
                                <div class="sensor-group-header">
                                    <span class="sensor-type-badge">${entry.getKey()}</span>
                                </div>
                                <div class="sensor-group-items">
                                    @for(Sensor sensor : entry.getValue())
                                        <label class="sensor-checkbox">
                                            <input type="checkbox" name="selectedSensors" value="${sensor.getId()}"
                                                   data-name="${sensor.getSensorName()}"
                                                   data-unit="${sensor.getUnit()}"
                                                   data-type="${sensor.getMeasurementType()}">
                                            <span class="sensor-info">
                                                <span class="sensor-name">${sensor.getSensorName()}</span>
                                                <span class="sensor-code">${sensor.getSensorCode()} - ${sensor.getUnit()}</span>
                                            </span>
                                        </label>
                                    @endfor
                                </div>
                            </div>
                        @endfor
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-outline" onclick="closeModal()">Abbrechen</button>
                <button class="btn btn-primary" onclick="createChart()">Chart erstellen</button>
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

        /* Sensor Selection */
        .sensor-selection {
            max-height: 300px;
            overflow-y: auto;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
        }

        .sensor-group {
            border-bottom: 1px solid var(--border-color);
        }

        .sensor-group:last-child {
            border-bottom: none;
        }

        .sensor-group-header {
            padding: 0.75rem 1rem;
            background: var(--hover-color);
            font-weight: 600;
        }

        .sensor-type-badge {
            display: inline-block;
            padding: 0.25rem 0.5rem;
            background: var(--primary-color);
            color: white;
            border-radius: var(--border-radius);
            font-size: 0.75rem;
            text-transform: uppercase;
        }

        .sensor-group-items {
            padding: 0.5rem;
        }

        .sensor-checkbox {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.5rem;
            border-radius: var(--border-radius);
            cursor: pointer;
        }

        .sensor-checkbox:hover {
            background: var(--hover-color);
        }

        .sensor-checkbox input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
        }

        .sensor-info {
            display: flex;
            flex-direction: column;
        }

        .sensor-name {
            font-weight: 500;
            color: var(--text-color);
        }

        .sensor-code {
            font-size: 0.8rem;
            color: var(--text-muted);
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
    </style>

    <script>
        // State management
        var charts = [];
        var chartCounter = 0;
        var currentTimeRange = {
            start: new Date(Date.now() - 24 * 60 * 60 * 1000),
            end: new Date()
        };

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            initTimeRangeButtons();
            setDefaultDateInputs();
            showEmptyState();
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
            document.querySelectorAll('input[name="selectedSensors"]').forEach(function(cb) {
                cb.checked = false;
            });
        }

        function closeModal() {
            document.getElementById('addChartModal').style.display = 'none';
        }

        function createChart() {
            var title = document.getElementById('chartTitle').value || 'Neuer Chart';
            var selectedCheckboxes = document.querySelectorAll('input[name="selectedSensors"]:checked');

            if (selectedCheckboxes.length === 0) {
                alert('Bitte waehlen Sie mindestens einen Sensor aus.');
                return;
            }

            var sensorIds = [];
            var sensorNames = [];
            var sensorUnits = [];

            selectedCheckboxes.forEach(function(cb) {
                sensorIds.push(cb.value);
                sensorNames.push(cb.dataset.name);
                if (sensorUnits.indexOf(cb.dataset.unit) === -1) {
                    sensorUnits.push(cb.dataset.unit);
                }
            });

            var chartId = 'chart_' + (++chartCounter);
            var chartConfig = {
                id: chartId,
                title: title,
                sensorIds: sensorIds,
                sensorNames: sensorNames,
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
            var refreshBtn = clone.querySelector('[data-action="refresh"]');
            refreshBtn.onclick = function() { refreshChart(chartConfig.id); };

            var downloadBtn = clone.querySelector('[data-action="download"]');
            downloadBtn.onclick = function() { downloadChart(chartConfig.id); };

            var removeBtn = clone.querySelector('[data-action="remove"]');
            removeBtn.onclick = function() { removeChart(chartConfig.id); };

            container.appendChild(clone);

            // Initialize ECharts instance
            var chartDom = document.getElementById(chartConfig.id);
            chartConfig.instance = echarts.init(chartDom);

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

            fetch('/monitoring/api/measurements?' + params.toString())
                .then(function(response) { return response.json(); })
                .then(function(data) {
                    var series = data.series.map(function(s) {
                        return {
                            name: s.sensorName,
                            type: 'line',
                            smooth: true,
                            symbol: 'none',
                            data: s.data,
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
                                backgroundColor: '#e9ecef',
                                fillerColor: 'rgba(47, 69, 84, 0.15)',
                                handleStyle: {
                                    color: '#3b82f6'
                                },
                                textStyle: {
                                    color: '#666'
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
                    chartConfig.instance.setOption(option);
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
    </script>
    `
)
