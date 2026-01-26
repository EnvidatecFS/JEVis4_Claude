@import org.jevis.controller.LoginController.LoginViewModel
@import org.springframework.security.web.csrf.CsrfToken

@param LoginViewModel model = new LoginViewModel()
@param CsrfToken csrf

@template.layout.base(title = "Login", content = @`
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-logo">
                <img src="/images/JEVis4_logo.png" alt="JEVis 4 Logo" class="auth-logo-image-large">
                <p>PV-Anlagen Datenmanagement</p>
            </div>

            !{var error = model.error();}
            !{var logout = model.logout();}

            @if(error != null && error)
                <div class="alert alert-danger">
                    Ungültiger Benutzername oder Passwort.
                </div>
            @endif

            @if(logout != null && logout)
                <div class="alert alert-success">
                    Sie wurden erfolgreich abgemeldet.
                </div>
            @endif

            <form method="post" action="/login">
                <input type="hidden" name="${csrf.getParameterName()}" value="${csrf.getToken()}">

                <div class="form-group">
                    <label for="username">Benutzername</label>
                    <input
                        type="text"
                        id="username"
                        name="username"
                        required
                        autofocus
                        placeholder="Benutzername eingeben"
                    >
                </div>

                <div class="form-group">
                    <label for="password">Passwort</label>
                    <input
                        type="password"
                        id="password"
                        name="password"
                        required
                        placeholder="Passwort eingeben"
                    >
                </div>

                <div class="form-group d-flex align-center justify-between">
                    <label style="margin-bottom: 0; font-weight: normal;">
                        <input type="checkbox" name="remember-me" style="width: auto; margin-right: 0.5rem;">
                        Angemeldet bleiben
                    </label>
                    <a href="/forgot-password" class="text-muted" style="font-size: 0.875rem;">
                        Passwort vergessen?
                    </a>
                </div>

                <button type="submit" class="btn btn-primary btn-full btn-lg">
                    Anmelden
                </button>
            </form>

            <div class="text-center mt-4">
                <p class="text-muted" style="font-size: 0.875rem;">
                    Noch kein Konto? <a href="/register">Registrieren</a>
                </p>
            </div>
        </div>
    </div>
`)
