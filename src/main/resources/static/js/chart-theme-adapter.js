/**
 * JEVis Chart Theme Adapter
 *
 * Bridges CSS variables to ECharts themes.
 * Charts should use this adapter instead of hardcoding colors.
 */
var JEVisChartTheme = (function() {
    'use strict';

    // Cache for computed styles
    var styleCache = {};
    var registeredCharts = [];

    /**
     * Read a CSS variable value from :root
     * @param {string} name - Variable name without '--' prefix
     * @returns {string} The computed value
     */
    function getCSSVar(name) {
        var fullName = '--' + name;
        if (styleCache[fullName]) {
            return styleCache[fullName];
        }
        var value = getComputedStyle(document.documentElement).getPropertyValue(fullName).trim();
        styleCache[fullName] = value;
        return value;
    }

    /**
     * Clear the style cache (called on theme change)
     */
    function clearCache() {
        styleCache = {};
    }

    /**
     * Get the 10 base chart colors as an array
     * @returns {string[]} Array of 10 colors
     */
    function getPalette() {
        return [
            getCSSVar('chart-color-1'),
            getCSSVar('chart-color-2'),
            getCSSVar('chart-color-3'),
            getCSSVar('chart-color-4'),
            getCSSVar('chart-color-5'),
            getCSSVar('chart-color-6'),
            getCSSVar('chart-color-7'),
            getCSSVar('chart-color-8'),
            getCSSVar('chart-color-9'),
            getCSSVar('chart-color-10')
        ];
    }

    /**
     * Get semantic colors for specific meanings
     * @returns {Object} Semantic color map
     */
    function getSemanticColors() {
        return {
            success: getCSSVar('chart-success'),
            warning: getCSSVar('chart-warning'),
            danger: getCSSVar('chart-danger'),
            info: getCSSVar('chart-info'),
            neutral: getCSSVar('chart-neutral'),
            statusOnline: getCSSVar('chart-status-online'),
            statusOffline: getCSSVar('chart-status-offline'),
            statusWarning: getCSSVar('chart-status-warning')
        };
    }

    /**
     * Get UI colors for chart elements
     * @returns {Object} UI color map
     */
    function getUIColors() {
        return {
            background: getCSSVar('chart-background'),
            gridLine: getCSSVar('chart-grid-line'),
            axisLine: getCSSVar('chart-axis-line'),
            axisLabel: getCSSVar('chart-axis-label'),
            tooltipBg: getCSSVar('chart-tooltip-bg'),
            tooltipBorder: getCSSVar('chart-tooltip-border'),
            tooltipText: getCSSVar('chart-tooltip-text'),
            legendText: getCSSVar('chart-legend-text'),
            gaugeProgress: getCSSVar('chart-gauge-progress'),
            gaugeTrack: getCSSVar('chart-gauge-track')
        };
    }

    /**
     * Get a specific series color by index
     * @param {number} index - Series index (wraps around)
     * @returns {string} Color value
     */
    function getSeriesColor(index) {
        var palette = getPalette();
        return palette[index % palette.length];
    }

    /**
     * Create a linear gradient for bar charts
     * @param {echarts} echartsInstance - ECharts graphic module (optional)
     * @returns {Object} ECharts LinearGradient or color object
     */
    function createBarGradient(echartsInstance) {
        var startColor = getCSSVar('chart-bar-gradient-start');
        var endColor = getCSSVar('chart-bar-gradient-end');

        // If echarts is available, create proper gradient
        if (typeof echarts !== 'undefined' && echarts.graphic) {
            return new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                { offset: 0, color: startColor },
                { offset: 1, color: endColor }
            ]);
        }

        // Fallback to start color
        return startColor;
    }

    /**
     * Build a complete ECharts theme object
     * @returns {Object} ECharts theme configuration
     */
    function buildEChartsTheme() {
        var palette = getPalette();
        var ui = getUIColors();
        var fillOpacity = parseFloat(getCSSVar('chart-fill-opacity')) || 0.3;

        return {
            color: palette,
            backgroundColor: ui.background,
            textStyle: {
                color: ui.axisLabel
            },
            title: {
                textStyle: {
                    color: getCSSVar('text-primary')
                }
            },
            legend: {
                textStyle: {
                    color: ui.legendText
                }
            },
            tooltip: {
                backgroundColor: ui.tooltipBg,
                borderColor: ui.tooltipBorder,
                textStyle: {
                    color: ui.tooltipText
                }
            },
            grid: {
                borderColor: ui.gridLine
            },
            categoryAxis: {
                axisLine: {
                    lineStyle: {
                        color: ui.axisLine
                    }
                },
                axisTick: {
                    lineStyle: {
                        color: ui.axisLine
                    }
                },
                axisLabel: {
                    color: ui.axisLabel
                },
                splitLine: {
                    lineStyle: {
                        color: ui.gridLine
                    }
                }
            },
            valueAxis: {
                axisLine: {
                    lineStyle: {
                        color: ui.axisLine
                    }
                },
                axisTick: {
                    lineStyle: {
                        color: ui.axisLine
                    }
                },
                axisLabel: {
                    color: ui.axisLabel
                },
                splitLine: {
                    lineStyle: {
                        color: ui.gridLine
                    }
                }
            },
            timeAxis: {
                axisLine: {
                    lineStyle: {
                        color: ui.axisLine
                    }
                },
                axisTick: {
                    lineStyle: {
                        color: ui.axisLine
                    }
                },
                axisLabel: {
                    color: ui.axisLabel
                },
                splitLine: {
                    lineStyle: {
                        color: ui.gridLine
                    }
                }
            },
            line: {
                smooth: true,
                symbol: 'none'
            },
            bar: {
                barMaxWidth: 50
            },
            pie: {
                itemStyle: {
                    borderColor: ui.tooltipBg,
                    borderWidth: 2
                }
            },
            gauge: {
                itemStyle: {
                    color: ui.gaugeProgress
                },
                axisLine: {
                    lineStyle: {
                        color: [[1, ui.gaugeTrack]]
                    }
                }
            },
            dataZoom: {
                backgroundColor: ui.gridLine,
                dataBackgroundColor: ui.gridLine,
                fillerColor: 'rgba(100, 100, 100, 0.15)',
                handleColor: palette[0],
                textStyle: {
                    color: ui.axisLabel
                }
            }
        };
    }

    /**
     * Register and apply theme to ECharts
     */
    function registerTheme() {
        if (typeof echarts === 'undefined') {
            console.warn('JEVisChartTheme: ECharts not loaded yet');
            return;
        }
        echarts.registerTheme('jevis', buildEChartsTheme());
    }

    /**
     * Initialize a chart with the JEVis theme
     * @param {HTMLElement|string} container - DOM element or ID
     * @returns {Object} ECharts instance
     */
    function initChart(container) {
        if (typeof echarts === 'undefined') {
            console.error('JEVisChartTheme: ECharts not available');
            return null;
        }

        var dom = typeof container === 'string'
            ? document.getElementById(container)
            : container;

        if (!dom) {
            console.error('JEVisChartTheme: Container not found');
            return null;
        }

        // Ensure theme is registered
        registerTheme();

        // Create chart with theme
        var chart = echarts.init(dom, 'jevis');

        // Track for refresh
        registeredCharts.push(chart);

        return chart;
    }

    /**
     * Refresh all registered charts (call after theme change)
     */
    function refresh() {
        clearCache();
        registerTheme();

        // Update all tracked charts
        registeredCharts = registeredCharts.filter(function(chart) {
            if (chart && !chart.isDisposed()) {
                // Re-apply theme by getting current options and re-setting
                var option = chart.getOption();
                chart.dispose();

                // Get container and reinitialize
                var dom = chart.getDom ? chart.getDom() : null;
                if (dom) {
                    var newChart = echarts.init(dom, 'jevis');
                    newChart.setOption(option);
                    return true;
                }
                return false;
            }
            return false;
        });
    }

    /**
     * Set up MutationObserver to watch for theme changes
     */
    function watchThemeChanges() {
        var observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
                if (mutation.type === 'attributes' && mutation.attributeName === 'data-theme') {
                    // Theme changed, refresh all charts
                    setTimeout(function() {
                        clearCache();
                        registerTheme();

                        // Notify any custom handlers
                        var event = new CustomEvent('jevis-theme-changed', {
                            detail: {
                                theme: document.documentElement.getAttribute('data-theme')
                            }
                        });
                        document.dispatchEvent(event);
                    }, 50);
                }
            });
        });

        observer.observe(document.documentElement, {
            attributes: true,
            attributeFilter: ['data-theme']
        });
    }

    /**
     * Get fill opacity value
     * @returns {number} Opacity value (0-1)
     */
    function getFillOpacity() {
        return parseFloat(getCSSVar('chart-fill-opacity')) || 0.3;
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            watchThemeChanges();
            if (typeof echarts !== 'undefined') {
                registerTheme();
            }
        });
    } else {
        watchThemeChanges();
        if (typeof echarts !== 'undefined') {
            registerTheme();
        }
    }

    // Public API
    return {
        getCSSVar: getCSSVar,
        getPalette: getPalette,
        getSemanticColors: getSemanticColors,
        getUIColors: getUIColors,
        getSeriesColor: getSeriesColor,
        createBarGradient: createBarGradient,
        buildEChartsTheme: buildEChartsTheme,
        initChart: initChart,
        registerTheme: registerTheme,
        refresh: refresh,
        getFillOpacity: getFillOpacity,
        clearCache: clearCache
    };
})();
