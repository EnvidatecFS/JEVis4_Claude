package org.jevis.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.jevis.model.Sensor;
import org.jevis.service.MeasurementService;
import org.jevis.service.SensorService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Controller
public class DashboardController {

    private final SensorService sensorService;
    private final MeasurementService measurementService;

    public DashboardController(SensorService sensorService, MeasurementService measurementService) {
        this.sensorService = sensorService;
        this.measurementService = measurementService;
    }

    @GetMapping("/")
    public String index() {
        return "redirect:/home";
    }

    @GetMapping("/home")
    public String home(@AuthenticationPrincipal UserDetails userDetails, HttpServletRequest request, Model model) {
        model.addAttribute("username", userDetails.getUsername());
        CsrfToken csrfToken = (CsrfToken) request.getAttribute(CsrfToken.class.getName());
        model.addAttribute("_csrf", csrfToken);
        return "pages/home";
    }

    @GetMapping("/dashboard")
    public String dashboard(@AuthenticationPrincipal UserDetails userDetails, HttpServletRequest request, Model model) {
        model.addAttribute("username", userDetails.getUsername());
        CsrfToken csrfToken = (CsrfToken) request.getAttribute(CsrfToken.class.getName());
        model.addAttribute("_csrf", csrfToken);

        // Get sensors for widget configuration
        List<Sensor> sensors = sensorService.getActiveSensors();
        model.addAttribute("sensors", sensors);

        Map<String, List<Sensor>> sensorsByType = sensors.stream()
                .collect(Collectors.groupingBy(Sensor::getMeasurementType));
        model.addAttribute("sensorsByType", sensorsByType);

        return "pages/dashboard";
    }

    // === Widget Data API Endpoints ===

    /**
     * Get data for line/area chart widgets
     */
    @GetMapping("/dashboard/api/widget/line")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getLineChartData(
            @RequestParam(required = false) List<Long> sensorIds,
            @RequestParam(defaultValue = "24") int hours) {

        Instant end = Instant.now();
        Instant start = end.minus(hours, ChronoUnit.HOURS);

        Map<String, Object> response = new HashMap<>();
        List<Map<String, Object>> series = new ArrayList<>();

        if (sensorIds != null && !sensorIds.isEmpty()) {
            for (Long sensorId : sensorIds) {
                try {
                    Sensor sensor = sensorService.getSensorById(sensorId);
                    var measurements = measurementService.getCurrentMeasurements(sensorId, start, end);

                    List<List<Object>> data = measurements.stream()
                            .sorted(Comparator.comparing(m -> m.getId().getMeasuredAt()))
                            .map(m -> {
                                List<Object> point = new ArrayList<>();
                                point.add(m.getId().getMeasuredAt().toEpochMilli());
                                point.add(m.getMeasurementValue());
                                return point;
                            })
                            .collect(Collectors.toList());

                    Map<String, Object> seriesData = new HashMap<>();
                    seriesData.put("name", sensor.getSensorName());
                    seriesData.put("data", data);
                    seriesData.put("unit", sensor.getUnit());
                    series.add(seriesData);
                } catch (Exception e) {
                    // Skip invalid sensors
                }
            }
        } else {
            // Demo data
            series.add(generateDemoLineData("Produktion", hours));
        }

        response.put("series", series);
        return ResponseEntity.ok(response);
    }

    /**
     * Get data for bar chart widgets
     */
    @GetMapping("/dashboard/api/widget/bar")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getBarChartData(
            @RequestParam(required = false) List<Long> sensorIds) {

        Map<String, Object> response = new HashMap<>();

        if (sensorIds != null && !sensorIds.isEmpty()) {
            List<String> categories = new ArrayList<>();
            List<BigDecimal> values = new ArrayList<>();

            Instant end = Instant.now();
            Instant start = end.minus(24, ChronoUnit.HOURS);

            for (Long sensorId : sensorIds) {
                try {
                    Sensor sensor = sensorService.getSensorById(sensorId);
                    BigDecimal avg = measurementService.calculateAverage(sensorId, start, end);
                    categories.add(sensor.getSensorName());
                    values.add(avg != null ? avg : BigDecimal.ZERO);
                } catch (Exception e) {
                    // Skip
                }
            }

            response.put("categories", categories);
            response.put("values", values);
        } else {
            // Demo data
            response.put("categories", Arrays.asList("Jan", "Feb", "Mrz", "Apr", "Mai", "Jun"));
            response.put("values", Arrays.asList(820, 932, 901, 934, 1290, 1330));
        }

        return ResponseEntity.ok(response);
    }

    /**
     * Get data for pie chart widgets
     */
    @GetMapping("/dashboard/api/widget/pie")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getPieChartData() {
        Map<String, Object> response = new HashMap<>();

        List<Map<String, Object>> data = new ArrayList<>();

        // Get sensor distribution by type
        List<Sensor> sensors = sensorService.getActiveSensors();
        Map<String, Long> countByType = sensors.stream()
                .collect(Collectors.groupingBy(Sensor::getMeasurementType, Collectors.counting()));

        if (!countByType.isEmpty()) {
            countByType.forEach((type, count) -> {
                Map<String, Object> item = new HashMap<>();
                item.put("name", translateType(type));
                item.put("value", count);
                data.add(item);
            });
        } else {
            // Demo data
            data.add(createPieItem("Leistung", 40));
            data.add(createPieItem("Energie", 25));
            data.add(createPieItem("Temperatur", 20));
            data.add(createPieItem("Einstrahlung", 15));
        }

        response.put("data", data);
        return ResponseEntity.ok(response);
    }

    /**
     * Get data for gauge widgets
     */
    @GetMapping("/dashboard/api/widget/gauge")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getGaugeData(
            @RequestParam(required = false) Long sensorId) {

        Map<String, Object> response = new HashMap<>();

        if (sensorId != null) {
            try {
                Sensor sensor = sensorService.getSensorById(sensorId);
                var latest = measurementService.getLatestMeasurement(sensorId);

                response.put("value", latest.getMeasurementValue());
                response.put("name", sensor.getSensorName());
                response.put("unit", sensor.getUnit());
                response.put("min", 0);
                response.put("max", getMaxForType(sensor.getMeasurementType()));
            } catch (Exception e) {
                response.put("value", 0);
                response.put("name", "Keine Daten");
                response.put("unit", "");
                response.put("min", 0);
                response.put("max", 100);
            }
        } else {
            // Demo data
            response.put("value", 72.5);
            response.put("name", "Wirkungsgrad");
            response.put("unit", "%");
            response.put("min", 0);
            response.put("max", 100);
        }

        return ResponseEntity.ok(response);
    }

    /**
     * Get data for radial bar widgets
     */
    @GetMapping("/dashboard/api/widget/radial")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getRadialData() {
        Map<String, Object> response = new HashMap<>();

        List<Map<String, Object>> data = new ArrayList<>();

        List<Sensor> sensors = sensorService.getActiveSensors();
        Instant end = Instant.now();
        Instant start = end.minus(24, ChronoUnit.HOURS);

        int count = 0;
        for (Sensor sensor : sensors) {
            if (count >= 5) break;
            if ("power".equals(sensor.getMeasurementType())) {
                try {
                    BigDecimal avg = measurementService.calculateAverage(sensor.getId(), start, end);
                    Map<String, Object> item = new HashMap<>();
                    item.put("name", sensor.getSensorName());
                    item.put("value", avg != null ? avg.doubleValue() : 0);
                    data.add(item);
                    count++;
                } catch (Exception e) {
                    // Skip
                }
            }
        }

        if (data.isEmpty()) {
            // Demo data
            data.add(createRadialItem("Anlage A", 80));
            data.add(createRadialItem("Anlage B", 65));
            data.add(createRadialItem("Anlage C", 90));
            data.add(createRadialItem("Anlage D", 45));
        }

        response.put("data", data);
        response.put("max", 100);
        return ResponseEntity.ok(response);
    }

    /**
     * Get locations for map widget
     */
    @GetMapping("/dashboard/api/widget/map")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getMapData() {
        Map<String, Object> response = new HashMap<>();

        List<Map<String, Object>> locations = new ArrayList<>();

        // Demo PV installation locations
        locations.add(createLocation("PV Anlage Hauptgebaeude", 51.1657, 10.4515, "5.2 kWp", "online"));
        locations.add(createLocation("PV Anlage Lager", 51.1680, 10.4480, "3.8 kWp", "online"));
        locations.add(createLocation("PV Anlage Carport", 51.1640, 10.4550, "2.1 kWp", "warning"));

        response.put("locations", locations);
        response.put("center", Arrays.asList(51.1657, 10.4515));
        response.put("zoom", 14);

        return ResponseEntity.ok(response);
    }

    // === Helper Methods ===

    private Map<String, Object> generateDemoLineData(String name, int hours) {
        Map<String, Object> series = new HashMap<>();
        series.put("name", name);

        List<List<Object>> data = new ArrayList<>();
        Instant now = Instant.now();
        Random random = new Random(42);

        for (int i = hours; i >= 0; i--) {
            Instant time = now.minus(i, ChronoUnit.HOURS);
            int hour = time.atZone(java.time.ZoneId.systemDefault()).getHour();

            // Simulate solar curve
            double value = 0;
            if (hour >= 6 && hour <= 20) {
                double hoursFromNoon = hour - 12.5;
                value = Math.exp(-hoursFromNoon * hoursFromNoon / 25) * 4.5;
                value += (random.nextDouble() - 0.5) * 0.5;
                value = Math.max(0, value);
            }

            List<Object> point = new ArrayList<>();
            point.add(time.toEpochMilli());
            point.add(Math.round(value * 100.0) / 100.0);
            data.add(point);
        }

        series.put("data", data);
        series.put("unit", "kW");
        return series;
    }

    private Map<String, Object> createPieItem(String name, int value) {
        Map<String, Object> item = new HashMap<>();
        item.put("name", name);
        item.put("value", value);
        return item;
    }

    private Map<String, Object> createRadialItem(String name, double value) {
        Map<String, Object> item = new HashMap<>();
        item.put("name", name);
        item.put("value", value);
        return item;
    }

    private Map<String, Object> createLocation(String name, double lat, double lng, String power, String status) {
        Map<String, Object> loc = new HashMap<>();
        loc.put("name", name);
        loc.put("lat", lat);
        loc.put("lng", lng);
        loc.put("power", power);
        loc.put("status", status);
        return loc;
    }

    private String translateType(String type) {
        switch (type) {
            case "power": return "Leistung";
            case "energy": return "Energie";
            case "temperature": return "Temperatur";
            case "voltage": return "Spannung";
            case "current": return "Strom";
            case "irradiance": return "Einstrahlung";
            default: return type;
        }
    }

    private int getMaxForType(String type) {
        switch (type) {
            case "power": return 10;
            case "energy": return 1000;
            case "temperature": return 100;
            case "voltage": return 500;
            case "current": return 20;
            case "irradiance": return 1200;
            default: return 100;
        }
    }
}
