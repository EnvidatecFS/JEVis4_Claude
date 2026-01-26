package gg.jte.generated.ondemand.components;
import org.springframework.security.web.csrf.CsrfToken;
public final class JteheaderGenerated {
	public static final String JTE_NAME = "components/header.jte";
	public static final int[] JTE_LINE_INFO = {0,0,2,2,2,7,7,14,22,24,31,39,47,51,51,51,54,54,54,62,73,73,74,74,74,74,74,74,74,74,74,74,74,74,74,74,74,74,74,75,75,87,87,87,2,3,3,3,3};
	public static void render(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, String username, CsrfToken _csrf) {
		jteOutput.writeContent("\n<header class=\"app-header\">\n    <div class=\"header-left\">\n        ");
		jteOutput.writeContent("\n        <button class=\"header-toggle\" onclick=\"toggleMobileSidebar()\" title=\"Navigation öffnen\">\n            <svg width=\"24\" height=\"24\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M4 6h16M4 12h16M4 18h16\"/>\n            </svg>\n        </button>\n\n        ");
		jteOutput.writeContent("\n        <div class=\"header-logo\">\n            <img src=\"/images/JEVis4_logo.png\" alt=\"JEVis 4 Logo\" style=\"width: 24px; height: 24px; margin-right: 8px;\">\n            <span>JEVis 4</span>\n        </div>\n    </div>\n\n    <div class=\"header-right\">\n        ");
		jteOutput.writeContent("\n        <div class=\"header-actions\">\n            ");
		jteOutput.writeContent("\n            <button class=\"icon-button\" title=\"Suche\">\n                <svg width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                    <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z\"/>\n                </svg>\n            </button>\n\n            ");
		jteOutput.writeContent("\n            <button class=\"icon-button\" title=\"Benachrichtigungen\">\n                <svg width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                    <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9\"/>\n                </svg>\n                <span class=\"badge\">3</span>\n            </button>\n\n            ");
		jteOutput.writeContent("\n            <button class=\"icon-button\" title=\"Hilfe\">\n                <svg width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                    <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z\"/>\n                </svg>\n            </button>\n        </div>\n\n        ");
		jteOutput.writeContent("\n        <div class=\"user-menu-wrapper\">\n            <div class=\"user-menu\" onclick=\"toggleUserMenu()\">\n                <div class=\"user-avatar\">\n                    ");
		jteOutput.setContext("div", null);
		jteOutput.writeUserContent(username.substring(0, 1).toUpperCase());
		jteOutput.writeContent("\n                </div>\n                <div class=\"user-info\">\n                    <div class=\"user-name\">");
		jteOutput.setContext("div", null);
		jteOutput.writeUserContent(username);
		jteOutput.writeContent("</div>\n                    <div class=\"user-role\">Administrator</div>\n                </div>\n                <svg width=\"16\" height=\"16\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\" style=\"color: var(--text-secondary);\">\n                    <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M19 9l-7 7-7-7\"/>\n                </svg>\n            </div>\n\n            ");
		jteOutput.writeContent("\n            <div class=\"user-dropdown\" id=\"userDropdown\">\n                <a href=\"/settings\" class=\"dropdown-item\">\n                    <svg width=\"18\" height=\"18\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z\"/>\n                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M15 12a3 3 0 11-6 0 3 3 0 016 0z\"/>\n                    </svg>\n                    <span>Einstellungen</span>\n                </a>\n                <div class=\"dropdown-divider\"></div>\n                <form method=\"post\" action=\"/logout\" style=\"margin: 0;\">\n                    ");
		if (_csrf != null) {
			jteOutput.writeContent("\n                        <input type=\"hidden\"");
			var __jte_html_attribute_0 = _csrf.getParameterName();
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_0)) {
				jteOutput.writeContent(" name=\"");
				jteOutput.setContext("input", "name");
				jteOutput.writeUserContent(__jte_html_attribute_0);
				jteOutput.setContext("input", null);
				jteOutput.writeContent("\"");
			}
			var __jte_html_attribute_1 = _csrf.getToken();
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_1)) {
				jteOutput.writeContent(" value=\"");
				jteOutput.setContext("input", "value");
				jteOutput.writeUserContent(__jte_html_attribute_1);
				jteOutput.setContext("input", null);
				jteOutput.writeContent("\"");
			}
			jteOutput.writeContent(">\n                    ");
		}
		jteOutput.writeContent("\n                    <button type=\"submit\" class=\"dropdown-item\" style=\"width: 100%; text-align: left; background: none; border: none; cursor: pointer; font-size: inherit; font-family: inherit; padding: var(--spacing-md); display: flex; align-items: center; gap: var(--spacing-md);\">\n                        <svg width=\"18\" height=\"18\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                            <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1\"/>\n                        </svg>\n                        <span>Abmelden</span>\n                    </button>\n                </form>\n            </div>\n        </div>\n    </div>\n</header>\n");
	}
	public static void renderMap(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, java.util.Map<String, Object> params) {
		String username = (String)params.get("username");
		CsrfToken _csrf = (CsrfToken)params.getOrDefault("_csrf", null);
		render(jteOutput, jteHtmlInterceptor, username, _csrf);
	}
}
