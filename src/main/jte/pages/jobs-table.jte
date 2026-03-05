@import org.jevis.model.Job
@import org.jevis.model.JobStatus
@import java.util.List
@import java.time.format.DateTimeFormatter

@param List<Job> jobs
@param int currentPage
@param int totalPages
@param long totalElements
@param String search = ""
@param String statusFilter = ""
@param String typeFilter = ""
@param String sortBy = "createdAt"
@param String sortDir = "desc"

!{var formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm").withZone(java.time.ZoneId.systemDefault());}

<div class="table-header">
    <span class="table-info">${totalElements} Jobs gefunden</span>
</div>

<div class="table-responsive">
    <table class="data-table">
        <thead>
            <tr>
                <th>ID</th>
                <th class="sortable"
                    hx-get="/jobs/table?sortBy=jobName&sortDir=${sortBy.equals("jobName") && sortDir.equals("asc") ? "desc" : "asc"}&search=${search}&statusFilter=${statusFilter}&typeFilter=${typeFilter}"
                    hx-target="#jobs-table-container">
                    Name
                    @if(sortBy.equals("jobName"))
                        <span class="sort-icon">${sortDir.equals("asc") ? "^" : "v"}</span>
                    @endif
                </th>
                <th>Typ</th>
                <th class="sortable"
                    hx-get="/jobs/table?sortBy=status&sortDir=${sortBy.equals("status") && sortDir.equals("asc") ? "desc" : "asc"}&search=${search}&statusFilter=${statusFilter}&typeFilter=${typeFilter}"
                    hx-target="#jobs-table-container">
                    Status
                </th>
                <th>Priorität</th>
                <th class="sortable"
                    hx-get="/jobs/table?sortBy=createdAt&sortDir=${sortBy.equals("createdAt") && sortDir.equals("asc") ? "desc" : "asc"}&search=${search}&statusFilter=${statusFilter}&typeFilter=${typeFilter}"
                    hx-target="#jobs-table-container">
                    Erstellt
                    @if(sortBy.equals("createdAt"))
                        <span class="sort-icon">${sortDir.equals("asc") ? "^" : "v"}</span>
                    @endif
                </th>
                <th>Retries</th>
                <th class="actions-col">Aktionen</th>
            </tr>
        </thead>
        <tbody>
            @if(jobs.isEmpty())
                <tr>
                    <td colspan="8" class="empty-state">
                        <p>Keine Jobs gefunden</p>
                    </td>
                </tr>
            @else
                @for(Job job : jobs)
                    <tr>
                        <td><code>#${job.getId()}</code></td>
                        <td>
                            <a href="/jobs/${job.getId()}" style="color: var(--primary-color); text-decoration: none; font-weight: 500;">
                                ${job.getJobName()}
                            </a>
                        </td>
                        <td><span class="badge" style="background-color: ${job.getJobType().getColor()}20; color: ${job.getJobType().getColor()};">${job.getJobType().getDisplayName()}</span></td>
                        <td><span class="status-badge" style="background-color: ${job.getStatus().getColor()}20; color: ${job.getStatus().getColor()};">${job.getStatus().getDisplayName()}</span></td>
                        <td><span class="badge" style="background-color: ${job.getPriority().getColor()}20; color: ${job.getPriority().getColor()};">${job.getPriority().getDisplayName()}</span></td>
                        <td class="date-cell">${job.getCreatedAt() != null ? formatter.format(job.getCreatedAt()) : "-"}</td>
                        <td>${job.getRetryCount()}/${job.getMaxRetryAttempts()}</td>
                        <td class="actions-cell">
                            <a href="/jobs/${job.getId()}" class="btn-icon" title="Details">
                                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                </svg>
                            </a>
                            @if(job.getStatus() != JobStatus.COMPLETED && job.getStatus() != JobStatus.CANCELLED && job.getStatus() != JobStatus.ALARM)
                                <button class="btn-icon btn-icon-danger" title="Abbrechen"
                                        onclick="cancelJob(${job.getId()})">
                                    <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                                    </svg>
                                </button>
                            @endif
                        </td>
                    </tr>
                @endfor
            @endif
        </tbody>
    </table>
</div>

@if(totalPages > 1)
    <div class="pagination">
        <button class="btn btn-outline btn-sm"
                disabled="${currentPage == 0}"
                hx-get="/jobs/table?page=${currentPage - 1}&search=${search}&statusFilter=${statusFilter}&typeFilter=${typeFilter}&sortBy=${sortBy}&sortDir=${sortDir}"
                hx-target="#jobs-table-container">
            Zurück
        </button>
        <span class="pagination-info">Seite ${currentPage + 1} von ${totalPages}</span>
        <button class="btn btn-outline btn-sm"
                disabled="${currentPage >= totalPages - 1}"
                hx-get="/jobs/table?page=${currentPage + 1}&search=${search}&statusFilter=${statusFilter}&typeFilter=${typeFilter}&sortBy=${sortBy}&sortDir=${sortDir}"
                hx-target="#jobs-table-container">
            Weiter
        </button>
    </div>
@endif

<script>
    function cancelJob(jobId) {
        if (!confirm('Job wirklich abbrechen?')) return;
        var csrfToken = document.querySelector('meta[name="csrf-token"]').content;
        var csrfHeader = document.querySelector('meta[name="csrf-header"]').content;
        var headers = {};
        headers[csrfHeader] = csrfToken;
        fetch('/jobs/' + jobId + '/cancel', { method: 'POST', headers: headers })
            .then(function() { htmx.trigger('#jobs-table-container', 'load'); });
    }
</script>

<style>
    .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--spacing-md); }
    .table-info { color: var(--text-secondary); font-size: var(--font-size-sm); }
    .table-responsive { overflow-x: auto; }
    .data-table { width: 100%; border-collapse: collapse; font-size: var(--font-size-sm); }
    .data-table th, .data-table td { padding: var(--spacing-md); text-align: left; border-bottom: 1px solid var(--border-color); }
    .data-table th { background-color: var(--background); font-weight: 600; color: var(--text-secondary); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; }
    .data-table th.sortable { cursor: pointer; user-select: none; }
    .data-table th.sortable:hover { background-color: var(--border-color); }
    .sort-icon { margin-left: var(--spacing-sm); font-size: 0.7rem; }
    .data-table tbody tr:hover { background-color: var(--background); }
    .badge { display: inline-block; padding: 2px 8px; border-radius: var(--radius-sm); font-size: 0.75rem; font-weight: 500; }
    .status-badge { display: inline-block; padding: 4px 10px; border-radius: var(--radius-lg); font-size: 0.75rem; font-weight: 500; }
    .date-cell { white-space: nowrap; color: var(--text-secondary); }
    .actions-col { width: 100px; text-align: center; }
    .actions-cell { text-align: center; white-space: nowrap; }
    .btn-icon { background: none; border: none; cursor: pointer; padding: var(--spacing-sm); color: var(--text-secondary); border-radius: var(--radius-md); transition: all 0.2s; display: inline-flex; }
    .btn-icon:hover { background-color: var(--background); color: var(--primary-color); }
    .btn-icon-danger:hover { background-color: #fee2e2; color: var(--danger-color); }
    .empty-state { text-align: center; padding: var(--spacing-2xl) !important; color: var(--text-secondary); }
    .pagination { display: flex; justify-content: center; align-items: center; gap: var(--spacing-md); margin-top: var(--spacing-lg); padding-top: var(--spacing-lg); border-top: 1px solid var(--border-color); }
    .pagination-info { color: var(--text-secondary); font-size: var(--font-size-sm); }
    .btn-sm { padding: var(--spacing-sm) var(--spacing-md); font-size: var(--font-size-sm); }
</style>
