@param String username

@template.layout.app(
    title = "Dashboard",
    username = username,
    currentPage = "dashboard",
    content = @`
        <div class="page-header">
            <h1 class="page-title">Dashboard</h1>
            <p class="page-description">Detaillierte Auswertungen und Statistiken Ihrer PV-Anlagen</p>
        </div>

        <div class="card">
            <div class="card-header">
                <h2>PV-Anlagen Übersicht</h2>
            </div>
            <p class="text-muted">Hier erscheint in Zukunft die detaillierte Übersicht Ihrer Photovoltaik-Anlagen mit Echtzeitdaten und Auswertungen.</p>

            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1rem; margin-top: 2rem;">
                <div class="card" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none;">
                    <h3 style="color: white;">Aktive Anlagen</h3>
                    <p style="font-size: 2rem; font-weight: bold; margin: 0;">0</p>
                </div>

                <div class="card" style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; border: none;">
                    <h3 style="color: white;">Heutige Produktion</h3>
                    <p style="font-size: 2rem; font-weight: bold; margin: 0;">0 kWh</p>
                </div>

                <div class="card" style="background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: white; border: none;">
                    <h3 style="color: white;">Gesamtleistung</h3>
                    <p style="font-size: 2rem; font-weight: bold; margin: 0;">0 kW</p>
                </div>
            </div>
        </div>
    `
)
