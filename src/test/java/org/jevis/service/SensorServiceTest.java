package org.jevis.service;

import org.jevis.model.Sensor;
import org.jevis.repository.SensorRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration tests for SensorService.
 * Tests sensor CRUD operations, validation, and replacement workflow.
 */
@SpringBootTest
@Transactional
class SensorServiceTest {

    @Autowired
    private SensorService sensorService;

    @Autowired
    private SensorRepository sensorRepository;

    @BeforeEach
    void setUp() {
        // Clean up database before each test
        sensorRepository.deleteAll();
    }

    // === CRUD Tests ===

    @Test
    void testCreateSensor_Success() {
        // Arrange
        Sensor sensor = new Sensor("PV_INVERTER_001", "power", "kW");
        sensor.setSensorName("Main Inverter");
        sensor.setLocation("Building A - Roof");
        sensor.setManufacturer("Siemens");
        sensor.setModel("SITOP PSU100C");

        // Act
        Sensor created = sensorService.createSensor(sensor);

        // Assert
        assertNotNull(created.getId());
        assertEquals("PV_INVERTER_001", created.getSensorCode());
        assertEquals("power", created.getMeasurementType());
        assertEquals("kW", created.getUnit());
        assertEquals("Main Inverter", created.getSensorName());
        assertTrue(created.getIsActive());
        assertNotNull(created.getCreatedAt());
        assertNotNull(created.getUpdatedAt());
    }

    @Test
    void testCreateSensor_DuplicateSensorCode_ThrowsException() {
        // Arrange
        Sensor sensor1 = new Sensor("PV_INVERTER_001", "power", "kW");
        sensorService.createSensor(sensor1);

        Sensor sensor2 = new Sensor("PV_INVERTER_001", "voltage", "V");

        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> sensorService.createSensor(sensor2));
    }

    @Test
    void testUpdateSensor_Success() {
        // Arrange
        Sensor sensor = new Sensor("PV_INVERTER_001", "power", "kW");
        Sensor created = sensorService.createSensor(sensor);

        // Act
        created.setSensorName("Updated Inverter");
        created.setLocation("Building B");
        Sensor updated = sensorService.updateSensor(created.getId(), created);

        // Assert
        assertEquals("Updated Inverter", updated.getSensorName());
        assertEquals("Building B", updated.getLocation());
        assertNotNull(updated.getUpdatedAt());
    }

    @Test
    void testDeleteSensor_Success() {
        // Arrange
        Sensor sensor = new Sensor("PV_INVERTER_001", "power", "kW");
        Sensor created = sensorService.createSensor(sensor);

        // Act
        sensorService.deleteSensor(created.getId());

        // Assert
        assertFalse(sensorRepository.existsById(created.getId()));
    }

    @Test
    void testGetSensorById_NotFound_ThrowsException() {
        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> sensorService.getSensorById(999L));
    }

    // === Retrieval Tests ===

    @Test
    void testGetSensorByCode_Success() {
        // Arrange
        Sensor sensor = new Sensor("PV_INVERTER_001", "power", "kW");
        sensorService.createSensor(sensor);

        // Act
        Optional<Sensor> found = sensorService.getSensorByCode("PV_INVERTER_001");

        // Assert
        assertTrue(found.isPresent());
        assertEquals("PV_INVERTER_001", found.get().getSensorCode());
    }

    @Test
    void testGetActiveSensors() {
        // Arrange
        Sensor sensor1 = new Sensor("PV_INVERTER_001", "power", "kW");
        Sensor sensor2 = new Sensor("PV_INVERTER_002", "voltage", "V");
        sensor2.setIsActive(false);

        sensorService.createSensor(sensor1);
        sensorService.createSensor(sensor2);

        // Act
        List<Sensor> activeSensors = sensorService.getActiveSensors();

        // Assert
        assertEquals(1, activeSensors.size());
        assertEquals("PV_INVERTER_001", activeSensors.get(0).getSensorCode());
    }

    @Test
    void testGetSensorsByType() {
        // Arrange
        Sensor sensor1 = new Sensor("PV_INVERTER_001", "power", "kW");
        Sensor sensor2 = new Sensor("PV_TEMP_001", "temperature", "°C");
        Sensor sensor3 = new Sensor("PV_INVERTER_002", "power", "kW");

        sensorService.createSensor(sensor1);
        sensorService.createSensor(sensor2);
        sensorService.createSensor(sensor3);

        // Act
        List<Sensor> powerSensors = sensorService.getSensorsByType("power");

        // Assert
        assertEquals(2, powerSensors.size());
    }

    // === Sensor Replacement Workflow Tests ===

    @Test
    void testReplaceSensor_Success() {
        // Arrange
        Sensor oldSensor = new Sensor("PV_INVERTER_001", "power", "kW");
        oldSensor.setSensorName("Old Inverter");
        Sensor created = sensorService.createSensor(oldSensor);

        Sensor newSensor = new Sensor("PV_INVERTER_001_V2", "power", "kW");
        newSensor.setSensorName("New Inverter");

        // Act
        Sensor replacement = sensorService.replaceSensor(created.getId(), newSensor);

        // Assert
        // Check old sensor is deactivated
        Sensor oldSensorUpdated = sensorService.getSensorById(created.getId());
        assertFalse(oldSensorUpdated.getIsActive());
        assertNotNull(oldSensorUpdated.getReplacedAt());

        // Check new sensor is active and linked
        assertTrue(replacement.getIsActive());
        assertNotNull(replacement.getLogicalSensorId());
        assertEquals(oldSensorUpdated.getLogicalSensorId(), replacement.getLogicalSensorId());
        assertNotNull(replacement.getReplacesSensor());
        assertEquals(oldSensorUpdated.getId(), replacement.getReplacesSensor().getId());
    }

    @Test
    void testReplaceSensor_DuplicateSensorCode_ThrowsException() {
        // Arrange
        Sensor oldSensor = new Sensor("PV_INVERTER_001", "power", "kW");
        Sensor created = sensorService.createSensor(oldSensor);

        Sensor existingSensor = new Sensor("PV_INVERTER_002", "power", "kW");
        sensorService.createSensor(existingSensor);

        Sensor newSensor = new Sensor("PV_INVERTER_002", "power", "kW");

        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> sensorService.replaceSensor(created.getId(), newSensor));
    }

    @Test
    void testSensorChain_MultipleReplacements() {
        // Arrange
        Sensor sensor1 = new Sensor("PV_INVERTER_001", "power", "kW");
        Sensor created1 = sensorService.createSensor(sensor1);

        Sensor sensor2 = new Sensor("PV_INVERTER_001_V2", "power", "kW");
        Sensor created2 = sensorService.replaceSensor(created1.getId(), sensor2);

        Sensor sensor3 = new Sensor("PV_INVERTER_001_V3", "power", "kW");
        Sensor created3 = sensorService.replaceSensor(created2.getId(), sensor3);

        // Act
        List<Sensor> chain = sensorService.getSensorChain(created3.getLogicalSensorId());

        // Assert
        assertEquals(3, chain.size());
        assertEquals("PV_INVERTER_001", chain.get(0).getSensorCode());
        assertEquals("PV_INVERTER_001_V2", chain.get(1).getSensorCode());
        assertEquals("PV_INVERTER_001_V3", chain.get(2).getSensorCode());

        // Only the last sensor should be active
        assertFalse(chain.get(0).getIsActive());
        assertFalse(chain.get(1).getIsActive());
        assertTrue(chain.get(2).getIsActive());
    }

    @Test
    void testGetLogicalSensorCurrent() {
        // Arrange
        Sensor sensor1 = new Sensor("PV_INVERTER_001", "power", "kW");
        Sensor created1 = sensorService.createSensor(sensor1);

        Sensor sensor2 = new Sensor("PV_INVERTER_001_V2", "power", "kW");
        Sensor created2 = sensorService.replaceSensor(created1.getId(), sensor2);

        // Act
        Optional<Sensor> current = sensorService.getLogicalSensorCurrent(created2.getLogicalSensorId());

        // Assert
        assertTrue(current.isPresent());
        assertEquals("PV_INVERTER_001_V2", current.get().getSensorCode());
        assertTrue(current.get().getIsActive());
    }

    @Test
    void testDeactivateSensor() {
        // Arrange
        Sensor sensor = new Sensor("PV_INVERTER_001", "power", "kW");
        Sensor created = sensorService.createSensor(sensor);

        // Act
        Sensor deactivated = sensorService.deactivateSensor(created.getId());

        // Assert
        assertFalse(deactivated.getIsActive());
        assertNotNull(deactivated.getReplacedAt());
    }

    // === Calibration Tests ===

    @Test
    void testGetSensorsNeedingCalibration() {
        // Arrange
        Sensor sensor1 = new Sensor("PV_INVERTER_001", "power", "kW");
        sensor1.setCalibrationDate(LocalDate.now().minusMonths(13)); // Past calibration
        sensorService.createSensor(sensor1);

        Sensor sensor2 = new Sensor("PV_INVERTER_002", "voltage", "V");
        sensor2.setCalibrationDate(LocalDate.now().plusMonths(1)); // Future calibration
        sensorService.createSensor(sensor2);

        Sensor sensor3 = new Sensor("PV_INVERTER_003", "current", "A");
        // No calibration date set
        sensorService.createSensor(sensor3);

        // Act
        List<Sensor> needingCalibration = sensorService.getSensorsNeedingCalibration();

        // Assert
        assertEquals(1, needingCalibration.size());
        assertEquals("PV_INVERTER_001", needingCalibration.get(0).getSensorCode());
    }

    // === Metadata Tests ===

    @Test
    void testSensorWithJsonMetadata() {
        // Arrange
        Sensor sensor = new Sensor("PV_INVERTER_001", "power", "kW");
        String metadata = "{\"location\":{\"lat\":52.5200,\"lon\":13.4050},\"site\":\"Berlin Office\"}";
        sensor.setMetadata(metadata);

        // Act
        Sensor created = sensorService.createSensor(sensor);

        // Assert
        assertNotNull(created.getMetadata());
        assertTrue(created.getMetadata().contains("Berlin Office"));
    }

    // === Optional Field Tests ===

    @Test
    void testCreateSensorWithOptionalFields() {
        // Arrange
        Sensor sensor = new Sensor("PV_INVERTER_001", "power", "kW");
        sensor.setSensorName("Test Inverter");
        sensor.setLocation("Building A");
        sensor.setDescription("Main inverter for PV system");
        sensor.setManufacturer("Siemens");
        sensor.setModel("SITOP PSU100C");
        sensor.setCalibrationDate(LocalDate.now());

        // Act
        Sensor created = sensorService.createSensor(sensor);

        // Assert
        assertEquals("Test Inverter", created.getSensorName());
        assertEquals("Building A", created.getLocation());
        assertEquals("Main inverter for PV system", created.getDescription());
        assertEquals("Siemens", created.getManufacturer());
        assertEquals("SITOP PSU100C", created.getModel());
        assertNotNull(created.getCalibrationDate());
    }

    @Test
    void testCreateSensorWithoutOptionalSensorName() {
        // Arrange
        Sensor sensor = new Sensor("PV_INVERTER_001", "power", "kW");
        // sensorName is NOT set (optional field)

        // Act
        Sensor created = sensorService.createSensor(sensor);

        // Assert
        assertNotNull(created.getId());
        assertNull(created.getSensorName());
        assertEquals("PV_INVERTER_001", created.getSensorCode());
    }
}
