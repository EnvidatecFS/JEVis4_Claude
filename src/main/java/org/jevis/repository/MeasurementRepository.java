package org.jevis.repository;

import org.jevis.model.Measurement;
import org.jevis.model.MeasurementId;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

/**
 * Repository for Measurement entity providing time-series queries, aggregations,
 * and priority-based measurement retrieval for PV system data analysis.
 */
@Repository
public interface MeasurementRepository extends JpaRepository<Measurement, MeasurementId> {

    // === Time-series Query Methods (using nested properties for composite key) ===

    /**
     * Find all measurements for a specific sensor (paginated).
     * @param sensorId The sensor ID
     * @param pageable Pagination parameters
     * @return Page of measurements
     */
    Page<Measurement> findById_SensorId(Long sensorId, Pageable pageable);

    /**
     * Find measurements for a sensor within a time range (paginated).
     * @param sensorId The sensor ID
     * @param start Start of time range
     * @param end End of time range
     * @param pageable Pagination parameters
     * @return Page of measurements
     */
    Page<Measurement> findById_SensorIdAndId_MeasuredAtBetween(
        Long sensorId,
        Instant start,
        Instant end,
        Pageable pageable
    );

    /**
     * Find measurements by source type (paginated).
     * @param sourceType The source type (automatic, manual, corrected, validated)
     * @param pageable Pagination parameters
     * @return Page of measurements
     */
    Page<Measurement> findBySourceType(String sourceType, Pageable pageable);

    /**
     * Find measurements created by a specific user (paginated).
     * @param createdBy The username
     * @param pageable Pagination parameters
     * @return Page of measurements
     */
    Page<Measurement> findByCreatedBy(String createdBy, Pageable pageable);

    // === measurements_current View Implementation ===

    /**
     * Get current measurements (highest priority only) for a sensor within time range.
     * Implements the measurements_current view logic.
     * @param sensorId The sensor ID
     * @param start Start of time range
     * @param end End of time range
     * @return List of measurements with highest priority per timestamp
     */
    @Query("""
        SELECT m FROM Measurement m
        WHERE m.id.sensorId = :sensorId
        AND m.id.measuredAt BETWEEN :start AND :end
        AND m.id.priority = (
            SELECT MAX(m2.id.priority)
            FROM Measurement m2
            WHERE m2.id.sensorId = m.id.sensorId
            AND m2.id.measuredAt = m.id.measuredAt
        )
        ORDER BY m.id.measuredAt DESC
    """)
    List<Measurement> findCurrentMeasurements(
        @Param("sensorId") Long sensorId,
        @Param("start") Instant start,
        @Param("end") Instant end
    );

    // === measurements_by_logical_sensor View Implementation ===

    /**
     * Get measurements for all sensors in a logical sensor chain within time range.
     * Implements the measurements_by_logical_sensor view logic.
     * @param logicalSensorId The logical sensor ID
     * @param start Start of time range
     * @param end End of time range
     * @return List of measurements across all sensors in the chain
     */
    @Query("""
        SELECT m FROM Measurement m
        JOIN m.sensor s
        WHERE s.logicalSensorId = :logicalSensorId
        AND m.id.measuredAt BETWEEN :start AND :end
        AND m.id.priority = (
            SELECT MAX(m2.id.priority)
            FROM Measurement m2
            WHERE m2.id.sensorId = m.id.sensorId
            AND m2.id.measuredAt = m.id.measuredAt
        )
        ORDER BY m.id.measuredAt DESC
    """)
    List<Measurement> findByLogicalSensorId(
        @Param("logicalSensorId") Long logicalSensorId,
        @Param("start") Instant start,
        @Param("end") Instant end
    );

    // === Aggregation Queries (for PV Analytics) ===

    /**
     * Calculate average measurement value for a sensor within time range.
     * @param sensorId The sensor ID
     * @param start Start of time range
     * @param end End of time range
     * @return Average value
     */
    @Query("""
        SELECT AVG(m.measurementValue) FROM Measurement m
        WHERE m.id.sensorId = :sensorId
        AND m.id.measuredAt BETWEEN :start AND :end
        AND m.id.priority = (
            SELECT MAX(m2.id.priority)
            FROM Measurement m2
            WHERE m2.id.sensorId = m.id.sensorId
            AND m2.id.measuredAt = m.id.measuredAt
        )
    """)
    BigDecimal calculateAverage(
        @Param("sensorId") Long sensorId,
        @Param("start") Instant start,
        @Param("end") Instant end
    );

    /**
     * Calculate sum of measurement values (e.g., total energy production).
     * @param sensorId The sensor ID
     * @param start Start of time range
     * @param end End of time range
     * @return Sum of values
     */
    @Query("""
        SELECT SUM(m.measurementValue) FROM Measurement m
        WHERE m.id.sensorId = :sensorId
        AND m.id.measuredAt BETWEEN :start AND :end
        AND m.id.priority = (
            SELECT MAX(m2.id.priority)
            FROM Measurement m2
            WHERE m2.id.sensorId = m.id.sensorId
            AND m2.id.measuredAt = m.id.measuredAt
        )
    """)
    BigDecimal calculateSum(
        @Param("sensorId") Long sensorId,
        @Param("start") Instant start,
        @Param("end") Instant end
    );

    /**
     * Find minimum measurement value within time range.
     * @param sensorId The sensor ID
     * @param start Start of time range
     * @param end End of time range
     * @return Minimum value
     */
    @Query("""
        SELECT MIN(m.measurementValue) FROM Measurement m
        WHERE m.id.sensorId = :sensorId
        AND m.id.measuredAt BETWEEN :start AND :end
        AND m.id.priority = (
            SELECT MAX(m2.id.priority)
            FROM Measurement m2
            WHERE m2.id.sensorId = m.id.sensorId
            AND m2.id.measuredAt = m.id.measuredAt
        )
    """)
    BigDecimal calculateMin(
        @Param("sensorId") Long sensorId,
        @Param("start") Instant start,
        @Param("end") Instant end
    );

    /**
     * Find maximum measurement value within time range.
     * @param sensorId The sensor ID
     * @param start Start of time range
     * @param end End of time range
     * @return Maximum value
     */
    @Query("""
        SELECT MAX(m.measurementValue) FROM Measurement m
        WHERE m.id.sensorId = :sensorId
        AND m.id.measuredAt BETWEEN :start AND :end
        AND m.id.priority = (
            SELECT MAX(m2.id.priority)
            FROM Measurement m2
            WHERE m2.id.sensorId = m.id.sensorId
            AND m2.id.measuredAt = m.id.measuredAt
        )
    """)
    BigDecimal calculateMax(
        @Param("sensorId") Long sensorId,
        @Param("start") Instant start,
        @Param("end") Instant end
    );

    // === Audit Trail Queries ===

    /**
     * Get all priority versions for a specific measurement timestamp (audit trail).
     * @param sensorId The sensor ID
     * @param measuredAt The measurement timestamp
     * @return List of all versions ordered by priority (highest first)
     */
    @Query("""
        SELECT m FROM Measurement m
        WHERE m.id.sensorId = :sensorId
        AND m.id.measuredAt = :measuredAt
        ORDER BY m.id.priority DESC
    """)
    List<Measurement> findAllVersions(
        @Param("sensorId") Long sensorId,
        @Param("measuredAt") Instant measuredAt
    );

    // === Data Retention and Maintenance ===

    /**
     * Delete measurements older than the specified date (for data retention policies).
     * @param before Delete measurements before this timestamp
     * @return Number of deleted records
     */
    @Modifying
    @Query("DELETE FROM Measurement m WHERE m.id.measuredAt < :before")
    int deleteOldMeasurements(@Param("before") Instant before);

    /**
     * Count total measurements for a specific sensor.
     * @param sensorId The sensor ID
     * @return Count of measurements
     */
    @Query("SELECT COUNT(m) FROM Measurement m WHERE m.id.sensorId = :sensorId")
    long countMeasurementsBySensor(@Param("sensorId") Long sensorId);

    /**
     * Find the latest measurement for a sensor (highest priority).
     * @param sensorId The sensor ID
     * @return Latest measurement
     */
    @Query("""
        SELECT m FROM Measurement m
        WHERE m.id.sensorId = :sensorId
        AND m.id.measuredAt = (
            SELECT MAX(m2.id.measuredAt)
            FROM Measurement m2
            WHERE m2.id.sensorId = :sensorId
        )
        AND m.id.priority = (
            SELECT MAX(m3.id.priority)
            FROM Measurement m3
            WHERE m3.id.sensorId = :sensorId
            AND m3.id.measuredAt = m.id.measuredAt
        )
    """)
    Measurement findLatestMeasurement(@Param("sensorId") Long sensorId);

    /**
     * Count measurements by source type for monitoring.
     * @param sourceType The source type
     * @return Count of measurements
     */
    long countBySourceType(String sourceType);
}
