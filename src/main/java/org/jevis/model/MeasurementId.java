package org.jevis.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.time.Instant;
import java.util.Objects;

/**
 * Composite primary key for Measurement entity.
 * Represents the unique identifier: (sensor_id, measured_at, priority)
 */
@Embeddable
public class MeasurementId implements Serializable {

    @Column(name = "sensor_id", nullable = false)
    private Long sensorId;

    @Column(name = "measured_at", nullable = false)
    private Instant measuredAt;

    @Column(name = "priority", nullable = false)
    private Short priority;

    public MeasurementId() {
    }

    public MeasurementId(Long sensorId, Instant measuredAt, Short priority) {
        this.sensorId = sensorId;
        this.measuredAt = measuredAt;
        this.priority = priority;
    }

    public Long getSensorId() {
        return sensorId;
    }

    public void setSensorId(Long sensorId) {
        this.sensorId = sensorId;
    }

    public Instant getMeasuredAt() {
        return measuredAt;
    }

    public void setMeasuredAt(Instant measuredAt) {
        this.measuredAt = measuredAt;
    }

    public Short getPriority() {
        return priority;
    }

    public void setPriority(Short priority) {
        this.priority = priority;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        MeasurementId that = (MeasurementId) o;
        return Objects.equals(sensorId, that.sensorId) &&
               Objects.equals(measuredAt, that.measuredAt) &&
               Objects.equals(priority, that.priority);
    }

    @Override
    public int hashCode() {
        return Objects.hash(sensorId, measuredAt, priority);
    }

    @Override
    public String toString() {
        return "MeasurementId{" +
               "sensorId=" + sensorId +
               ", measuredAt=" + measuredAt +
               ", priority=" + priority +
               '}';
    }
}
