package gg.jte.generated.ondemand.pages;
import org.springframework.security.web.csrf.CsrfToken;
import org.jevis.model.JobStatus;
import org.jevis.model.JobType;
public final class JtejobsGenerated {
	public static final String JTE_NAME = "pages/jobs.jte";
	public static final int[] JTE_LINE_INFO = {0,0,1,2,4,4,4,7,7,13,13,24,43,43,44,44,44,44,44,44,44,44,44,44,44,44,45,45,56,56,57,57,57,57,57,57,57,57,57,57,57,57,58,58,70,80,95,95,96,96,96,96,96,96,96,96,96,96,96,96,97,97,174,174,174,175,175,175,4,5,5,5,5};
	public static void render(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, String username, CsrfToken _csrf) {
		jteOutput.writeContent("\r\n");
		gg.jte.generated.ondemand.layout.JteappGenerated.render(jteOutput, jteHtmlInterceptor, "Jobs", username, "jobs", new gg.jte.html.HtmlContent() {
			public void writeTo(gg.jte.html.HtmlTemplateOutput jteOutput) {
				jteOutput.writeContent("\r\n        <div class=\"page-header d-flex justify-between align-center\">\r\n            <div>\r\n                <h1 class=\"page-title\">Job-Verwaltung</h1>\r\n                <p class=\"page-description\">Überwachen und verwalten Sie alle geplanten und laufenden Jobs</p>\r\n            </div>\r\n            <button class=\"btn btn-primary\" onclick=\"showCreateJobModal()\">\r\n                + Job erstellen\r\n            </button>\r\n        </div>\r\n\r\n        ");
				jteOutput.writeContent("\r\n        <div class=\"card mb-3\">\r\n            <div class=\"filter-row\">\r\n                <div class=\"filter-group\">\r\n                    <label for=\"search\">Suche</label>\r\n                    <input type=\"text\" id=\"search\" name=\"search\" placeholder=\"Job-Name...\"\r\n                           hx-get=\"/jobs/table\"\r\n                           hx-trigger=\"keyup changed delay:300ms\"\r\n                           hx-target=\"#jobs-table-container\"\r\n                           hx-include=\"[name='statusFilter'], [name='typeFilter']\">\r\n                </div>\r\n                <div class=\"filter-group\">\r\n                    <label for=\"statusFilter\">Status</label>\r\n                    <select id=\"statusFilter\" name=\"statusFilter\"\r\n                            hx-get=\"/jobs/table\"\r\n                            hx-trigger=\"change\"\r\n                            hx-target=\"#jobs-table-container\"\r\n                            hx-include=\"[name='search'], [name='typeFilter']\">\r\n                        <option value=\"\">Alle Status</option>\r\n                        ");
				for (JobStatus s : JobStatus.values()) {
					jteOutput.writeContent("\r\n                            <option");
					var __jte_html_attribute_0 = s.name();
					if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_0)) {
						jteOutput.writeContent(" value=\"");
						jteOutput.setContext("option", "value");
						jteOutput.writeUserContent(__jte_html_attribute_0);
						jteOutput.setContext("option", null);
						jteOutput.writeContent("\"");
					}
					jteOutput.writeContent(">");
					jteOutput.setContext("option", null);
					jteOutput.writeUserContent(s.getDisplayName());
					jteOutput.writeContent("</option>\r\n                        ");
				}
				jteOutput.writeContent("\r\n                    </select>\r\n                </div>\r\n                <div class=\"filter-group\">\r\n                    <label for=\"typeFilter\">Typ</label>\r\n                    <select id=\"typeFilter\" name=\"typeFilter\"\r\n                            hx-get=\"/jobs/table\"\r\n                            hx-trigger=\"change\"\r\n                            hx-target=\"#jobs-table-container\"\r\n                            hx-include=\"[name='search'], [name='statusFilter']\">\r\n                        <option value=\"\">Alle Typen</option>\r\n                        ");
				for (JobType t : JobType.values()) {
					jteOutput.writeContent("\r\n                            <option");
					var __jte_html_attribute_1 = t.name();
					if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_1)) {
						jteOutput.writeContent(" value=\"");
						jteOutput.setContext("option", "value");
						jteOutput.writeUserContent(__jte_html_attribute_1);
						jteOutput.setContext("option", null);
						jteOutput.writeContent("\"");
					}
					jteOutput.writeContent(">");
					jteOutput.setContext("option", null);
					jteOutput.writeUserContent(t.getDisplayName());
					jteOutput.writeContent("</option>\r\n                        ");
				}
				jteOutput.writeContent("\r\n                    </select>\r\n                </div>\r\n                <div class=\"filter-group filter-actions\">\r\n                    <label>&nbsp;</label>\r\n                    <button type=\"button\" class=\"btn btn-outline\" onclick=\"resetJobFilters()\">\r\n                        Filter zurücksetzen\r\n                    </button>\r\n                </div>\r\n            </div>\r\n        </div>\r\n\r\n        ");
				jteOutput.writeContent("\r\n        <div class=\"card\">\r\n            <div id=\"jobs-table-container\"\r\n                 hx-get=\"/jobs/table\"\r\n                 hx-trigger=\"load, every 10s\"\r\n                 hx-swap=\"innerHTML\">\r\n                <div class=\"loading-spinner\">Lade Jobs...</div>\r\n            </div>\r\n        </div>\r\n\r\n        ");
				jteOutput.writeContent("\r\n        <div id=\"create-job-modal\" class=\"modal-overlay\" style=\"display:none;\">\r\n            <div class=\"modal-content\">\r\n                <div class=\"modal-header\">\r\n                    <h2>Neuen Job erstellen</h2>\r\n                    <button class=\"btn-close\" onclick=\"closeCreateJobModal()\">&times;</button>\r\n                </div>\r\n                <div class=\"modal-body\">\r\n                    <div class=\"form-group\">\r\n                        <label for=\"newJobName\">Job-Name</label>\r\n                        <input type=\"text\" id=\"newJobName\" placeholder=\"z.B. Daten-Import Station A\">\r\n                    </div>\r\n                    <div class=\"form-group\">\r\n                        <label for=\"newJobType\">Job-Typ</label>\r\n                        <select id=\"newJobType\">\r\n                            ");
				for (JobType t : JobType.values()) {
					jteOutput.writeContent("\r\n                                <option");
					var __jte_html_attribute_2 = t.name();
					if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_2)) {
						jteOutput.writeContent(" value=\"");
						jteOutput.setContext("option", "value");
						jteOutput.writeUserContent(__jte_html_attribute_2);
						jteOutput.setContext("option", null);
						jteOutput.writeContent("\"");
					}
					jteOutput.writeContent(">");
					jteOutput.setContext("option", null);
					jteOutput.writeUserContent(t.getDisplayName());
					jteOutput.writeContent("</option>\r\n                            ");
				}
				jteOutput.writeContent("\r\n                        </select>\r\n                    </div>\r\n                    <div class=\"form-group\">\r\n                        <label for=\"newJobPriority\">Priorität</label>\r\n                        <select id=\"newJobPriority\">\r\n                            <option value=\"NORMAL\" selected>Normal</option>\r\n                            <option value=\"CRITICAL\">Kritisch</option>\r\n                            <option value=\"HIGH\">Hoch</option>\r\n                            <option value=\"LOW\">Niedrig</option>\r\n                        </select>\r\n                    </div>\r\n                    <div class=\"form-group\">\r\n                        <label for=\"newJobParams\">Parameter (JSON)</label>\r\n                        <textarea id=\"newJobParams\" rows=\"3\" placeholder='{\"url\": \"https://...\", \"sensorId\": 1}'></textarea>\r\n                    </div>\r\n                </div>\r\n                <div class=\"modal-footer\">\r\n                    <button class=\"btn btn-outline\" onclick=\"closeCreateJobModal()\">Abbrechen</button>\r\n                    <button class=\"btn btn-primary\" onclick=\"submitCreateJob()\">Job erstellen</button>\r\n                </div>\r\n            </div>\r\n        </div>\r\n\r\n        <style>\r\n            .filter-row { display: flex; gap: var(--spacing-lg); flex-wrap: wrap; align-items: flex-end; }\r\n            .filter-group { flex: 1; min-width: 200px; }\r\n            .filter-group label { display: block; margin-bottom: var(--spacing-sm); font-weight: 500; font-size: var(--font-size-sm); }\r\n            .filter-actions { flex: 0 0 auto; min-width: auto; }\r\n            .loading-spinner { text-align: center; padding: var(--spacing-xl); color: var(--text-secondary); }\r\n            .modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1000; }\r\n            .modal-content { background: var(--surface); border-radius: var(--radius-lg); width: 90%; max-width: 500px; box-shadow: var(--shadow-xl); }\r\n            .modal-header { display: flex; justify-content: space-between; align-items: center; padding: var(--spacing-lg); border-bottom: 1px solid var(--border-color); }\r\n            .modal-header h2 { margin: 0; font-size: 1.1rem; }\r\n            .btn-close { background: none; border: none; font-size: 1.5rem; cursor: pointer; color: var(--text-secondary); }\r\n            .modal-body { padding: var(--spacing-lg); }\r\n            .modal-footer { display: flex; justify-content: flex-end; gap: var(--spacing-md); padding: var(--spacing-lg); border-top: 1px solid var(--border-color); }\r\n        </style>\r\n\r\n        <script>\r\n            function resetJobFilters() {\r\n                document.getElementById('search').value = '';\r\n                document.getElementById('statusFilter').value = '';\r\n                document.getElementById('typeFilter').value = '';\r\n                htmx.trigger('#search', 'keyup');\r\n            }\r\n            function showCreateJobModal() {\r\n                document.getElementById('create-job-modal').style.display = 'flex';\r\n            }\r\n            function closeCreateJobModal() {\r\n                document.getElementById('create-job-modal').style.display = 'none';\r\n            }\r\n            function submitCreateJob() {\r\n                var csrfToken = document.querySelector('meta[name=\"csrf-token\"]').content;\r\n                var csrfHeader = document.querySelector('meta[name=\"csrf-header\"]').content;\r\n\r\n                var formData = new URLSearchParams();\r\n                formData.append('jobName', document.getElementById('newJobName').value);\r\n                formData.append('jobType', document.getElementById('newJobType').value);\r\n                formData.append('priority', document.getElementById('newJobPriority').value);\r\n                formData.append('jobParameters', document.getElementById('newJobParams').value);\r\n\r\n                var headers = {'Content-Type': 'application/x-www-form-urlencoded'};\r\n                headers[csrfHeader] = csrfToken;\r\n\r\n                fetch('/jobs/create', {\r\n                    method: 'POST',\r\n                    headers: headers,\r\n                    body: formData.toString()\r\n                }).then(function(r) { return r.json(); })\r\n                .then(function(data) {\r\n                    if (data.error) { alert('Fehler: ' + data.error); return; }\r\n                    closeCreateJobModal();\r\n                    htmx.trigger('#jobs-table-container', 'load');\r\n                });\r\n            }\r\n        </script>\r\n    ");
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
