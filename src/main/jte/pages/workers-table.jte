@import org.jevis.model.TaskWorker
@import org.jevis.model.WorkerPool
@import java.util.List
@import java.time.format.DateTimeFormatter
@import java.time.Duration
@import java.time.Instant

@param List<TaskWorker> workers
@param List<WorkerPool> pools

!{var formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm:ss").withZone(java.time.ZoneId.systemDefault());}

<!-- Pool Overview -->
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: var(--spacing-md); margin-bottom: var(--spacing-lg);">
    @for(WorkerPool pool : pools)
        <div class="card" style="padding: var(--spacing-lg);">
            <div style="font-weight: 600; margin-bottom: 4px;">${pool.getPoolName()}</div>
            <div style="font-size: var(--font-size-sm); color: var(--text-secondary);">${pool.getDescription() != null ? pool.getDescription() : ""}</div>
            <div style="margin-top: var(--spacing-sm); font-size: var(--font-size-sm);">
                Max Jobs: <strong>${pool.getMaxConcurrentJobs()}</strong>
                @if(pool.getIsDefault())
                    <span class="badge" style="background: #dbeafe; color: #1e40af; margin-left: 8px;">Default</span>
                @endif
            </div>
        </div>
    @endfor
</div>

<div class="table-header">
    <span class="table-info">${workers.size()} Worker registriert</span>
</div>

<div class="table-responsive">
    <table class="data-table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Pool</th>
                <th>Status</th>
                <th>Jobs</th>
                <th>Capabilities</th>
                <th>Host</th>
                <th>Letzter Heartbeat</th>
            </tr>
        </thead>
        <tbody>
            @if(workers.isEmpty())
                <tr>
                    <td colspan="8" class="empty-state">
                        <p>Keine Worker registriert</p>
                        <p style="font-size: 0.8rem; color: var(--text-secondary);">Worker können sich über die REST-API registrieren: POST /api/workers/register</p>
                    </td>
                </tr>
            @else
                @for(TaskWorker worker : workers)
                    <tr>
                        <td><code>#${worker.getId()}</code></td>
                        <td style="font-weight: 500;">${worker.getWorkerName() != null ? worker.getWorkerName() : worker.getWorkerIdentifier()}</td>
                        <td>${worker.getWorkerPool() != null ? worker.getWorkerPool().getPoolName() : "-"}</td>
                        <td>
                            <span class="status-badge" style="background-color: ${worker.getStatus().getColor()}20; color: ${worker.getStatus().getColor()};">
                                ${worker.getStatus().getDisplayName()}
                            </span>
                        </td>
                        <td>${worker.getCurrentJobCount()} / ${worker.getMaxConcurrentJobs()}</td>
                        <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis;">${worker.getCapabilities() != null ? worker.getCapabilities() : "Alle"}</td>
                        <td>${worker.getHostName() != null ? worker.getHostName() : "-"}</td>
                        <td class="date-cell">${worker.getLastHeartbeatAt() != null ? formatter.format(worker.getLastHeartbeatAt()) : "-"}</td>
                    </tr>
                @endfor
            @endif
        </tbody>
    </table>
</div>

<style>
    .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--spacing-md); }
    .table-info { color: var(--text-secondary); font-size: var(--font-size-sm); }
    .table-responsive { overflow-x: auto; }
    .data-table { width: 100%; border-collapse: collapse; font-size: var(--font-size-sm); }
    .data-table th, .data-table td { padding: var(--spacing-md); text-align: left; border-bottom: 1px solid var(--border-color); }
    .data-table th { background-color: var(--background); font-weight: 600; color: var(--text-secondary); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; }
    .data-table tbody tr:hover { background-color: var(--background); }
    .badge { display: inline-block; padding: 2px 8px; border-radius: var(--radius-sm); font-size: 0.75rem; font-weight: 500; }
    .status-badge { display: inline-block; padding: 4px 10px; border-radius: var(--radius-lg); font-size: 0.75rem; font-weight: 500; }
    .date-cell { white-space: nowrap; color: var(--text-secondary); }
    .empty-state { text-align: center; padding: var(--spacing-2xl) !important; color: var(--text-secondary); }
</style>
