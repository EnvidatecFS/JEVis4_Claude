package org.jevis.service;

import org.jevis.model.Sensor;
import org.jevis.repository.SensorRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service for managing sensors and sensor replacement workflows in PV systems.
 * Provides business logic for sensor CRUD operations, validation, and replacement tracking.
 */
@Service
@Transactional(readOnly = true)
public class SensorService {

    private final SensorRepository sensorRepository;

    public SensorService(SensorRepository sensorRepository) {
        this.sensorRepository = sensorRepository;
    }

    // === CRUD Operations ===

    /**
     * Create a new sensor with validation.
     * @param sensor The sensor to create
     * @return The created sensor
     * @throws IllegalArgumentException if sensor_code already exists
     */
    @Transactional
    public Sensor createSensor(Sensor sensor) {
        // Validate sensor_code uniqueness
        if (sensorRepository.existsBySensorCode(sensor.getSensorCode())) {
            throw new IllegalArgumentException("Sensor code already exists: " + sensor.getSensorCode());
        }

        // Set defaults
        if (sensor.getIsActive() == null) {
            sensor.setIsActive(true);
        }

        return sensorRepository.save(sensor);
    }

    /**
     * Update an existing sensor.
     * @param id The sensor ID
     * @param updatedSensor The updated sensor data
     * @return The updated sensor
     * @throws IllegalArgumentException if sensor not found
     */
    @Transactional
    public Sensor updateSensor(Long id, Sensor updatedSensor) {
        Sensor existingSensor = getSensorById(id);

        // Update fields (excluding ID and sensor_code which shouldn't change)
        existingSensor.setSensorName(updatedSensor.getSensorName());
        existingSensor.setMeasurementType(updatedSensor.getMeasurementType());
        existingSensor.setUnit(updatedSensor.getUnit());
        existingSensor.setLocation(updatedSensor.getLocation());
        existingSensor.setDescription(updatedSensor.getDescription());
        existingSensor.setManufacturer(updatedSensor.getManufacturer());
        existingSensor.setModel(updatedSensor.getModel());
        existingSensor.setCalibrationDate(updatedSensor.getCalibrationDate());
        existingSensor.setIsActive(updatedSensor.getIsActive());
        existingSensor.setMetadata(updatedSensor.getMetadata());

        return sensorRepository.save(existingSensor);
    }

    /**
     * Delete a sensor (will CASCADE delete all measurements).
     * @param id The sensor ID
     * @throws IllegalArgumentException if sensor not found
     */
    @Transactional
    public void deleteSensor(Long id) {
        if (!sensorRepository.existsById(id)) {
            throw new IllegalArgumentException("Sensor not found with ID: " + id);
        }
        sensorRepository.deleteById(id);
    }

    // === Retrieval Methods ===

    /**
     * Get all sensors.
     * @return List of all sensors
     */
    public List<Sensor> getAllSensors() {
        return sensorRepository.findAll();
    }

    /**
     * Get all sensors (paginated).
     * @param pageable Pagination parameters
     * @return Page of sensors
     */
    public Page<Sensor> getAllSensors(Pageable pageable) {
        return sensorRepository.findAll(pageable);
    }

    /**
     * Search sensors with filters.
     * @param search Search term for sensor code, name, or location
     * @param type Measurement type filter
     * @param status Status filter (active, inactive, or empty for all)
     * @param pageable Pagination parameters
     * @return Page of matching sensors
     */
    public Page<Sensor> searchSensors(String search, String type, String status, Pageable pageable) {
        Boolean isActive = null;
        if ("active".equalsIgnoreCase(status)) {
            isActive = true;
        } else if ("inactive".equalsIgnoreCase(status)) {
            isActive = false;
        }

        String searchTerm = (search == null || search.isEmpty()) ? null : "%" + search.toLowerCase() + "%";
        String typeFilter = (type == null || type.isEmpty()) ? null : type;

        return sensorRepository.searchSensors(searchTerm, typeFilter, isActive, pageable);
    }

    /**
     * Get all distinct measurement types.
     * @return List of measurement types
     */
    public List<String> getAllMeasurementTypes() {
        return sensorRepository.findAll().stream()
            .map(Sensor::getMeasurementType)
            .distinct()
            .sorted()
            .collect(Collectors.toList());
    }

    /**
     * Get sensor by ID.
     * @param id The sensor ID
     * @return The sensor
     * @throws IllegalArgumentException if sensor not found
     */
    public Sensor getSensorById(Long id) {
        return sensorRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Sensor not found with ID: " + id));
    }

    /**
     * Get sensor by unique sensor code.
     * @param sensorCode The sensor code
     * @return Optional containing the sensor if found
     */
    public Optional<Sensor> getSensorByCode(String sensorCode) {
        return sensorRepository.findBySensorCode(sensorCode);
    }

    /**
     * Get all active sensors.
     * @return List of active sensors
     */
    public List<Sensor> getActiveSensors() {
        return sensorRepository.findByIsActiveTrue();
    }

    /**
     * Get sensors by measurement type.
     * @param measurementType The measurement type (e.g., "power", "voltage", "temperature")
     * @return List of sensors
     */
    public List<Sensor> getSensorsByType(String measurementType) {
        return sensorRepository.findByMeasurementType(measurementType);
    }

    /**
     * Get sensors by location.
     * @param location The location
     * @return List of sensors
     */
    public List<Sensor> getSensorsByLocation(String location) {
        return sensorRepository.findByLocation(location);
    }

    // === Sensor Replacement Workflow ===

    /**
     * Replace a sensor with a new one, maintaining the logical sensor chain.
     * This workflow:
     * 1. Deactivates the old sensor
     * 2. Creates new sensor with same logical_sensor_id
     * 3. Sets replaces_sensor_id to old sensor
     * 4. Sets replaced_at to current timestamp
     * @param oldSensorId The ID of the sensor to replace
     * @param newSensor The new sensor data
     * @return The newly created replacement sensor
     * @throws IllegalArgumentException if old sensor not found
     */
    @Transactional
    public Sensor replaceSensor(Long oldSensorId, Sensor newSensor) {
        // Get the old sensor
        Sensor oldSensor = getSensorById(oldSensorId);

        // Deactivate old sensor
        oldSensor.setIsActive(false);
        oldSensor.setReplacedAt(Instant.now());
        sensorRepository.save(oldSensor);

        // Set up new sensor to continue the logical chain
        if (oldSensor.getLogicalSensorId() != null) {
            newSensor.setLogicalSensorId(oldSensor.getLogicalSensorId());
        } else {
            // If old sensor doesn't have a logical_sensor_id, use its ID as the logical ID
            newSensor.setLogicalSensorId(oldSensorId);
            // Also update the old sensor to have this logical ID
            oldSensor.setLogicalSensorId(oldSensorId);
            sensorRepository.save(oldSensor);
        }

        newSensor.setReplacesSensor(oldSensor);
        newSensor.setReplacedAt(Instant.now());
        newSensor.setIsActive(true);

        // Validate new sensor code uniqueness
        if (sensorRepository.existsBySensorCode(newSensor.getSensorCode())) {
            throw new IllegalArgumentException("Sensor code already exists: " + newSensor.getSensorCode());
        }

        return sensorRepository.save(newSensor);
    }

    /**
     * Deactivate a sensor.
     * @param id The sensor ID
     * @return The deactivated sensor
     * @throws IllegalArgumentException if sensor not found
     */
    @Transactional
    public Sensor deactivateSensor(Long id) {
        Sensor sensor = getSensorById(id);
        sensor.setIsActive(false);
        sensor.setReplacedAt(Instant.now());
        return sensorRepository.save(sensor);
    }

    /**
     * Get complete sensor replacement chain for a logical sensor.
     * @param logicalSensorId The logical sensor ID
     * @return List of sensors in chronological order
     */
    public List<Sensor> getSensorChain(Long logicalSensorId) {
        return sensorRepository.findSensorChain(logicalSensorId);
    }

    /**
     * Get replacement history for a logical sensor.
     * @param logicalSensorId The logical sensor ID
     * @return List of replacement sensors in chronological order
     */
    public List<Sensor> getReplacementHistory(Long logicalSensorId) {
        return sensorRepository.findReplacementHistory(logicalSensorId);
    }

    // === Queries ===

    /**
     * Get sensors that need calibration (calibration date is past).
     * @return List of sensors needing calibration
     */
    public List<Sensor> getSensorsNeedingCalibration() {
        return sensorRepository.findSensorsNeedingCalibration(LocalDate.now());
    }

    /**
     * Get the currently active sensor in a logical sensor chain.
     * @param logicalSensorId The logical sensor ID
     * @return Optional containing the active sensor if found
     */
    public Optional<Sensor> getLogicalSensorCurrent(Long logicalSensorId) {
        return sensorRepository.findByLogicalSensorIdAndIsActiveTrue(logicalSensorId);
    }

    /**
     * Get sensors by manufacturer.
     * @param manufacturer The manufacturer name
     * @return List of sensors
     */
    public List<Sensor> getSensorsByManufacturer(String manufacturer) {
        return sensorRepository.findByManufacturer(manufacturer);
    }

    /**
     * Get sensors by model.
     * @param model The model name
     * @return List of sensors
     */
    public List<Sensor> getSensorsByModel(String model) {
        return sensorRepository.findByModel(model);
    }

    /**
     * Get all inactive sensors.
     * @return List of inactive sensors
     */
    public List<Sensor> getInactiveSensors() {
        return sensorRepository.findInactiveSensors();
    }
}
