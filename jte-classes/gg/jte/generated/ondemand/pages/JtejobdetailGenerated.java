package gg.jte.generated.ondemand.pages;
import org.springframework.security.web.csrf.CsrfToken;
import org.jevis.model.Job;
import org.jevis.model.JobExecution;
import org.jevis.model.JobEvent;
import java.util.List;
import java.time.format.DateTimeFormatter;
public final class JtejobdetailGenerated {
	public static final String JTE_NAME = "pages/job-detail.jte";
	public static final int[] JTE_LINE_INFO = {0,0,1,2,3,4,5,7,7,7,13,13,13,15,21,21,25,25,25,26,26,26,26,26,26,26,26,27,27,27,32,36,36,36,40,40,40,40,40,40,40,40,40,40,40,44,44,44,44,44,44,48,48,48,52,52,55,55,55,57,57,59,61,61,61,62,62,64,64,79,79,81,81,81,82,82,82,82,82,82,82,82,82,82,82,83,83,83,84,84,84,85,85,85,89,89,89,89,91,91,91,94,94,94,94,94,94,94,94,94,94,94,94,96,96,100,100,103,105,105,105,106,106,108,108,110,110,115,115,115,116,116,116,118,118,118,121,121,123,123,144,144,144,145,145,145,7,8,9,10,11,11,11,11};
	public static void render(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, String username, Job job, List<JobExecution> executions, List<JobEvent> events, CsrfToken _csrf) {
		jteOutput.writeContent("\r\n");
		var formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm:ss").withZone(java.time.ZoneId.systemDefault());
		jteOutput.writeContent("\r\n\r\n");
		gg.jte.generated.ondemand.layout.JteappGenerated.render(jteOutput, jteHtmlInterceptor, "Job #" + job.getId(), username, "jobs", new gg.jte.html.HtmlContent() {
			public void writeTo(gg.jte.html.HtmlTemplateOutput jteOutput) {
				jteOutput.writeContent("\r\n        <div class=\"page-header\">\r\n            <div class=\"d-flex align-center\" style=\"gap: var(--spacing-md); margin-bottom: var(--spacing-sm);\">\r\n                <a href=\"/jobs\" class=\"btn btn-outline btn-sm\">Zurück</a>\r\n                <h1 class=\"page-title\" style=\"margin:0;\">");
				jteOutput.setContext("h1", null);
				jteOutput.writeUserContent(job.getJobName());
				jteOutput.writeContent("</h1>\r\n                <span class=\"status-badge\" style=\"background-color: ");
				jteOutput.setContext("span", "style");
				jteOutput.writeUserContent(job.getStatus().getColor());
				jteOutput.setContext("span", null);
				jteOutput.writeContent("20; color: ");
				jteOutput.setContext("span", "style");
				jteOutput.writeUserContent(job.getStatus().getColor());
				jteOutput.setContext("span", null);
				jteOutput.writeContent(";\">\r\n                    ");
				jteOutput.setContext("span", null);
				jteOutput.writeUserContent(job.getStatus().getDisplayName());
				jteOutput.writeContent("\r\n                </span>\r\n            </div>\r\n        </div>\r\n\r\n        ");
				jteOutput.writeContent("\r\n        <div style=\"display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: var(--spacing-md); margin-bottom: var(--spacing-lg);\">\r\n            <div class=\"card\" style=\"padding: var(--spacing-lg);\">\r\n                <div style=\"color: var(--text-secondary); font-size: var(--font-size-sm); margin-bottom: 4px;\">Typ</div>\r\n                <div style=\"font-weight: 600;\">");
				jteOutput.setContext("div", null);
				jteOutput.writeUserContent(job.getJobType().getDisplayName());
				jteOutput.writeContent("</div>\r\n            </div>\r\n            <div class=\"card\" style=\"padding: var(--spacing-lg);\">\r\n                <div style=\"color: var(--text-secondary); font-size: var(--font-size-sm); margin-bottom: 4px;\">Priorität</div>\r\n                <div><span class=\"badge\" style=\"background-color: ");
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
				jteOutput.writeContent("</span></div>\r\n            </div>\r\n            <div class=\"card\" style=\"padding: var(--spacing-lg);\">\r\n                <div style=\"color: var(--text-secondary); font-size: var(--font-size-sm); margin-bottom: 4px;\">Retries</div>\r\n                <div style=\"font-weight: 600;\">");
				jteOutput.setContext("div", null);
				jteOutput.writeUserContent(job.getRetryCount());
				jteOutput.writeContent(" / ");
				jteOutput.setContext("div", null);
				jteOutput.writeUserContent(job.getMaxRetryAttempts());
				jteOutput.writeContent("</div>\r\n            </div>\r\n            <div class=\"card\" style=\"padding: var(--spacing-lg);\">\r\n                <div style=\"color: var(--text-secondary); font-size: var(--font-size-sm); margin-bottom: 4px;\">Erstellt</div>\r\n                <div style=\"font-weight: 600;\">");
				jteOutput.setContext("div", null);
				jteOutput.writeUserContent(job.getCreatedAt() != null ? formatter.format(job.getCreatedAt()) : "-");
				jteOutput.writeContent("</div>\r\n            </div>\r\n        </div>\r\n\r\n        ");
				if (job.getJobParameters() != null && !job.getJobParameters().isBlank()) {
					jteOutput.writeContent("\r\n        <div class=\"card mb-3\" style=\"padding: var(--spacing-lg);\">\r\n            <h3 style=\"margin-top:0; font-size: 1rem;\">Parameter</h3>\r\n            <pre style=\"background: var(--background); padding: var(--spacing-md); border-radius: var(--radius-md); overflow-x: auto; font-size: 0.85rem;\">");
					jteOutput.setContext("pre", null);
					jteOutput.writeUserContent(job.getJobParameters());
					jteOutput.writeContent("</pre>\r\n        </div>\r\n        ");
				}
				jteOutput.writeContent("\r\n\r\n        ");
				jteOutput.writeContent("\r\n        <div class=\"card mb-3\" style=\"padding: var(--spacing-lg);\">\r\n            <h3 style=\"margin-top:0; font-size: 1rem;\">Ausführungen (");
				jteOutput.setContext("h3", null);
				jteOutput.writeUserContent(executions.size());
				jteOutput.writeContent(")</h3>\r\n            ");
				if (executions.isEmpty()) {
					jteOutput.writeContent("\r\n                <p style=\"color: var(--text-secondary);\">Keine Ausführungen vorhanden.</p>\r\n            ");
				} else {
					jteOutput.writeContent("\r\n                <div class=\"table-responsive\">\r\n                    <table class=\"data-table\">\r\n                        <thead>\r\n                            <tr>\r\n                                <th>#</th>\r\n                                <th>Status</th>\r\n                                <th>Worker</th>\r\n                                <th>Gestartet</th>\r\n                                <th>Dauer</th>\r\n                                <th>Fortschritt</th>\r\n                                <th>Fehler</th>\r\n                            </tr>\r\n                        </thead>\r\n                        <tbody>\r\n                            ");
					for (JobExecution exec : executions) {
						jteOutput.writeContent("\r\n                                <tr>\r\n                                    <td>");
						jteOutput.setContext("td", null);
						jteOutput.writeUserContent(exec.getExecutionNumber());
						jteOutput.writeContent("</td>\r\n                                    <td><span class=\"status-badge\" style=\"background-color: ");
						jteOutput.setContext("span", "style");
						jteOutput.writeUserContent(exec.getStatus().getColor());
						jteOutput.setContext("span", null);
						jteOutput.writeContent("20; color: ");
						jteOutput.setContext("span", "style");
						jteOutput.writeUserContent(exec.getStatus().getColor());
						jteOutput.setContext("span", null);
						jteOutput.writeContent(";\">");
						jteOutput.setContext("span", null);
						jteOutput.writeUserContent(exec.getStatus().getDisplayName());
						jteOutput.writeContent("</span></td>\r\n                                    <td>");
						jteOutput.setContext("td", null);
						jteOutput.writeUserContent(exec.getWorker() != null ? exec.getWorker().getWorkerName() : "-");
						jteOutput.writeContent("</td>\r\n                                    <td class=\"date-cell\">");
						jteOutput.setContext("td", null);
						jteOutput.writeUserContent(exec.getStartedAt() != null ? formatter.format(exec.getStartedAt()) : "-");
						jteOutput.writeContent("</td>\r\n                                    <td>");
						jteOutput.setContext("td", null);
						jteOutput.writeUserContent(exec.getDurationMs() != null ? exec.getDurationMs() + " ms" : "-");
						jteOutput.writeContent("</td>\r\n                                    <td>\r\n                                        <div style=\"display: flex; align-items: center; gap: 8px;\">\r\n                                            <div style=\"flex: 1; background: var(--border-color); border-radius: 4px; height: 8px; overflow: hidden;\">\r\n                                                <div style=\"background: var(--primary-color); height: 100%; width: ");
						jteOutput.setContext("div", "style");
						jteOutput.writeUserContent(exec.getProgressPercent());
						jteOutput.setContext("div", null);
						jteOutput.writeContent("%; transition: width 0.3s;\"></div>\r\n                                            </div>\r\n                                            <span style=\"font-size: 0.75rem; color: var(--text-secondary);\">");
						jteOutput.setContext("span", null);
						jteOutput.writeUserContent(exec.getProgressPercent());
						jteOutput.writeContent("%</span>\r\n                                        </div>\r\n                                    </td>\r\n                                    <td style=\"max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;\"");
						var __jte_html_attribute_0 = exec.getErrorMessage() != null ? exec.getErrorMessage() : "";
						if (gg.jte.runtime.TemplateUtils.isAttributeRendered(__jte_html_attribute_0)) {
							jteOutput.writeContent(" title=\"");
							jteOutput.setContext("td", "title");
							jteOutput.writeUserContent(__jte_html_attribute_0);
							jteOutput.setContext("td", null);
							jteOutput.writeContent("\"");
						}
						jteOutput.writeContent(">");
						jteOutput.setContext("td", null);
						jteOutput.writeUserContent(exec.getErrorMessage() != null ? exec.getErrorMessage() : "-");
						jteOutput.writeContent("</td>\r\n                                </tr>\r\n                            ");
					}
					jteOutput.writeContent("\r\n                        </tbody>\r\n                    </table>\r\n                </div>\r\n            ");
				}
				jteOutput.writeContent("\r\n        </div>\r\n\r\n        ");
				jteOutput.writeContent("\r\n        <div class=\"card\" style=\"padding: var(--spacing-lg);\">\r\n            <h3 style=\"margin-top:0; font-size: 1rem;\">Event-Timeline (");
				jteOutput.setContext("h3", null);
				jteOutput.writeUserContent(events.size());
				jteOutput.writeContent(")</h3>\r\n            ");
				if (events.isEmpty()) {
					jteOutput.writeContent("\r\n                <p style=\"color: var(--text-secondary);\">Keine Events vorhanden.</p>\r\n            ");
				} else {
					jteOutput.writeContent("\r\n                <div class=\"timeline\">\r\n                    ");
					for (JobEvent event : events) {
						jteOutput.writeContent("\r\n                        <div class=\"timeline-item\">\r\n                            <div class=\"timeline-dot\"></div>\r\n                            <div class=\"timeline-content\">\r\n                                <div class=\"timeline-header\">\r\n                                    <span class=\"badge\" style=\"font-size: 0.7rem;\">");
						jteOutput.setContext("span", null);
						jteOutput.writeUserContent(event.getEventType().getDisplayName());
						jteOutput.writeContent("</span>\r\n                                    <span class=\"timeline-date\">");
						jteOutput.setContext("span", null);
						jteOutput.writeUserContent(event.getCreatedAt() != null ? formatter.format(event.getCreatedAt()) : "");
						jteOutput.writeContent("</span>\r\n                                </div>\r\n                                <div class=\"timeline-message\">");
						jteOutput.setContext("div", null);
						jteOutput.writeUserContent(event.getEventMessage() != null ? event.getEventMessage() : "");
						jteOutput.writeContent("</div>\r\n                            </div>\r\n                        </div>\r\n                    ");
					}
					jteOutput.writeContent("\r\n                </div>\r\n            ");
				}
				jteOutput.writeContent("\r\n        </div>\r\n\r\n        <style>\r\n            .badge { display: inline-block; padding: 2px 8px; border-radius: var(--radius-sm); font-size: 0.75rem; font-weight: 500; background: var(--background); }\r\n            .status-badge { display: inline-block; padding: 4px 10px; border-radius: var(--radius-lg); font-size: 0.75rem; font-weight: 500; }\r\n            .table-responsive { overflow-x: auto; }\r\n            .data-table { width: 100%; border-collapse: collapse; font-size: var(--font-size-sm); }\r\n            .data-table th, .data-table td { padding: var(--spacing-sm) var(--spacing-md); text-align: left; border-bottom: 1px solid var(--border-color); }\r\n            .data-table th { background-color: var(--background); font-weight: 600; color: var(--text-secondary); font-size: 0.75rem; text-transform: uppercase; }\r\n            .date-cell { white-space: nowrap; color: var(--text-secondary); }\r\n            .mb-3 { margin-bottom: var(--spacing-lg); }\r\n            .timeline { position: relative; padding-left: 24px; }\r\n            .timeline-item { position: relative; padding-bottom: var(--spacing-lg); }\r\n            .timeline-item:not(:last-child)::before { content: ''; position: absolute; left: -20px; top: 8px; bottom: 0; width: 2px; background: var(--border-color); }\r\n            .timeline-dot { position: absolute; left: -24px; top: 4px; width: 10px; height: 10px; border-radius: 50%; background: var(--primary-color); border: 2px solid var(--surface); }\r\n            .timeline-header { display: flex; align-items: center; gap: var(--spacing-md); margin-bottom: 4px; }\r\n            .timeline-date { font-size: 0.75rem; color: var(--text-secondary); }\r\n            .timeline-message { font-size: var(--font-size-sm); color: var(--text-primary); }\r\n            .btn-sm { padding: var(--spacing-sm) var(--spacing-md); font-size: var(--font-size-sm); }\r\n        </style>\r\n    ");
			}
		}, _csrf);
		jteOutput.writeContent("\r\n");
	}
	public static void renderMap(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, java.util.Map<String, Object> params) {
		String username = (String)params.get("username");
		Job job = (Job)params.get("job");
		List<JobExecution> executions = (List<JobExecution>)params.get("executions");
		List<JobEvent> events = (List<JobEvent>)params.get("events");
		CsrfToken _csrf = (CsrfToken)params.getOrDefault("_csrf", null);
		render(jteOutput, jteHtmlInterceptor, username, job, executions, events, _csrf);
	}
}
