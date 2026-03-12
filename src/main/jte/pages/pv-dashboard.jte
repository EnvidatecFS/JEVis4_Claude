@import org.jevis.model.PvDashboardConfig
@import org.jevis.model.Sensor
@import java.util.List
@import org.springframework.security.web.csrf.CsrfToken
@import org.jevis.model.Tenant

@param String username
@param PvDashboardConfig config
@param List<Sensor> sensors
@param CsrfToken _csrf = null
@param boolean isAdmin = false
@param List<Tenant> userTenants = java.util.Collections.emptyList()
@param Tenant activeTenant = null

@template.layout.app(
    title = "PV Live",
    username = username,
    currentPage = "pv-dashboard",
    isAdmin = isAdmin,
    userTenants = userTenants,
    activeTenant = activeTenant,
    content = @`

<style>
/* ── PV Dashboard Styles ────────────────────────────────── */
.pv-wrap {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-lg);
}

.pv-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: var(--spacing-md);
}

.pv-canvas-card {
    background: var(--surface-color);
    border: 1px solid var(--border-color);
    border-radius: var(--border-radius-lg);
    padding: var(--spacing-xl);
    overflow: hidden;
}

.pv-svg-wrap {
    width: 100%;
    max-width: 900px;
    margin: 0 auto;
}

.pv-svg-wrap svg {
    width: 100%;
    height: auto;
    display: block;
}

/* ── Component boxes ─────────────────────────────────────── */
.pv-box {
    rx: 12;
    ry: 12;
}

.box-pv      { fill: #fef3c7; stroke: #f59e0b; stroke-width: 2; }
.box-house   { fill: #dbeafe; stroke: #3b82f6; stroke-width: 2; }
.box-battery { fill: #d1fae5; stroke: #10b981; stroke-width: 2; }
.box-grid    { fill: #fce7f3; stroke: #ec4899; stroke-width: 2; }

/* ── Flow paths ──────────────────────────────────────────── */
.flow-path {
    fill: none;
    stroke-width: 3;
    stroke-linecap: round;
}
.flow-path.pv-to-house   { stroke: #f59e0b; }
.flow-path.house-to-bat  { stroke: #10b981; }
.flow-path.bat-to-house  { stroke: #10b981; }
.flow-path.house-to-grid { stroke: #ec4899; }
.flow-path.grid-to-house { stroke: #ec4899; }

/* ── Animated dashes on active flow paths ──────────────────── */
.flow-active {
    stroke-dasharray: 12 8;
    animation: flow-anim 1.5s linear infinite;
}
.flow-active.speed-slow   { animation-duration: 3s; }
.flow-active.speed-medium { animation-duration: 1.5s; }
.flow-active.speed-fast   { animation-duration: 0.8s; }
.flow-active.speed-vfast  { animation-duration: 0.4s; }
.flow-active.reverse      { animation-direction: reverse; }

@keyframes flow-anim {
    to { stroke-dashoffset: -20; }
}

/* ── Value labels ───────────────────────────────────────── */
.pv-label-title {
    font-size: 13px;
    font-weight: 600;
    fill: #1e293b;
}
.pv-label-value {
    font-size: 14px;
    font-weight: 700;
    fill: #0f172a;
}
.pv-label-sub {
    font-size: 11px;
    fill: #475569;
}

/* ── Stats bar ──────────────────────────────────────────── */
.pv-stats {
    display: flex;
    gap: var(--spacing-lg);
    flex-wrap: wrap;
}
.pv-stat {
    flex: 1;
    min-width: 140px;
    background: var(--surface-color);
    border: 1px solid var(--border-color);
    border-radius: var(--border-radius);
    padding: var(--spacing-md) var(--spacing-lg);
}
.pv-stat-label {
    font-size: 0.75rem;
    color: var(--text-secondary);
    text-transform: uppercase;
    letter-spacing: 0.05em;
    margin-bottom: 4px;
}
.pv-stat-value {
    font-size: 1.5rem;
    font-weight: 700;
    color: var(--text-primary);
}
.pv-stat-unit {
    font-size: 0.8rem;
    color: var(--text-secondary);
    margin-left: 4px;
}

/* ── Config modal ───────────────────────────────────────── */
.modal-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.5);
    z-index: 1000;
    align-items: center;
    justify-content: center;
}
.modal-overlay.open { display: flex; }
.modal-box {
    background: var(--surface-color);
    border-radius: var(--border-radius-lg);
    padding: var(--spacing-xl);
    width: 520px;
    max-width: 95vw;
    max-height: 90vh;
    overflow-y: auto;
}
.modal-box h2 { margin-top: 0; font-size: 1.2rem; }
.config-row {
    display: flex;
    align-items: center;
    gap: var(--spacing-md);
    margin-bottom: var(--spacing-md);
}
.config-row label {
    width: 140px;
    font-size: 0.875rem;
    font-weight: 500;
    flex-shrink: 0;
}
.config-row select {
    flex: 1;
    padding: 6px 10px;
    border: 1px solid var(--border-color);
    border-radius: var(--border-radius);
    font-size: 0.875rem;
    background: var(--background-color);
    color: var(--text-primary);
}

/* ── Status dot ─────────────────────────────────────────── */
.pv-status {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 0.8rem;
    color: var(--text-secondary);
}
.status-dot {
    width: 8px; height: 8px;
    border-radius: 50%;
    background: #10b981;
    box-shadow: 0 0 6px #10b981;
}
.status-dot.offline { background: #ef4444; box-shadow: 0 0 6px #ef4444; }
</style>

<div class="pv-wrap">
    <!-- Header -->
    <div class="pv-header">
        <div>
            <h1 style="margin:0; font-size:1.5rem;">${config.getName()}</h1>
            <div class="pv-status" style="margin-top:4px;">
                <span class="status-dot" id="statusDot"></span>
                <span id="statusText">Verbinde…</span>
            </div>
        </div>
        <div style="display:flex; gap: var(--spacing-sm);">
            <button class="btn btn-secondary" onclick="openConfig()">
                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="margin-right:6px; vertical-align:-2px;">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
                Konfigurieren
            </button>
        </div>
    </div>

    <!-- Stats bar -->
    <div class="pv-stats">
        <div class="pv-stat">
            <div class="pv-stat-label">☀️ PV Erzeugung</div>
            <div><span class="pv-stat-value" id="stat-pv">–</span><span class="pv-stat-unit" id="unit-pv">W</span></div>
        </div>
        <div class="pv-stat">
            <div class="pv-stat-label">🏠 Verbrauch</div>
            <div><span class="pv-stat-value" id="stat-cons">–</span><span class="pv-stat-unit" id="unit-cons">W</span></div>
        </div>
        <div class="pv-stat">
            <div class="pv-stat-label">🔋 Batterie</div>
            <div><span class="pv-stat-value" id="stat-bat">–</span><span class="pv-stat-unit" id="unit-bat">W</span></div>
        </div>
        <div class="pv-stat">
            <div class="pv-stat-label">🔋 Ladezustand</div>
            <div><span class="pv-stat-value" id="stat-soc">–</span><span class="pv-stat-unit">%</span></div>
        </div>
        <div class="pv-stat">
            <div class="pv-stat-label">⚡ Netz</div>
            <div><span class="pv-stat-value" id="stat-grid">–</span><span class="pv-stat-unit" id="unit-grid">W</span></div>
        </div>
    </div>

    <!-- SVG Infographic -->
    <div class="pv-canvas-card">
        <div class="pv-svg-wrap">
            <svg viewBox="0 0 900 460" xmlns="http://www.w3.org/2000/svg" font-family="system-ui, sans-serif">

                <!-- ═══════════════════════ DEFS ═══════════════════════ -->
                <defs>
                    <!-- Arrow marker for grid direction indicator -->
                    <marker id="arrowOrange" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto">
                        <path d="M0,0 L0,6 L6,3 Z" fill="#f59e0b"/>
                    </marker>
                    <marker id="arrowGreen" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto">
                        <path d="M0,0 L0,6 L6,3 Z" fill="#10b981"/>
                    </marker>
                    <marker id="arrowPink" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto">
                        <path d="M0,0 L0,6 L6,3 Z" fill="#ec4899"/>
                    </marker>
                </defs>

                <!-- ═══════════════════════ SUN ══════════════════════ -->
                <!-- Decorative sun rays -->
                <g opacity="0.6">
                    <line x1="450" y1="8"  x2="450" y2="20" stroke="#fbbf24" stroke-width="2"/>
                    <line x1="450" y1="56" x2="450" y2="68" stroke="#fbbf24" stroke-width="2"/>
                    <line x1="418" y1="14" x2="424" y2="25" stroke="#fbbf24" stroke-width="2"/>
                    <line x1="476" y1="51" x2="482" y2="62" stroke="#fbbf24" stroke-width="2"/>
                    <line x1="404" y1="38" x2="416" y2="38" stroke="#fbbf24" stroke-width="2"/>
                    <line x1="484" y1="38" x2="496" y2="38" stroke="#fbbf24" stroke-width="2"/>
                    <line x1="418" y1="62" x2="424" y2="51" stroke="#fbbf24" stroke-width="2"/>
                    <line x1="476" y1="25" x2="482" y2="14" stroke="#fbbf24" stroke-width="2"/>
                </g>
                <circle cx="450" cy="38" r="20" fill="#fde68a" stroke="#f59e0b" stroke-width="2"/>
                <circle cx="450" cy="38" r="13" fill="#fbbf24"/>

                <!-- ═══════════════════════ FLOW PATHS ════════════════ -->

                <!-- PV → House (vertical, center) -->
                <path id="path-pv-house"
                      d="M 450,152 L 450,240"
                      class="flow-path pv-to-house"/>

                <!-- House ↔ Battery (horizontal left) -->
                <path id="path-house-bat"
                      d="M 295,320 L 220,320"
                      class="flow-path house-to-bat"/>

                <!-- House ↔ Grid (horizontal right) -->
                <path id="path-house-grid"
                      d="M 605,320 L 680,320"
                      class="flow-path house-to-grid"/>

                <!-- ═══════════════════════ PV PANEL BOX ═══════════════ -->
                <rect x="295" y="72" width="310" height="80" rx="12" ry="12" class="box-pv"/>
                <!-- Panel icon (simplified solar cell grid) -->
                <g transform="translate(315, 87)" opacity="0.7">
                    <rect x="0"  y="0"  width="14" height="10" rx="1" fill="#f59e0b" stroke="#d97706" stroke-width="0.5"/>
                    <rect x="16" y="0"  width="14" height="10" rx="1" fill="#f59e0b" stroke="#d97706" stroke-width="0.5"/>
                    <rect x="0"  y="12" width="14" height="10" rx="1" fill="#f59e0b" stroke="#d97706" stroke-width="0.5"/>
                    <rect x="16" y="12" width="14" height="10" rx="1" fill="#f59e0b" stroke="#d97706" stroke-width="0.5"/>
                    <line x1="7" y1="22" x2="7" y2="28" stroke="#d97706" stroke-width="1.5"/>
                    <line x1="23" y1="22" x2="23" y2="28" stroke="#d97706" stroke-width="1.5"/>
                    <line x1="0" y1="28" x2="30" y2="28" stroke="#d97706" stroke-width="1.5"/>
                    <line x1="15" y1="28" x2="15" y2="34" stroke="#d97706" stroke-width="1.5"/>
                </g>
                <text x="370" y="105" class="pv-label-title" dominant-baseline="middle">PV Anlage</text>
                <text x="370" y="126" class="pv-label-value" dominant-baseline="middle" id="svg-pv-value">–</text>

                <!-- ═══════════════════════ HOUSE BOX ═════════════════ -->
                <!-- Roof -->
                <polygon points="380,240 450,200 520,240" fill="#93c5fd" stroke="#3b82f6" stroke-width="2"/>
                <!-- Body -->
                <rect x="385" y="240" width="130" height="120" rx="4" ry="4" class="box-house"/>
                <!-- Door -->
                <rect x="432" y="318" width="36" height="42" rx="3" fill="#bfdbfe" stroke="#3b82f6" stroke-width="1.5"/>
                <!-- Window left -->
                <rect x="395" y="262" width="32" height="28" rx="3" fill="#bfdbfe" stroke="#3b82f6" stroke-width="1.5"/>
                <!-- Window right -->
                <rect x="443" y="262" width="32" height="28" rx="3" fill="#bfdbfe" stroke="#3b82f6" stroke-width="1.5"/>
                <!-- House label outside box (below) -->
                <text x="450" y="376" class="pv-label-title" text-anchor="middle" dominant-baseline="middle">Haus</text>
                <text x="450" y="393" class="pv-label-value" text-anchor="middle" dominant-baseline="middle" id="svg-cons-value">–</text>

                <!-- ═══════════════════════ BATTERY BOX ═══════════════ -->
                <rect x="20" y="240" width="200" height="160" rx="12" ry="12" class="box-battery"/>
                <!-- Battery icon -->
                <g transform="translate(35, 258)">
                    <rect x="0" y="4" width="56" height="28" rx="3" fill="none" stroke="#059669" stroke-width="2"/>
                    <rect x="56" y="10" width="6" height="16" rx="2" fill="#059669"/>
                    <rect id="svg-bat-fill" x="3" y="7" width="40" height="22" rx="2" fill="#6ee7b7"/>
                </g>
                <text x="120" y="276" class="pv-label-title" text-anchor="middle" dominant-baseline="middle">Batterie</text>
                <text x="120" y="296" class="pv-label-value" text-anchor="middle" dominant-baseline="middle" id="svg-bat-value">–</text>
                <text x="120" y="314" class="pv-label-sub" text-anchor="middle" dominant-baseline="middle">
                    SOC: <tspan id="svg-soc-value" font-weight="600">–</tspan>%
                </text>
                <!-- Battery direction arrow -->
                <text x="120" y="360" class="pv-label-sub" text-anchor="middle" id="svg-bat-dir" dominant-baseline="middle"></text>

                <!-- ═══════════════════════ GRID BOX ══════════════════ -->
                <rect x="680" y="240" width="200" height="160" rx="12" ry="12" class="box-grid"/>
                <!-- Grid / pylon icon -->
                <g transform="translate(690, 258)" opacity="0.8">
                    <line x1="25" y1="0"  x2="25" y2="36" stroke="#be185d" stroke-width="2"/>
                    <line x1="0"  y1="8"  x2="50" y2="8"  stroke="#be185d" stroke-width="2"/>
                    <line x1="5"  y1="20" x2="45" y2="20" stroke="#be185d" stroke-width="2"/>
                    <circle cx="0"  cy="8"  r="3" fill="#be185d"/>
                    <circle cx="50" cy="8"  r="3" fill="#be185d"/>
                    <circle cx="5"  cy="20" r="3" fill="#be185d"/>
                    <circle cx="45" cy="20" r="3" fill="#be185d"/>
                </g>
                <text x="780" y="276" class="pv-label-title" text-anchor="middle" dominant-baseline="middle">Netz</text>
                <text x="780" y="296" class="pv-label-value" text-anchor="middle" dominant-baseline="middle" id="svg-grid-value">–</text>
                <text x="780" y="314" class="pv-label-sub" text-anchor="middle" dominant-baseline="middle" id="svg-grid-dir"></text>

                <!-- ═══════════════════════ FLOW LABELS ══════════════ -->
                <!-- PV→House midpoint label -->
                <text x="460" y="198" class="pv-label-sub" id="svg-pv-flow-label" dominant-baseline="middle"></text>
                <!-- House↔Battery midpoint label -->
                <text x="258" y="310" class="pv-label-sub" text-anchor="middle" id="svg-bat-flow-label"></text>
                <!-- House↔Grid midpoint label -->
                <text x="643" y="310" class="pv-label-sub" text-anchor="middle" id="svg-grid-flow-label"></text>

            </svg>
        </div>
        <div style="text-align: right; font-size: 0.7rem; color: var(--text-secondary); margin-top: var(--spacing-sm);">
            Aktualisiert: <span id="lastUpdate">–</span>
        </div>
    </div>
</div>

<!-- ═══════════════════════ CONFIG MODAL ══════════════════════ -->
<div class="modal-overlay" id="configModal" onclick="if(event.target===this)closeConfig()">
    <div class="modal-box">
        <h2>PV Live konfigurieren</h2>
        <form id="configForm" onsubmit="saveConfig(event)">
            <input type="hidden" id="cfg-id" name="id" value="${config.getId()}">
            <div class="config-row">
                <label>Name</label>
                <input type="text" name="name" value="${config.getName()}"
                       style="flex:1; padding:6px 10px; border:1px solid var(--border-color); border-radius:var(--border-radius); font-size:0.875rem; background:var(--background-color); color:var(--text-primary);">
            </div>
            <hr style="border-color:var(--border-color); margin: var(--spacing-md) 0;">
            <div class="config-row">
                <label>☀️ PV Erzeugung</label>
                <select name="sensorIdPvPower">
                    <option value="">– kein Sensor –</option>
                    @for(Sensor s : sensors)
                    <option value="${s.getId()}" selected="${config.getSensorIdPvPower() != null && config.getSensorIdPvPower().equals(s.getId())}">${s.getSensorCode()}${s.getSensorName() != null ? " – " + s.getSensorName() : ""}</option>
                    @endfor
                </select>
            </div>
            <div class="config-row">
                <label>🏠 Verbrauch</label>
                <select name="sensorIdConsumption">
                    <option value="">– kein Sensor –</option>
                    @for(Sensor s : sensors)
                    <option value="${s.getId()}" selected="${config.getSensorIdConsumption() != null && config.getSensorIdConsumption().equals(s.getId())}">${s.getSensorCode()}${s.getSensorName() != null ? " – " + s.getSensorName() : ""}</option>
                    @endfor
                </select>
            </div>
            <div class="config-row">
                <label>🔋 Batterie Leistung</label>
                <select name="sensorIdBatteryPower">
                    <option value="">– kein Sensor –</option>
                    @for(Sensor s : sensors)
                    <option value="${s.getId()}" selected="${config.getSensorIdBatteryPower() != null && config.getSensorIdBatteryPower().equals(s.getId())}">${s.getSensorCode()}${s.getSensorName() != null ? " – " + s.getSensorName() : ""}</option>
                    @endfor
                </select>
            </div>
            <div class="config-row">
                <label>🔋 Ladezustand</label>
                <select name="sensorIdBatterySoc">
                    <option value="">– kein Sensor –</option>
                    @for(Sensor s : sensors)
                    <option value="${s.getId()}" selected="${config.getSensorIdBatterySoc() != null && config.getSensorIdBatterySoc().equals(s.getId())}">${s.getSensorCode()}${s.getSensorName() != null ? " – " + s.getSensorName() : ""}</option>
                    @endfor
                </select>
            </div>
            <div class="config-row">
                <label>⚡ Netz</label>
                <select name="sensorIdGrid">
                    <option value="">– kein Sensor –</option>
                    @for(Sensor s : sensors)
                    <option value="${s.getId()}" selected="${config.getSensorIdGrid() != null && config.getSensorIdGrid().equals(s.getId())}">${s.getSensorCode()}${s.getSensorName() != null ? " – " + s.getSensorName() : ""}</option>
                    @endfor
                </select>
            </div>
            <div style="display:flex; gap:var(--spacing-sm); justify-content:flex-end; margin-top:var(--spacing-lg);">
                <button type="button" class="btn btn-secondary" onclick="closeConfig()">Abbrechen</button>
                <button type="submit" class="btn btn-primary">Speichern</button>
            </div>
        </form>
    </div>
</div>

<script>
(function() {
    const configId = ${config.getId()};
    const csrfToken = '${_csrf != null ? _csrf.getToken() : ""}';
    const csrfHeader = '${_csrf != null ? _csrf.getHeaderName() : "X-CSRF-TOKEN"}';
    let pollInterval = null;

    // ── Helpers ──────────────────────────────────────────────────
    function fmt(val, unit) {
        if (val == null) return '–';
        const abs = Math.abs(val);
        if (unit === 'W' && abs >= 1000) {
            return (val / 1000).toFixed(2) + ' kW';
        }
        return val.toFixed(1) + ' ' + unit;
    }

    function fmtW(val) {
        if (val == null) return { text: '–', unit: 'W' };
        const abs = Math.abs(val);
        if (abs >= 1000) return { text: (val / 1000).toFixed(2), unit: 'kW' };
        return { text: val.toFixed(0), unit: 'W' };
    }

    function speedClass(watts) {
        const abs = Math.abs(watts || 0);
        if (abs < 200)  return 'speed-slow';
        if (abs < 800)  return 'speed-medium';
        if (abs < 2000) return 'speed-fast';
        return 'speed-vfast';
    }

    function setFlowPath(pathId, watts, baseClass, reverse) {
        const el = document.getElementById(pathId);
        if (!el) return;
        el.className.baseVal = 'flow-path ' + baseClass;
        if (watts != null && Math.abs(watts) > 5) {
            el.classList.add('flow-active', speedClass(watts));
            if (reverse) el.classList.add('reverse');
        }
    }

    function setStatValue(statId, unitId, val) {
        const s = document.getElementById(statId);
        const u = document.getElementById(unitId);
        if (!s) return;
        const f = fmtW(val);
        s.textContent = f.text;
        if (u) u.textContent = f.unit;
    }

    function setSvgText(id, text) {
        const el = document.getElementById(id);
        if (el) el.textContent = text;
    }

    // ── Update the SVG with live data ─────────────────────────────
    function applyData(d) {
        const pv   = d.pvPower      != null ? parseFloat(d.pvPower)      : null;
        const cons = d.consumption  != null ? parseFloat(d.consumption)  : null;
        const bat  = d.batteryPower != null ? parseFloat(d.batteryPower) : null;
        const soc  = d.batterySoc   != null ? parseFloat(d.batterySoc)   : null;
        const grid = d.grid         != null ? parseFloat(d.grid)         : null;

        // Stats bar
        setStatValue('stat-pv',   'unit-pv',   pv);
        setStatValue('stat-cons', 'unit-cons',  cons);
        setStatValue('stat-bat',  'unit-bat',   bat);
        setStatValue('stat-grid', 'unit-grid',  grid);
        const socEl = document.getElementById('stat-soc');
        if (socEl) socEl.textContent = soc != null ? soc.toFixed(1) : '–';

        // SVG labels
        const pvF = fmtW(pv);
        setSvgText('svg-pv-value',   pv   != null ? pvF.text + ' ' + pvF.unit : '–');
        const consF = fmtW(cons);
        setSvgText('svg-cons-value', cons != null ? consF.text + ' ' + consF.unit : '–');
        const batF = fmtW(bat);
        setSvgText('svg-bat-value',  bat  != null ? batF.text + ' ' + batF.unit : '–');
        setSvgText('svg-soc-value',  soc  != null ? soc.toFixed(1) : '–');
        const gridF = fmtW(grid);
        setSvgText('svg-grid-value', grid != null ? gridF.text + ' ' + gridF.unit : '–');

        // Battery fill bar (width 0–50 for SOC 0–100%)
        const fillEl = document.getElementById('svg-bat-fill');
        if (fillEl && soc != null) {
            const w = Math.max(1, Math.round(soc / 100 * 50));
            fillEl.setAttribute('width', w);
            fillEl.setAttribute('fill', soc > 20 ? '#6ee7b7' : '#fca5a5');
        }

        // Battery direction label
        if (bat != null) {
            setSvgText('svg-bat-dir', bat > 5 ? '▲ Laden' : bat < -5 ? '▼ Entladen' : '● Standby');
        }

        // Grid direction label
        if (grid != null) {
            setSvgText('svg-grid-dir', grid > 5 ? '▲ Einspeisung' : grid < -5 ? '▼ Bezug' : '● Standby');
        }

        // Animated flow paths
        // PV → House: always positive flow if PV > 0
        setFlowPath('path-pv-house', pv, 'pv-to-house', false);

        // House ↔ Battery: positive=charging (house→bat), negative=discharging (bat→house)
        if (bat != null && Math.abs(bat) > 5) {
            setFlowPath('path-house-bat', bat, 'house-to-bat', bat < 0 /* reverse when discharging */);
        } else {
            const el = document.getElementById('path-house-bat');
            if (el) el.className.baseVal = 'flow-path house-to-bat';
        }

        // House ↔ Grid: positive=export (house→grid), negative=import (grid→house)
        if (grid != null && Math.abs(grid) > 5) {
            setFlowPath('path-house-grid', grid, 'house-to-grid', grid < 0 /* reverse when importing */);
        } else {
            const el = document.getElementById('path-house-grid');
            if (el) el.className.baseVal = 'flow-path house-to-grid';
        }

        // Status
        document.getElementById('statusDot').className = 'status-dot';
        document.getElementById('statusText').textContent = 'Live';
        document.getElementById('lastUpdate').textContent = new Date().toLocaleTimeString('de-DE');
    }

    // ── Poll live data ────────────────────────────────────────────
    async function poll() {
        try {
            const res = await fetch('/pv-dashboard/data?configId=' + configId);
            if (!res.ok) throw new Error('HTTP ' + res.status);
            const data = await res.json();
            applyData(data);
        } catch (e) {
            document.getElementById('statusDot').className = 'status-dot offline';
            document.getElementById('statusText').textContent = 'Offline';
            console.error('PV poll error:', e);
        }
    }

    poll();
    pollInterval = setInterval(poll, 5000);

    // ── Config modal ──────────────────────────────────────────────
    window.openConfig = function() {
        document.getElementById('configModal').classList.add('open');
    };
    window.closeConfig = function() {
        document.getElementById('configModal').classList.remove('open');
    };

    window.saveConfig = async function(e) {
        e.preventDefault();
        const form = e.target;
        const data = new URLSearchParams(new FormData(form));
        const headers = { 'Content-Type': 'application/x-www-form-urlencoded' };
        if (csrfToken) headers[csrfHeader] = csrfToken;
        try {
            const res = await fetch('/pv-dashboard/config', {
                method: 'POST', headers, body: data.toString()
            });
            if (!res.ok) throw new Error('HTTP ' + res.status);
            closeConfig();
            poll();
        } catch (e) {
            alert('Fehler beim Speichern: ' + e.message);
        }
    };
})();
</script>
`
)
