@import org.springframework.security.web.csrf.CsrfToken
@import org.jevis.model.JobStatus
@import org.jevis.model.JobType

@param String username
@param CsrfToken _csrf = null

@template.layout.app(
    title = "Jobs",
    username = username,
    currentPage = "jobs",
    _csrf = _csrf,
    content = @`
        <div class="page-header d-flex justify-between align-center">
            <div>
                <h1 class="page-title">Job-Verwaltung</h1>
                <p class="page-description">Überwachen und verwalten Sie alle geplanten und laufenden Jobs</p>
            </div>
            <button class="btn btn-primary" onclick="showCreateJobModal()">
                + Job erstellen
            </button>
        </div>

        <!-- Filter Section -->
        <div class="card mb-3">
            <div class="filter-row">
                <div class="filter-group">
                    <label for="search">Suche</label>
                    <input type="text" id="search" name="search" placeholder="Job-Name..."
                           hx-get="/jobs/table"
                           hx-trigger="keyup changed delay:300ms"
                           hx-target="#jobs-table-container"
                           hx-include="[name='statusFilter'], [name='typeFilter']">
                </div>
                <div class="filter-group">
                    <label for="statusFilter">Status</label>
                    <select id="statusFilter" name="statusFilter"
                            hx-get="/jobs/table"
                            hx-trigger="change"
                            hx-target="#jobs-table-container"
                            hx-include="[name='search'], [name='typeFilter']">
                        <option value="">Alle Status</option>
                        @for(JobStatus s : JobStatus.values())
                            <option value="${s.name()}">${s.getDisplayName()}</option>
                        @endfor
                    </select>
                </div>
                <div class="filter-group">
                    <label for="typeFilter">Typ</label>
                    <select id="typeFilter" name="typeFilter"
                            hx-get="/jobs/table"
                            hx-trigger="change"
                            hx-target="#jobs-table-container"
                            hx-include="[name='search'], [name='statusFilter']">
                        <option value="">Alle Typen</option>
                        @for(JobType t : JobType.values())
                            <option value="${t.name()}">${t.getDisplayName()}</option>
                        @endfor
                    </select>
                </div>
                <div class="filter-group filter-actions">
                    <label>&nbsp;</label>
                    <button type="button" class="btn btn-outline" onclick="resetJobFilters()">
                        Filter zurücksetzen
                    </button>
                </div>
            </div>
        </div>

        <!-- Table Container -->
        <div class="card">
            <div id="jobs-table-container"
                 hx-get="/jobs/table"
                 hx-trigger="load, every 10s"
                 hx-swap="innerHTML">
                <div class="loading-spinner">Lade Jobs...</div>
            </div>
        </div>

        <!-- Create Job Modal -->
        <div id="create-job-modal" class="modal-overlay" style="display:none;">
            <div class="modal-content">
                <div class="modal-header">
                    <h2>Neuen Job erstellen</h2>
                    <button class="btn-close" onclick="closeCreateJobModal()">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label for="newJobName">Job-Name</label>
                        <input type="text" id="newJobName" placeholder="z.B. Daten-Import Station A">
                    </div>
                    <div class="form-group">
                        <label for="newJobType">Job-Typ</label>
                        <select id="newJobType">
                            @for(JobType t : JobType.values())
                                <option value="${t.name()}">${t.getDisplayName()}</option>
                            @endfor
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="newJobPriority">Priorität</label>
                        <select id="newJobPriority">
                            <option value="NORMAL" selected>Normal</option>
                            <option value="CRITICAL">Kritisch</option>
                            <option value="HIGH">Hoch</option>
                            <option value="LOW">Niedrig</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="newJobParams">Parameter (JSON)</label>
                        <textarea id="newJobParams" rows="3" placeholder='{"url": "https://...", "sensorId": 1}'></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-outline" onclick="closeCreateJobModal()">Abbrechen</button>
                    <button class="btn btn-primary" onclick="submitCreateJob()">Job erstellen</button>
                </div>
            </div>
        </div>

        <style>
            .filter-row { display: flex; gap: var(--spacing-lg); flex-wrap: wrap; align-items: flex-end; }
            .filter-group { flex: 1; min-width: 200px; }
            .filter-group label { display: block; margin-bottom: var(--spacing-sm); font-weight: 500; font-size: var(--font-size-sm); }
            .filter-actions { flex: 0 0 auto; min-width: auto; }
            .loading-spinner { text-align: center; padding: var(--spacing-xl); color: var(--text-secondary); }
            .modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1000; }
            .modal-content { background: var(--surface); border-radius: var(--radius-lg); width: 90%; max-width: 500px; box-shadow: var(--shadow-xl); }
            .modal-header { display: flex; justify-content: space-between; align-items: center; padding: var(--spacing-lg); border-bottom: 1px solid var(--border-color); }
            .modal-header h2 { margin: 0; font-size: 1.1rem; }
            .btn-close { background: none; border: none; font-size: 1.5rem; cursor: pointer; color: var(--text-secondary); }
            .modal-body { padding: var(--spacing-lg); }
            .modal-footer { display: flex; justify-content: flex-end; gap: var(--spacing-md); padding: var(--spacing-lg); border-top: 1px solid var(--border-color); }
        </style>

        <script>
            function resetJobFilters() {
                document.getElementById('search').value = '';
                document.getElementById('statusFilter').value = '';
                document.getElementById('typeFilter').value = '';
                htmx.trigger('#search', 'keyup');
            }
            function showCreateJobModal() {
                document.getElementById('create-job-modal').style.display = 'flex';
            }
            function closeCreateJobModal() {
                document.getElementById('create-job-modal').style.display = 'none';
            }
            function submitCreateJob() {
                var csrfToken = document.querySelector('meta[name="csrf-token"]').content;
                var csrfHeader = document.querySelector('meta[name="csrf-header"]').content;

                var formData = new URLSearchParams();
                formData.append('jobName', document.getElementById('newJobName').value);
                formData.append('jobType', document.getElementById('newJobType').value);
                formData.append('priority', document.getElementById('newJobPriority').value);
                formData.append('jobParameters', document.getElementById('newJobParams').value);

                var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
                headers[csrfHeader] = csrfToken;

                fetch('/jobs/create', {
                    method: 'POST',
                    headers: headers,
                    body: formData.toString()
                }).then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.error) { alert('Fehler: ' + data.error); return; }
                    closeCreateJobModal();
                    htmx.trigger('#jobs-table-container', 'load');
                });
            }
        </script>
    `
)
