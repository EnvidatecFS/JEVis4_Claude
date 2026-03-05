package gg.jte.generated.ondemand.pages;
import org.springframework.security.web.csrf.CsrfToken;
public final class JteworkersGenerated {
	public static final String JTE_NAME = "pages/workers.jte";
	public static final int[] JTE_LINE_INFO = {0,0,2,2,2,5,5,11,11,29,29,29,30,30,30,2,3,3,3,3};
	public static void render(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, String username, CsrfToken _csrf) {
		jteOutput.writeContent("\r\n");
		gg.jte.generated.ondemand.layout.JteappGenerated.render(jteOutput, jteHtmlInterceptor, "Workers", username, "workers", new gg.jte.html.HtmlContent() {
			public void writeTo(gg.jte.html.HtmlTemplateOutput jteOutput) {
				jteOutput.writeContent("\r\n        <div class=\"page-header\">\r\n            <h1 class=\"page-title\">Task Workers</h1>\r\n            <p class=\"page-description\">Registrierte Worker und Pool-Übersicht</p>\r\n        </div>\r\n\r\n        <div class=\"card\">\r\n            <div id=\"workers-table-container\"\r\n                 hx-get=\"/workers/table\"\r\n                 hx-trigger=\"load, every 15s\"\r\n                 hx-swap=\"innerHTML\">\r\n                <div class=\"loading-spinner\">Lade Worker-Daten...</div>\r\n            </div>\r\n        </div>\r\n\r\n        <style>\r\n            .loading-spinner { text-align: center; padding: var(--spacing-xl); color: var(--text-secondary); }\r\n        </style>\r\n    ");
			}
		}, _csrf);
		jteOutput.writeContent("\r\n");
	}
	public static void renderMap(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, java.util.Map<String, Object> params) {
		String username = (String)params.get("username");
		CsrfToken _csrf = (CsrfToken)params.getOrDefault("_csrf", null);
		render(jteOutput, jteHtmlInterceptor, username, _csrf);
	}
}
