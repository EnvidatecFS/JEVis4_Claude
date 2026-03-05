package org.jevis.model;

public enum WorkerStatus {
    IDLE("Bereit", "#28a745"),
    BUSY("Beschäftigt", "#ffc107"),
    OFFLINE("Offline", "#6c757d");

    private final String displayName;
    private final String color;

    WorkerStatus(String displayName, String color) {
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
