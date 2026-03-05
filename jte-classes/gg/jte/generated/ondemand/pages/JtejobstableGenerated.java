package gg.jte.generated.ondemand.pages;
import org.jevis.model.Job;
import org.jevis.model.JobStatus;
import java.util.List;
import java.time.format.DateTimeFormatter;
public final class JtejobstableGenerated {
	public static final String JTE_NAME = "pages/jobs-table.jte";
	public static final int[] JTE_LINE_INFO = {0,0,1,2,3,5,5,5,15,15,15,18,18,18,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,30,30,31,31,31,32,32,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,45,45,46,46,46,47,47,54,54,60,60,61,61,63,63,63,65,65,65,65,66,66,66,69,69,69,69,69,69,69,69,69,69,69,70,70,70,70,70,70,70,70,70,70,70,71,71,71,71,71,71,71,71,71,71,71,72,72,72,73,73,73,73,73,73,75,75,75,75,81,81,83,83,83,83,88,88,91,91,92,92,97,97,100,100,100,100,100,101,101,101,101,101,101,101,101,101,101,101,101,101,101,101,101,101,101,101,101,101,101,101,101,105,105,105,105,105,105,107,107,107,107,107,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,113,113,151,151,151,5,6,7,8,9,10,11,12,13,13,13,13};
	public static void render(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, List<Job> jobs, int currentPage, int totalPages, long totalElements, String search, String statusFilter, String typeFilter, String sortBy, String sortDir) {
		jteOutput.writeContent("\r\n");
		var formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm").withZone(java.time.ZoneId.systemDefault());
		jteOutput.writeContent("\r\n\r\n<div class=\"table-header\">\r\n    <span class=\"table-info\">");
		jteOutput.setContext("span", null);
		jteOutput.writeUserContent(totalElements);
		jteOutput.writeContent(" Jobs gefunden</span>\r\n</div>\r\n\r\n<div class=\"table-responsive\">\r\n    <table class=\"data-table\">\r\n        <thead>\r\n            <tr>\r\n                <th>ID</th>\r\n                <th class=\"sortable\"\r\n                    hx-get=\"/jobs/table?sortBy=jobName&sortDir=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(sortBy.equals("jobName") && sortDir.equals("asc") ? "desc" : "asc");
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&search=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(search);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&statusFilter=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(statusFilter);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&typeFilter=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(typeFilter);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("\"\r\n                    hx-target=\"#jobs-table-container\">\r\n                    Name\r\n                    ");
		if (sortBy.equals("jobName")) {
			jteOutput.writeContent("\r\n                        <span class=\"sort-icon\">");
			jteOutput.setContext("span", null);
			jteOutput.writeUserContent(sortDir.equals("asc") ? "^" : "v");
			jteOutput.writeContent("</span>\r\n                    ");
		}
		jteOutput.writeContent("\r\n                </th>\r\n                <th>Typ</th>\r\n                <th class=\"sortable\"\r\n                    hx-get=\"/jobs/table?sortBy=status&sortDir=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(sortBy.equals("status") && sortDir.equals("asc") ? "desc" : "asc");
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&search=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(search);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&statusFilter=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(statusFilter);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&typeFilter=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(typeFilter);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("\"\r\n                    hx-target=\"#jobs-table-container\">\r\n                    Status\r\n                </th>\r\n                <th>Priorität</th>\r\n                <th class=\"sortable\"\r\n                    hx-get=\"/jobs/table?sortBy=createdAt&sortDir=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(sortBy.equals("createdAt") && sortDir.equals("asc") ? "desc" : "asc");
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&search=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(search);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&statusFilter=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(statusFilter);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("&typeFilter=");
		jteOutput.setContext("th", "hx-get");
		jteOutput.writeUserContent(typeFilter);
		jteOutput.setContext("th", null);
		jteOutput.writeContent("\"\r\n                    hx-target=\"#jobs-table-container\">\r\n                    Erstellt\r\n                    ");
		if (sortBy.equals("createdAt")) {
			jteOutput.writeContent("\r\n                        <span class=\"sort-icon\">");
			jteOutput.setContext("span", null);
			jteOutput.writeUserContent(sortDir.equals("asc") ? "^" : "v");
			jteOutput.writeContent("</span>\r\n                    ");
		}
		jteOutput.writeContent("\r\n                </th>\r\n                <th>Retries</th>\r\n                <th class=\"actions-col\">Aktionen</th>\r\n            </tr>\r\n        </thead>\r\n        <tbody>\r\n            ");
		if (jobs.isEmpty()) {
			jteOutput.writeContent("\r\n                <tr>\r\n                    <td colspan=\"8\" class=\"empty-state\">\r\n                        <p>Keine Jobs gefunden</p>\r\n                    </td>\r\n                </tr>\r\n            ");
		} else {
			jteOutput.writeContent("\r\n                ");
			for (Job job : jobs) {
				jteOutput.writeContent("\r\n                    <tr>\r\n                        <td><code>#");
				jteOutput.setContext("code", null);
				jteOutput.writeUserContent(job.getId());
				jteOutput.writeContent("</code></td>\r\n                        <td>\r\n                            <a href=\"/jobs/");
				jteOutput.setContext("a", "href");
				jteOutput.writeUserContent(job.getId());
				jteOutput.setContext("a", null);
				jteOutput.writeContent("\" style=\"color: var(--primary-color); text-decoration: none; font-weight: 500;\">\r\n                                ");
				jteOutput.setContext("a", null);
				jteOutput.writeUserContent(job.getJobName());
				jteOutput.writeContent("\r\n                            </a>\r\n                        </td>\r\n                        <td><span class=\"badge\" style=\"background-color: ");
				jteOutput.setContext("span", "style");
				jteOutput.writeUserContent(job.getJobType().getColor());
				jteOutput.setContext("span", null);
				jteOutput.writeContent("20; color: ");
				jteOutput.setContext("span", "style");
				jteOutput.writeUserContent(job.getJobType().getColor());
				jteOutput.setContext("span", null);
				jteOutput.writeContent(";\">");
				jteOutput.setContext("span", null);
				jteOutput.writeUserContent(job.getJobType().getDisplayName());
				jteOutput.writeContent("</span></td>\r\n                        <td><span class=\"status-badge\" style=\"background-color: ");
				jteOutput.setContext("span", "style");
				jteOutput.writeUserContent(job.getStatus().getColor());
				jteOutput.setContext("span", null);
				jteOutput.writeContent("20; color: ");
				jteOutput.setContext("span", "style");
				jteOutput.writeUserContent(job.getStatus().getColor());
				jteOutput.setContext("span", null);
				jteOutput.writeContent(";\">");
				jteOutput.setContext("span", null);
				jteOutput.writeUserContent(job.getStatus().getDisplayName());
				jteOutput.writeContent("</span></td>\r\n                        <td><span class=\"badge\" style=\"background-color: ");
				jteOutput.setContext("span", "style");
				jteOutput.writeUserContent(job.getPriority().getColor());
				jteOutput.setContext("span", null);
				jteOutput.writeContent("20; color: ");
				jteOutput.setContext("span", "style");
				jteOutput.writeUserContent(job.getPriority().getColor());
				jteOutput.setContext("span", null);
				jteOutput.writeContent(";\">");
				jteOutput.setContext("span", null);
				jteOutput.writeUserContent(job.getPriority().getDisplayName());
				jteOutput.writeContent("</span></td>\r\n                        <td class=\"date-cell\">");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(job.getCreatedAt() != null ? formatter.format(job.getCreatedAt()) : "-");
				jteOutput.writeContent("</td>\r\n                        <td>");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(job.getRetryCount());
				jteOutput.writeContent("/");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(job.getMaxRetryAttempts());
				jteOutput.writeContent("</td>\r\n                        <td class=\"actions-cell\">\r\n                            <a href=\"/jobs/");
				jteOutput.setContext("a", "href");
				jteOutput.writeUserContent(job.getId());
				jteOutput.setContext("a", null);
				jteOutput.writeContent("\" class=\"btn-icon\" title=\"Details\">\r\n                                <svg width=\"16\" height=\"16\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\r\n                                    <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M15 12a3 3 0 11-6 0 3 3 0 016 0z\"/>\r\n                                    <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z\"/>\r\n                                </svg>\r\n                            </a>\r\n                            ");
				if (job.getStatus() != JobStatus.COMPLETED && job.getStatus() != JobStatus.CANCELLED && job.getStatus() != JobStatus.ALARM) {
					jteOutput.writeContent("\r\n                                <button class=\"btn-icon btn-icon-danger\" title=\"Abbrechen\"\r\n                                        onclick=\"cancelJob(");
					jteOutput.setContext("button", "onclick");
					jteOutput.writeUserContent(job.getId());
					jteOutput.setContext("button", null);
					jteOutput.writeContent(")\">\r\n                                    <svg width=\"16\" height=\"16\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\">\r\n                                        <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M6 18L18 6M6 6l12 12\"/>\r\n                                    </svg>\r\n                                </button>\r\n                            ");
				}
				jteOutput.writeContent("\r\n                        </td>\r\n                    </tr>\r\n                ");
			}
			jteOutput.writeContent("\r\n            ");
		}
		jteOutput.writeContent("\r\n        </tbody>\r\n    </table>\r\n</div>\r\n\r\n");
		if (totalPages > 1) {
			jteOutput.writeContent("\r\n    <div class=\"pagination\">\r\n        <button class=\"btn btn-outline btn-sm\"\r\n               ");
			var __jte_html_attribute_0 = currentPage == 0;
			if (__jte_html_attribute_0) {
			jteOutput.writeContent(" disabled");
			}
			jteOutput.writeContent("\r\n                hx-get=\"/jobs/table?page=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(currentPage - 1);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&search=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(search);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&statusFilter=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(statusFilter);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&typeFilter=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(typeFilter);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&sortBy=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(sortBy);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&sortDir=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(sortDir);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("\"\r\n                hx-target=\"#jobs-table-container\">\r\n            Zurück\r\n        </button>\r\n        <span class=\"pagination-info\">Seite ");
			jteOutput.setContext("span", null);
			jteOutput.writeUserContent(currentPage + 1);
			jteOutput.writeContent(" von ");
			jteOutput.setContext("span", null);
			jteOutput.writeUserContent(totalPages);
			jteOutput.writeContent("</span>\r\n        <button class=\"btn btn-outline btn-sm\"\r\n               ");
			var __jte_html_attribute_1 = currentPage >= totalPages - 1;
			if (__jte_html_attribute_1) {
			jteOutput.writeContent(" disabled");
			}
			jteOutput.writeContent("\r\n                hx-get=\"/jobs/table?page=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(currentPage + 1);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&search=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(search);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&statusFilter=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(statusFilter);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&typeFilter=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(typeFilter);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&sortBy=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(sortBy);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("&sortDir=");
			jteOutput.setContext("button", "hx-get");
			jteOutput.writeUserContent(sortDir);
			jteOutput.setContext("button", null);
			jteOutput.writeContent("\"\r\n                hx-target=\"#jobs-table-container\">\r\n            Weiter\r\n        </button>\r\n    </div>\r\n");
		}
		jteOutput.writeContent("\r\n\r\n<script>\r\n    function cancelJob(jobId) {\r\n        if (!confirm('Job wirklich abbrechen?')) return;\r\n        var csrfToken = document.querySelector('meta[name=\"csrf-token\"]').content;\r\n        var csrfHeader = document.querySelector('meta[name=\"csrf-header\"]').content;\r\n        var headers = {};\r\n        headers[csrfHeader] = csrfToken;\r\n        fetch('/jobs/' + jobId + '/cancel', { method: 'POST', headers: headers })\r\n            .then(function() { htmx.trigger('#jobs-table-container', 'load'); });\r\n    }\r\n</script>\r\n\r\n<style>\r\n    .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--spacing-md); }\r\n    .table-info { color: var(--text-secondary); font-size: var(--font-size-sm); }\r\n    .table-responsive { overflow-x: auto; }\r\n    .data-table { width: 100%; border-collapse: collapse; font-size: var(--font-size-sm); }\r\n    .data-table th, .data-table td { padding: var(--spacing-md); text-align: left; border-bottom: 1px solid var(--border-color); }\r\n    .data-table th { background-color: var(--background); font-weight: 600; color: var(--text-secondary); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; }\r\n    .data-table th.sortable { cursor: pointer; user-select: none; }\r\n    .data-table th.sortable:hover { background-color: var(--border-color); }\r\n    .sort-icon { margin-left: var(--spacing-sm); font-size: 0.7rem; }\r\n    .data-table tbody tr:hover { background-color: var(--background); }\r\n    .badge { display: inline-block; padding: 2px 8px; border-radius: var(--radius-sm); font-size: 0.75rem; font-weight: 500; }\r\n    .status-badge { display: inline-block; padding: 4px 10px; border-radius: var(--radius-lg); font-size: 0.75rem; font-weight: 500; }\r\n    .date-cell { white-space: nowrap; color: var(--text-secondary); }\r\n    .actions-col { width: 100px; text-align: center; }\r\n    .actions-cell { text-align: center; white-space: nowrap; }\r\n    .btn-icon { background: none; border: none; cursor: pointer; padding: var(--spacing-sm); color: var(--text-secondary); border-radius: var(--radius-md); transition: all 0.2s; display: inline-flex; }\r\n    .btn-icon:hover { background-color: var(--background); color: var(--primary-color); }\r\n    .btn-icon-danger:hover { background-color: #fee2e2; color: var(--danger-color); }\r\n    .empty-state { text-align: center; padding: var(--spacing-2xl) !important; color: var(--text-secondary); }\r\n    .pagination { display: flex; justify-content: center; align-items: center; gap: var(--spacing-md); margin-top: var(--spacing-lg); padding-top: var(--spacing-lg); border-top: 1px solid var(--border-color); }\r\n    .pagination-info { color: var(--text-secondary); font-size: var(--font-size-sm); }\r\n    .btn-sm { padding: var(--spacing-sm) var(--spacing-md); font-size: var(--font-size-sm); }\r\n</style>\r\n");
	}
	public static void renderMap(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, java.util.Map<String, Object> params) {
		List<Job> jobs = (List<Job>)params.get("jobs");
		int currentPage = (int)params.get("currentPage");
		int totalPages = (int)params.get("totalPages");
		long totalElements = (long)params.get("totalElements");
		String search = (String)params.getOrDefault("search", "");
		String statusFilter = (String)params.getOrDefault("statusFilter", "");
		String typeFilter = (String)params.getOrDefault("typeFilter", "");
		String sortBy = (String)params.getOrDefault("sortBy", "createdAt");
		String sortDir = (String)params.getOrDefault("sortDir", "desc");
		render(jteOutput, jteHtmlInterceptor, jobs, currentPage, totalPages, totalElements, search, statusFilter, typeFilter, sortBy, sortDir);
	}
}
