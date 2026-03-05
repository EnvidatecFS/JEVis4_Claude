package gg.jte.generated.ondemand.pages;
import org.jevis.model.TaskWorker;
import org.jevis.model.WorkerPool;
import java.util.List;
import java.time.format.DateTimeFormatter;
import java.time.Duration;
import java.time.Instant;
public final class JteworkerstableGenerated {
	public static final String JTE_NAME = "pages/workers-table.jte";
	public static final int[] JTE_LINE_INFO = {0,0,1,2,3,4,5,7,7,7,10,10,10,12,14,14,16,16,16,17,17,17,19,19,19,20,20,22,22,25,25,29,29,29,47,47,54,54,55,55,57,57,57,58,58,58,59,59,59,61,61,61,61,61,61,61,61,62,62,62,65,65,65,65,65,65,66,66,66,67,67,67,68,68,68,70,70,71,71,89,89,89,7,8,8,8,8};
	public static void render(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, List<TaskWorker> workers, List<WorkerPool> pools) {
		jteOutput.writeContent("\r\n");
		var formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm:ss").withZone(java.time.ZoneId.systemDefault());
		jteOutput.writeContent("\r\n\r\n");
		jteOutput.writeContent("\r\n<div style=\"display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: var(--spacing-md); margin-bottom: var(--spacing-lg);\">\r\n    ");
		for (WorkerPool pool : pools) {
			jteOutput.writeContent("\r\n        <div class=\"card\" style=\"padding: var(--spacing-lg);\">\r\n            <div style=\"font-weight: 600; margin-bottom: 4px;\">");
			jteOutput.setContext("div", null);
			jteOutput.writeUserContent(pool.getPoolName());
			jteOutput.writeContent("</div>\r\n            <div style=\"font-size: var(--font-size-sm); color: var(--text-secondary);\">");
			jteOutput.setContext("div", null);
			jteOutput.writeUserContent(pool.getDescription() != null ? pool.getDescription() : "");
			jteOutput.writeContent("</div>\r\n            <div style=\"margin-top: var(--spacing-sm); font-size: var(--font-size-sm);\">\r\n                Max Jobs: <strong>");
			jteOutput.setContext("strong", null);
			jteOutput.writeUserContent(pool.getMaxConcurrentJobs());
			jteOutput.writeContent("</strong>\r\n                ");
			if (pool.getIsDefault()) {
				jteOutput.writeContent("\r\n                    <span class=\"badge\" style=\"background: #dbeafe; color: #1e40af; margin-left: 8px;\">Default</span>\r\n                ");
			}
			jteOutput.writeContent("\r\n            </div>\r\n        </div>\r\n    ");
		}
		jteOutput.writeContent("\r\n</div>\r\n\r\n<div class=\"table-header\">\r\n    <span class=\"table-info\">");
		jteOutput.setContext("span", null);
		jteOutput.writeUserContent(workers.size());
		jteOutput.writeContent(" Worker registriert</span>\r\n</div>\r\n\r\n<div class=\"table-responsive\">\r\n    <table class=\"data-table\">\r\n        <thead>\r\n            <tr>\r\n                <th>ID</th>\r\n                <th>Name</th>\r\n                <th>Pool</th>\r\n                <th>Status</th>\r\n                <th>Jobs</th>\r\n                <th>Capabilities</th>\r\n                <th>Host</th>\r\n                <th>Letzter Heartbeat</th>\r\n            </tr>\r\n        </thead>\r\n        <tbody>\r\n            ");
		if (workers.isEmpty()) {
			jteOutput.writeContent("\r\n                <tr>\r\n                    <td colspan=\"8\" class=\"empty-state\">\r\n                        <p>Keine Worker registriert</p>\r\n                        <p style=\"font-size: 0.8rem; color: var(--text-secondary);\">Worker können sich über die REST-API registrieren: POST /api/workers/register</p>\r\n                    </td>\r\n                </tr>\r\n            ");
		} else {
			jteOutput.writeContent("\r\n                ");
			for (TaskWorker worker : workers) {
				jteOutput.writeContent("\r\n                    <tr>\r\n                        <td><code>#");
				jteOutput.setContext("code", null);
				jteOutput.writeUserContent(worker.getId());
				jteOutput.writeContent("</code></td>\r\n                        <td style=\"font-weight: 500;\">");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(worker.getWorkerName() != null ? worker.getWorkerName() : worker.getWorkerIdentifier());
				jteOutput.writeContent("</td>\r\n                        <td>");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(worker.getWorkerPool() != null ? worker.getWorkerPool().getPoolName() : "-");
				jteOutput.writeContent("</td>\r\n                        <td>\r\n                            <span class=\"status-badge\" style=\"background-color: ");
				jteOutput.setContext("span", "style");
				jteOutput.writeUserContent(worker.getStatus().getColor());
				jteOutput.setContext("span", null);
				jteOutput.writeContent("20; color: ");
				jteOutput.setContext("span", "style");
				jteOutput.writeUserContent(worker.getStatus().getColor());
				jteOutput.setContext("span", null);
				jteOutput.writeContent(";\">\r\n                                ");
				jteOutput.setContext("span", null);
				jteOutput.writeUserContent(worker.getStatus().getDisplayName());
				jteOutput.writeContent("\r\n                            </span>\r\n                        </td>\r\n                        <td>");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(worker.getCurrentJobCount());
				jteOutput.writeContent(" / ");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(worker.getMaxConcurrentJobs());
				jteOutput.writeContent("</td>\r\n                        <td style=\"max-width: 200px; overflow: hidden; text-overflow: ellipsis;\">");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(worker.getCapabilities() != null ? worker.getCapabilities() : "Alle");
				jteOutput.writeContent("</td>\r\n                        <td>");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(worker.getHostName() != null ? worker.getHostName() : "-");
				jteOutput.writeContent("</td>\r\n                        <td class=\"date-cell\">");
				jteOutput.setContext("td", null);
				jteOutput.writeUserContent(worker.getLastHeartbeatAt() != null ? formatter.format(worker.getLastHeartbeatAt()) : "-");
				jteOutput.writeContent("</td>\r\n                    </tr>\r\n                ");
			}
			jteOutput.writeContent("\r\n            ");
		}
		jteOutput.writeContent("\r\n        </tbody>\r\n    </table>\r\n</div>\r\n\r\n<style>\r\n    .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--spacing-md); }\r\n    .table-info { color: var(--text-secondary); font-size: var(--font-size-sm); }\r\n    .table-responsive { overflow-x: auto; }\r\n    .data-table { width: 100%; border-collapse: collapse; font-size: var(--font-size-sm); }\r\n    .data-table th, .data-table td { padding: var(--spacing-md); text-align: left; border-bottom: 1px solid var(--border-color); }\r\n    .data-table th { background-color: var(--background); font-weight: 600; color: var(--text-secondary); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; }\r\n    .data-table tbody tr:hover { background-color: var(--background); }\r\n    .badge { display: inline-block; padding: 2px 8px; border-radius: var(--radius-sm); font-size: 0.75rem; font-weight: 500; }\r\n    .status-badge { display: inline-block; padding: 4px 10px; border-radius: var(--radius-lg); font-size: 0.75rem; font-weight: 500; }\r\n    .date-cell { white-space: nowrap; color: var(--text-secondary); }\r\n    .empty-state { text-align: center; padding: var(--spacing-2xl) !important; color: var(--text-secondary); }\r\n</style>\r\n");
	}
	public static void renderMap(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, java.util.Map<String, Object> params) {
		List<TaskWorker> workers = (List<TaskWorker>)params.get("workers");
		List<WorkerPool> pools = (List<WorkerPool>)params.get("pools");
		render(jteOutput, jteHtmlInterceptor, workers, pools);
	}
}
