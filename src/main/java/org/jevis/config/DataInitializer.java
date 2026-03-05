package org.jevis.config;

import org.jevis.model.*;
import org.jevis.repository.CsrActionRepository;
import org.jevis.repository.JobRepository;
import org.jevis.repository.MeasurementRepository;
import org.jevis.repository.NodeRedDataPointRepository;
import org.jevis.repository.NodeRedDeviceRepository;
import org.jevis.repository.SensorRepository;
import org.jevis.repository.WorkerPoolRepository;
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
    private final CsrActionRepository csrActionRepository;
    private final WorkerPoolRepository workerPoolRepository;
    private final JobRepository jobRepository;
    private final NodeRedDeviceRepository nodeRedDeviceRepository;
    private final NodeRedDataPointRepository nodeRedDataPointRepository;
    private final Random random = new Random(42); // Fixed seed for reproducible data

    public DataInitializer(SensorRepository sensorRepository, MeasurementRepository measurementRepository,
                            CsrActionRepository csrActionRepository, WorkerPoolRepository workerPoolRepository,
                            JobRepository jobRepository, NodeRedDeviceRepository nodeRedDeviceRepository,
                            NodeRedDataPointRepository nodeRedDataPointRepository) {
        this.sensorRepository = sensorRepository;
        this.measurementRepository = measurementRepository;
        this.csrActionRepository = csrActionRepository;
        this.workerPoolRepository = workerPoolRepository;
        this.jobRepository = jobRepository;
        this.nodeRedDeviceRepository = nodeRedDeviceRepository;
        this.nodeRedDataPointRepository = nodeRedDataPointRepository;
    }

    @Override
    @Transactional
    public void run(String... args) {
        if (sensorRepository.count() == 0) {
            log.info("Initializing database with sample data...");

            List<Sensor> sensors = initializeSensors();
            log.info("Created {} sensors", sensors.size());

            initializeMeasurements(sensors);

            initializeCsrActions();
            initializeJobSystem();
            initializeNodeRedDevices(sensors);

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

    private void initializeCsrActions() {
        if (csrActionRepository.count() > 0) {
            return;
        }

        List<CsrAction> actions = new ArrayList<>();

        // Environmental actions
        actions.add(createCsrAction(
            "CO2-Emissionen um 30% reduzieren",
            "Reduktion der betrieblichen CO2-Emissionen durch Optimierung der Energieeffizienz und verstärkten Einsatz erneuerbarer Energien.",
            CsrCategory.ENVIRONMENTAL,
            CsrStatus.IN_PROGRESS,
            "Maria Schmidt",
            LocalDate.now().plusMonths(6),
            45,
            "HIGH",
            "Erwartete Einsparung von 1.500 Tonnen CO2 pro Jahr",
            "admin"
        ));

        actions.add(createCsrAction(
            "Wasserverbrauch optimieren",
            "Implementierung eines Wassermanagement-Systems zur Reduzierung des Wasserverbrauchs um 20%.",
            CsrCategory.ENVIRONMENTAL,
            CsrStatus.PLANNED,
            "Thomas Weber",
            LocalDate.now().plusMonths(9),
            0,
            "MEDIUM",
            "Einsparung von 50.000 Litern Wasser pro Monat",
            "admin"
        ));

        actions.add(createCsrAction(
            "Recycling-Quote auf 90% erhöhen",
            "Einführung eines umfassenden Abfalltrennungssystems und Schulung der Mitarbeiter.",
            CsrCategory.ENVIRONMENTAL,
            CsrStatus.COMPLETED,
            "Lisa Müller",
            LocalDate.now().minusMonths(1),
            100,
            "MEDIUM",
            "Reduktion der Restmüllmenge um 60%",
            "admin"
        ));

        // Social actions
        actions.add(createCsrAction(
            "Diversity & Inclusion Programm",
            "Entwicklung und Umsetzung eines umfassenden D&I-Programms zur Förderung von Vielfalt und Inklusion.",
            CsrCategory.SOCIAL,
            CsrStatus.IN_PROGRESS,
            "Sandra Braun",
            LocalDate.now().plusMonths(3),
            60,
            "HIGH",
            "Steigerung der Mitarbeiterzufriedenheit um 25%",
            "admin"
        ));

        actions.add(createCsrAction(
            "Ausbildungsprogramm für Jugendliche",
            "Etablierung eines Ausbildungsprogramms für benachteiligte Jugendliche in der Region.",
            CsrCategory.SOCIAL,
            CsrStatus.PLANNED,
            "Michael Hoffmann",
            LocalDate.now().plusMonths(4),
            10,
            "HIGH",
            "Ausbildung von 15 Jugendlichen pro Jahr",
            "admin"
        ));

        actions.add(createCsrAction(
            "Gesundheitsförderung am Arbeitsplatz",
            "Einführung von Gesundheitsprogrammen wie Fitnesskurse und ergonomische Arbeitsplatzgestaltung.",
            CsrCategory.SOCIAL,
            CsrStatus.ON_HOLD,
            "Anna Fischer",
            LocalDate.now().plusMonths(2),
            30,
            "MEDIUM",
            "Reduktion der Krankheitstage um 15%",
            "admin"
        ));

        // Governance actions
        actions.add(createCsrAction(
            "Transparente Lieferkettenüberwachung",
            "Implementierung eines Systems zur Überwachung und Dokumentation der Lieferkette hinsichtlich Nachhaltigkeit.",
            CsrCategory.GOVERNANCE,
            CsrStatus.IN_PROGRESS,
            "Peter Schäfer",
            LocalDate.now().plusMonths(8),
            35,
            "HIGH",
            "100% Transparenz über Tier-1 und Tier-2 Lieferanten",
            "admin"
        ));

        actions.add(createCsrAction(
            "Ethik-Richtlinien aktualisieren",
            "Überarbeitung und Erweiterung der unternehmensweiten Ethik-Richtlinien.",
            CsrCategory.GOVERNANCE,
            CsrStatus.COMPLETED,
            "Dr. Julia Becker",
            LocalDate.now().minusWeeks(2),
            100,
            "MEDIUM",
            "Klare Richtlinien für alle Mitarbeiter",
            "admin"
        ));

        // Economic actions
        actions.add(createCsrAction(
            "Regionale Lieferanten fördern",
            "Steigerung des Anteils regionaler Lieferanten auf 50% zur Stärkung der lokalen Wirtschaft.",
            CsrCategory.ECONOMIC,
            CsrStatus.IN_PROGRESS,
            "Klaus Richter",
            LocalDate.now().plusMonths(12),
            25,
            "MEDIUM",
            "Stärkung der regionalen Wirtschaft und Reduktion von Transportwegen",
            "admin"
        ));

        actions.add(createCsrAction(
            "Nachhaltige Investitionsstrategie",
            "Entwicklung einer Investitionsstrategie unter Berücksichtigung von ESG-Kriterien.",
            CsrCategory.ECONOMIC,
            CsrStatus.PLANNED,
            "Sabine Klein",
            LocalDate.now().plusMonths(5),
            5,
            "HIGH",
            "Langfristige Wertsteigerung durch nachhaltige Investments",
            "admin"
        ));

        // Overdue action for testing
        actions.add(createCsrAction(
            "Energieaudit durchführen",
            "Durchführung eines umfassenden Energieaudits aller Standorte.",
            CsrCategory.ENVIRONMENTAL,
            CsrStatus.IN_PROGRESS,
            "Markus Wolf",
            LocalDate.now().minusWeeks(1),
            70,
            "HIGH",
            "Identifikation von Einsparpotentialen",
            "admin"
        ));

        csrActionRepository.saveAll(actions);
        log.info("Created {} CSR actions", actions.size());
    }

    private void initializeJobSystem() {
        if (workerPoolRepository.count() > 0) {
            return;
        }

        // Create Worker Pools
        WorkerPool defaultPool = new WorkerPool("default-pool", "Standard-Pool für allgemeine Jobs", true);
        defaultPool.setMaxConcurrentJobs(10);
        defaultPool = workerPoolRepository.save(defaultPool);

        WorkerPool fetchPool = new WorkerPool("data-fetch-pool", "Pool für Daten-Import Jobs", false);
        fetchPool.setMaxConcurrentJobs(5);
        fetchPool = workerPoolRepository.save(fetchPool);

        WorkerPool calcPool = new WorkerPool("calculation-pool", "Pool für Berechnungs-Jobs", false);
        calcPool.setMaxConcurrentJobs(3);
        calcPool = workerPoolRepository.save(calcPool);

        log.info("Created {} worker pools", workerPoolRepository.count());

        // Create sample Jobs
        List<Job> jobs = new ArrayList<>();

        Job job1 = new Job();
        job1.setJobName("Messdaten-Import Station Ost");
        job1.setJobType(JobType.DATA_FETCH);
        job1.setPriority(JobPriority.HIGH);
        job1.setStatus(JobStatus.COMPLETED);
        job1.setWorkerPool(fetchPool);
        job1.setJobParameters("{\"stationId\": \"EAST-01\", \"url\": \"https://api.example.com/data\"}");
        job1.setCreatedBy("admin");
        job1.setOnSuccessJobType(JobType.CALCULATION);
        job1.setOnSuccessJobParams("{\"calculationType\": \"daily-yield\"}");
        jobs.add(job1);

        Job job2 = new Job();
        job2.setJobName("Tägliche Ertragsberechnung");
        job2.setJobType(JobType.CALCULATION);
        job2.setPriority(JobPriority.NORMAL);
        job2.setStatus(JobStatus.QUEUED);
        job2.setWorkerPool(calcPool);
        job2.setJobParameters("{\"calculationType\": \"daily-yield\", \"period\": \"2024-01\"}");
        job2.setCreatedBy("admin");
        job2.setScheduledFor(Instant.now());
        jobs.add(job2);

        Job job3 = new Job();
        job3.setJobName("Monatsbericht generieren");
        job3.setJobType(JobType.REPORT_GENERATION);
        job3.setPriority(JobPriority.LOW);
        job3.setStatus(JobStatus.CREATED);
        job3.setWorkerPool(defaultPool);
        job3.setJobParameters("{\"reportType\": \"monthly\", \"month\": \"2024-01\"}");
        job3.setCreatedBy("admin");
        jobs.add(job3);

        Job job4 = new Job();
        job4.setJobName("Datenbereinigung ältere Messwerte");
        job4.setJobType(JobType.DATA_CLEANUP);
        job4.setPriority(JobPriority.LOW);
        job4.setStatus(JobStatus.FAILED);
        job4.setRetryCount(2);
        job4.setWorkerPool(defaultPool);
        job4.setCreatedBy("admin");
        jobs.add(job4);

        Job job5 = new Job();
        job5.setJobName("Stündlicher Daten-Import (Cron)");
        job5.setJobType(JobType.DATA_FETCH);
        job5.setPriority(JobPriority.NORMAL);
        job5.setStatus(JobStatus.CREATED);
        job5.setIsRecurring(true);
        job5.setCronExpression("0 0 * * * ?");
        job5.setWorkerPool(fetchPool);
        job5.setCreatedBy("system");
        jobs.add(job5);

        jobRepository.saveAll(jobs);
        log.info("Created {} sample jobs", jobs.size());
    }

    private void initializeNodeRedDevices(List<Sensor> sensors) {
        if (nodeRedDeviceRepository.count() > 0) {
            return;
        }

        // Create demo Node-Red device
        NodeRedDevice device = new NodeRedDevice();
        device.setDeviceName("Schuby Hauptzähler");
        device.setApiUrl("http://schubyhh.selfhost.bz:3000/api/data");
        device.setUsername("");
        device.setPassword("");
        device.setDefaultLimit(1000);
        device.setIsActive(true);
        device = nodeRedDeviceRepository.save(device);

        // Create data point mappings for existing sensors
        if (sensors.size() >= 2) {
            NodeRedDataPoint dp1 = new NodeRedDataPoint();
            dp1.setDevice(device);
            dp1.setSensor(sensors.get(0)); // PV_INV_001
            dp1.setRemoteId("fbf2f46773a02bbf");
            dp1.setRemoteName("Hauptzähler2Energy");
            dp1.setIsActive(true);
            nodeRedDataPointRepository.save(dp1);

            NodeRedDataPoint dp2 = new NodeRedDataPoint();
            dp2.setDevice(device);
            dp2.setSensor(sensors.get(5)); // PV_ENE_001 energy sensor
            dp2.setRemoteId("a1b2c3d4e5f6g7h8");
            dp2.setRemoteName("Energiezähler Gesamt");
            dp2.setIsActive(true);
            nodeRedDataPointRepository.save(dp2);
        }

        log.info("Created {} Node-Red devices with data points", nodeRedDeviceRepository.count());
    }

    private CsrAction createCsrAction(String title, String description, CsrCategory category,
                                       CsrStatus status, String responsible, LocalDate deadline,
                                       int progress, String priority, String impact, String createdBy) {
        CsrAction action = new CsrAction();
        action.setTitle(title);
        action.setDescription(description);
        action.setCategory(category);
        action.setStatus(status);
        action.setResponsiblePerson(responsible);
        action.setDeadline(deadline);
        action.setProgressPercent(progress);
        action.setPriority(priority);
        action.setEstimatedImpact(impact);
        action.setCreatedBy(createdBy);
        return action;
    }
}
