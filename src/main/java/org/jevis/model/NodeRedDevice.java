package org.jevis.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "nodered_devices", indexes = {
    @Index(name = "idx_nodered_devices_active", columnList = "is_active")
})
public class NodeRedDevice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Gerätename ist erforderlich")
    @Column(name = "device_name", length = 255, nullable = false)
    private String deviceName;

    @NotBlank(message = "API-URL ist erforderlich")
    @Column(name = "api_url", length = 500, nullable = false)
    private String apiUrl;

    @Column(length = 255)
    private String username;

    @Column(length = 255)
    private String password;

    @Column(name = "default_limit", nullable = false)
    private Integer defaultLimit = 1000;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "last_reached_at")
    private Instant lastReachedAt;

    @Column(name = "last_data_import_at")
    private Instant lastDataImportAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @OneToMany(mappedBy = "device", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<NodeRedDataPoint> dataPoints = new ArrayList<>();

    public NodeRedDevice() {
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getDeviceName() { return deviceName; }
    public void setDeviceName(String deviceName) { this.deviceName = deviceName; }

    public String getApiUrl() { return apiUrl; }
    public void setApiUrl(String apiUrl) { this.apiUrl = apiUrl; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public Integer getDefaultLimit() { return defaultLimit; }
    public void setDefaultLimit(Integer defaultLimit) { this.defaultLimit = defaultLimit; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public Instant getLastReachedAt() { return lastReachedAt; }
    public void setLastReachedAt(Instant lastReachedAt) { this.lastReachedAt = lastReachedAt; }

    public Instant getLastDataImportAt() { return lastDataImportAt; }
    public void setLastDataImportAt(Instant lastDataImportAt) { this.lastDataImportAt = lastDataImportAt; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

    public List<NodeRedDataPoint> getDataPoints() { return dataPoints; }
    public void setDataPoints(List<NodeRedDataPoint> dataPoints) { this.dataPoints = dataPoints; }

    @Override
    public String toString() {
        return "NodeRedDevice{id=" + id + ", deviceName='" + deviceName + "', apiUrl='" + apiUrl + "', isActive=" + isActive + "}";
    }
}
