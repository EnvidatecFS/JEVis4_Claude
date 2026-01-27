package org.jevis.config;

import org.jevis.model.Measurement;
import org.jevis.model.MeasurementId;
import org.jevis.model.Sensor;
import org.jevis.repository.MeasurementRepository;
import org.jevis.repository.SensorRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * Initializes the database with sample data on application startup.
 * Generates realistic PV sensor data with hourly measurements for one month.
 */
@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    private final SensorRepository sensorRepository;
    private final MeasurementRepository measurementRepository;
    private final Random random = new Random(42); // Fixed seed for reproducible data

    public DataInitializer(SensorRepository sensorRepository, MeasurementRepository measurementRepository) {
        this.sensorRepository = sensorRepository;
        this.measurementRepository = measurementRepository;
    }

    @Override
    @Transactional
    public void run(String... args) {
        if (sensorRepository.count() == 0) {
            log.info("Initializing database with sample data...");

            List<Sensor> sensors = initializeSensors();
            log.info("Created {} sensors", sensors.size());

            initializeMeasurements(sensors);
            log.info("Database initialization complete");
        } else {
            log.debug("Database already initialized with {} sensors", sensorRepository.count());
        }
    }

    private List<Sensor> initializeSensors() {
        List<Sensor> sensors = new ArrayList<>();

        // Power sensors (Wechselrichter)
        sensors.add(createSensor("PV_INV_001", "Wechselrichter Dach Ost", "power", "kW",
                "Gebäude A, Dach Ost", "Hauptwechselrichter für die Ostseite der PV-Anlage",
                "SMA", "Sunny Boy 5.0", true));

        sensors.add(createSensor("PV_INV_002", "Wechselrichter Dach West", "power", "kW",
                "Gebäude A, Dach West", "Hauptwechselrichter für die Westseite der PV-Anlage",
                "Fronius", "Primo 6.0", true));

        // Voltage sensor
        sensors.add(createSensor("PV_VOLT_001", "Spannungssensor Eingang", "voltage", "V",
                "Gebäude A, Technikraum", "Misst die Eingangsspannung der PV-Anlage",
                "ABB", "VSN300", true));

        // Temperature sensor
        sensors.add(createSensor("PV_TEMP_001", "Temperatursensor Module", "temperature", "°C",
                "Gebäude A, Dach", "Misst die Modultemperatur",
                "Siemens", "QAM2120", true));

        // Irradiance sensor
        sensors.add(createSensor("PV_IRR_001", "Einstrahlungssensor", "irradiance", "W/m²",
                "Gebäude A, Dach", "Misst die Sonneneinstrahlung",
                "Kipp & Zonen", "CMP11", true));

        // Energy sensor
        sensors.add(createSensor("PV_ENE_001", "Energiezähler Gesamt", "energy", "kWh",
                "Gebäude A, Zählerschrank", "Gesamtenergiezähler der PV-Anlage",
                "ABB", "B23 112-100", true));

        // Inactive sensor
        sensors.add(createSensor("PV_INV_OLD_001", "Alter Wechselrichter (ersetzt)", "power", "kW",
                "Gebäude A, Dach", "Wurde durch PV_INV_001 ersetzt",
                "SMA", "Sunny Boy 3.0", false));

        return sensors;
    }

    private Sensor createSensor(String code, String name, String type, String unit,
                                 String location, String description, String manufacturer,
                                 String model, boolean active) {
        Sensor sensor = new Sensor();
        sensor.setSensorCode(code);
        sensor.setSensorName(name);
        sensor.setMeasurementType(type);
        sensor.setUnit(unit);
        sensor.setLocation(location);
        sensor.setDescription(description);
        sensor.setManufacturer(manufacturer);
        sensor.setModel(model);
        sensor.setIsActive(active);
        sensor.setCalibrationDate(LocalDate.now().plusMonths(6));
        return sensorRepository.save(sensor);
    }

    private void initializeMeasurements(List<Sensor> sensors) {
        // Generate 30 days of hourly data = 720 measurements per sensor
        Instant startTime = Instant.now().minus(30, ChronoUnit.DAYS).truncatedTo(ChronoUnit.HOURS);
        int hoursToGenerate = 30 * 24; // 720 hours

        int totalMeasurements = 0;
        List<Measurement> batch = new ArrayList<>(1000);

        for (Sensor sensor : sensors) {
            if (!sensor.getIsActive()) {
                continue; // Skip inactive sensors
            }

            BigDecimal cumulativeEnergy = BigDecimal.ZERO;

            for (int hour = 0; hour < hoursToGenerate; hour++) {
                Instant measurementTime = startTime.plus(hour, ChronoUnit.HOURS);
                int hourOfDay = measurementTime.atZone(ZoneId.systemDefault()).getHour();
                int dayOfMonth = measurementTime.atZone(ZoneId.systemDefault()).getDayOfMonth();

                BigDecimal value = generateRealisticValue(sensor.getMeasurementType(),
                        hourOfDay, dayOfMonth, cumulativeEnergy);

                // Update cumulative energy for energy sensors
                if ("energy".equals(sensor.getMeasurementType())) {
                    cumulativeEnergy = value;
                }

                Measurement measurement = new Measurement();
                measurement.setId(new MeasurementId(sensor.getId(), measurementTime, (short) 0));
                measurement.setMeasurementValue(value);
                measurement.setSourceType("automatic");
                measurement.setQualityFlag((short) 0);
                measurement.setCreatedBy("system");

                batch.add(measurement);
                totalMeasurements++;

                // Batch save every 1000 records
                if (batch.size() >= 1000) {
                    measurementRepository.saveAll(batch);
                    batch.clear();
                }
            }
        }

        // Save remaining batch
        if (!batch.isEmpty()) {
            measurementRepository.saveAll(batch);
        }

        log.info("Generated {} measurement records for {} active sensors",
                totalMeasurements, sensors.stream().filter(Sensor::getIsActive).count());
    }

    private BigDecimal generateRealisticValue(String measurementType, int hourOfDay,
                                               int dayOfMonth, BigDecimal cumulativeEnergy) {
        double value;

        switch (measurementType) {
            case "power":
                // PV power follows sun pattern: 0 at night, peak around noon
                value = generateSolarCurveValue(hourOfDay, 5.0); // Max 5 kW
                break;

            case "voltage":
                // DC voltage: higher during production, lower at night
                if (hourOfDay >= 6 && hourOfDay <= 20) {
                    value = 350 + random.nextDouble() * 50 + generateSolarCurveValue(hourOfDay, 30);
                } else {
                    value = 0; // No voltage at night
                }
                break;

            case "temperature":
                // Module temperature: follows day cycle, warmer midday
                double baseTemp = 15 + (dayOfMonth % 10); // Variation by day
                double dailyVariation = Math.sin((hourOfDay - 6) * Math.PI / 12) * 15;
                value = baseTemp + (hourOfDay >= 6 && hourOfDay <= 20 ? dailyVariation : -5);
                value += random.nextDouble() * 3 - 1.5; // Small random variation
                break;

            case "irradiance":
                // Solar irradiance: 0 at night, up to 1000 W/m² at noon
                value = generateSolarCurveValue(hourOfDay, 1000);
                break;

            case "energy":
                // Cumulative energy: increases during daytime
                double hourlyEnergy = generateSolarCurveValue(hourOfDay, 4.5); // kWh per hour
                value = cumulativeEnergy.doubleValue() + hourlyEnergy;
                break;

            default:
                value = random.nextDouble() * 100;
        }

        return BigDecimal.valueOf(value).setScale(3, RoundingMode.HALF_UP);
    }

    /**
     * Generates a value following a typical solar production curve.
     * Returns 0 at night, peaks around solar noon (12-13h).
     */
    private double generateSolarCurveValue(int hourOfDay, double maxValue) {
        if (hourOfDay < 6 || hourOfDay > 20) {
            return 0; // Night time
        }

        // Gaussian-like curve centered around 12:30
        double hoursFromNoon = hourOfDay - 12.5;
        double normalizedPosition = hoursFromNoon / 7.0; // 7 hours from noon to sunset
        double curveValue = Math.exp(-normalizedPosition * normalizedPosition * 2);

        // Add some randomness for cloud cover simulation
        double cloudFactor = 0.85 + random.nextDouble() * 0.15;

        return curveValue * maxValue * cloudFactor;
    }
}
