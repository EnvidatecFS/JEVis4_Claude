package org.jevis.model;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.Instant;

@Entity
@Table(name = "meter_types")
public class MeterType {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "device_type", length = 255)
    private String deviceType;

    @Column(name = "accuracy", length = 100)
    private String accuracy;

    @Column(name = "datasheet_path", length = 500)
    private String datasheetPath;

    @Column(name = "image_path", length = 500)
    private String imagePath;

    @Column(name = "decimal_places")
    private Integer decimalPlaces;

    @Column(name = "manufacturer", length = 255)
    private String manufacturer;

    @Column(name = "manufacturer_url", length = 500)
    private String manufacturerUrl;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    public MeterType() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getDeviceType() { return deviceType; }
    public void setDeviceType(String deviceType) { this.deviceType = deviceType; }
    public String getAccuracy() { return accuracy; }
    public void setAccuracy(String accuracy) { this.accuracy = accuracy; }
    public String getDatasheetPath() { return datasheetPath; }
    public void setDatasheetPath(String datasheetPath) { this.datasheetPath = datasheetPath; }
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
    public Integer getDecimalPlaces() { return decimalPlaces; }
    public void setDecimalPlaces(Integer decimalPlaces) { this.decimalPlaces = decimalPlaces; }
    public String getManufacturer() { return manufacturer; }
    public void setManufacturer(String manufacturer) { this.manufacturer = manufacturer; }
    public String getManufacturerUrl() { return manufacturerUrl; }
    public void setManufacturerUrl(String manufacturerUrl) { this.manufacturerUrl = manufacturerUrl; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
