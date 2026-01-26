package org.jevis.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * Measurement entity representing time-series sensor data with priority-based override system.
 * Uses composite key (sensor_id, measured_at, priority) to support multiple values per timestamp.
 * Higher priority values override lower priority values for the same timestamp.
 */
@Entity
@Table(name = "measurements", indexes = {
    @Index(name = "idx_measurements_sensor_time_prio", columnList = "sensor_id, measured_at DESC, priority DESC"),
    @Index(name = "idx_measurements_time", columnList = "measured_at DESC"),
    @Index(name = "idx_measurements_imported", columnList = "imported_at"),
    @Index(name = "idx_measurements_created_by", columnList = "created_by")
})
public class Measurement {

    @EmbeddedId
    private MeasurementId id;

    // Required fields
    @NotNull(message = "Measurement value is required")
    @Column(name = "measurement_value", precision = 15, scale = 6, nullable = false)
    private BigDecimal measurementValue;

    @NotNull(message = "Source type is required")
    @Pattern(regexp = "^(automatic|manual|corrected|validated)$",
             message = "Source type must be one of: automatic, manual, corrected, validated")
    @Column(name = "source_type", length = 50, nullable = false)
    private String sourceType = "automatic";

    // Optional fields
    @Min(value = 0, message = "Quality flag must be at least 0")
    @Column(name = "quality_flag")
    private Short qualityFlag = 0;

    @Column(name = "created_by", length = 100)
    private String createdBy;

    @Column(columnDefinition = "TEXT")
    private String comment;

    // Timestamp
    @CreationTimestamp
    @Column(name = "imported_at", nullable = false, updatable = false)
    private Instant importedAt;

    // Relationship to Sensor (insertable=false, updatable=false to avoid conflicts with composite key)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sensor_id", referencedColumnName = "id", insertable = false, updatable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Sensor sensor;

    // Constructors
    public Measurement() {
    }

    public Measurement(MeasurementId id, BigDecimal measurementValue) {
        this.id = id;
        this.measurementValue = measurementValue;
    }

    public Measurement(Long sensorId, Instant measuredAt, Short priority, BigDecimal measurementValue) {
        this.id = new MeasurementId(sensorId, measuredAt, priority);
        this.measurementValue = measurementValue;
    }

    // Getters and setters
    public MeasurementId getId() {
        return id;
    }

    public void setId(MeasurementId id) {
        this.id = id;
    }

    public BigDecimal getMeasurementValue() {
        return measurementValue;
    }

    public void setMeasurementValue(BigDecimal measurementValue) {
        this.measurementValue = measurementValue;
    }

    public String getSourceType() {
        return sourceType;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public Short getQualityFlag() {
        return qualityFlag;
    }

    public void setQualityFlag(Short qualityFlag) {
        this.qualityFlag = qualityFlag;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Instant getImportedAt() {
        return importedAt;
    }

    public void setImportedAt(Instant importedAt) {
        this.importedAt = importedAt;
    }

    public Sensor getSensor() {
        return sensor;
    }

    public void setSensor(Sensor sensor) {
        this.sensor = sensor;
    }

    // Validation method for priority (called via @PrePersist and @PreUpdate)
    @PrePersist
    @PreUpdate
    private void validatePriority() {
        if (id != null && id.getPriority() != null) {
            if (id.getPriority() < 0 || id.getPriority() > 3) {
                throw new IllegalArgumentException("Priority must be between 0 and 3");
            }
        }
    }

    @Override
    public String toString() {
        return "Measurement{" +
               "id=" + id +
               ", measurementValue=" + measurementValue +
               ", sourceType='" + sourceType + '\'' +
               ", qualityFlag=" + qualityFlag +
               ", importedAt=" + importedAt +
               '}';
    }
}
