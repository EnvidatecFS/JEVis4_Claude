@param String username

@template.layout.app(
    title = "Einstellungen",
    username = username,
    currentPage = "settings",
    content = @`
        <div class="page-header">
            <h1 class="page-title">Einstellungen</h1>
            <p class="page-description">Verwalten Sie Ihre Kontoeinstellungen und Präferenzen</p>
        </div>

        <div class="settings-grid">
            <!-- Account Settings -->
            <div class="card">
                <div class="card-header">
                    <h3>Kontoinformationen</h3>
                </div>
                <div class="form-group">
                    <label for="username">Benutzername</label>
                    <input type="text" id="username" value="${username}" disabled>
                </div>
                <div class="form-group">
                    <label for="email">E-Mail</label>
                    <input type="email" id="email" value="${username}@jevis.org" placeholder="ihre@email.de">
                </div>
                <div class="form-group">
                    <label for="fullname">Vollständiger Name</label>
                    <input type="text" id="fullname" placeholder="Ihr vollständiger Name">
                </div>
                <button class="btn btn-primary">Profil aktualisieren</button>
            </div>

            <!-- Password Settings -->
            <div class="card">
                <div class="card-header">
                    <h3>Passwort ändern</h3>
                </div>
                <div class="form-group">
                    <label for="current-password">Aktuelles Passwort</label>
                    <input type="password" id="current-password" placeholder="Aktuelles Passwort">
                </div>
                <div class="form-group">
                    <label for="new-password">Neues Passwort</label>
                    <input type="password" id="new-password" placeholder="Neues Passwort">
                </div>
                <div class="form-group">
                    <label for="confirm-password">Passwort bestätigen</label>
                    <input type="password" id="confirm-password" placeholder="Passwort bestätigen">
                </div>
                <button class="btn btn-primary">Passwort ändern</button>
            </div>

            <!-- Notification Settings -->
            <div class="card">
                <div class="card-header">
                    <h3>Benachrichtigungen</h3>
                </div>
                <div class="form-group">
                    <label>
                        <input type="checkbox" checked>
                        E-Mail-Benachrichtigungen aktivieren
                    </label>
                </div>
                <div class="form-group">
                    <label>
                        <input type="checkbox" checked>
                        Alarm-Benachrichtigungen für PV-Anlagen
                    </label>
                </div>
                <div class="form-group">
                    <label>
                        <input type="checkbox">
                        Wöchentliche Berichte erhalten
                    </label>
                </div>
                <div class="form-group">
                    <label>
                        <input type="checkbox" checked>
                        System-Updates und Wartungsmeldungen
                    </label>
                </div>
                <button class="btn btn-primary">Benachrichtigungen speichern</button>
            </div>

            <!-- Display Settings -->
            <div class="card">
                <div class="card-header">
                    <h3>Anzeigeeinstellungen</h3>
                </div>
                <div class="form-group">
                    <label for="theme">Thema</label>
                    <select id="theme" onchange="changeTheme(this.value)">
                        <option value="light" selected>Hell</option>
                        <option value="dark">Dunkel</option>
                        <option value="blue">Blau</option>
                        <option value="green">Grün (PV-optimiert)</option>
                        <option value="ocean">Ozean</option>
                        <option value="sunset">Sonnenuntergang</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="language">Sprache</label>
                    <select id="language">
                        <option value="de" selected>Deutsch</option>
                        <option value="en">English</option>
                        <option value="fr">Français</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="timezone">Zeitzone</label>
                    <select id="timezone">
                        <option value="Europe/Berlin" selected>Europa/Berlin (CET)</option>
                        <option value="Europe/London">Europa/London (GMT)</option>
                        <option value="America/New_York">Amerika/New York (EST)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="date-format">Datumsformat</label>
                    <select id="date-format">
                        <option value="DD.MM.YYYY" selected>DD.MM.YYYY</option>
                        <option value="MM/DD/YYYY">MM/DD/YYYY</option>
                        <option value="YYYY-MM-DD">YYYY-MM-DD</option>
                    </select>
                </div>
                <button class="btn btn-primary">Einstellungen speichern</button>
            </div>

            <!-- Session & Security -->
            <div class="card">
                <div class="card-header">
                    <h3>Sitzung & Sicherheit</h3>
                </div>
                <div class="form-group">
                    <p class="text-muted" style="margin-bottom: var(--spacing-md);">
                        Letzte Anmeldung: Heute um 14:32 Uhr
                    </p>
                </div>
                <div class="form-group">
                    <label>
                        <input type="checkbox">
                        Zwei-Faktor-Authentifizierung (2FA) aktivieren
                    </label>
                </div>
                <div class="form-group">
                    <label>
                        <input type="checkbox" checked>
                        Angemeldet bleiben auf diesem Gerät
                    </label>
                </div>
                <button class="btn btn-outline">Alle Sitzungen abmelden</button>
            </div>

            <!-- Danger Zone -->
            <div class="card" style="border-color: var(--danger-color);">
                <div class="card-header">
                    <h3 style="color: var(--danger-color);">Gefahrenzone</h3>
                </div>
                <p class="text-muted" style="margin-bottom: var(--spacing-lg);">
                    Diese Aktionen können nicht rückgängig gemacht werden.
                </p>
                <button class="btn" style="background-color: var(--danger-color); color: white;">
                    Konto löschen
                </button>
            </div>
        </div>
    `
)

<style>
.settings-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
    gap: var(--spacing-xl);
}

@media (max-width: 768px) {
    .settings-grid {
        grid-template-columns: 1fr;
    }
}
</style>

<script>
// Theme Management
function changeTheme(theme) {
    // Apply theme to document
    document.documentElement.setAttribute('data-theme', theme);

    // Save to localStorage
    localStorage.setItem('selectedTheme', theme);

    // Show confirmation (optional)
    console.log('Theme changed to:', theme);
}

// Load saved theme on page load
document.addEventListener('DOMContentLoaded', function() {
    const savedTheme = localStorage.getItem('selectedTheme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);

    // Set the select value
    const themeSelect = document.getElementById('theme');
    if (themeSelect) {
        themeSelect.value = savedTheme;
    }
});
</script>
