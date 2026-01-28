package gg.jte.generated.ondemand.layout;
import gg.jte.Content;
import org.springframework.security.web.csrf.CsrfToken;
public final class JteappGenerated {
	public static final String JTE_NAME = "layout/app.jte";
	public static final int[] JTE_LINE_INFO = {0,0,1,3,3,3,14,14,14,14,16,22,23,23,24,24,24,24,24,24,24,24,24,25,25,25,25,25,25,25,25,25,26,26,26,26,26,26,26,26,26,27,27,33,47,48,48,50,52,53,53,55,57,57,57,62,63,63,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,67,67,68,70,70,73,79,83,88,94,104,110,120,124,136,145,151,151,151,3,4,5,6,7,7,7,7};
	public static void render(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, String title, String username, String currentPage, Content content, CsrfToken _csrf) {
		jteOutput.writeContent("\n<!DOCTYPE html>\n<html lang=\"de\">\n<head>\n    <meta charset=\"UTF-8\">\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n    <title>");
		jteOutput.setContext("title", null);
		jteOutput.writeUserContent(title);
		jteOutput.writeContent(" - JEVis 4</title>\n\n    ");
		jteOutput.writeContent("\n    <link rel=\"icon\" type=\"image/x-icon\" href=\"/images/favicon.ico\">\n    <link rel=\"icon\" type=\"image/png\" sizes=\"32x32\" href=\"/images/favicon-32x32.png\">\n    <link rel=\"icon\" type=\"image/png\" sizes=\"16x16\" href=\"/images/favicon-16x16.png\">\n    <link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"/images/apple-touch-icon.png\">\n\n    ");
		jteOutput.writeContent("\n    ");
		if (_csrf != null) {
			jteOutput.writeContent("\n    <meta name=\"csrf-token\"");
			var __jte_html_attribute_0 = _csrf.getToken();
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_0)) {
				jteOutput.writeContent(" content=\"");
				jteOutput.setContext("meta", "content");
				jteOutput.writeUserContent(__jte_html_attribute_0);
				jteOutput.setContext("meta", null);
				jteOutput.writeContent("\"");
			}
			jteOutput.writeContent(">\n    <meta name=\"csrf-header\"");
			var __jte_html_attribute_1 = _csrf.getHeaderName();
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_1)) {
				jteOutput.writeContent(" content=\"");
				jteOutput.setContext("meta", "content");
				jteOutput.writeUserContent(__jte_html_attribute_1);
				jteOutput.setContext("meta", null);
				jteOutput.writeContent("\"");
			}
			jteOutput.writeContent(">\n    <meta name=\"csrf-param\"");
			var __jte_html_attribute_2 = _csrf.getParameterName();
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_2)) {
				jteOutput.writeContent(" content=\"");
				jteOutput.setContext("meta", "content");
				jteOutput.writeUserContent(__jte_html_attribute_2);
				jteOutput.setContext("meta", null);
				jteOutput.writeContent("\"");
			}
			jteOutput.writeContent(">\n    ");
		}
		jteOutput.writeContent("\n\n    <link rel=\"stylesheet\" href=\"/css/theme.css\">\n    <script src=\"https://unpkg.com/htmx.org@1.9.10\"></script>\n    <script src=\"/js/chart-theme-adapter.js\"></script>\n    <script>\n        ");
		jteOutput.writeContent("\n        document.addEventListener('DOMContentLoaded', function() {\n            var csrfToken = document.querySelector('meta[name=\"csrf-token\"]');\n            var csrfHeader = document.querySelector('meta[name=\"csrf-header\"]');\n            if (csrfToken && csrfHeader) {\n                document.body.addEventListener('htmx:configRequest', function(event) {\n                    event.detail.headers[csrfHeader.content] = csrfToken.content;\n                });\n            }\n        });\n    </script>\n</head>\n<body>\n    <div class=\"app-layout\">\n        ");
		jteOutput.writeContent("\n        ");
		gg.jte.generated.ondemand.components.JteheaderGenerated.render(jteOutput, jteHtmlInterceptor, username, _csrf);
		jteOutput.writeContent("\n\n        ");
		jteOutput.writeContent("\n        <div class=\"content-wrapper\">\n            ");
		jteOutput.writeContent("\n            ");
		gg.jte.generated.ondemand.components.JtesidebarGenerated.render(jteOutput, jteHtmlInterceptor, currentPage);
		jteOutput.writeContent("\n\n            ");
		jteOutput.writeContent("\n            <main class=\"main-content\" id=\"mainWrapper\">\n                ");
		jteOutput.setContext("main", null);
		jteOutput.writeUserContent(content);
		jteOutput.writeContent("\n            </main>\n        </div>\n    </div>\n\n    ");
		jteOutput.writeContent("\n    ");
		if (_csrf != null) {
			jteOutput.writeContent("\n        <form method=\"post\" action=\"/logout\" id=\"logoutForm\" style=\"display: none;\">\n            <input type=\"hidden\"");
			var __jte_html_attribute_3 = _csrf.getParameterName();
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_3)) {
				jteOutput.writeContent(" name=\"");
				jteOutput.setContext("input", "name");
				jteOutput.writeUserContent(__jte_html_attribute_3);
				jteOutput.setContext("input", null);
				jteOutput.writeContent("\"");
			}
			var __jte_html_attribute_4 = _csrf.getToken();
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_4)) {
				jteOutput.writeContent(" value=\"");
				jteOutput.setContext("input", "value");
				jteOutput.writeUserContent(__jte_html_attribute_4);
				jteOutput.setContext("input", null);
				jteOutput.writeContent("\"");
			}
			jteOutput.writeContent(">\n        </form>\n    ");
		} else {
			jteOutput.writeContent("\n        ");
			jteOutput.writeContent("\n        <div id=\"logoutForm\" data-no-csrf=\"true\" style=\"display: none;\"></div>\n    ");
		}
		jteOutput.writeContent("\n\n    <script>\n        ");
		jteOutput.writeContent("\n        (function() {\n            const savedTheme = localStorage.getItem('selectedTheme') || 'light';\n            document.documentElement.setAttribute('data-theme', savedTheme);\n        })();\n\n        ");
		jteOutput.writeContent("\n        function toggleSidebar() {\n            const sidebar = document.getElementById('sidebar');\n\n            ");
		jteOutput.writeContent("\n            if (window.innerWidth <= 768) {\n                sidebar.classList.toggle('open');\n            } else {\n                sidebar.classList.toggle('collapsed');\n                ");
		jteOutput.writeContent("\n                const isCollapsed = sidebar.classList.contains('collapsed');\n                localStorage.setItem('sidebarCollapsed', isCollapsed);\n            }\n        }\n\n        ");
		jteOutput.writeContent("\n        document.addEventListener('DOMContentLoaded', function() {\n            if (window.innerWidth > 768) {\n                const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';\n                if (isCollapsed) {\n                    document.getElementById('sidebar').classList.add('collapsed');\n                }\n            }\n        });\n\n        ");
		jteOutput.writeContent("\n        function toggleUserMenu() {\n            const dropdown = document.getElementById('userDropdown');\n            dropdown.classList.toggle('show');\n        }\n\n        ");
		jteOutput.writeContent("\n        document.addEventListener('click', function(event) {\n            const userMenu = document.querySelector('.user-menu-wrapper');\n            const dropdown = document.getElementById('userDropdown');\n\n            if (userMenu && !userMenu.contains(event.target)) {\n                dropdown.classList.remove('show');\n            }\n        });\n\n        ");
		jteOutput.writeContent("\n        function performLogout() {\n            const formElement = document.getElementById('logoutForm');\n\n            ");
		jteOutput.writeContent("\n            if (formElement.hasAttribute('data-no-csrf')) {\n                console.error('CSRF token not available! Cannot logout securely.');\n                alert('Fehler: CSRF Token nicht verfügbar. Bitte Seite neu laden und erneut versuchen.');\n                return;\n            }\n\n            console.log('=== LOGOUT DEBUG ===');\n            console.log('Form element:', formElement);\n            console.log('Form action:', formElement.action);\n            console.log('Form method:', formElement.method);\n\n            ");
		jteOutput.writeContent("\n            const csrfInputs = formElement.querySelectorAll('input[type=\"hidden\"]');\n            console.log('Hidden inputs found:', csrfInputs.length);\n\n            csrfInputs.forEach(function(input, index) {\n                var displayValue = input.value ? input.value.substring(0, 10) + '...' : '(empty)';\n                console.log('Input ' + index + ': name=\"' + input.name + '\", value=\"' + displayValue + '\"');\n            });\n\n            ");
		jteOutput.writeContent("\n            formElement.submit();\n        }\n    </script>\n</body>\n</html>\n");
	}
	public static void renderMap(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, java.util.Map<String, Object> params) {
		String title = (String)params.getOrDefault("title", "JEVis 4");
		String username = (String)params.get("username");
		String currentPage = (String)params.getOrDefault("currentPage", "");
		Content content = (Content)params.get("content");
		CsrfToken _csrf = (CsrfToken)params.getOrDefault("_csrf", null);
		render(jteOutput, jteHtmlInterceptor, title, username, currentPage, content, _csrf);
	}
}
