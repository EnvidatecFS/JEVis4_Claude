package org.jevis.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.time.LocalDate;

/**
 * Sensor entity representing physical sensors in PV (photovoltaic) systems.
 * Supports sensor replacement tracking through logical_sensor_id and replacement chain.
 */
@Entity
@Table(name = "sensors", indexes = {
    @Index(name = "idx_sensors_code", columnList = "sensor_code"),
    @Index(name = "idx_sensors_type", columnList = "measurement_type"),
    @Index(name = "idx_sensors_logical_id", columnList = "logical_sensor_id")
})
public class Sensor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Required fields
    @NotBlank(message = "Sensor code is required")
    @Column(name = "sensor_code", length = 100, unique = true, nullable = false)
    private String sensorCode;

    @NotNull(message = "Measurement type is required")
    @Column(name = "measurement_type", length = 100, nullable = false)
    private String measurementType;

    @NotNull(message = "Unit is required")
    @Column(length = 50, nullable = false)
    private String unit;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    // Optional fields
    @Column(name = "sensor_name", length = 255)
    private String sensorName;

    @Column(length = 255)
    private String location;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(length = 100)
    private String manufacturer;

    @Column(length = 100)
    private String model;

    @Column(name = "calibration_date")
    private LocalDate calibrationDate;

    // Sensor replacement tracking
    @Column(name = "logical_sensor_id")
    private Long logicalSensorId;

    @Column(name = "replaced_at")
    private Instant replacedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "replaces_sensor_id", referencedColumnName = "id")
    private Sensor replacesSensor;

    // Timestamps
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    // Metadata (stored as TEXT for H2 compatibility, use JSONB in PostgreSQL)
    @Column(columnDefinition = "TEXT")
    private String metadata;

    // Constructors
    public Sensor() {
    }

    public Sensor(String sensorCode, String measurementType, String unit) {
        this.sensorCode = sensorCode;
        this.measurementType = measurementType;
        this.unit = unit;
    }

    // Getters and setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getSensorCode() {
        return sensorCode;
    }

    public void setSensorCode(String sensorCode) {
        this.sensorCode = sensorCode;
    }

    public String getMeasurementType() {
        return measurementType;
    }

    public void setMeasurementType(String measurementType) {
        this.measurementType = measurementType;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public String getSensorName() {
        return sensorName;
    }

    public void setSensorName(String sensorName) {
        this.sensorName = sensorName;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getManufacturer() {
        return manufacturer;
    }

    public void setManufacturer(String manufacturer) {
        this.manufacturer = manufacturer;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public LocalDate getCalibrationDate() {
        return calibrationDate;
    }

    public void setCalibrationDate(LocalDate calibrationDate) {
        this.calibrationDate = calibrationDate;
    }

    public Long getLogicalSensorId() {
        return logicalSensorId;
    }

    public void setLogicalSensorId(Long logicalSensorId) {
        this.logicalSensorId = logicalSensorId;
    }

    public Instant getReplacedAt() {
        return replacedAt;
    }

    public void setReplacedAt(Instant replacedAt) {
        this.replacedAt = replacedAt;
    }

    public Sensor getReplacesSensor() {
        return replacesSensor;
    }

    public void setReplacesSensor(Sensor replacesSensor) {
        this.replacesSensor = replacesSensor;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getMetadata() {
        return metadata;
    }

    public void setMetadata(String metadata) {
        this.metadata = metadata;
    }

    @Override
    public String toString() {
        return "Sensor{" +
               "id=" + id +
               ", sensorCode='" + sensorCode + '\'' +
               ", measurementType='" + measurementType + '\'' +
               ", unit='" + unit + '\'' +
               ", isActive=" + isActive +
               ", location='" + location + '\'' +
               '}';
    }
}
