package org.jevis.model;

/**
 * Categories for CSR (Corporate Social Responsibility) actions.
 */
public enum CsrCategory {
    ENVIRONMENTAL("Umwelt", "#10b981"),
    SOCIAL("Sozial", "#3b82f6"),
    GOVERNANCE("Governance", "#8b5cf6"),
    ECONOMIC("Wirtschaftlich", "#f59e0b");

    private final String displayName;
    private final String color;

    CsrCategory(String displayName, String color) {
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
