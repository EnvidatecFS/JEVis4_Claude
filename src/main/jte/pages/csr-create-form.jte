@import org.jevis.model.CsrAction
@import org.jevis.model.CsrCategory
@import org.jevis.model.CsrStatus

@param CsrAction action = new CsrAction()
@param CsrCategory[] categories = CsrCategory.values()
@param CsrStatus[] statuses = CsrStatus.values()
@param Boolean success = null
@param String message = null

<div class="modal-backdrop" onclick="closeModal()"></div>
<div class="modal modal-lg">
    <div class="modal-header">
        <h3>Neue Maßnahme</h3>
        <button class="modal-close" onclick="closeModal()">&times;</button>
    </div>

    @if(success != null)
        @if(success)
            <div class="alert alert-success">
                ${message}
                <script>
                    setTimeout(function() {
                        closeModal();
                        htmx.ajax('GET', '/csr/table', '#csr-table-container');
                    }, 1500);
                </script>
            </div>
        @else
            <div class="alert alert-danger">${message}</div>
        @endif
    @endif

    @if(success == null || !success)
    <form hx-post="/csr"
          hx-target="#modal-container"
          hx-swap="innerHTML">

        <div class="modal-body">
            <div class="form-group">
                <label for="title">Titel *</label>
                <input type="text" id="title" name="title"
                       value="${action.getTitle() != null ? action.getTitle() : ""}" required
                       placeholder="z.B. CO2-Reduktion um 20% bis 2025">
                <span class="form-help">Geben Sie einen aussagekräftigen Titel für die Maßnahme ein</span>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="category">Kategorie *</label>
                    <select id="category" name="category" required>
                        <option value="">Bitte wählen...</option>
                        @for(CsrCategory cat : categories)
                            @if(action.getCategory() == cat)
                                <option value="${cat.name()}" selected>${cat.getDisplayName()}</option>
                            @else
                                <option value="${cat.name()}">${cat.getDisplayName()}</option>
                            @endif
                        @endfor
                    </select>
                </div>
                <div class="form-group">
                    <label for="status">Status</label>
                    <select id="status" name="status">
                        @for(CsrStatus st : statuses)
                            @if(st == CsrStatus.PLANNED)
                                <option value="${st.name()}" selected>${st.getDisplayName()}</option>
                            @else
                                <option value="${st.name()}">${st.getDisplayName()}</option>
                            @endif
                        @endfor
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="description">Beschreibung</label>
                <textarea id="description" name="description" rows="3"
                          placeholder="Detaillierte Beschreibung der Maßnahme...">${action.getDescription() != null ? action.getDescription() : ""}</textarea>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="responsiblePerson">Verantwortlich</label>
                    <input type="text" id="responsiblePerson" name="responsiblePerson"
                           value="${action.getResponsiblePerson() != null ? action.getResponsiblePerson() : ""}"
                           placeholder="z.B. Max Mustermann">
                </div>
                <div class="form-group">
                    <label for="deadline">Deadline</label>
                    <input type="date" id="deadline" name="deadline"
                           value="${action.getDeadline() != null ? action.getDeadline().toString() : ""}">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="priority">Priorität</label>
                    <select id="priority" name="priority">
                        <option value="LOW">Niedrig</option>
                        <option value="MEDIUM" selected>Mittel</option>
                        <option value="HIGH">Hoch</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="progressPercent">Fortschritt (%)</label>
                    <input type="number" id="progressPercent" name="progressPercent"
                           value="0" min="0" max="100">
                </div>
            </div>

            <div class="form-group">
                <label for="estimatedImpact">Erwartete Wirkung</label>
                <textarea id="estimatedImpact" name="estimatedImpact" rows="2"
                          placeholder="z.B. Reduktion von 500 Tonnen CO2 pro Jahr...">${action.getEstimatedImpact() != null ? action.getEstimatedImpact() : ""}</textarea>
            </div>
        </div>

        <div class="modal-footer">
            <button type="button" class="btn btn-outline" onclick="closeModal()">Abbrechen</button>
            <button type="submit" class="btn btn-primary">Erstellen</button>
        </div>
    </form>
    @endif
</div>

<style>
    .modal-backdrop {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: rgba(0, 0, 0, 0.5);
        z-index: 1000;
    }
    .modal {
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: var(--surface);
        border-radius: var(--radius-xl);
        box-shadow: var(--shadow-lg);
        width: 90%;
        max-width: 600px;
        max-height: 90vh;
        overflow-y: auto;
        z-index: 1001;
    }
    .modal-lg {
        max-width: 700px;
    }
    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: var(--spacing-lg);
        border-bottom: 1px solid var(--border-color);
    }
    .modal-header h3 {
        margin: 0;
    }
    .modal-close {
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        color: var(--text-secondary);
        padding: var(--spacing-sm);
        line-height: 1;
    }
    .modal-close:hover {
        color: var(--text-primary);
    }
    .modal-body {
        padding: var(--spacing-lg);
    }
    .modal-footer {
        display: flex;
        justify-content: flex-end;
        gap: var(--spacing-md);
        padding: var(--spacing-lg);
        border-top: 1px solid var(--border-color);
    }
    .form-row {
        display: flex;
        gap: var(--spacing-lg);
    }
    .form-row .form-group {
        flex: 1;
    }
    @media (max-width: 600px) {
        .form-row {
            flex-direction: column;
            gap: 0;
        }
    }
</style>

<script>
    function closeModal() {
        document.getElementById('modal-container').innerHTML = '';
        // Refresh the table
        htmx.ajax('GET', '/csr/table', '#csr-table-container');
    }

    // Close modal on escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeModal();
        }
    });
</script>
