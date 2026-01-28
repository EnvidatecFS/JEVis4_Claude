package gg.jte.generated.ondemand.pages;
import org.jevis.model.Sensor;
import java.util.List;
import java.time.format.DateTimeFormatter;
public final class JtesensorstableGenerated {
	public static final String JTE_NAME = "pages/sensors-table.jte";
	public static final int[] JTE_LINE_INFO = {0,0,1,2,4,4,4,15,15,15,17,22,22,22,24,24,25,25,25,25,25,25,25,25,25,26,26,33,33,33,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,44,44,45,45,45,46,46,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,52,52,53,53,53,54,54,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,60,60,61,61,61,62,62,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,70,70,71,71,71,72,72,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,78,78,79,79,79,80,80,86,86,95,95,97,97,100,100,101,101,102,102,102,102,103,103,103,104,104,104,105,105,105,106,106,106,107,107,107,109,109,111,111,113,113,115,115,115,118,118,118,118,126,126,126,126,127,127,127,127,136,136,137,137,142,143,143,146,146,146,146,146,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,151,151,151,151,151,151,153,153,153,153,153,154,154,154,154,154,154,154,154,154,154,154,154,154,154,154,154,154,154,154,154,154,154,154,154,159,159,297,297,297,4,5,6,7,8,9,10,11,12,13,13,13,13};
	public static void render(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, List<Sensor> sensors, int currentPage, int totalPages, long totalElements, String search, String type, String status, String sortBy, String sortDir, List<String> measurementTypes) {
		jteOutput.writeContent("\n");
		var formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm").withZone(java.time.ZoneId.systemDefault());
		jteOutput.writeContent("\n\n");
		jteOutput.writeContent("\n<script>\n    (function() {\n        var typeSelect = document.getElementById('type');\n        if (typeSelect) {\n            var currentValue = '");
		jteOutput.setContext("script", null);
		jteOutput.writeUserContent(type);
		jteOutput.writeContent("';\n            typeSelect.innerHTML = '<option value=\"\">Alle Typen</option>';\n            ");
		for (String mt : measurementTypes) {
			jteOutput.writeContent("\n                typeSelect.innerHTML += '<option value=\"");
			jteOutput.setContext("script", null);
			jteOutput.writeUserContent(mt);
			jteOutput.writeContent("\" ");
			jteOutput.setContext("script", null);
			jteOutput.writeUserContent(type.equals(mt) ? "selected" : "");
			jteOutput.writeContent(">");
			jteOutput.setContext("script", null);
			jteOutput.writeUserContent(mt);
			jteOutput.writeContent("</option>';\n            ");
		}
		jteOutput.writeContent("\n            typeSelect.value = currentValue;\n        }\n    })();\n</script>\n\n<div class=\"table-header\">\n    <span class=\"table-info\">");
		jteOutput.setContext("span", null);
		jteOutput.writeUserContent(totalElements);
		jteOutput.writeContent(" Messpunkte gefunden</span>\n</div>\n\n<div class=\"table-responsive\">\n    <table class=\"data-table\">\n        <thead>\n            <tr>\n                <th class=\"sortable\"\n                    hx-get=\"/sensors/table?sortBy=sensorCode&sortDir=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(sortBy.equals("sensorCode") && sortDir.equals("asc") ? "desc" : "asc");
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&search=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(search);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&type=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(type);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&status=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(status);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("\"\n                    hx-target=\"#sensors-table-container\">\n                    Code\n                    ");
		if (sortBy.equals("sensorCode")) {
			jteOutput.writeContent("\n                        <span class=\"sort-icon\">");
			jteOutput.setContext("span", null);
			jteOutput.writeUserContent(sortDir.equals("asc") ? "^" : "v");
			jteOutput.writeContent("</span>\n                    ");
		}
		jteOutput.writeContent("\n                </th>\n                <th class=\"sortable\"\n                    hx-get=\"/sensors/table?sortBy=sensorName&sortDir=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(sortBy.equals("sensorName") && sortDir.equals("asc") ? "desc" : "asc");
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&search=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(search);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&type=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(type);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&status=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(status);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("\"\n                    hx-target=\"#sensors-table-container\">\n                    Name\n                    ");
		if (sortBy.equals("sensorName")) {
			jteOutput.writeContent("\n                        <span class=\"sort-icon\">");
			jteOutput.setContext("span", null);
			jteOutput.writeUserContent(sortDir.equals("asc") ? "^" : "v");
			jteOutput.writeContent("</span>\n                    ");
		}
		jteOutput.writeContent("\n                </th>\n                <th class=\"sortable\"\n                    hx-get=\"/sensors/table?sortBy=measurementType&sortDir=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(sortBy.equals("measurementType") && sortDir.equals("asc") ? "desc" : "asc");
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&search=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(search);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&type=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(type);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&status=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(status);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("\"\n                    hx-target=\"#sensors-table-container\">\n                    Typ\n                    ");
		if (sortBy.equals("measurementType")) {
			jteOutput.writeContent("\n                        <span class=\"sort-icon\">");
			jteOutput.setContext("span", null);
			jteOutput.writeUserContent(sortDir.equals("asc") ? "^" : "v");
			jteOutput.writeContent("</span>\n                    ");
		}
		jteOutput.writeContent("\n                </th>\n                <th>Einheit</th>\n                <th>Standort</th>\n                <th class=\"sortable\"\n                    hx-get=\"/sensors/table?sortBy=isActive&sortDir=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(sortBy.equals("isActive") && sortDir.equals("asc") ? "desc" : "asc");
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&search=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(search);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&type=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(type);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&status=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(status);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("\"\n                    hx-target=\"#sensors-table-container\">\n                    Status\n                    ");
		if (sortBy.equals("isActive")) {
			jteOutput.writeContent("\n                        <span class=\"sort-icon\">");
			jteOutput.setContext("span", null);
			jteOutput.writeUserContent(sortDir.equals("asc") ? "^" : "v");
			jteOutput.writeContent("</span>\n                    ");
		}
		jteOutput.writeContent("\n                </th>\n                <th class=\"sortable\"\n                    hx-get=\"/sensors/table?sortBy=createdAt&sortDir=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(sortBy.equals("createdAt") && sortDir.equals("asc") ? "desc" : "asc");
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&search=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(search);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&type=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(type);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&status=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(status);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("\"\n                    hx-target=\"#sensors-table-container\">\n                    Erstellt\n                    ");
		if (sortBy.equals("createdAt")) {
			jteOutput.writeContent("\n                        <span class=\"sort-icon\">");
			jteOutput.setContext("span", null);
			jteOutput.writeUserContent(sortDir.equals("asc") ? "^" : "v");
			jteOutput.writeContent("</span>\n                    ");
		}
		jteOutput.writeContent("\n                </th>\n                <th class=\"actions-col\">Aktionen</th>\n            </tr>\n        </thead>\n        <tbody>\n            ");
		if (sensors.isEmpty()) {
			jteOutput.writeContent("\n                <tr>\n                    <td colspan=\"8\" class=\"empty-state\">\n                        <div class=\"empty-icon\">\n                            <svg width=\"48\" height=\"48\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                                <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"1.5\" d=\"M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z\"/>\n                            </svg>\n                        </div>\n                        <p>Keine Messpunkte gefunden</p>\n                        ");
			if (!search.isEmpty() || !type.isEmpty() || !status.isEmpty()) {
				jteOutput.writeContent("\n                            <p class=\"text-muted\">Versuchen Sie, die Filter anzupassen</p>\n                        ");
			}
			jteOutput.writeContent("\n                    </td>\n                </tr>\n            ");
		} else {
			jteOutput.writeContent("\n                ");
			for (Sensor sensor : sensors) {
				jteOutput.writeContent("\n                    <tr id=\"sensor-row-");
				jteOutput.setContext("tr", "id");
				jteOutput.writeUserContent(sensor.getId());
				jteOutput.setContext("tr", null);
				jteOutput.writeContent("\">\n                        <td><code class=\"sensor-code\">");
				jteOutput.setContext("code", null);
				jteOutput.writeUserContent(sensor.getSensorCode());
				jteOutput.writeContent("</code></td>\n                        <td>");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(sensor.getSensorName() != null ? sensor.getSensorName() : "-");
				jteOutput.writeContent("</td>\n                        <td><span class=\"badge badge-type\">");
				jteOutput.setContext("span", null);
				jteOutput.writeUserContent(sensor.getMeasurementType());
				jteOutput.writeContent("</span></td>\n                        <td>");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(sensor.getUnit());
				jteOutput.writeContent("</td>\n                        <td>");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(sensor.getLocation() != null ? sensor.getLocation() : "-");
				jteOutput.writeContent("</td>\n                        <td>\n                            ");
				if (sensor.getIsActive()) {
					jteOutput.writeContent("\n                                <span class=\"status-badge status-active\">Aktiv</span>\n                            ");
				} else {
					jteOutput.writeContent("\n                                <span class=\"status-badge status-inactive\">Inaktiv</span>\n                            ");
				}
				jteOutput.writeContent("\n                        </td>\n                        <td class=\"date-cell\">");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(sensor.getCreatedAt() != null ? formatter.format(sensor.getCreatedAt()) : "-");
				jteOutput.writeContent("</td>\n                        <td class=\"actions-cell\">\n                            <button class=\"btn-icon\" title=\"Bearbeiten\"\n                                    hx-get=\"/sensors/");
				jteOutput.setContext("button", "hx-get");
				jteOutput.writeUserContent(sensor.getId());
				jteOutput.setContext("button", null);
				jteOutput.writeContent("/edit\"\n                                    hx-target=\"#modal-container\"\n                                    hx-swap=\"innerHTML\">\n                                <svg width=\"16\" height=\"16\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                                    <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z\"/>\n                                </svg>\n                            </button>\n                            <button class=\"btn-icon btn-icon-danger\" title=\"Löschen\"\n                                    hx-delete=\"/sensors/");
				jteOutput.setContext("button", "hx-delete");
				jteOutput.writeUserContent(sensor.getId());
				jteOutput.setContext("button", null);
				jteOutput.writeContent("\"\n                                    hx-target=\"#sensor-row-");
				jteOutput.setContext("button", "hx-target");
				jteOutput.writeUserContent(sensor.getId());
				jteOutput.setContext("button", null);
				jteOutput.writeContent("\"\n                                    hx-swap=\"outerHTML\"\n                                    hx-confirm=\"Möchten Sie diesen Messpunkt wirklich löschen? Alle zugehörigen Messdaten werden ebenfalls gelöscht!\">\n                                <svg width=\"16\" height=\"16\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\n                                    <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16\"/>\n                                </svg>\n                            </button>\n                        </td>\n                    </tr>\n                ");
			}
			jteOutput.writeContent("\n            ");
		}
		jteOutput.writeContent("\n        </tbody>\n    </table>\n</div>\n\n");
		jteOutput.writeContent("\n");
		if (totalPages > 1) {
			jteOutput.writeContent("\n    <div class=\"pagination\">\n        <button class=\"btn btn-outline btn-sm\"\n               ");
			var __jte_html_attribute_0 = currentPage == 0;
			if (__jte_html_attribute_0) {
			jteOutput.writeContent(" disabled");
			}
			jteOutput.writeContent("\n                hx-get=\"/sensors/table?page=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(currentPage - 1);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&search=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(search);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&type=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(type);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&status=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(status);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&sortBy=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(sortBy);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&sortDir=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(sortDir);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("\"\n                hx-target=\"#sensors-table-container\">\n            Zurück\n        </button>\n        <span class=\"pagination-info\">Seite ");
			jteOutput.setContext("span", null);
			jteOutput.writeUserContent(currentPage + 1);
			jteOutput.writeContent(" von ");
			jteOutput.setContext("span", null);
			jteOutput.writeUserContent(totalPages);
			jteOutput.writeContent("</span>\n        <button class=\"btn btn-outline btn-sm\"\n               ");
			var __jte_html_attribute_1 = currentPage >= totalPages - 1;
			if (__jte_html_attribute_1) {
			jteOutput.writeContent(" disabled");
			}
			jteOutput.writeContent("\n                hx-get=\"/sensors/table?page=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(currentPage + 1);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&search=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(search);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&type=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(type);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&status=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(status);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&sortBy=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(sortBy);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&sortDir=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(sortDir);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("\"\n                hx-target=\"#sensors-table-container\">\n            Weiter\n        </button>\n    </div>\n");
		}
		jteOutput.writeContent("\n\n<style>\n    .table-header {\n        display: flex;\n        justify-content: space-between;\n        align-items: center;\n        margin-bottom: var(--spacing-md);\n    }\n    .table-info {\n        color: var(--text-secondary);\n        font-size: var(--font-size-sm);\n    }\n    .table-responsive {\n        overflow-x: auto;\n    }\n    .data-table {\n        width: 100%;\n        border-collapse: collapse;\n        font-size: var(--font-size-sm);\n    }\n    .data-table th,\n    .data-table td {\n        padding: var(--spacing-md);\n        text-align: left;\n        border-bottom: 1px solid var(--border-color);\n    }\n    .data-table th {\n        background-color: var(--background);\n        font-weight: 600;\n        color: var(--text-secondary);\n        font-size: 0.75rem;\n        text-transform: uppercase;\n        letter-spacing: 0.05em;\n    }\n    .data-table th.sortable {\n        cursor: pointer;\n        user-select: none;\n    }\n    .data-table th.sortable:hover {\n        background-color: var(--border-color);\n    }\n    .sort-icon {\n        margin-left: var(--spacing-sm);\n        font-size: 0.7rem;\n    }\n    .data-table tbody tr:hover {\n        background-color: var(--background);\n    }\n    .sensor-code {\n        background-color: var(--background);\n        padding: 2px 6px;\n        border-radius: var(--radius-sm);\n        font-family: monospace;\n        font-size: 0.85rem;\n    }\n    .badge {\n        display: inline-block;\n        padding: 2px 8px;\n        border-radius: var(--radius-sm);\n        font-size: 0.75rem;\n        font-weight: 500;\n    }\n    .badge-type {\n        background-color: #dbeafe;\n        color: #1e40af;\n    }\n    .status-badge {\n        display: inline-block;\n        padding: 4px 10px;\n        border-radius: var(--radius-lg);\n        font-size: 0.75rem;\n        font-weight: 500;\n    }\n    .status-active {\n        background-color: #d1fae5;\n        color: #065f46;\n    }\n    .status-inactive {\n        background-color: #fee2e2;\n        color: #991b1b;\n    }\n    .date-cell {\n        white-space: nowrap;\n        color: var(--text-secondary);\n    }\n    .actions-col {\n        width: 100px;\n        text-align: center;\n    }\n    .actions-cell {\n        text-align: center;\n        white-space: nowrap;\n    }\n    .btn-icon {\n        background: none;\n        border: none;\n        cursor: pointer;\n        padding: var(--spacing-sm);\n        color: var(--text-secondary);\n        border-radius: var(--radius-md);\n        transition: all 0.2s;\n    }\n    .btn-icon:hover {\n        background-color: var(--background);\n        color: var(--primary-color);\n    }\n    .btn-icon-danger:hover {\n        background-color: #fee2e2;\n        color: var(--danger-color);\n    }\n    .empty-state {\n        text-align: center;\n        padding: var(--spacing-2xl) !important;\n        color: var(--text-secondary);\n    }\n    .empty-icon {\n        margin-bottom: var(--spacing-md);\n        opacity: 0.5;\n    }\n    .pagination {\n        display: flex;\n        justify-content: center;\n        align-items: center;\n        gap: var(--spacing-md);\n        margin-top: var(--spacing-lg);\n        padding-top: var(--spacing-lg);\n        border-top: 1px solid var(--border-color);\n    }\n    .pagination-info {\n        color: var(--text-secondary);\n        font-size: var(--font-size-sm);\n    }\n    .btn-sm {\n        padding: var(--spacing-sm) var(--spacing-md);\n        font-size: var(--font-size-sm);\n    }\n</style>\n");
	}
	public static void renderMap(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, java.util.Map<String, Object> params) {
		List<Sensor> sensors = (List<Sensor>)params.get("sensors");
		int currentPage = (int)params.get("currentPage");
		int totalPages = (int)params.get("totalPages");
		long totalElements = (long)params.get("totalElements");
		String search = (String)params.getOrDefault("search", "");
		String type = (String)params.getOrDefault("type", "");
		String status = (String)params.getOrDefault("status", "");
		String sortBy = (String)params.getOrDefault("sortBy", "createdAt");
		String sortDir = (String)params.getOrDefault("sortDir", "desc");
		List<String> measurementTypes = (List<String>)params.getOrDefault("measurementTypes", java.util.Collections.emptyList());
		render(jteOutput, jteHtmlInterceptor, sensors, currentPage, totalPages, totalElements, search, type, status, sortBy, sortDir, measurementTypes);
	}
}
