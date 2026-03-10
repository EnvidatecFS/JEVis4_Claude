package org.jevis.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
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

    // Extended fields
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_sensor_id")
    private Sensor parentSensor;

    @Column(name = "sensor_tag", length = 100)
    private String sensorTag;

    @Column(name = "medium", length = 50)
    private String medium;

    @Column(name = "device_number", length = 255)
    private String deviceNumber;

    @Column(name = "gps_lat", precision = 10, scale = 7)
    private BigDecimal gpsLat;

    @Column(name = "gps_lon", precision = 10, scale = 7)
    private BigDecimal gpsLon;

    @Column(name = "installation_location_lat", precision = 10, scale = 7)
    private BigDecimal installationLocationLat;

    @Column(name = "installation_location_lon", precision = 10, scale = 7)
    private BigDecimal installationLocationLon;

    @Column(name = "cost_center", length = 255)
    private String costCenter;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "meter_type_id")
    private MeterType meterType;

    @Column(name = "serial_number", length = 255)
    private String serialNumber;

    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    @Column(name = "verification_document_path", length = 500)
    private String verificationDocumentPath;

    @Column(name = "sensor_image_path", length = 500)
    private String sensorImagePath;

    @Column(name = "installation_date")
    private LocalDate installationDate;

    @Column(name = "last_inspection_date")
    private LocalDate lastInspectionDate;

    @Column(name = "current_transformer", length = 255)
    private Double currentTransformer;

    @Column(name = "current_transformer_ratio", length = 100)
    private String currentTransformerRatio;

    @Column(name = "voltage_transformer_ratio", length = 100)
    private String voltageTransformerRatio;

    @Column(name = "voltage_transformer", length = 255)
    private Double voltageTransformer;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

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

    public Sensor getParentSensor() { return parentSensor; }
    public void setParentSensor(Sensor parentSensor) { this.parentSensor = parentSensor; }

    public String getSensorTag() { return sensorTag; }
    public void setSensorTag(String sensorTag) { this.sensorTag = sensorTag; }

    public String getMedium() { return medium; }
    public void setMedium(String medium) { this.medium = medium; }

    public String getDeviceNumber() { return deviceNumber; }
    public void setDeviceNumber(String deviceNumber) { this.deviceNumber = deviceNumber; }

    public BigDecimal getGpsLat() { return gpsLat; }
    public void setGpsLat(BigDecimal gpsLat) { this.gpsLat = gpsLat; }

    public BigDecimal getGpsLon() { return gpsLon; }
    public void setGpsLon(BigDecimal gpsLon) { this.gpsLon = gpsLon; }

    public BigDecimal getInstallationLocationLat() { return installationLocationLat; }
    public void setInstallationLocationLat(BigDecimal installationLocationLat) { this.installationLocationLat = installationLocationLat; }

    public BigDecimal getInstallationLocationLon() { return installationLocationLon; }
    public void setInstallationLocationLon(BigDecimal installationLocationLon) { this.installationLocationLon = installationLocationLon; }

    public String getCostCenter() { return costCenter; }
    public void setCostCenter(String costCenter) { this.costCenter = costCenter; }

    public MeterType getMeterType() { return meterType; }
    public void setMeterType(MeterType meterType) { this.meterType = meterType; }

    public String getSerialNumber() { return serialNumber; }
    public void setSerialNumber(String serialNumber) { this.serialNumber = serialNumber; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public String getVerificationDocumentPath() { return verificationDocumentPath; }
    public void setVerificationDocumentPath(String verificationDocumentPath) { this.verificationDocumentPath = verificationDocumentPath; }

    public String getSensorImagePath() { return sensorImagePath; }
    public void setSensorImagePath(String sensorImagePath) { this.sensorImagePath = sensorImagePath; }

    public LocalDate getInstallationDate() { return installationDate; }
    public void setInstallationDate(LocalDate installationDate) { this.installationDate = installationDate; }

    public LocalDate getLastInspectionDate() { return lastInspectionDate; }
    public void setLastInspectionDate(LocalDate lastInspectionDate) { this.lastInspectionDate = lastInspectionDate; }

    public Double getCurrentTransformer() { return currentTransformer; }
    public void setCurrentTransformer(Double currentTransformer) { this.currentTransformer = currentTransformer; }

    public String getCurrentTransformerRatio() { return currentTransformerRatio; }
    public void setCurrentTransformerRatio(String currentTransformerRatio) { this.currentTransformerRatio = currentTransformerRatio; }

    public String getVoltageTransformerRatio() { return voltageTransformerRatio; }
    public void setVoltageTransformerRatio(String voltageTransformerRatio) { this.voltageTransformerRatio = voltageTransformerRatio; }

    public Double getVoltageTransformer() { return voltageTransformer; }
    public void setVoltageTransformer(Double voltageTransformer) { this.voltageTransformer = voltageTransformer; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

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
