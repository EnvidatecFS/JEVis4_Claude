@import org.jevis.model.NodeRedDevice
@import org.jevis.model.NodeRedDataPoint
@import org.jevis.model.Sensor
@import java.util.List

@param NodeRedDevice device
@param NodeRedDataPoint dataPoint
@param List<Sensor> sensors = java.util.Collections.emptyList()
@param boolean success = false
@param String message = ""

<div class="modal-overlay" onclick="if(event.target===this) this.remove()">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Messpunkt-Zuordnung hinzufügen</h2>
            <button class="modal-close" onclick="this.closest('.modal-overlay').remove()">&times;</button>
        </div>

        <p class="modal-subtitle">Gerät: <strong>${device.getDeviceName()}</strong></p>

        @if(!message.isEmpty())
            <div class="alert ${success ? "alert-success" : "alert-danger"}">${message}</div>
        @endif

        <form hx-post="/devices/${device.getId()}/datapoints"
              hx-target="#modal-container"
              hx-swap="innerHTML">

            <div class="form-group">
                <label for="remoteId">Remote-ID *</label>
                <input type="text" id="remoteId" name="remoteId"
                       placeholder="z.B. fbf2f46773a02bbf" required>
                <small class="form-help">Die ID des Messpunkts in Node-Red</small>
            </div>

            <div class="form-group">
                <label for="remoteName">Remote-Name</label>
                <input type="text" id="remoteName" name="remoteName"
                       placeholder="z.B. Hauptzähler2Energy">
                <small class="form-help">Optionaler Name zur Identifikation</small>
            </div>

            <div class="form-group">
                <label for="sensorId">JEVis Sensor *</label>
                <select id="sensorId" name="sensorId" required>
                    <option value="">-- Sensor auswählen --</option>
                    @for(Sensor sensor : sensors)
                        <option value="${sensor.getId()}">
                            ${sensor.getSensorName() != null ? sensor.getSensorName() : sensor.getSensorCode()}
                            (${sensor.getSensorCode()} - ${sensor.getMeasurementType()} [${sensor.getUnit()}])
                        </option>
                    @endfor
                </select>
            </div>

            <div class="form-actions">
                <button type="button" class="btn btn-outline" onclick="this.closest('.modal-overlay').remove()">Abbrechen</button>
                <button type="submit" class="btn btn-primary">Zuordnung erstellen</button>
            </div>
        </form>
    </div>
</div>

<style>
    .modal-overlay {
        position: fixed; top: 0; left: 0; right: 0; bottom: 0;
        background: rgba(0,0,0,0.5); display: flex; align-items: center;
        justify-content: center; z-index: 1000;
    }
    .modal-content {
        background: var(--card-background); border-radius: var(--radius-lg);
        padding: var(--spacing-xl); width: 90%; max-width: 550px;
        box-shadow: var(--shadow-lg); max-height: 90vh; overflow-y: auto;
    }
    .modal-header {
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: var(--spacing-sm);
    }
    .modal-header h2 { margin: 0; }
    .modal-close {
        background: none; border: none; font-size: 1.5rem;
        cursor: pointer; color: var(--text-secondary); padding: var(--spacing-sm);
    }
    .modal-subtitle { color: var(--text-secondary); margin-bottom: var(--spacing-lg); }
    .form-group { margin-bottom: var(--spacing-md); }
    .form-group label { display: block; margin-bottom: var(--spacing-sm); font-weight: 500; font-size: var(--font-size-sm); }
    .form-group input, .form-group select {
        width: 100%; padding: var(--spacing-md); border: 1px solid var(--border-color);
        border-radius: var(--radius-md); font-size: var(--font-size-base);
        background: var(--card-background); color: var(--text-primary);
    }
    .form-help { display: block; margin-top: var(--spacing-xs); color: var(--text-secondary); font-size: 0.75rem; }
    .form-actions { display: flex; justify-content: flex-end; gap: var(--spacing-md); margin-top: var(--spacing-lg); }
    .alert { padding: var(--spacing-md); border-radius: var(--radius-md); margin-bottom: var(--spacing-md); }
    .alert-success { background-color: #d1fae5; color: #065f46; }
    .alert-danger { background-color: #fee2e2; color: #991b1b; }
</style>
