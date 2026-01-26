package gg.jte.generated.ondemand.pages;
public final class JteerrorGenerated {
	public static final String JTE_NAME = "pages/error.jte";
	public static final int[] JTE_LINE_INFO = {0,0,0,0,5,5,5,5,10,10,10,19,19,19,25,25,25,31,31,31,38,38,38,43,43,47,47,49,49,53,53,61,61,61,62,62,62,0,1,2,3,3,3,3};
	public static void render(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, Integer statusCode, String errorMessage, String requestUri, String exception) {
		jteOutput.writeContent("\n");
		gg.jte.generated.ondemand.layout.JtebaseGenerated.render(jteOutput, jteHtmlInterceptor, "Fehler", new gg.jte.html.HtmlContent() {
			public void writeTo(gg.jte.html.HtmlTemplateOutput jteOutput) {
				jteOutput.writeContent("\n    <div class=\"auth-container\">\n        <div class=\"auth-card\" style=\"max-width: 600px;\">\n            <div class=\"auth-logo\">\n                <img src=\"/images/JEVis4_logo.png\" alt=\"JEVis 4 Logo\" class=\"auth-logo-image\">\n                <h1 style=\"color: var(--danger-color);\">Fehler ");
				jteOutput.setContext("h1", null);
				jteOutput.writeUserContent(statusCode);
				jteOutput.writeContent("</h1>\n            </div>\n\n            <div class=\"card\" style=\"margin-bottom: var(--spacing-lg); background: var(--background); padding: var(--spacing-lg);\">\n                <h3 style=\"margin-bottom: var(--spacing-md);\">Fehlerdetails:</h3>\n\n                <div style=\"margin-bottom: var(--spacing-md);\">\n                    <strong>Status Code:</strong>\n                    <p style=\"color: var(--danger-color); font-size: var(--font-size-xl); margin: var(--spacing-sm) 0;\">\n                        ");
				jteOutput.setContext("p", null);
				jteOutput.writeUserContent(statusCode);
				jteOutput.writeContent("\n                    </p>\n                </div>\n\n                <div style=\"margin-bottom: var(--spacing-md);\">\n                    <strong>Nachricht:</strong>\n                    <p style=\"margin: var(--spacing-sm) 0;\">");
				jteOutput.setContext("p", null);
				jteOutput.writeUserContent(errorMessage);
				jteOutput.writeContent("</p>\n                </div>\n\n                <div style=\"margin-bottom: var(--spacing-md);\">\n                    <strong>Request URI:</strong>\n                    <p style=\"margin: var(--spacing-sm) 0; font-family: monospace; background: var(--surface); padding: var(--spacing-sm); border-radius: var(--radius-sm);\">\n                        ");
				jteOutput.setContext("p", null);
				jteOutput.writeUserContent(requestUri);
				jteOutput.writeContent("\n                    </p>\n                </div>\n\n                <div style=\"margin-bottom: var(--spacing-md);\">\n                    <strong>Exception:</strong>\n                    <p style=\"margin: var(--spacing-sm) 0; font-family: monospace; font-size: var(--font-size-sm); background: var(--surface); padding: var(--spacing-sm); border-radius: var(--radius-sm); word-break: break-all;\">\n                        ");
				jteOutput.setContext("p", null);
				jteOutput.writeUserContent(exception);
				jteOutput.writeContent("\n                    </p>\n                </div>\n            </div>\n\n            ");
				if (statusCode == 403) {
					jteOutput.writeContent("\n                <div class=\"alert alert-warning\" style=\"margin-bottom: var(--spacing-lg);\">\n                    <strong>403 Forbidden:</strong> Dies ist oft ein CSRF-Token Problem oder fehlende Berechtigungen.\n                </div>\n            ");
				}
				jteOutput.writeContent("\n\n            ");
				if (statusCode == 404) {
					jteOutput.writeContent("\n                <div class=\"alert alert-info\" style=\"margin-bottom: var(--spacing-lg);\">\n                    <strong>404 Not Found:</strong> Die angeforderte Seite wurde nicht gefunden.\n                </div>\n            ");
				}
				jteOutput.writeContent("\n\n            <div style=\"display: flex; gap: var(--spacing-md); justify-content: center;\">\n                <a href=\"javascript:history.back()\" class=\"btn btn-outline\">Zurück</a>\n                <a href=\"/home\" class=\"btn btn-primary\">Zur Startseite</a>\n            </div>\n        </div>\n    </div>\n");
			}
		});
		jteOutput.writeContent("\n");
	}
	public static void renderMap(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, java.util.Map<String, Object> params) {
		Integer statusCode = (Integer)params.getOrDefault("statusCode", 500);
		String errorMessage = (String)params.getOrDefault("errorMessage", "Unknown error");
		String requestUri = (String)params.getOrDefault("requestUri", "unknown");
		String exception = (String)params.getOrDefault("exception", "No exception details");
		render(jteOutput, jteHtmlInterceptor, statusCode, errorMessage, requestUri, exception);
	}
}
