package gg.jte.generated.ondemand.pages;
import org.jevis.model.Sensor;
import java.util.List;
public final class JtesensorcreateformGenerated {
	public static final String JTE_NAME = "pages/sensor-create-form.jte";
	public static final int[] JTE_LINE_INFO = {0,0,1,3,3,3,15,15,15,16,16,18,18,18,26,26,27,27,27,28,28,29,29,31,31,41,41,41,41,41,41,41,41,41,49,49,49,49,49,49,49,49,49,58,58,58,58,58,58,58,58,58,69,69,70,70,70,70,70,70,70,70,70,71,71,77,77,77,77,77,77,77,77,77,99,99,99,99,99,99,99,99,99,115,115,115,115,115,115,115,115,115,121,121,121,121,121,121,121,121,121,129,129,129,146,146,223,227,234,234,234,3,4,5,6,6,6,6};
	public static void render(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, Sensor sensor, List<String> measurementTypes, Boolean success, String message) {
		jteOutput.writeContent("\n<div class=\"modal-backdrop\" onclick=\"closeModal()\"></div>\n<div class=\"modal\">\n    <div class=\"modal-header\">\n        <h3>Neuer Messpunkt</h3>\n        <button class=\"modal-close\" onclick=\"closeModal()\">&times;</button>\n    </div>\n\n    ");
		if (success != null) {
			jteOutput.writeContent("\n        ");
			if (success) {
				jteOutput.writeContent("\n            <div class=\"alert alert-success\">\n                ");
				jteOutput.setContext("div", null);
				jteOutput.writeUserContent(message);
				jteOutput.writeContent("\n                <script>\n                    setTimeout(function() {\n                        closeModal();\n                        htmx.ajax('GET', '/sensors/table', '#sensors-table-container');\n                    }, 1500);\n                </script>\n            </div>\n        ");
			} else {
				jteOutput.writeContent("\n            <div class=\"alert alert-danger\">");
				jteOutput.setContext("div", null);
				jteOutput.writeUserContent(message);
				jteOutput.writeContent("</div>\n        ");
			}
			jteOutput.writeContent("\n    ");
		}
		jteOutput.writeContent("\n\n    ");
		if (success == null || !success) {
			jteOutput.writeContent("\n    <form hx-post=\"/sensors\"\n          hx-target=\"#modal-container\"\n          hx-swap=\"innerHTML\">\n\n        <div class=\"modal-body\">\n            <div class=\"form-row\">\n                <div class=\"form-group\">\n                    <label for=\"sensorCode\">Sensor-Code *</label>\n                    <input type=\"text\" id=\"sensorCode\" name=\"sensorCode\"\n                          ");
			var __jte_html_attribute_0 = sensor.getSensorCode() != null ? sensor.getSensorCode() : "";
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_0)) {
				jteOutput.writeContent(" value=\"");
				jteOutput.setContext("input", "value");
				jteOutput.writeUserContent(__jte_html_attribute_0);
				jteOutput.setContext("input", null);
				jteOutput.writeContent("\"");
			}
			jteOutput.writeContent("\n                           required\n                           placeholder=\"z.B. PV_INV_001\">\n                    <span class=\"form-help\">Eindeutiger Identifikator für den Sensor</span>\n                </div>\n                <div class=\"form-group\">\n                    <label for=\"sensorName\">Name</label>\n                    <input type=\"text\" id=\"sensorName\" name=\"sensorName\"\n                          ");
			var __jte_html_attribute_1 = sensor.getSensorName() != null ? sensor.getSensorName() : "";
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_1)) {
				jteOutput.writeContent(" value=\"");
				jteOutput.setContext("input", "value");
				jteOutput.writeUserContent(__jte_html_attribute_1);
				jteOutput.setContext("input", null);
				jteOutput.writeContent("\"");
			}
			jteOutput.writeContent("\n                           placeholder=\"z.B. Wechselrichter Dach Ost\">\n                </div>\n            </div>\n\n            <div class=\"form-row\">\n                <div class=\"form-group\">\n                    <label for=\"measurementType\">Messtyp *</label>\n                    <input type=\"text\" id=\"measurementType\" name=\"measurementType\"\n                          ");
			var __jte_html_attribute_2 = sensor.getMeasurementType() != null ? sensor.getMeasurementType() : "";
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_2)) {
				jteOutput.writeContent(" value=\"");
				jteOutput.setContext("input", "value");
				jteOutput.writeUserContent(__jte_html_attribute_2);
				jteOutput.setContext("input", null);
				jteOutput.writeContent("\"");
			}
			jteOutput.writeContent("\n                           required\n                           list=\"measurementTypeList\"\n                           placeholder=\"z.B. power, voltage, temperature\">\n                    <datalist id=\"measurementTypeList\">\n                        <option value=\"power\"></option>\n                        <option value=\"voltage\"></option>\n                        <option value=\"current\"></option>\n                        <option value=\"temperature\"></option>\n                        <option value=\"irradiance\"></option>\n                        <option value=\"energy\"></option>\n                        ");
			for (String mt : measurementTypes) {
				jteOutput.writeContent("\n                            <option");
				var __jte_html_attribute_3 = mt;
				if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_3)) {
					jteOutput.writeContent(" value=\"");
					jteOutput.setContext("option", "value");
					jteOutput.writeUserContent(__jte_html_attribute_3);
					jteOutput.setContext("option", null);
					jteOutput.writeContent("\"");
				}
				jteOutput.writeContent("></option>\n                        ");
			}
			jteOutput.writeContent("\n                    </datalist>\n                </div>\n                <div class=\"form-group\">\n                    <label for=\"unit\">Einheit *</label>\n                    <input type=\"text\" id=\"unit\" name=\"unit\"\n                          ");
			var __jte_html_attribute_4 = sensor.getUnit() != null ? sensor.getUnit() : "";
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_4)) {
				jteOutput.writeContent(" value=\"");
				jteOutput.setContext("input", "value");
				jteOutput.writeUserContent(__jte_html_attribute_4);
				jteOutput.setContext("input", null);
				jteOutput.writeContent("\"");
			}
			jteOutput.writeContent("\n                           required\n                           list=\"unitList\"\n                           placeholder=\"z.B. kW, V, °C\">\n                    <datalist id=\"unitList\">\n                        <option value=\"kW\"></option>\n                        <option value=\"W\"></option>\n                        <option value=\"kWh\"></option>\n                        <option value=\"Wh\"></option>\n                        <option value=\"V\"></option>\n                        <option value=\"A\"></option>\n                        <option value=\"°C\"></option>\n                        <option value=\"W/m²\"></option>\n                        <option value=\"%\"></option>\n                    </datalist>\n                </div>\n            </div>\n\n            <div class=\"form-row\">\n                <div class=\"form-group\">\n                    <label for=\"location\">Standort</label>\n                    <input type=\"text\" id=\"location\" name=\"location\"\n                          ");
			var __jte_html_attribute_5 = sensor.getLocation() != null ? sensor.getLocation() : "";
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_5)) {
				jteOutput.writeContent(" value=\"");
				jteOutput.setContext("input", "value");
				jteOutput.writeUserContent(__jte_html_attribute_5);
				jteOutput.setContext("input", null);
				jteOutput.writeContent("\"");
			}
			jteOutput.writeContent("\n                           placeholder=\"z.B. Gebäude A, Dach\">\n                </div>\n                <div class=\"form-group\">\n                    <label for=\"isActive\">Status</label>\n                    <select id=\"isActive\" name=\"isActive\">\n                        <option value=\"true\" selected>Aktiv</option>\n                        <option value=\"false\">Inaktiv</option>\n                    </select>\n                </div>\n            </div>\n\n            <div class=\"form-row\">\n                <div class=\"form-group\">\n                    <label for=\"manufacturer\">Hersteller</label>\n                    <input type=\"text\" id=\"manufacturer\" name=\"manufacturer\"\n                          ");
			var __jte_html_attribute_6 = sensor.getManufacturer() != null ? sensor.getManufacturer() : "";
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_6)) {
				jteOutput.writeContent(" value=\"");
				jteOutput.setContext("input", "value");
				jteOutput.writeUserContent(__jte_html_attribute_6);
				jteOutput.setContext("input", null);
				jteOutput.writeContent("\"");
			}
			jteOutput.writeContent("\n                           placeholder=\"z.B. SMA, Fronius\">\n                </div>\n                <div class=\"form-group\">\n                    <label for=\"model\">Modell</label>\n                    <input type=\"text\" id=\"model\" name=\"model\"\n                          ");
			var __jte_html_attribute_7 = sensor.getModel() != null ? sensor.getModel() : "";
			if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_7)) {
				jteOutput.writeContent(" value=\"");
				jteOutput.setContext("input", "value");
				jteOutput.writeUserContent(__jte_html_attribute_7);
				jteOutput.setContext("input", null);
				jteOutput.writeContent("\"");
			}
			jteOutput.writeContent("\n                           placeholder=\"z.B. Sunny Boy 5.0\">\n                </div>\n            </div>\n\n            <div class=\"form-group\">\n                <label for=\"description\">Beschreibung</label>\n                <textarea id=\"description\" name=\"description\" rows=\"3\"\n                          placeholder=\"Optionale Beschreibung des Messpunkts...\">");
			jteOutput.setContext("textarea", null);
			jteOutput.writeUserContent(sensor.getDescription() != null ? sensor.getDescription() : "");
			jteOutput.writeContent("</textarea>\n            </div>\n\n            <div class=\"form-row\">\n                <div class=\"form-group\">\n                    <label for=\"calibrationDate\">Kalibrierdatum</label>\n                    <input type=\"date\" id=\"calibrationDate\" name=\"calibrationDate\"\n                           value=\"\">\n                </div>\n            </div>\n        </div>\n\n        <div class=\"modal-footer\">\n            <button type=\"button\" class=\"btn btn-outline\" onclick=\"closeModal()\">Abbrechen</button>\n            <button type=\"submit\" class=\"btn btn-primary\">Erstellen</button>\n        </div>\n    </form>\n    ");
		}
		jteOutput.writeContent("\n</div>\n\n<style>\n    .modal-backdrop {\n        position: fixed;\n        top: 0;\n        left: 0;\n        right: 0;\n        bottom: 0;\n        background-color: rgba(0, 0, 0, 0.5);\n        z-index: 1000;\n    }\n    .modal {\n        position: fixed;\n        top: 50%;\n        left: 50%;\n        transform: translate(-50%, -50%);\n        background: var(--surface);\n        border-radius: var(--radius-xl);\n        box-shadow: var(--shadow-lg);\n        width: 90%;\n        max-width: 600px;\n        max-height: 90vh;\n        overflow-y: auto;\n        z-index: 1001;\n    }\n    .modal-header {\n        display: flex;\n        justify-content: space-between;\n        align-items: center;\n        padding: var(--spacing-lg);\n        border-bottom: 1px solid var(--border-color);\n    }\n    .modal-header h3 {\n        margin: 0;\n    }\n    .modal-close {\n        background: none;\n        border: none;\n        font-size: 1.5rem;\n        cursor: pointer;\n        color: var(--text-secondary);\n        padding: var(--spacing-sm);\n        line-height: 1;\n    }\n    .modal-close:hover {\n        color: var(--text-primary);\n    }\n    .modal-body {\n        padding: var(--spacing-lg);\n    }\n    .modal-footer {\n        display: flex;\n        justify-content: flex-end;\n        gap: var(--spacing-md);\n        padding: var(--spacing-lg);\n        border-top: 1px solid var(--border-color);\n    }\n    .form-row {\n        display: flex;\n        gap: var(--spacing-lg);\n    }\n    .form-row .form-group {\n        flex: 1;\n    }\n    @media (max-width: 600px) {\n        .form-row {\n            flex-direction: column;\n            gap: 0;\n        }\n    }\n</style>\n\n<script>\n    function closeModal() {\n        document.getElementById('modal-container').innerHTML = '';\n        ");
		jteOutput.writeContent("\n        htmx.ajax('GET', '/sensors/table', '#sensors-table-container');\n    }\n\n    ");
		jteOutput.writeContent("\n    document.addEventListener('keydown', function(e) {\n        if (e.key === 'Escape') {\n            closeModal();\n        }\n    });\n</script>\n");
	}
	public static void renderMap(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, java.util.Map<String, Object> params) {
		Sensor sensor = (Sensor)params.getOrDefault("sensor", new Sensor());
		List<String> measurementTypes = (List<String>)params.getOrDefault("measurementTypes", java.util.Collections.emptyList());
		Boolean success = (Boolean)params.getOrDefault("success", null);
		String message = (String)params.getOrDefault("message", null);
		render(jteOutput, jteHtmlInterceptor, sensor, measurementTypes, success, message);
	}
}
