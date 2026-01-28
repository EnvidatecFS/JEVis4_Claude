package gg.jte.generated.ondemand.components;
public final class JtesidebarGenerated {
	public static final String JTE_NAME = "components/sidebar.jte";
	public static final int[] JTE_LINE_INFO = {0,0,0,0,3,3,5,8,8,8,8,16,16,16,16,26,29,29,29,29,37,37,37,37,45,45,45,45,55,58,58,58,58,66,66,66,66,74,74,74,74,84,87,87,87,87,95,95,95,95,108,108,108,0,0,0,0};
	public static void render(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, String currentPage) {
		jteOutput.writeContent("\n<aside class=\"sidebar\" id=\"sidebar\">\n    ");
		jteOutput.writeContent("\n    <nav class=\"sidebar-nav\">\n        ");
		jteOutput.writeContent("\n        <div class=\"nav-section\">\n            <div class=\"nav-section-title\">Hauptmenü</div>\n            <a href=\"/home\" class=\"nav-item ");
		jteOutput.setContext("a", "class");
		jteOutput.writeUserContent(currentPage.equals("home") ? "active" : "");
		jteOutput.setContext("a", null);
		jteOutput.writeContent("\" title=\"Übersicht\">\n                <span class=\"nav-item-icon\">\n                    <svg width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6\"/>\n                    </svg>\n                </span>\n                <span class=\"nav-item-text\">Übersicht</span>\n            </a>\n            <a href=\"/dashboard\" class=\"nav-item ");
		jteOutput.setContext("a", "class");
		jteOutput.writeUserContent(currentPage.equals("dashboard") ? "active" : "");
		jteOutput.setContext("a", null);
		jteOutput.writeContent("\" title=\"Dashboard\">\n                <span class=\"nav-item-icon\">\n                    <svg width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z\"/>\n                    </svg>\n                </span>\n                <span class=\"nav-item-text\">Dashboard</span>\n            </a>\n        </div>\n\n        ");
		jteOutput.writeContent("\n        <div class=\"nav-section\">\n            <div class=\"nav-section-title\">PV Anlagen</div>\n            <a href=\"/plants\" class=\"nav-item ");
		jteOutput.setContext("a", "class");
		jteOutput.writeUserContent(currentPage.equals("plants") ? "active" : "");
		jteOutput.setContext("a", null);
		jteOutput.writeContent("\" title=\"Anlagen\">\n                <span class=\"nav-item-icon\">\n                    <svg width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M13 10V3L4 14h7v7l9-11h-7z\"/>\n                    </svg>\n                </span>\n                <span class=\"nav-item-text\">Anlagen</span>\n            </a>\n            <a href=\"/monitoring\" class=\"nav-item ");
		jteOutput.setContext("a", "class");
		jteOutput.writeUserContent(currentPage.equals("monitoring") ? "active" : "");
		jteOutput.setContext("a", null);
		jteOutput.writeContent("\" title=\"Monitoring\">\n                <span class=\"nav-item-icon\">\n                    <svg width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z\"/>\n                    </svg>\n                </span>\n                <span class=\"nav-item-text\">Monitoring</span>\n            </a>\n            <a href=\"/analytics\" class=\"nav-item ");
		jteOutput.setContext("a", "class");
		jteOutput.writeUserContent(currentPage.equals("analytics") ? "active" : "");
		jteOutput.setContext("a", null);
		jteOutput.writeContent("\" title=\"Auswertungen\">\n                <span class=\"nav-item-icon\">\n                    <svg width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M16 8v8m-4-5v5m-4-2v2m-2 4h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z\"/>\n                    </svg>\n                </span>\n                <span class=\"nav-item-text\">Auswertungen</span>\n            </a>\n        </div>\n\n        ");
		jteOutput.writeContent("\n        <div class=\"nav-section\">\n            <div class=\"nav-section-title\">Datenverwaltung</div>\n            <a href=\"/sensors\" class=\"nav-item ");
		jteOutput.setContext("a", "class");
		jteOutput.writeUserContent(currentPage.equals("sensors") ? "active" : "");
		jteOutput.setContext("a", null);
		jteOutput.writeContent("\" title=\"Messpunkte\">\n                <span class=\"nav-item-icon\">\n                    <svg width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z\"/>\n                    </svg>\n                </span>\n                <span class=\"nav-item-text\">Messpunkte</span>\n            </a>\n            <a href=\"/data\" class=\"nav-item ");
		jteOutput.setContext("a", "class");
		jteOutput.writeUserContent(currentPage.equals("data") ? "active" : "");
		jteOutput.setContext("a", null);
		jteOutput.writeContent("\" title=\"Datenbank\">\n                <span class=\"nav-item-icon\">\n                    <svg width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4\"/>\n                    </svg>\n                </span>\n                <span class=\"nav-item-text\">Datenbank</span>\n            </a>\n            <a href=\"/reports\" class=\"nav-item ");
		jteOutput.setContext("a", "class");
		jteOutput.writeUserContent(currentPage.equals("reports") ? "active" : "");
		jteOutput.setContext("a", null);
		jteOutput.writeContent("\" title=\"Berichte\">\n                <span class=\"nav-item-icon\">\n                    <svg width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z\"/>\n                    </svg>\n                </span>\n                <span class=\"nav-item-text\">Berichte</span>\n            </a>\n        </div>\n\n        ");
		jteOutput.writeContent("\n        <div class=\"nav-section\">\n            <div class=\"nav-section-title\">System</div>\n            <a href=\"/users\" class=\"nav-item ");
		jteOutput.setContext("a", "class");
		jteOutput.writeUserContent(currentPage.equals("users") ? "active" : "");
		jteOutput.setContext("a", null);
		jteOutput.writeContent("\" title=\"Benutzer\">\n                <span class=\"nav-item-icon\">\n                    <svg width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z\"/>\n                    </svg>\n                </span>\n                <span class=\"nav-item-text\">Benutzer</span>\n            </a>\n            <a href=\"/settings\" class=\"nav-item ");
		jteOutput.setContext("a", "class");
		jteOutput.writeUserContent(currentPage.equals("settings") ? "active" : "");
		jteOutput.setContext("a", null);
		jteOutput.writeContent("\" title=\"Einstellungen\">\n                <span class=\"nav-item-icon\">\n                    <svg width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z\"/>\n                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M15 12a3 3 0 11-6 0 3 3 0 016 0z\"/>\n                    </svg>\n                </span>\n                <span class=\"nav-item-text\">Einstellungen</span>\n            </a>\n        </div>\n    </nav>\n\n</aside>\n");
	}
	public static void renderMap(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, java.util.Map<String, Object> params) {
		String currentPage = (String)params.getOrDefault("currentPage", "");
		render(jteOutput, jteHtmlInterceptor, currentPage);
	}
}
