package org.jevis.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;

@Entity
@Table(name = "nodered_datapoints", indexes = {
    @Index(name = "idx_nodered_dp_device", columnList = "device_id"),
    @Index(name = "idx_nodered_dp_sensor", columnList = "sensor_id"),
    @Index(name = "idx_nodered_dp_remote_id", columnList = "remote_id")
})
public class NodeRedDataPoint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "device_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private NodeRedDevice device;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sensor_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Sensor sensor;

    @NotBlank(message = "Remote-ID ist erforderlich")
    @Column(name = "remote_id", length = 255, nullable = false)
    private String remoteId;

    @Column(name = "remote_name", length = 255)
    private String remoteName;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "last_success_at")
    private Instant lastSuccessAt;

    @Column(name = "last_data_timestamp")
    private Instant lastDataTimestamp;

    @Column(name = "last_import_count")
    private Integer lastImportCount;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    public NodeRedDataPoint() {
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public NodeRedDevice getDevice() { return device; }
    public void setDevice(NodeRedDevice device) { this.device = device; }

    public Sensor getSensor() { return sensor; }
    public void setSensor(Sensor sensor) { this.sensor = sensor; }

    public String getRemoteId() { return remoteId; }
    public void setRemoteId(String remoteId) { this.remoteId = remoteId; }

    public String getRemoteName() { return remoteName; }
    public void setRemoteName(String remoteName) { this.remoteName = remoteName; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public Instant getLastSuccessAt() { return lastSuccessAt; }
    public void setLastSuccessAt(Instant lastSuccessAt) { this.lastSuccessAt = lastSuccessAt; }

    public Instant getLastDataTimestamp() { return lastDataTimestamp; }
    public void setLastDataTimestamp(Instant lastDataTimestamp) { this.lastDataTimestamp = lastDataTimestamp; }

    public Integer getLastImportCount() { return lastImportCount; }
    public void setLastImportCount(Integer lastImportCount) { this.lastImportCount = lastImportCount; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "NodeRedDataPoint{id=" + id + ", remoteId='" + remoteId + "', remoteName='" + remoteName + "', isActive=" + isActive + "}";
    }
}
