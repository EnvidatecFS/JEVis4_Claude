@import org.springframework.security.web.csrf.CsrfToken
@import org.jevis.model.Job
@import org.jevis.model.JobExecution
@import org.jevis.model.JobEvent
@import java.util.List
@import java.time.format.DateTimeFormatter

@param String username
@param Job job
@param List<JobExecution> executions
@param List<JobEvent> events
@param CsrfToken _csrf = null

!{var formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm:ss").withZone(java.time.ZoneId.systemDefault());}

@template.layout.app(
    title = "Job #" + job.getId(),
    username = username,
    currentPage = "jobs",
    _csrf = _csrf,
    content = @`
        <div class="page-header">
            <div class="d-flex align-center" style="gap: var(--spacing-md); margin-bottom: var(--spacing-sm);">
                <a href="/jobs" class="btn btn-outline btn-sm">Zurück</a>
                <h1 class="page-title" style="margin:0;">${job.getJobName()}</h1>
                <span class="status-badge" style="background-color: ${job.getStatus().getColor()}20; color: ${job.getStatus().getColor()};">
                    ${job.getStatus().getDisplayName()}
                </span>
            </div>
        </div>

        <!-- Job Info Cards -->
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: var(--spacing-md); margin-bottom: var(--spacing-lg);">
            <div class="card" style="padding: var(--spacing-lg);">
                <div style="color: var(--text-secondary); font-size: var(--font-size-sm); margin-bottom: 4px;">Typ</div>
                <div style="font-weight: 600;">${job.getJobType().getDisplayName()}</div>
            </div>
            <div class="card" style="padding: var(--spacing-lg);">
                <div style="color: var(--text-secondary); font-size: var(--font-size-sm); margin-bottom: 4px;">Priorität</div>
                <div><span class="badge" style="background-color: ${job.getPriority().getColor()}20; color: ${job.getPriority().getColor()};">${job.getPriority().getDisplayName()}</span></div>
            </div>
            <div class="card" style="padding: var(--spacing-lg);">
                <div style="color: var(--text-secondary); font-size: var(--font-size-sm); margin-bottom: 4px;">Retries</div>
                <div style="font-weight: 600;">${job.getRetryCount()} / ${job.getMaxRetryAttempts()}</div>
            </div>
            <div class="card" style="padding: var(--spacing-lg);">
                <div style="color: var(--text-secondary); font-size: var(--font-size-sm); margin-bottom: 4px;">Erstellt</div>
                <div style="font-weight: 600;">${job.getCreatedAt() != null ? formatter.format(job.getCreatedAt()) : "-"}</div>
            </div>
        </div>

        @if(job.getJobParameters() != null && !job.getJobParameters().isBlank())
        <div class="card mb-3" style="padding: var(--spacing-lg);">
            <h3 style="margin-top:0; font-size: 1rem;">Parameter</h3>
            <pre style="background: var(--background); padding: var(--spacing-md); border-radius: var(--radius-md); overflow-x: auto; font-size: 0.85rem;">${job.getJobParameters()}</pre>
        </div>
        @endif

        <!-- Executions -->
        <div class="card mb-3" style="padding: var(--spacing-lg);">
            <h3 style="margin-top:0; font-size: 1rem;">Ausführungen (${executions.size()})</h3>
            @if(executions.isEmpty())
                <p style="color: var(--text-secondary);">Keine Ausführungen vorhanden.</p>
            @else
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Status</th>
                                <th>Worker</th>
                                <th>Gestartet</th>
                                <th>Dauer</th>
                                <th>Fortschritt</th>
                                <th>Fehler</th>
                            </tr>
                        </thead>
                        <tbody>
                            @for(JobExecution exec : executions)
                                <tr>
                                    <td>${exec.getExecutionNumber()}</td>
                                    <td><span class="status-badge" style="background-color: ${exec.getStatus().getColor()}20; color: ${exec.getStatus().getColor()};">${exec.getStatus().getDisplayName()}</span></td>
                                    <td>${exec.getWorker() != null ? exec.getWorker().getWorkerName() : "-"}</td>
                                    <td class="date-cell">${exec.getStartedAt() != null ? formatter.format(exec.getStartedAt()) : "-"}</td>
                                    <td>${exec.getDurationMs() != null ? exec.getDurationMs() + " ms" : "-"}</td>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 8px;">
                                            <div style="flex: 1; background: var(--border-color); border-radius: 4px; height: 8px; overflow: hidden;">
                                                <div style="background: var(--primary-color); height: 100%; width: ${exec.getProgressPercent()}%; transition: width 0.3s;"></div>
                                            </div>
                                            <span style="font-size: 0.75rem; color: var(--text-secondary);">${exec.getProgressPercent()}%</span>
                                        </div>
                                    </td>
                                    <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${exec.getErrorMessage() != null ? exec.getErrorMessage() : ""}">${exec.getErrorMessage() != null ? exec.getErrorMessage() : "-"}</td>
                                </tr>
                            @endfor
                        </tbody>
                    </table>
                </div>
            @endif
        </div>

        <!-- Event Timeline -->
        <div class="card" style="padding: var(--spacing-lg);">
            <h3 style="margin-top:0; font-size: 1rem;">Event-Timeline (${events.size()})</h3>
            @if(events.isEmpty())
                <p style="color: var(--text-secondary);">Keine Events vorhanden.</p>
            @else
                <div class="timeline">
                    @for(JobEvent event : events)
                        <div class="timeline-item">
                            <div class="timeline-dot"></div>
                            <div class="timeline-content">
                                <div class="timeline-header">
                                    <span class="badge" style="font-size: 0.7rem;">${event.getEventType().getDisplayName()}</span>
                                    <span class="timeline-date">${event.getCreatedAt() != null ? formatter.format(event.getCreatedAt()) : ""}</span>
                                </div>
                                <div class="timeline-message">${event.getEventMessage() != null ? event.getEventMessage() : ""}</div>
                            </div>
                        </div>
                    @endfor
                </div>
            @endif
        </div>

        <style>
            .badge { display: inline-block; padding: 2px 8px; border-radius: var(--radius-sm); font-size: 0.75rem; font-weight: 500; background: var(--background); }
            .status-badge { display: inline-block; padding: 4px 10px; border-radius: var(--radius-lg); font-size: 0.75rem; font-weight: 500; }
            .table-responsive { overflow-x: auto; }
            .data-table { width: 100%; border-collapse: collapse; font-size: var(--font-size-sm); }
            .data-table th, .data-table td { padding: var(--spacing-sm) var(--spacing-md); text-align: left; border-bottom: 1px solid var(--border-color); }
            .data-table th { background-color: var(--background); font-weight: 600; color: var(--text-secondary); font-size: 0.75rem; text-transform: uppercase; }
            .date-cell { white-space: nowrap; color: var(--text-secondary); }
            .mb-3 { margin-bottom: var(--spacing-lg); }
            .timeline { position: relative; padding-left: 24px; }
            .timeline-item { position: relative; padding-bottom: var(--spacing-lg); }
            .timeline-item:not(:last-child)::before { content: ''; position: absolute; left: -20px; top: 8px; bottom: 0; width: 2px; background: var(--border-color); }
            .timeline-dot { position: absolute; left: -24px; top: 4px; width: 10px; height: 10px; border-radius: 50%; background: var(--primary-color); border: 2px solid var(--surface); }
            .timeline-header { display: flex; align-items: center; gap: var(--spacing-md); margin-bottom: 4px; }
            .timeline-date { font-size: 0.75rem; color: var(--text-secondary); }
            .timeline-message { font-size: var(--font-size-sm); color: var(--text-primary); }
            .btn-sm { padding: var(--spacing-sm) var(--spacing-md); font-size: var(--font-size-sm); }
        </style>
    `
)
