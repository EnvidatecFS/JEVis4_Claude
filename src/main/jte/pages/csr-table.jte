@import org.jevis.model.CsrAction
@import org.jevis.model.CsrCategory
@import org.jevis.model.CsrStatus
@import java.util.List
@import java.time.format.DateTimeFormatter
@import java.time.LocalDate

@param List<CsrAction> actions
@param int currentPage
@param int totalPages
@param long totalElements
@param String search = ""
@param String category = ""
@param String status = ""
@param String sortBy = "createdAt"
@param String sortDir = "desc"
@param CsrCategory[] categories = CsrCategory.values()
@param CsrStatus[] statuses = CsrStatus.values()

!{var formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy").withZone(java.time.ZoneId.systemDefault());}
!{var dateFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy");}

<div class="table-header">
    <span class="table-info">${totalElements} Maßnahmen gefunden</span>
</div>

<div class="table-responsive">
    <table class="data-table">
        <thead>
            <tr>
                <th class="sortable"
                    hx-get="/csr/table?sortBy=title&sortDir=${sortBy.equals("title") && sortDir.equals("asc") ? "desc" : "asc"}&search=${search}&category=${category}&status=${status}"
                    hx-target="#csr-table-container">
                    Titel
                    @if(sortBy.equals("title"))
                        <span class="sort-icon">${sortDir.equals("asc") ? "^" : "v"}</span>
                    @endif
                </th>
                <th class="sortable"
                    hx-get="/csr/table?sortBy=category&sortDir=${sortBy.equals("category") && sortDir.equals("asc") ? "desc" : "asc"}&search=${search}&category=${category}&status=${status}"
                    hx-target="#csr-table-container">
                    Kategorie
                    @if(sortBy.equals("category"))
                        <span class="sort-icon">${sortDir.equals("asc") ? "^" : "v"}</span>
                    @endif
                </th>
                <th class="sortable"
                    hx-get="/csr/table?sortBy=status&sortDir=${sortBy.equals("status") && sortDir.equals("asc") ? "desc" : "asc"}&search=${search}&category=${category}&status=${status}"
                    hx-target="#csr-table-container">
                    Status
                    @if(sortBy.equals("status"))
                        <span class="sort-icon">${sortDir.equals("asc") ? "^" : "v"}</span>
                    @endif
                </th>
                <th>Verantwortlich</th>
                <th class="sortable"
                    hx-get="/csr/table?sortBy=deadline&sortDir=${sortBy.equals("deadline") && sortDir.equals("asc") ? "desc" : "asc"}&search=${search}&category=${category}&status=${status}"
                    hx-target="#csr-table-container">
                    Deadline
                    @if(sortBy.equals("deadline"))
                        <span class="sort-icon">${sortDir.equals("asc") ? "^" : "v"}</span>
                    @endif
                </th>
                <th class="sortable"
                    hx-get="/csr/table?sortBy=progressPercent&sortDir=${sortBy.equals("progressPercent") && sortDir.equals("asc") ? "desc" : "asc"}&search=${search}&category=${category}&status=${status}"
                    hx-target="#csr-table-container">
                    Fortschritt
                    @if(sortBy.equals("progressPercent"))
                        <span class="sort-icon">${sortDir.equals("asc") ? "^" : "v"}</span>
                    @endif
                </th>
                <th class="actions-col">Aktionen</th>
            </tr>
        </thead>
        <tbody>
            @if(actions.isEmpty())
                <tr>
                    <td colspan="7" class="empty-state">
                        <div class="empty-icon">
                            <svg width="48" height="48" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                                      d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                        </div>
                        <p>Keine Maßnahmen gefunden</p>
                        @if(!search.isEmpty() || !category.isEmpty() || !status.isEmpty())
                            <p class="text-muted">Versuchen Sie, die Filter anzupassen</p>
                        @endif
                    </td>
                </tr>
            @else
                @for(CsrAction action : actions)
                    !{var isOverdue = action.getDeadline() != null && action.getDeadline().isBefore(LocalDate.now()) && action.getStatus() != CsrStatus.COMPLETED && action.getStatus() != CsrStatus.CANCELLED;}
                    <tr id="csr-row-${action.getId()}">
                        <td>
                            <div class="action-title">${action.getTitle()}</div>
                            @if(action.getDescription() != null && !action.getDescription().isEmpty())
                                <div class="action-description">${action.getDescription().length() > 80 ? action.getDescription().substring(0, 80) + "..." : action.getDescription()}</div>
                            @endif
                        </td>
                        <td>
                            <span class="category-badge" style="background-color: ${action.getCategory().getColor()}20; color: ${action.getCategory().getColor()}; border: 1px solid ${action.getCategory().getColor()}40;">
                                ${action.getCategory().getDisplayName()}
                            </span>
                        </td>
                        <td>
                            <span class="status-badge" style="background-color: ${action.getStatus().getColor()}20; color: ${action.getStatus().getColor()};">
                                ${action.getStatus().getDisplayName()}
                            </span>
                        </td>
                        <td>${action.getResponsiblePerson() != null ? action.getResponsiblePerson() : "-"}</td>
                        <td class="date-cell ${isOverdue ? "overdue" : ""}">
                            @if(action.getDeadline() != null)
                                ${dateFormatter.format(action.getDeadline())}
                                @if(isOverdue)
                                    <span class="overdue-badge">Überfällig</span>
                                @endif
                            @else
                                -
                            @endif
                        </td>
                        <td>
                            <div class="progress-container">
                                <div class="progress-bar">
                                    <div class="progress-fill" style="width: ${action.getProgressPercent()}%; background-color: ${action.getStatus() == CsrStatus.COMPLETED ? "#10b981" : "#3b82f6"};"></div>
                                </div>
                                <span class="progress-text">${action.getProgressPercent()}%</span>
                            </div>
                        </td>
                        <td class="actions-cell">
                            <button class="btn-icon" title="Bearbeiten"
                                    hx-get="/csr/${action.getId()}/edit"
                                    hx-target="#modal-container"
                                    hx-swap="innerHTML">
                                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                                </svg>
                            </button>
                            <button class="btn-icon btn-icon-danger" title="Löschen"
                                    hx-delete="/csr/${action.getId()}"
                                    hx-target="#csr-row-${action.getId()}"
                                    hx-swap="outerHTML"
                                    hx-confirm="Möchten Sie diese Maßnahme wirklich löschen?">
                                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                                </svg>
                            </button>
                        </td>
                    </tr>
                @endfor
            @endif
        </tbody>
    </table>
</div>

<!-- Pagination -->
@if(totalPages > 1)
    <div class="pagination">
        <button class="btn btn-outline btn-sm"
                disabled="${currentPage == 0}"
                hx-get="/csr/table?page=${currentPage - 1}&search=${search}&category=${category}&status=${status}&sortBy=${sortBy}&sortDir=${sortDir}"
                hx-target="#csr-table-container">
            Zurück
        </button>
        <span class="pagination-info">Seite ${currentPage + 1} von ${totalPages}</span>
        <button class="btn btn-outline btn-sm"
                disabled="${currentPage >= totalPages - 1}"
                hx-get="/csr/table?page=${currentPage + 1}&search=${search}&category=${category}&status=${status}&sortBy=${sortBy}&sortDir=${sortDir}"
                hx-target="#csr-table-container">
            Weiter
        </button>
    </div>
@endif

<style>
    .table-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: var(--spacing-md);
    }
    .table-info {
        color: var(--text-secondary);
        font-size: var(--font-size-sm);
    }
    .table-responsive {
        overflow-x: auto;
    }
    .data-table {
        width: 100%;
        border-collapse: collapse;
        font-size: var(--font-size-sm);
    }
    .data-table th,
    .data-table td {
        padding: var(--spacing-md);
        text-align: left;
        border-bottom: 1px solid var(--border-color);
    }
    .data-table th {
        background-color: var(--background);
        font-weight: 600;
        color: var(--text-secondary);
        font-size: 0.75rem;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    .data-table th.sortable {
        cursor: pointer;
        user-select: none;
    }
    .data-table th.sortable:hover {
        background-color: var(--border-color);
    }
    .sort-icon {
        margin-left: var(--spacing-sm);
        font-size: 0.7rem;
    }
    .data-table tbody tr:hover {
        background-color: var(--background);
    }
    .action-title {
        font-weight: 500;
        color: var(--text-primary);
    }
    .action-description {
        font-size: 0.75rem;
        color: var(--text-secondary);
        margin-top: 2px;
    }
    .category-badge {
        display: inline-block;
        padding: 4px 10px;
        border-radius: var(--radius-lg);
        font-size: 0.75rem;
        font-weight: 500;
    }
    .status-badge {
        display: inline-block;
        padding: 4px 10px;
        border-radius: var(--radius-lg);
        font-size: 0.75rem;
        font-weight: 500;
    }
    .date-cell {
        white-space: nowrap;
        color: var(--text-secondary);
    }
    .date-cell.overdue {
        color: #ef4444;
    }
    .overdue-badge {
        display: inline-block;
        margin-left: 4px;
        padding: 2px 6px;
        background-color: #fee2e2;
        color: #ef4444;
        border-radius: var(--radius-sm);
        font-size: 0.65rem;
        font-weight: 600;
    }
    .progress-container {
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    .progress-bar {
        flex: 1;
        height: 8px;
        background-color: var(--border-color);
        border-radius: 4px;
        overflow: hidden;
        min-width: 60px;
    }
    .progress-fill {
        height: 100%;
        transition: width 0.3s ease;
    }
    .progress-text {
        font-size: 0.75rem;
        color: var(--text-secondary);
        min-width: 35px;
        text-align: right;
    }
    .actions-col {
        width: 100px;
        text-align: center;
    }
    .actions-cell {
        text-align: center;
        white-space: nowrap;
    }
    .btn-icon {
        background: none;
        border: none;
        cursor: pointer;
        padding: var(--spacing-sm);
        color: var(--text-secondary);
        border-radius: var(--radius-md);
        transition: all 0.2s;
    }
    .btn-icon:hover {
        background-color: var(--background);
        color: var(--primary-color);
    }
    .btn-icon-danger:hover {
        background-color: #fee2e2;
        color: var(--danger-color);
    }
    .empty-state {
        text-align: center;
        padding: var(--spacing-2xl) !important;
        color: var(--text-secondary);
    }
    .empty-icon {
        margin-bottom: var(--spacing-md);
        opacity: 0.5;
    }
    .pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: var(--spacing-md);
        margin-top: var(--spacing-lg);
        padding-top: var(--spacing-lg);
        border-top: 1px solid var(--border-color);
    }
    .pagination-info {
        color: var(--text-secondary);
        font-size: var(--font-size-sm);
    }
    .btn-sm {
        padding: var(--spacing-sm) var(--spacing-md);
        font-size: var(--font-size-sm);
    }
</style>
