package org.jevis.repository;

import org.jevis.model.Sensor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Repository for Sensor entity providing query methods for sensor management
 * and sensor replacement chain tracking.
 */
@Repository
public interface SensorRepository extends JpaRepository<Sensor, Long> {

    // Find by unique sensor code
    Optional<Sensor> findBySensorCode(String sensorCode);

    // Find all active sensors
    List<Sensor> findByIsActiveTrue();

    // Filter by measurement type
    List<Sensor> findByMeasurementType(String measurementType);

    // Filter by location
    List<Sensor> findByLocation(String location);

    // Get all sensors in replacement chain by logical sensor ID
    List<Sensor> findByLogicalSensorId(Long logicalSensorId);

    // Get active sensor in replacement chain
    Optional<Sensor> findByLogicalSensorIdAndIsActiveTrue(Long logicalSensorId);

    // Check if sensor code exists (for validation)
    boolean existsBySensorCode(String sensorCode);

    /**
     * Find sensors that need calibration (calibration date is before the given date).
     * @param date The date to check against
     * @return List of sensors needing calibration
     */
    @Query("SELECT s FROM Sensor s WHERE s.calibrationDate IS NOT NULL AND s.calibrationDate < :date AND s.isActive = true")
    List<Sensor> findSensorsNeedingCalibration(@Param("date") LocalDate date);

    /**
     * Get complete replacement chain for a logical sensor, ordered chronologically.
     * @param logicalSensorId The logical sensor ID
     * @return List of sensors in the replacement chain
     */
    @Query("SELECT s FROM Sensor s WHERE s.logicalSensorId = :logicalSensorId ORDER BY s.createdAt ASC")
    List<Sensor> findSensorChain(@Param("logicalSensorId") Long logicalSensorId);

    /**
     * Get chronological list of sensor replacements (sensors that replaced other sensors).
     * @param logicalSensorId The logical sensor ID
     * @return List of replacement sensors ordered by replaced_at
     */
    @Query("SELECT s FROM Sensor s WHERE s.logicalSensorId = :logicalSensorId AND s.replacesSensor IS NOT NULL ORDER BY s.replacedAt ASC")
    List<Sensor> findReplacementHistory(@Param("logicalSensorId") Long logicalSensorId);

    /**
     * Find sensors by manufacturer.
     * @param manufacturer The manufacturer name
     * @return List of sensors
     */
    List<Sensor> findByManufacturer(String manufacturer);

    /**
     * Find sensors by model.
     * @param model The model name
     * @return List of sensors
     */
    List<Sensor> findByModel(String model);

    /**
     * Find all inactive sensors.
     * @return List of inactive sensors
     */
    @Query("SELECT s FROM Sensor s WHERE s.isActive = false")
    List<Sensor> findInactiveSensors();

    /**
     * Search sensors with filters (paginated).
     * @param search Search term (matches sensor code, name, or location)
     * @param measurementType Measurement type filter
     * @param isActive Active status filter
     * @param pageable Pagination parameters
     * @return Page of matching sensors
     */
    @Query("""
        SELECT s FROM Sensor s
        WHERE (:search IS NULL OR LOWER(s.sensorCode) LIKE :search OR LOWER(s.sensorName) LIKE :search OR LOWER(s.location) LIKE :search)
        AND (:measurementType IS NULL OR s.measurementType = :measurementType)
        AND (:isActive IS NULL OR s.isActive = :isActive)
    """)
    Page<Sensor> searchSensors(
        @Param("search") String search,
        @Param("measurementType") String measurementType,
        @Param("isActive") Boolean isActive,
        Pageable pageable
    );
}
