package gg.jte.generated.ondemand.pages;
import org.jevis.controller.LoginController.LoginViewModel;
import org.springframework.security.web.csrf.CsrfToken;
public final class JteloginGenerated {
	public static final String JTE_NAME = "pages/login.jte";
	public static final int[] JTE_LINE_INFO = {0,0,1,3,3,3,6,6,6,6,14,14,15,15,17,17,21,21,23,23,27,27,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,77,77,77,78,78,78,3,4,4,4,4};
	public static void render(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, LoginViewModel model, CsrfToken csrf) {
		jteOutput.writeContent("\n");
		gg.jte.generated.ondemand.layout.JtebaseGenerated.render(jteOutput, jteHtmlInterceptor, "Login", new gg.jte.html.HtmlContent() {
			public void writeTo(gg.jte.html.HtmlTemplateOutput jteOutput) {
				jteOutput.writeContent("\n    <div class=\"auth-container\">\n        <div class=\"auth-card\">\n            <div class=\"auth-logo\">\n                <img src=\"/images/JEVis4_logo.png\" alt=\"JEVis 4 Logo\" class=\"auth-logo-image-large\">\n                <p>PV-Anlagen Datenmanagement</p>\n            </div>\n\n            ");
				var error = model.error();
				jteOutput.writeContent("\n            ");
				var logout = model.logout();
				jteOutput.writeContent("\n\n            ");
				if (error != null && error) {
					jteOutput.writeContent("\n                <div class=\"alert alert-danger\">\n                    Ungültiger Benutzername oder Passwort.\n                </div>\n            ");
				}
				jteOutput.writeContent("\n\n            ");
				if (logout != null && logout) {
					jteOutput.writeContent("\n                <div class=\"alert alert-success\">\n                    Sie wurden erfolgreich abgemeldet.\n                </div>\n            ");
				}
				jteOutput.writeContent("\n\n            <form method=\"post\" action=\"/login\">\n                <input type=\"hidden\"");
				var __jte_html_attribute_0 = csrf.getParameterName();
				if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_0)) {
					jteOutput.writeContent(" name=\"");
					jteOutput.setContext("input", "name");
					jteOutput.writeUserContent(__jte_html_attribute_0);
					jteOutput.setContext("input", null);
					jteOutput.writeContent("\"");
				}
				var __jte_html_attribute_1 = csrf.getToken();
				if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_1)) {
					jteOutput.writeContent(" value=\"");
					jteOutput.setContext("input", "value");
					jteOutput.writeUserContent(__jte_html_attribute_1);
					jteOutput.setContext("input", null);
					jteOutput.writeContent("\"");
				}
				jteOutput.writeContent(">\n\n                <div class=\"form-group\">\n                    <label for=\"username\">Benutzername</label>\n                    <input\n                        type=\"text\"\n                        id=\"username\"\n                        name=\"username\"\n                        required\n                        autofocus\n                        placeholder=\"Benutzername eingeben\"\n                    >\n                </div>\n\n                <div class=\"form-group\">\n                    <label for=\"password\">Passwort</label>\n                    <input\n                        type=\"password\"\n                        id=\"password\"\n                        name=\"password\"\n                        required\n                        placeholder=\"Passwort eingeben\"\n                    >\n                </div>\n\n                <div class=\"form-group d-flex align-center justify-between\">\n                    <label style=\"margin-bottom: 0; font-weight: normal;\">\n                        <input type=\"checkbox\" name=\"remember-me\" style=\"width: auto; margin-right: 0.5rem;\">\n                        Angemeldet bleiben\n                    </label>\n                    <a href=\"/forgot-password\" class=\"text-muted\" style=\"font-size: 0.875rem;\">\n                        Passwort vergessen?\n                    </a>\n                </div>\n\n                <button type=\"submit\" class=\"btn btn-primary btn-full btn-lg\">\n                    Anmelden\n                </button>\n            </form>\n\n            <div class=\"text-center mt-4\">\n                <p class=\"text-muted\" style=\"font-size: 0.875rem;\">\n                    Noch kein Konto? <a href=\"/register\">Registrieren</a>\n                </p>\n            </div>\n        </div>\n    </div>\n");
			}
		});
		jteOutput.writeContent("\n");
	}
	public static void renderMap(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, java.util.Map<String, Object> params) {
		LoginViewModel model = (LoginViewModel)params.getOrDefault("model", new LoginViewModel());
		CsrfToken csrf = (CsrfToken)params.get("csrf");
		render(jteOutput, jteHtmlInterceptor, model, csrf);
	}
}
