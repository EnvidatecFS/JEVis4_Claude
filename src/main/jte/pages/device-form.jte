@import org.jevis.model.NodeRedDevice

@param NodeRedDevice device
@param boolean success = false
@param String message = ""

<div class="modal-overlay" onclick="if(event.target===this) this.remove()">
    <div class="modal-content">
        <div class="modal-header">
            <h2>${device.getId() != null ? "Gerät bearbeiten" : "Neues Gerät"}</h2>
            <button class="modal-close" onclick="this.closest('.modal-overlay').remove()">&times;</button>
        </div>

        @if(!message.isEmpty())
            <div class="alert ${success ? "alert-success" : "alert-danger"}">${message}</div>
        @endif

        <form hx-${device.getId() != null ? "put" : "post"}="${device.getId() != null ? "/devices/" + device.getId() : "/devices"}"
              hx-target="#modal-container"
              hx-swap="innerHTML">

            <div class="form-group">
                <label for="deviceName">Gerätename *</label>
                <input type="text" id="deviceName" name="deviceName"
                       value="${device.getDeviceName() != null ? device.getDeviceName() : ""}"
                       placeholder="z.B. Schuby Hauptzähler" required>
            </div>

            <div class="form-group">
                <label for="apiUrl">API-URL *</label>
                <input type="url" id="apiUrl" name="apiUrl"
                       value="${device.getApiUrl() != null ? device.getApiUrl() : ""}"
                       placeholder="http://example.com:3000/api/data" required>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="username">Benutzername</label>
                    <input type="text" id="username" name="username"
                           value="${device.getUsername() != null ? device.getUsername() : ""}"
                           placeholder="Basic Auth Username">
                </div>
                <div class="form-group">
                    <label for="password">Passwort</label>
                    <input type="password" id="password" name="password"
                           value="${device.getPassword() != null ? device.getPassword() : ""}"
                           placeholder="Basic Auth Password">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="defaultLimit">Default Limit</label>
                    <input type="number" id="defaultLimit" name="defaultLimit"
                           value="${device.getDefaultLimit() != null ? device.getDefaultLimit() : 1000}"
                           min="1" max="100000">
                </div>
                <div class="form-group">
                    <label for="isActive">Status</label>
                    <select id="isActive" name="isActive">
                        <option value="true" ${device.getIsActive() != null && device.getIsActive() ? "selected" : ""}>Aktiv</option>
                        <option value="false" ${device.getIsActive() != null && !device.getIsActive() ? "selected" : ""}>Inaktiv</option>
                    </select>
                </div>
            </div>

            <div class="form-actions">
                <button type="button" class="btn btn-outline" onclick="this.closest('.modal-overlay').remove()">Abbrechen</button>
                <button type="submit" class="btn btn-primary">${device.getId() != null ? "Speichern" : "Erstellen"}</button>
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
        padding: var(--spacing-xl); width: 90%; max-width: 600px;
        box-shadow: var(--shadow-lg); max-height: 90vh; overflow-y: auto;
    }
    .modal-header {
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: var(--spacing-lg);
    }
    .modal-header h2 { margin: 0; }
    .modal-close {
        background: none; border: none; font-size: 1.5rem;
        cursor: pointer; color: var(--text-secondary); padding: var(--spacing-sm);
    }
    .form-group { margin-bottom: var(--spacing-md); }
    .form-group label { display: block; margin-bottom: var(--spacing-sm); font-weight: 500; font-size: var(--font-size-sm); }
    .form-group input, .form-group select {
        width: 100%; padding: var(--spacing-md); border: 1px solid var(--border-color);
        border-radius: var(--radius-md); font-size: var(--font-size-base);
        background: var(--card-background); color: var(--text-primary);
    }
    .form-row { display: flex; gap: var(--spacing-md); }
    .form-row .form-group { flex: 1; }
    .form-actions { display: flex; justify-content: flex-end; gap: var(--spacing-md); margin-top: var(--spacing-lg); }
    .alert { padding: var(--spacing-md); border-radius: var(--radius-md); margin-bottom: var(--spacing-md); }
    .alert-success { background-color: #d1fae5; color: #065f46; }
    .alert-danger { background-color: #fee2e2; color: #991b1b; }
</style>
