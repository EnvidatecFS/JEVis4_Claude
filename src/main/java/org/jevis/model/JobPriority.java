package org.jevis.model;

public enum JobPriority {
    CRITICAL(1, "Kritisch", "#dc3545"),
    HIGH(2, "Hoch", "#fd7e14"),
    NORMAL(3, "Normal", "#007bff"),
    LOW(4, "Niedrig", "#6c757d"),
    RETRY(5, "Retry", "#6f42c1");

    private final int level;
    private final String displayName;
    private final String color;

    JobPriority(int level, String displayName, String color) {
        this.level = level;
        this.displayName = displayName;
        this.color = color;
    }

    public int getLevel() {
        return level;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getColor() {
        return color;
    }
}
