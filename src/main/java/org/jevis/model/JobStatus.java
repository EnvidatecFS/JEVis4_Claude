package org.jevis.model;

public enum JobStatus {
    CREATED("Erstellt", "#6c757d"),
    QUEUED("In Warteschlange", "#17a2b8"),
    ASSIGNED("Zugewiesen", "#007bff"),
    RUNNING("Läuft", "#ffc107"),
    COMPLETED("Abgeschlossen", "#28a745"),
    FAILED("Fehlgeschlagen", "#dc3545"),
    TIMED_OUT("Timeout", "#fd7e14"),
    RETRY_SCHEDULED("Retry geplant", "#6f42c1"),
    CANCELLED("Abgebrochen", "#6c757d"),
    ALARM("Alarm", "#dc3545");

    private final String displayName;
    private final String color;

    JobStatus(String displayName, String color) {
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
