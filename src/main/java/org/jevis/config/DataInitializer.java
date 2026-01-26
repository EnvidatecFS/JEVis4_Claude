package org.jevis.config;

import org.jevis.model.Sensor;
import org.jevis.repository.SensorRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

/**
 * Initializes the database with sample data on application startup.
 */
@Component
public class DataInitializer implements CommandLineRunner {

    private final SensorRepository sensorRepository;

    public DataInitializer(SensorRepository sensorRepository) {
        this.sensorRepository = sensorRepository;
    }

    @Override
    public void run(String... args) {
        // Only initialize if database is empty
        if (sensorRepository.count() == 0) {
            System.out.println("Initializing database with sample sensors...");

            // Sample PV system sensors
            Sensor inverter1 = new Sensor();
            inverter1.setSensorCode("PV_INV_001");
            inverter1.setSensorName("Wechselrichter Dach Ost");
            inverter1.setMeasurementType("power");
            inverter1.setUnit("kW");
            inverter1.setLocation("Gebäude A, Dach");
            inverter1.setDescription("Hauptwechselrichter für die Ostseite der PV-Anlage");
            inverter1.setManufacturer("SMA");
            inverter1.setModel("Sunny Boy 5.0");
            inverter1.setIsActive(true);
            inverter1.setCalibrationDate(LocalDate.now().plusMonths(6));
            sensorRepository.save(inverter1);

            Sensor inverter2 = new Sensor();
            inverter2.setSensorCode("PV_INV_002");
            inverter2.setSensorName("Wechselrichter Dach West");
            inverter2.setMeasurementType("power");
            inverter2.setUnit("kW");
            inverter2.setLocation("Gebäude A, Dach");
            inverter2.setDescription("Hauptwechselrichter für die Westseite der PV-Anlage");
            inverter2.setManufacturer("Fronius");
            inverter2.setModel("Primo 6.0");
            inverter2.setIsActive(true);
            inverter2.setCalibrationDate(LocalDate.now().plusMonths(8));
            sensorRepository.save(inverter2);

            Sensor voltage = new Sensor();
            voltage.setSensorCode("PV_VOLT_001");
            voltage.setSensorName("Spannungssensor Eingang");
            voltage.setMeasurementType("voltage");
            voltage.setUnit("V");
            voltage.setLocation("Gebäude A, Technikraum");
            voltage.setDescription("Misst die Eingangsspannung der PV-Anlage");
            voltage.setManufacturer("ABB");
            voltage.setModel("VSN300");
            voltage.setIsActive(true);
            voltage.setCalibrationDate(LocalDate.now().plusMonths(12));
            sensorRepository.save(voltage);

            Sensor temperature = new Sensor();
            temperature.setSensorCode("PV_TEMP_001");
            temperature.setSensorName("Temperatursensor Module");
            temperature.setMeasurementType("temperature");
            temperature.setUnit("°C");
            temperature.setLocation("Gebäude A, Dach");
            temperature.setDescription("Misst die Modultemperatur");
            temperature.setManufacturer("Siemens");
            temperature.setModel("QAM2120");
            temperature.setIsActive(true);
            temperature.setCalibrationDate(LocalDate.now().plusYears(1));
            sensorRepository.save(temperature);

            Sensor irradiance = new Sensor();
            irradiance.setSensorCode("PV_IRR_001");
            irradiance.setSensorName("Einstrahlungssensor");
            irradiance.setMeasurementType("irradiance");
            irradiance.setUnit("W/m²");
            irradiance.setLocation("Gebäude A, Dach");
            irradiance.setDescription("Misst die Sonneneinstrahlung");
            irradiance.setManufacturer("Kipp & Zonen");
            irradiance.setModel("CMP11");
            irradiance.setIsActive(true);
            irradiance.setCalibrationDate(LocalDate.now().plusMonths(3));
            sensorRepository.save(irradiance);

            Sensor energy = new Sensor();
            energy.setSensorCode("PV_ENE_001");
            energy.setSensorName("Energiezähler Gesamt");
            energy.setMeasurementType("energy");
            energy.setUnit("kWh");
            energy.setLocation("Gebäude A, Zählerschrank");
            energy.setDescription("Gesamtenergiezähler der PV-Anlage");
            energy.setManufacturer("ABB");
            energy.setModel("B23 112-100");
            energy.setIsActive(true);
            energy.setCalibrationDate(LocalDate.now().plusYears(2));
            sensorRepository.save(energy);

            // Add one inactive sensor
            Sensor oldSensor = new Sensor();
            oldSensor.setSensorCode("PV_INV_OLD_001");
            oldSensor.setSensorName("Alter Wechselrichter (ersetzt)");
            oldSensor.setMeasurementType("power");
            oldSensor.setUnit("kW");
            oldSensor.setLocation("Gebäude A, Dach");
            oldSensor.setDescription("Wurde durch PV_INV_001 ersetzt");
            oldSensor.setManufacturer("SMA");
            oldSensor.setModel("Sunny Boy 3.0");
            oldSensor.setIsActive(false);
            oldSensor.setCalibrationDate(LocalDate.now().minusYears(1));
            sensorRepository.save(oldSensor);

            System.out.println("✓ Successfully initialized " + sensorRepository.count() + " sample sensors");
        } else {
            System.out.println("Database already contains " + sensorRepository.count() + " sensors");
        }
    }
}
