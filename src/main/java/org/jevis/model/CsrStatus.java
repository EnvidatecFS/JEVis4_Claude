package org.jevis.model;

/**
 * Status values for CSR (Corporate Social Responsibility) actions.
 */
public enum CsrStatus {
    PLANNED("Geplant", "#6b7280"),
    IN_PROGRESS("In Bearbeitung", "#3b82f6"),
    ON_HOLD("Pausiert", "#f59e0b"),
    COMPLETED("Abgeschlossen", "#10b981"),
    CANCELLED("Abgebrochen", "#ef4444");

    private final String displayName;
    private final String color;

    CsrStatus(String displayName, String color) {
        this.displayName = displayName;
        this.color = color;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getColor() {
        return color;
    }
}
