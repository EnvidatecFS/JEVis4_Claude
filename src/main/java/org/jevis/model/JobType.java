package org.jevis.model;

public enum JobType {
    DATA_FETCH("Daten-Import", "#17a2b8"),
    CALCULATION("Berechnung", "#007bff"),
    REPORT_GENERATION("Berichterstellung", "#28a745"),
    DATA_CLEANUP("Datenbereinigung", "#fd7e14"),
    CUSTOM("Benutzerdefiniert", "#6c757d");

    private final String displayName;
    private final String color;

    JobType(String displayName, String color) {
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
