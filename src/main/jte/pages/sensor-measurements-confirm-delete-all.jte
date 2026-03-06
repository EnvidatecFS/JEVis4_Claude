@param Long sensorId
@param long count

<div class="confirm-delete-panel" id="confirm-delete-panel">
    <div class="confirm-icon">&#9888;</div>
    <div class="confirm-text">
        <strong>Alle ${count} Messwerte löschen?</strong>
        <p>Diese Aktion kann nicht rückgängig gemacht werden. Alle Messwerte dieses Messpunkts werden dauerhaft gelöscht.</p>
    </div>
    <div class="confirm-actions" id="confirm-step1-actions">
        <button type="button" class="btn btn-outline"
                onclick="document.getElementById('confirm-delete-panel').remove()">
            Abbrechen
        </button>
        <button type="button" class="btn"
                style="background:#dc2626; color:white; border-color:#dc2626;"
                onclick="showFinalConfirm()">
            Ja, alle löschen
        </button>
    </div>

    <div id="confirm-step2" style="display:none; margin-top: var(--spacing-md); padding-top: var(--spacing-md); border-top: 1px solid #fca5a5;">
        <p style="color: #991b1b; font-weight:600; margin:0 0 var(--spacing-md) 0;">
            Letzte Warnung: Wirklich alle ${count} Messwerte unwiderruflich löschen?
        </p>
        <div style="display:flex; gap: var(--spacing-md); justify-content: flex-end;">
            <button type="button" class="btn btn-outline"
                    onclick="document.getElementById('confirm-delete-panel').remove()">
                Abbrechen
            </button>
            <button type="button" class="btn"
                    style="background:#991b1b; color:white; border-color:#991b1b;"
                    hx-delete="/sensors/${sensorId}/measurements/all"
                    hx-target="#measurements-list"
                    hx-swap="innerHTML">
                Endgültig löschen
            </button>
        </div>
    </div>
</div>

<style>
    .confirm-delete-panel {
        display: flex;
        flex-direction: column;
        gap: var(--spacing-sm);
        background: #fff5f5;
        border: 1px solid #fca5a5;
        border-radius: var(--radius-md);
        padding: var(--spacing-lg);
        margin-bottom: var(--spacing-md);
    }
    .confirm-icon {
        font-size: 1.5rem;
        color: #dc2626;
    }
    .confirm-text p {
        margin: 4px 0 0 0;
        font-size: var(--font-size-sm);
        color: #7f1d1d;
    }
    .confirm-actions {
        display: flex;
        gap: var(--spacing-md);
        justify-content: flex-end;
    }
</style>

<script>
    function showFinalConfirm() {
        document.getElementById('confirm-step2').style.display = 'block';
        document.getElementById('confirm-step1-actions').style.display = 'none';
        htmx.process(document.getElementById('confirm-step2'));
    }
</script>
