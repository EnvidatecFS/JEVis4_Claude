package org.jevis.service;

import org.jevis.model.Measurement;
import org.jevis.model.MeasurementId;
import org.jevis.model.Sensor;
import org.jevis.repository.MeasurementRepository;
import org.jevis.repository.SensorRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service for managing time-series measurements with priority-based override system.
 * Provides business logic for measurement CRUD, aggregations, and PV system analytics.
 */
@Service
@Transactional(readOnly = true)
public class MeasurementService {

    private final MeasurementRepository measurementRepository;
    private final SensorRepository sensorRepository;

    private static final List<String> VALID_SOURCE_TYPES = List.of("automatic", "manual", "corrected", "validated");

    public MeasurementService(MeasurementRepository measurementRepository, SensorRepository sensorRepository) {
        this.measurementRepository = measurementRepository;
        this.sensorRepository = sensorRepository;
    }

    // === CRUD Operations ===

    /**
     * Create a new measurement with validation.
     * @param measurement The measurement to create
     * @return The created measurement
     * @throws IllegalArgumentException if validation fails
     */
    @Transactional
    public Measurement createMeasurement(Measurement measurement) {
        validateMeasurement(measurement);
        return measurementRepository.save(measurement);
    }

    /**
     * Bulk insert measurements (optimized for data imports).
     * @param measurements List of measurements to create
     * @return List of created measurements
     * @throws IllegalArgumentException if validation fails
     */
    @Transactional
    public List<Measurement> createMeasurementsBatch(List<Measurement> measurements) {
        // Validate all measurements first
        for (Measurement measurement : measurements) {
            validateMeasurement(measurement);
        }
        return measurementRepository.saveAll(measurements);
    }

    /**
     * Override a measurement with a higher priority value.
     * Creates a new version of the measurement with higher priority.
     * @param sensorId The sensor ID
     * @param measuredAt The measurement timestamp
     * @param newValue The new measurement value
     * @param priority The priority (must be 1-3 for manual overrides)
     * @param createdBy Username of the person making the override
     * @param comment Explanation for the override
     * @return The created override measurement
     * @throws IllegalArgumentException if validation fails
     */
    @Transactional
    public Measurement overrideMeasurement(
        Long sensorId,
        Instant measuredAt,
        BigDecimal newValue,
        short priority,
        String createdBy,
        String comment
    ) {
        // Validate sensor exists
        if (!sensorRepository.existsById(sensorId)) {
            throw new IllegalArgumentException("Sensor not found with ID: " + sensorId);
        }

        // Priority for manual overrides should be 1-3
        if (priority < 1 || priority > 3) {
            throw new IllegalArgumentException("Override priority must be between 1 and 3");
        }

        // Create the override measurement
        MeasurementId id = new MeasurementId(sensorId, measuredAt, priority);
        Measurement override = new Measurement(id, newValue);

        // Set source type based on priority
        String sourceType = switch (priority) {
            case 1 -> "manual";
            case 2 -> "corrected";
            case 3 -> "validated";
            default -> "automatic";
        };
        override.setSourceType(sourceType);
        override.setCreatedBy(createdBy);
        override.setComment(comment);

        return measurementRepository.save(override);
    }

    /**
     * Delete a specific measurement version.
     * @param id The composite measurement ID
     * @throws IllegalArgumentException if measurement not found
     */
    @Transactional
    public void deleteMeasurement(MeasurementId id) {
        if (!measurementRepository.existsById(id)) {
            throw new IllegalArgumentException("Measurement not found with ID: " + id);
        }
        measurementRepository.deleteById(id);
    }

    // === Retrieval Methods ===

    /**
     * Get measurement by composite ID.
     * @param id The composite measurement ID
     * @return The measurement
     * @throws IllegalArgumentException if measurement not found
     */
    public Measurement getMeasurementById(MeasurementId id) {
        return measurementRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Measurement not found with ID: " + id));
    }

    /**
     * Get all measurements for a sensor (paginated).
     * @param sensorId The sensor ID
     * @param pageable Pagination parameters
     * @return Page of measurements
     */
    public Page<Measurement> getMeasurementsBySensor(Long sensorId, Pageable pageable) {
        return measurementRepository.findById_SensorId(sensorId, pageable);
    }

    /**
     * Get current measurements (highest priority only) for a sensor within time range.
     * @param sensorId The sensor ID
     * @param start Start of time range
     * @param end End of time range
     * @return List of current measurements
     */
    public List<Measurement> getCurrentMeasurements(Long sensorId, Instant start, Instant end) {
        return measurementRepository.findCurrentMeasurements(sensorId, start, end);
    }

    /**
     * Get all priority versions for a specific measurement timestamp (audit trail).
     * @param sensorId The sensor ID
     * @param measuredAt The measurement timestamp
     * @return List of all versions ordered by priority
     */
    public List<Measurement> getAllVersions(Long sensorId, Instant measuredAt) {
        return measurementRepository.findAllVersions(sensorId, measuredAt);
    }

    // === Time-Series Queries ===

    /**
     * Get measurements for a sensor within a time range (paginated).
     * @param sensorId The sensor ID
     * @param start Start of time range
     * @param end End of time range
     * @param pageable Pagination parameters
     * @return Page of measurements
     */
    public Page<Measurement> getMeasurementsInRange(Long sensorId, Instant start, Instant end, Pageable pageable) {
        return measurementRepository.findById_SensorIdAndId_MeasuredAtBetween(sensorId, start, end, pageable);
    }

    /**
     * Get the latest measurement for a sensor.
     * @param sensorId The sensor ID
     * @return The latest measurement
     * @throws IllegalArgumentException if no measurement found
     */
    public Measurement getLatestMeasurement(Long sensorId) {
        Measurement latest = measurementRepository.findLatestMeasurement(sensorId);
        if (latest == null) {
            throw new IllegalArgumentException("No measurements found for sensor ID: " + sensorId);
        }
        return latest;
    }

    /**
     * Get measurements for all sensors in a logical sensor chain.
     * @param logicalSensorId The logical sensor ID
     * @param start Start of time range
     * @param end End of time range
     * @return List of measurements across all sensors in the chain
     */
    public List<Measurement> getMeasurementsByLogicalSensor(Long logicalSensorId, Instant start, Instant end) {
        return measurementRepository.findByLogicalSensorId(logicalSensorId, start, end);
    }

    // === Aggregations (for PV Analytics) ===

    /**
     * Calculate average measurement value for a sensor within time range.
     * @param sensorId The sensor ID
     * @param start Start of time range
     * @param end End of time range
     * @return Average value
     */
    public BigDecimal calculateAverage(Long sensorId, Instant start, Instant end) {
        BigDecimal avg = measurementRepository.calculateAverage(sensorId, start, end);
        return avg != null ? avg : BigDecimal.ZERO;
    }

    /**
     * Calculate sum of measurement values (e.g., total energy production).
     * @param sensorId The sensor ID
     * @param start Start of time range
     * @param end End of time range
     * @return Sum of values
     */
    public BigDecimal calculateSum(Long sensorId, Instant start, Instant end) {
        BigDecimal sum = measurementRepository.calculateSum(sensorId, start, end);
        return sum != null ? sum : BigDecimal.ZERO;
    }

    /**
     * Calculate minimum and maximum measurement values within time range.
     * @param sensorId The sensor ID
     * @param start Start of time range
     * @param end End of time range
     * @return Map with "min" and "max" keys
     */
    public Map<String, BigDecimal> calculateMinMax(Long sensorId, Instant start, Instant end) {
        BigDecimal min = measurementRepository.calculateMin(sensorId, start, end);
        BigDecimal max = measurementRepository.calculateMax(sensorId, start, end);

        Map<String, BigDecimal> result = new HashMap<>();
        result.put("min", min != null ? min : BigDecimal.ZERO);
        result.put("max", max != null ? max : BigDecimal.ZERO);
        return result;
    }

    // === Data Maintenance ===

    /**
     * Delete measurements older than the specified date (for data retention policies).
     * @param before Delete measurements before this timestamp
     * @return Number of deleted records
     */
    @Transactional
    public int deleteOldMeasurements(Instant before) {
        return measurementRepository.deleteOldMeasurements(before);
    }

    /**
     * Validate a measurement by creating a priority=2 version.
     * @param sensorId The sensor ID
     * @param measuredAt The measurement timestamp
     * @param validatedBy Username of the validator
     * @return The validated measurement
     */
    @Transactional
    public Measurement validateMeasurement(Long sensorId, Instant measuredAt, String validatedBy) {
        // Get the current measurement value
        List<Measurement> versions = measurementRepository.findAllVersions(sensorId, measuredAt);
        if (versions.isEmpty()) {
            throw new IllegalArgumentException("No measurement found at timestamp: " + measuredAt);
        }

        Measurement current = versions.get(0); // Highest priority

        // Create validated version with priority=2
        return overrideMeasurement(
            sensorId,
            measuredAt,
            current.getMeasurementValue(),
            (short) 2,
            validatedBy,
            "Validated measurement"
        );
    }

    /**
     * Count total measurements for a sensor.
     * @param sensorId The sensor ID
     * @return Count of measurements
     */
    public long countMeasurementsBySensor(Long sensorId) {
        return measurementRepository.countMeasurementsBySensor(sensorId);
    }

    // === Validation Helper ===

    private void validateMeasurement(Measurement measurement) {
        // Check sensor exists
        Long sensorId = measurement.getId().getSensorId();
        if (!sensorRepository.existsById(sensorId)) {
            throw new IllegalArgumentException("Sensor not found with ID: " + sensorId);
        }

        // Validate priority range (0-3)
        Short priority = measurement.getId().getPriority();
        if (priority == null || priority < 0 || priority > 3) {
            throw new IllegalArgumentException("Priority must be between 0 and 3");
        }

        // Validate source_type enum
        String sourceType = measurement.getSourceType();
        if (sourceType != null && !VALID_SOURCE_TYPES.contains(sourceType)) {
            throw new IllegalArgumentException("Invalid source type. Must be one of: " + VALID_SOURCE_TYPES);
        }

        // Check measurement_value not null
        if (measurement.getMeasurementValue() == null) {
            throw new IllegalArgumentException("Measurement value is required");
        }
    }
}
