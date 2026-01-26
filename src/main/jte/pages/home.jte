@param String username

@template.layout.app(
    title = "Übersicht",
    username = username,
    currentPage = "home",
    content = @`
        <div class="page-header">
            <h1 class="page-title">Willkommen, ${username}! 👋</h1>
            <p class="page-description">
                Hier ist Ihre Übersicht über alle PV-Anlagen und aktuelle Systemdaten.
            </p>
        </div>

        <!-- Stats Cards -->
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: var(--spacing-lg); margin-bottom: var(--spacing-xl);">
            <div class="card" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none;">
                <div style="display: flex; justify-content: space-between; align-items: start;">
                    <div>
                        <p style="color: rgba(255,255,255,0.9); font-size: var(--font-size-sm); margin-bottom: var(--spacing-sm);">Aktive Anlagen</p>
                        <h2 style="font-size: var(--font-size-3xl); color: white; margin: 0;">0</h2>
                        <p style="color: rgba(255,255,255,0.8); font-size: var(--font-size-sm); margin-top: var(--spacing-sm);">
                            <span style="color: #10b981;">↑ 0%</span> seit letztem Monat
                        </p>
                    </div>
                    <div style="background: rgba(255,255,255,0.2); padding: var(--spacing-md); border-radius: var(--radius-lg);">
                        <svg width="32" height="32" fill="none" stroke="white" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                        </svg>
                    </div>
                </div>
            </div>

            <div class="card" style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; border: none;">
                <div style="display: flex; justify-content: space-between; align-items: start;">
                    <div>
                        <p style="color: rgba(255,255,255,0.9); font-size: var(--font-size-sm); margin-bottom: var(--spacing-sm);">Heutige Produktion</p>
                        <h2 style="font-size: var(--font-size-3xl); color: white; margin: 0;">0 kWh</h2>
                        <p style="color: rgba(255,255,255,0.8); font-size: var(--font-size-sm); margin-top: var(--spacing-sm);">
                            Durchschnitt: 0 kWh/Tag
                        </p>
                    </div>
                    <div style="background: rgba(255,255,255,0.2); padding: var(--spacing-md); border-radius: var(--radius-lg);">
                        <svg width="32" height="32" fill="none" stroke="white" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>
                        </svg>
                    </div>
                </div>
            </div>

            <div class="card" style="background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: white; border: none;">
                <div style="display: flex; justify-content: space-between; align-items: start;">
                    <div>
                        <p style="color: rgba(255,255,255,0.9); font-size: var(--font-size-sm); margin-bottom: var(--spacing-sm);">Gesamtleistung</p>
                        <h2 style="font-size: var(--font-size-3xl); color: white; margin: 0;">0 kW</h2>
                        <p style="color: rgba(255,255,255,0.8); font-size: var(--font-size-sm); margin-top: var(--spacing-sm);">
                            Installierte Kapazität
                        </p>
                    </div>
                    <div style="background: rgba(255,255,255,0.2); padding: var(--spacing-md); border-radius: var(--radius-lg);">
                        <svg width="32" height="32" fill="none" stroke="white" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                        </svg>
                    </div>
                </div>
            </div>

            <div class="card" style="background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); color: white; border: none;">
                <div style="display: flex; justify-content: space-between; align-items: start;">
                    <div>
                        <p style="color: rgba(255,255,255,0.9); font-size: var(--font-size-sm); margin-bottom: var(--spacing-sm);">CO₂ Einsparung</p>
                        <h2 style="font-size: var(--font-size-3xl); color: white; margin: 0;">0 t</h2>
                        <p style="color: rgba(255,255,255,0.8); font-size: var(--font-size-sm); margin-top: var(--spacing-sm);">
                            Dieses Jahr
                        </p>
                    </div>
                    <div style="background: rgba(255,255,255,0.2); padding: var(--spacing-md); border-radius: var(--radius-lg);">
                        <svg width="32" height="32" fill="none" stroke="white" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                        </svg>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Content Area -->
        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: var(--spacing-xl);">
            <!-- Recent Activity -->
            <div class="card">
                <div class="card-header">
                    <h2>Letzte Aktivitäten</h2>
                </div>
                <div class="alert alert-info">
                    <strong>Info:</strong> Hier werden zukünftig die letzten Aktivitäten und Ereignisse Ihrer PV-Anlagen angezeigt.
                </div>
                <p class="text-muted">
                    Diese Übersicht wird folgende Informationen enthalten:
                </p>
                <ul style="color: var(--text-secondary); margin-left: var(--spacing-lg);">
                    <li>Neue Datenpunkte und Messwerte</li>
                    <li>Systembenachrichtigungen</li>
                    <li>Wartungshinweise</li>
                    <li>Performance-Warnungen</li>
                </ul>
            </div>

            <!-- Quick Actions -->
            <div>
                <div class="card" style="margin-bottom: var(--spacing-lg);">
                    <div class="card-header">
                        <h3>Schnellaktionen</h3>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: var(--spacing-sm);">
                        <a href="/plants" class="btn btn-primary" style="text-decoration: none;">
                            <span style="margin-right: var(--spacing-sm);">⚡</span>
                            Neue Anlage hinzufügen
                        </a>
                        <a href="/reports" class="btn btn-outline" style="text-decoration: none;">
                            <span style="margin-right: var(--spacing-sm);">📊</span>
                            Bericht erstellen
                        </a>
                        <a href="/data" class="btn btn-outline" style="text-decoration: none;">
                            <span style="margin-right: var(--spacing-sm);">💾</span>
                            Daten importieren
                        </a>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h3>System Status</h3>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: var(--spacing-md);">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span class="text-muted">Datenbank</span>
                            <span style="color: var(--secondary-color); font-weight: 500;">● Online</span>
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span class="text-muted">API Status</span>
                            <span style="color: var(--secondary-color); font-weight: 500;">● Aktiv</span>
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span class="text-muted">Letzte Sync</span>
                            <span class="text-muted">Gerade eben</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `
)
