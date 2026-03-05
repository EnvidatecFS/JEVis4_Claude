package org.jevis.model;

public enum JobEventType {
    JOB_CREATED("Job erstellt"),
    JOB_QUEUED("Job in Warteschlange"),
    JOB_ASSIGNED("Job zugewiesen"),
    JOB_STARTED("Job gestartet"),
    JOB_COMPLETED("Job abgeschlossen"),
    JOB_FAILED("Job fehlgeschlagen"),
    JOB_TIMEOUT("Job Timeout"),
    JOB_RETRY_SCHEDULED("Retry geplant"),
    JOB_CANCELLED("Job abgebrochen"),
    JOB_ALARM("Job Alarm");

    private final String displayName;

    JobEventType(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
