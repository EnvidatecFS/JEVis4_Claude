@param Integer statusCode = 500
@param String errorMessage = "Unknown error"
@param String requestUri = "unknown"
@param String exception = "No exception details"

@template.layout.base(title = "Fehler", content = @`
    <div class="auth-container">
        <div class="auth-card" style="max-width: 600px;">
            <div class="auth-logo">
                <img src="/images/JEVis4_logo.png" alt="JEVis 4 Logo" class="auth-logo-image">
                <h1 style="color: var(--danger-color);">Fehler ${statusCode}</h1>
            </div>

            <div class="card" style="margin-bottom: var(--spacing-lg); background: var(--background); padding: var(--spacing-lg);">
                <h3 style="margin-bottom: var(--spacing-md);">Fehlerdetails:</h3>

                <div style="margin-bottom: var(--spacing-md);">
                    <strong>Status Code:</strong>
                    <p style="color: var(--danger-color); font-size: var(--font-size-xl); margin: var(--spacing-sm) 0;">
                        ${statusCode}
                    </p>
                </div>

                <div style="margin-bottom: var(--spacing-md);">
                    <strong>Nachricht:</strong>
                    <p style="margin: var(--spacing-sm) 0;">${errorMessage}</p>
                </div>

                <div style="margin-bottom: var(--spacing-md);">
                    <strong>Request URI:</strong>
                    <p style="margin: var(--spacing-sm) 0; font-family: monospace; background: var(--surface); padding: var(--spacing-sm); border-radius: var(--radius-sm);">
                        ${requestUri}
                    </p>
                </div>

                <div style="margin-bottom: var(--spacing-md);">
                    <strong>Exception:</strong>
                    <p style="margin: var(--spacing-sm) 0; font-family: monospace; font-size: var(--font-size-sm); background: var(--surface); padding: var(--spacing-sm); border-radius: var(--radius-sm); word-break: break-all;">
                        ${exception}
                    </p>
                </div>
            </div>

            @if(statusCode == 403)
                <div class="alert alert-warning" style="margin-bottom: var(--spacing-lg);">
                    <strong>403 Forbidden:</strong> Dies ist oft ein CSRF-Token Problem oder fehlende Berechtigungen.
                </div>
            @endif

            @if(statusCode == 404)
                <div class="alert alert-info" style="margin-bottom: var(--spacing-lg);">
                    <strong>404 Not Found:</strong> Die angeforderte Seite wurde nicht gefunden.
                </div>
            @endif

            <div style="display: flex; gap: var(--spacing-md); justify-content: center;">
                <a href="javascript:history.back()" class="btn btn-outline">Zurück</a>
                <a href="/home" class="btn btn-primary">Zur Startseite</a>
            </div>
        </div>
    </div>
`)
