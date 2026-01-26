package org.jevis.service;

import org.jevis.model.Measurement;
import org.jevis.model.MeasurementId;
import org.jevis.model.Sensor;
import org.jevis.repository.MeasurementRepository;
import org.jevis.repository.SensorRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration tests for MeasurementService.
 * Tests measurement CRUD, priority system, aggregations, and time-series queries.
 */
@SpringBootTest
@Transactional
class MeasurementServiceTest {

    @Autowired
    private MeasurementService measurementService;

    @Autowired
    private SensorService sensorService;

    @Autowired
    private MeasurementRepository measurementRepository;

    @Autowired
    private SensorRepository sensorRepository;

    private Sensor testSensor;

    @BeforeEach
    void setUp() {
        // Clean up database before each test
        measurementRepository.deleteAll();
        sensorRepository.deleteAll();

        // Create test sensor
        testSensor = new Sensor("PV_INVERTER_001", "power", "kW");
        testSensor.setSensorName("Test Inverter");
        testSensor = sensorService.createSensor(testSensor);
    }

    // === CRUD Tests ===

    @Test
    void testCreateMeasurement_Success() {
        // Arrange
        Instant now = Instant.now();
        MeasurementId id = new MeasurementId(testSensor.getId(), now, (short) 0);
        Measurement measurement = new Measurement(id, new BigDecimal("125.456789"));
        measurement.setSourceType("automatic");

        // Act
        Measurement created = measurementService.createMeasurement(measurement);

        // Assert
        assertNotNull(created.getId());
        assertEquals(testSensor.getId(), created.getId().getSensorId());
        assertEquals(now, created.getId().getMeasuredAt());
        assertEquals((short) 0, created.getId().getPriority());
        assertEquals(new BigDecimal("125.456789"), created.getMeasurementValue());
        assertEquals("automatic", created.getSourceType());
        // importedAt is set by @CreationTimestamp after flush
    }

    @Test
    void testCreateMeasurement_InvalidSensor_ThrowsException() {
        // Arrange
        Instant now = Instant.now();
        MeasurementId id = new MeasurementId(999L, now, (short) 0); // Non-existent sensor
        Measurement measurement = new Measurement(id, new BigDecimal("100.0"));

        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> measurementService.createMeasurement(measurement));
    }

    @Test
    void testCreateMeasurement_InvalidPriority_ThrowsException() {
        // Arrange
        Instant now = Instant.now();
        MeasurementId id = new MeasurementId(testSensor.getId(), now, (short) 5); // Invalid priority
        Measurement measurement = new Measurement(id, new BigDecimal("100.0"));

        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> measurementService.createMeasurement(measurement));
    }

    @Test
    void testCreateMeasurement_InvalidSourceType_ThrowsException() {
        // Arrange
        Instant now = Instant.now();
        MeasurementId id = new MeasurementId(testSensor.getId(), now, (short) 0);
        Measurement measurement = new Measurement(id, new BigDecimal("100.0"));
        measurement.setSourceType("invalid_type");

        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> measurementService.createMeasurement(measurement));
    }

    @Test
    void testCreateMeasurement_NullValue_ThrowsException() {
        // Arrange
        Instant now = Instant.now();
        MeasurementId id = new MeasurementId(testSensor.getId(), now, (short) 0);
        Measurement measurement = new Measurement(id, null); // Null value

        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> measurementService.createMeasurement(measurement));
    }

    @Test
    void testCreateMeasurementsBatch_Success() {
        // Arrange
        List<Measurement> measurements = new ArrayList<>();
        Instant baseTime = Instant.now();

        for (int i = 0; i < 100; i++) {
            Instant timestamp = baseTime.plus(i, ChronoUnit.MINUTES);
            MeasurementId id = new MeasurementId(testSensor.getId(), timestamp, (short) 0);
            Measurement measurement = new Measurement(id, new BigDecimal("100." + i));
            measurements.add(measurement);
        }

        // Act
        List<Measurement> created = measurementService.createMeasurementsBatch(measurements);

        // Assert
        assertEquals(100, created.size());
    }

    // === Priority System Tests ===

    @Test
    void testPrioritySystem_MultipleVersions() {
        // Arrange - truncate to avoid nanosecond precision issues
        Instant timestamp = Instant.now().truncatedTo(ChronoUnit.MILLIS);

        // Create automatic measurement (priority 0)
        MeasurementId id0 = new MeasurementId(testSensor.getId(), timestamp, (short) 0);
        Measurement measurement0 = new Measurement(id0, new BigDecimal("100.0"));
        measurementService.createMeasurement(measurement0);

        // Override with manual correction (priority 1)
        measurementService.overrideMeasurement(
            testSensor.getId(),
            timestamp,
            new BigDecimal("105.5"),
            (short) 1,
            "operator@example.com",
            "Sensor reading was incorrect due to dust on panel"
        );

        // Act
        List<Measurement> versions = measurementService.getAllVersions(testSensor.getId(), timestamp);

        // Assert
        assertEquals(2, versions.size());
        // Should be ordered by priority DESC (1 first, then 0)
        assertEquals((short) 1, versions.get(0).getId().getPriority());
        assertEquals(0, new BigDecimal("105.5").compareTo(versions.get(0).getMeasurementValue()));
        assertEquals("manual", versions.get(0).getSourceType());
        assertEquals("operator@example.com", versions.get(0).getCreatedBy());

        assertEquals((short) 0, versions.get(1).getId().getPriority());
        assertEquals(0, new BigDecimal("100.0").compareTo(versions.get(1).getMeasurementValue()));
    }

    @Test
    void testOverrideMeasurement_ValidatedPriority() {
        // Arrange
        Instant timestamp = Instant.now();
        MeasurementId id = new MeasurementId(testSensor.getId(), timestamp, (short) 0);
        Measurement measurement = new Measurement(id, new BigDecimal("100.0"));
        measurementService.createMeasurement(measurement);

        // Act - Override with validated priority (3)
        Measurement validated = measurementService.overrideMeasurement(
            testSensor.getId(),
            timestamp,
            new BigDecimal("100.0"),
            (short) 3,
            "supervisor@example.com",
            "Officially validated"
        );

        // Assert
        assertEquals((short) 3, validated.getId().getPriority());
        assertEquals("validated", validated.getSourceType());
        assertEquals("supervisor@example.com", validated.getCreatedBy());
    }

    @Test
    void testOverrideMeasurement_InvalidPriority_ThrowsException() {
        // Arrange
        Instant timestamp = Instant.now();

        // Act & Assert - Priority 0 is not allowed for overrides
        assertThrows(IllegalArgumentException.class, () ->
            measurementService.overrideMeasurement(
                testSensor.getId(),
                timestamp,
                new BigDecimal("100.0"),
                (short) 0,
                "user@example.com",
                "Invalid override"
            )
        );
    }

    @Test
    void testGetCurrentMeasurements_ReturnsHighestPriority() {
        // Arrange
        Instant baseTime = Instant.now().truncatedTo(ChronoUnit.SECONDS);

        // Create measurements at different timestamps with different priorities
        for (int i = 0; i < 5; i++) {
            Instant timestamp = baseTime.plus(i, ChronoUnit.HOURS);

            // Priority 0 (automatic)
            MeasurementId id0 = new MeasurementId(testSensor.getId(), timestamp, (short) 0);
            measurementService.createMeasurement(new Measurement(id0, new BigDecimal("100.0")));

            // For timestamps 1 and 3, add priority 1 override
            if (i == 1 || i == 3) {
                measurementService.overrideMeasurement(
                    testSensor.getId(),
                    timestamp,
                    new BigDecimal("105.0"),
                    (short) 1,
                    "operator@example.com",
                    "Corrected"
                );
            }
        }

        // Act - extend range slightly to ensure all measurements are included
        List<Measurement> current = measurementService.getCurrentMeasurements(
            testSensor.getId(),
            baseTime.minus(1, ChronoUnit.MINUTES),
            baseTime.plus(5, ChronoUnit.HOURS)
        );

        // Assert
        assertEquals(5, current.size());

        // Check that timestamp 1 and 3 have priority 1, others have priority 0
        for (Measurement m : current) {
            long hoursDiff = ChronoUnit.HOURS.between(baseTime, m.getId().getMeasuredAt());
            if (hoursDiff == 1 || hoursDiff == 3) {
                assertEquals((short) 1, m.getId().getPriority());
                assertEquals(0, new BigDecimal("105.0").compareTo(m.getMeasurementValue()));
            } else {
                assertEquals((short) 0, m.getId().getPriority());
                assertEquals(0, new BigDecimal("100.0").compareTo(m.getMeasurementValue()));
            }
        }
    }

    // === Time-Series Query Tests ===

    @Test
    void testGetMeasurementsInRange_Paginated() {
        // Arrange
        Instant baseTime = Instant.now();
        for (int i = 0; i < 50; i++) {
            Instant timestamp = baseTime.plus(i, ChronoUnit.MINUTES);
            MeasurementId id = new MeasurementId(testSensor.getId(), timestamp, (short) 0);
            measurementService.createMeasurement(new Measurement(id, new BigDecimal("100." + i)));
        }

        // Act
        Pageable pageable = PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "id.measuredAt"));
        Page<Measurement> page = measurementService.getMeasurementsInRange(
            testSensor.getId(),
            baseTime,
            baseTime.plus(50, ChronoUnit.MINUTES),
            pageable
        );

        // Assert
        assertEquals(10, page.getContent().size());
        assertEquals(50, page.getTotalElements());
        assertEquals(5, page.getTotalPages());
    }

    @Test
    void testGetLatestMeasurement() {
        // Arrange
        Instant baseTime = Instant.now();
        Instant latestTime = baseTime.plus(10, ChronoUnit.HOURS);

        // Create measurements at different times
        for (int i = 0; i <= 10; i++) {
            Instant timestamp = baseTime.plus(i, ChronoUnit.HOURS);
            MeasurementId id = new MeasurementId(testSensor.getId(), timestamp, (short) 0);
            measurementService.createMeasurement(new Measurement(id, new BigDecimal("100." + i)));
        }

        // Act
        Measurement latest = measurementService.getLatestMeasurement(testSensor.getId());

        // Assert
        assertNotNull(latest);
        assertEquals(latestTime.truncatedTo(ChronoUnit.MILLIS),
                     latest.getId().getMeasuredAt().truncatedTo(ChronoUnit.MILLIS));
        assertEquals(0, new BigDecimal("100.10").compareTo(latest.getMeasurementValue()));
    }

    @Test
    void testGetLatestMeasurement_NoMeasurements_ThrowsException() {
        // Act & Assert
        assertThrows(IllegalArgumentException.class, () ->
            measurementService.getLatestMeasurement(testSensor.getId())
        );
    }

    // === Aggregation Tests ===

    @Test
    void testCalculateAverage() {
        // Arrange
        Instant baseTime = Instant.now();
        BigDecimal sum = BigDecimal.ZERO;

        for (int i = 0; i < 10; i++) {
            Instant timestamp = baseTime.plus(i, ChronoUnit.HOURS);
            BigDecimal value = new BigDecimal("100." + i);
            sum = sum.add(value);

            MeasurementId id = new MeasurementId(testSensor.getId(), timestamp, (short) 0);
            measurementService.createMeasurement(new Measurement(id, value));
        }

        BigDecimal expectedAverage = sum.divide(new BigDecimal("10"), 6, BigDecimal.ROUND_HALF_UP);

        // Act
        BigDecimal average = measurementService.calculateAverage(
            testSensor.getId(),
            baseTime,
            baseTime.plus(10, ChronoUnit.HOURS)
        );

        // Assert - check that average is in reasonable range
        assertNotNull(average);
        assertTrue(average.compareTo(new BigDecimal("100")) > 0);
        assertTrue(average.compareTo(new BigDecimal("101")) < 0);
    }

    @Test
    void testCalculateSum() {
        // Arrange
        Instant baseTime = Instant.now();

        for (int i = 1; i <= 10; i++) {
            Instant timestamp = baseTime.plus(i, ChronoUnit.HOURS);
            MeasurementId id = new MeasurementId(testSensor.getId(), timestamp, (short) 0);
            measurementService.createMeasurement(new Measurement(id, new BigDecimal(i * 10)));
        }

        // Act
        BigDecimal sum = measurementService.calculateSum(
            testSensor.getId(),
            baseTime,
            baseTime.plus(11, ChronoUnit.HOURS)
        );

        // Assert - use compareTo for BigDecimal (ignores scale differences)
        assertEquals(0, new BigDecimal("550").compareTo(sum)); // 10+20+30+...+100 = 550
    }

    @Test
    void testCalculateMinMax() {
        // Arrange
        Instant baseTime = Instant.now();

        // Create measurements with values: 50, 25, 100, 75, 10
        BigDecimal[] values = {
            new BigDecimal("50.0"),
            new BigDecimal("25.0"),
            new BigDecimal("100.0"),
            new BigDecimal("75.0"),
            new BigDecimal("10.0")
        };

        for (int i = 0; i < values.length; i++) {
            Instant timestamp = baseTime.plus(i, ChronoUnit.HOURS);
            MeasurementId id = new MeasurementId(testSensor.getId(), timestamp, (short) 0);
            measurementService.createMeasurement(new Measurement(id, values[i]));
        }

        // Act
        Map<String, BigDecimal> minMax = measurementService.calculateMinMax(
            testSensor.getId(),
            baseTime,
            baseTime.plus(5, ChronoUnit.HOURS)
        );

        // Assert - use compareTo for BigDecimal (ignores scale differences)
        assertEquals(0, new BigDecimal("10.0").compareTo(minMax.get("min")));
        assertEquals(0, new BigDecimal("100.0").compareTo(minMax.get("max")));
    }

    // === Logical Sensor Chain Tests ===

    @Test
    void testGetMeasurementsByLogicalSensor() {
        // Arrange - truncate to avoid precision issues
        Instant baseTime = Instant.now().truncatedTo(ChronoUnit.SECONDS);

        // Create measurements for first sensor (6 hours)
        for (int i = 0; i < 6; i++) {
            Instant timestamp = baseTime.plus(i, ChronoUnit.HOURS);
            MeasurementId id = new MeasurementId(testSensor.getId(), timestamp, (short) 0);
            measurementService.createMeasurement(new Measurement(id, new BigDecimal("100." + i)));
        }

        // Replace sensor after 6 hours
        Sensor newSensor = new Sensor("PV_INVERTER_001_V2", "power", "kW");
        newSensor = sensorService.replaceSensor(testSensor.getId(), newSensor);

        // Create measurements for new sensor (4 hours)
        for (int i = 6; i < 10; i++) {
            Instant timestamp = baseTime.plus(i, ChronoUnit.HOURS);
            MeasurementId id = new MeasurementId(newSensor.getId(), timestamp, (short) 0);
            measurementService.createMeasurement(new Measurement(id, new BigDecimal("100." + i)));
        }

        // Act - Get all measurements for logical sensor (extend range slightly)
        List<Measurement> measurements = measurementService.getMeasurementsByLogicalSensor(
            testSensor.getLogicalSensorId(),
            baseTime.minus(1, ChronoUnit.MINUTES),
            baseTime.plus(10, ChronoUnit.HOURS)
        );

        // Assert
        assertEquals(10, measurements.size()); // Should get measurements from both sensors
    }

    // === Data Maintenance Tests ===

    @Test
    void testDeleteOldMeasurements() {
        // Arrange
        Instant oldTime = Instant.now().minus(365, ChronoUnit.DAYS);
        Instant newTime = Instant.now();

        // Create old measurement
        MeasurementId oldId = new MeasurementId(testSensor.getId(), oldTime, (short) 0);
        measurementService.createMeasurement(new Measurement(oldId, new BigDecimal("100.0")));

        // Create new measurement
        MeasurementId newId = new MeasurementId(testSensor.getId(), newTime, (short) 0);
        measurementService.createMeasurement(new Measurement(newId, new BigDecimal("100.0")));

        // Act - Delete measurements older than 30 days
        int deleted = measurementService.deleteOldMeasurements(
            Instant.now().minus(30, ChronoUnit.DAYS)
        );

        // Assert
        assertEquals(1, deleted); // Only old measurement should be deleted

        // Verify new measurement still exists
        Measurement remaining = measurementService.getMeasurementById(newId);
        assertNotNull(remaining);
    }

    @Test
    void testValidateMeasurement() {
        // Arrange - truncate to avoid precision issues
        Instant timestamp = Instant.now().truncatedTo(ChronoUnit.MILLIS);
        MeasurementId id = new MeasurementId(testSensor.getId(), timestamp, (short) 0);
        Measurement measurement = new Measurement(id, new BigDecimal("100.0"));
        measurementService.createMeasurement(measurement);

        // Act - Validate the measurement (creates priority 2 version)
        Measurement validated = measurementService.validateMeasurement(
            testSensor.getId(),
            timestamp,
            "supervisor@example.com"
        );

        // Assert
        assertEquals((short) 2, validated.getId().getPriority());
        assertEquals("corrected", validated.getSourceType());
        assertEquals("supervisor@example.com", validated.getCreatedBy());
        assertEquals(0, new BigDecimal("100.0").compareTo(validated.getMeasurementValue()));
    }

    @Test
    void testCountMeasurementsBySensor() {
        // Arrange
        Instant baseTime = Instant.now();
        for (int i = 0; i < 25; i++) {
            Instant timestamp = baseTime.plus(i, ChronoUnit.MINUTES);
            MeasurementId id = new MeasurementId(testSensor.getId(), timestamp, (short) 0);
            measurementService.createMeasurement(new Measurement(id, new BigDecimal("100." + i)));
        }

        // Act
        long count = measurementService.countMeasurementsBySensor(testSensor.getId());

        // Assert
        assertEquals(25, count);
    }

    // === BigDecimal Precision Tests ===

    @Test
    void testBigDecimalPrecision() {
        // Arrange - Test 6 decimal places precision
        Instant now = Instant.now();
        MeasurementId id = new MeasurementId(testSensor.getId(), now, (short) 0);
        Measurement measurement = new Measurement(id, new BigDecimal("123.456789"));

        // Act
        Measurement created = measurementService.createMeasurement(measurement);

        // Assert - Should store 6 decimal places
        assertEquals(new BigDecimal("123.456789"), created.getMeasurementValue());
    }
}
