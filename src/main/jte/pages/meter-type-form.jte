@import org.jevis.model.MeterType
@import org.springframework.security.web.csrf.CsrfToken

@param MeterType meterType
@param boolean isNew = true
@param String error = null
@param boolean success = false
@param CsrfToken _csrf = null

<div class="modal-backdrop"></div>
<div class="modal" style="min-height: 400px;">
    <div class="modal-header">
        <h2 class="modal-title">${isNew ? "Neuer Zählertyp" : "Zählertyp bearbeiten"}</h2>
        <button type="button" class="modal-close" onclick="closeModal()">×</button>
    </div>

    @if(success)
        <div class="alert alert-success" style="margin: var(--spacing-md);">Gespeichert.</div>
        <script>
            setTimeout(function() {
                closeModal();
                htmx.ajax('GET', '/meter-types/table', '#meter-types-table-container');
            }, 600);
        </script>
    @endif

    @if(error != null)
        <div class="alert alert-danger" style="margin: var(--spacing-md);">${error}</div>
    @endif

    @if(isNew)
    <form hx-encoding="multipart/form-data"
          hx-post="/meter-types"
          hx-target="#modal-container"
          hx-swap="innerHTML">

        @if(_csrf != null)
            <input type="hidden" name="${_csrf.getParameterName()}" value="${_csrf.getToken()}">
        @endif

        <div class="modal-body">
            <div class="form-row">
                <div class="form-group">
                    <label for="deviceType">Gerätetype</label>
                    <input type="text" id="deviceType" name="deviceType"
                           value="${meterType.getDeviceType() != null ? meterType.getDeviceType() : ""}">
                </div>
                <div class="form-group">
                    <label for="manufacturer">Herstellerfirma</label>
                    <input type="text" id="manufacturer" name="manufacturer"
                           value="${meterType.getManufacturer() != null ? meterType.getManufacturer() : ""}">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="accuracy">Genauigkeit</label>
                    <input type="text" id="accuracy" name="accuracy"
                           value="${meterType.getAccuracy() != null ? meterType.getAccuracy() : ""}">
                </div>
                <div class="form-group">
                    <label for="decimalPlaces">Dezimalstellen</label>
                    <input type="number" id="decimalPlaces" name="decimalPlaces" min="0" max="10"
                           value="${meterType.getDecimalPlaces() != null ? meterType.getDecimalPlaces().toString() : ""}">
                </div>
            </div>
            <div class="form-group">
                <label for="manufacturerUrl">URL Hersteller</label>
                <input type="url" id="manufacturerUrl" name="manufacturerUrl"
                       value="${meterType.getManufacturerUrl() != null ? meterType.getManufacturerUrl() : ""}">
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="datasheet">Datenblatt (PDF/Word)</label>
                    <input type="file" id="datasheet" name="datasheet" accept=".pdf,.doc,.docx">
                </div>
                <div class="form-group">
                    <label for="meterTypeImage">Bild (Herstellerfoto)</label>
                    <input type="file" id="meterTypeImage" name="meterTypeImage" accept=".jpg,.jpeg,.png">
                </div>
            </div>
        </div>

        <div class="modal-footer">
            <button type="button" class="btn btn-outline" onclick="closeModal()">Abbrechen</button>
            <button type="submit" class="btn btn-primary">Speichern</button>
        </div>
    </form>
    @else
    <form hx-encoding="multipart/form-data"
          hx-put="/meter-types/${meterType.getId()}"
          hx-target="#modal-container"
          hx-swap="innerHTML">

        @if(_csrf != null)
            <input type="hidden" name="${_csrf.getParameterName()}" value="${_csrf.getToken()}">
        @endif

        <div class="modal-body">
            <div class="form-row">
                <div class="form-group">
                    <label for="deviceType">Gerätetype</label>
                    <input type="text" id="deviceType" name="deviceType"
                           value="${meterType.getDeviceType() != null ? meterType.getDeviceType() : ""}">
                </div>
                <div class="form-group">
                    <label for="manufacturer">Herstellerfirma</label>
                    <input type="text" id="manufacturer" name="manufacturer"
                           value="${meterType.getManufacturer() != null ? meterType.getManufacturer() : ""}">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="accuracy">Genauigkeit</label>
                    <input type="text" id="accuracy" name="accuracy"
                           value="${meterType.getAccuracy() != null ? meterType.getAccuracy() : ""}">
                </div>
                <div class="form-group">
                    <label for="decimalPlaces">Dezimalstellen</label>
                    <input type="number" id="decimalPlaces" name="decimalPlaces" min="0" max="10"
                           value="${meterType.getDecimalPlaces() != null ? meterType.getDecimalPlaces().toString() : ""}">
                </div>
            </div>
            <div class="form-group">
                <label for="manufacturerUrl">URL Hersteller</label>
                <input type="url" id="manufacturerUrl" name="manufacturerUrl"
                       value="${meterType.getManufacturerUrl() != null ? meterType.getManufacturerUrl() : ""}">
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="datasheet">Datenblatt (PDF/Word)</label>
                    <input type="file" id="datasheet" name="datasheet" accept=".pdf,.doc,.docx">
                    @if(meterType.getDatasheetPath() != null)
                        <a href="/uploads/${meterType.getDatasheetPath()}" target="_blank" style="font-size:0.8rem;">Aktuelles Datenblatt</a>
                    @endif
                </div>
                <div class="form-group">
                    <label for="meterTypeImage">Bild (Herstellerfoto)</label>
                    <input type="file" id="meterTypeImage" name="meterTypeImage" accept=".jpg,.jpeg,.png">
                    @if(meterType.getImagePath() != null)
                        <img src="/uploads/${meterType.getImagePath()}" style="max-height:60px; display:block; margin-top:4px;">
                    @endif
                </div>
            </div>
        </div>

        <div class="modal-footer">
            <button type="button" class="btn btn-outline" onclick="closeModal()">Abbrechen</button>
            <button type="submit" class="btn btn-primary">Speichern</button>
        </div>
    </form>
    @endif
</div>

<style>
    .modal-backdrop {
        position: fixed; top: 0; left: 0; right: 0; bottom: 0;
        background-color: rgba(0,0,0,0.5); z-index: 1000;
    }
    .modal {
        position: fixed; top: 50%; left: 50%;
        transform: translate(-50%, -50%);
        background: var(--surface); border-radius: var(--radius-xl);
        box-shadow: var(--shadow-lg); width: 90%; max-width: 600px;
        max-height: 90vh; overflow-y: auto; z-index: 1001;
    }
    .modal-header { display: flex; justify-content: space-between; align-items: center; padding: var(--spacing-lg); border-bottom: 1px solid var(--border-color); }
    .modal-title { margin: 0; font-size: 1.1rem; }
    .modal-close { background: none; border: none; font-size: 1.5rem; cursor: pointer; color: var(--text-secondary); }
    .modal-body { padding: var(--spacing-lg); }
    .modal-footer { display: flex; justify-content: flex-end; gap: var(--spacing-md); padding: var(--spacing-lg); border-top: 1px solid var(--border-color); }
    .form-row { display: flex; gap: var(--spacing-lg); }
    .form-row .form-group { flex: 1; }
</style>

<script>
    function closeModal() {
        document.getElementById('modal-container').innerHTML = '';
    }
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeModal();
    });
</script>
