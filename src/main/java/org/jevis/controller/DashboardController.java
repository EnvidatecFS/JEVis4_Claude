package org.jevis.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.jevis.model.DashboardView;
import org.jevis.model.Sensor;
import org.jevis.service.DashboardViewService;
import org.jevis.service.MeasurementService;
import org.jevis.service.SensorService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.csrf.CsrfToken;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Controller
@Tag(name = "Dashboard", description = "Dashboard-Widgets und Ansichtenverwaltung")
public class DashboardController {

    private final SensorService sensorService;
    private final MeasurementService measurementService;
    private final DashboardViewService dashboardViewService;

    public DashboardController(SensorService sensorService, MeasurementService measurementService,
                               DashboardViewService dashboardViewService) {
        this.sensorService = sensorService;
        this.measurementService = measurementService;
        this.dashboardViewService = dashboardViewService;
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

    @Operation(summary = "Liniendiagramm-Daten", description = "Liefert Zeitreihendaten fuer Linien-/Flaechendiagramme")
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

    @Operation(summary = "Balkendiagramm-Daten", description = "Liefert Durchschnittswerte fuer Balkendiagramme")
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

    @Operation(summary = "Kreisdiagramm-Daten", description = "Sensorverteilung nach Messtyp")
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

    @Operation(summary = "Tachometer-Daten", description = "Aktueller Sensorwert fuer Tachometer-Widgets")
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

    @Operation(summary = "Radialdiagramm-Daten", description = "Durchschnittswerte der Leistungssensoren")
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

    @Operation(summary = "Treemap-Daten", description = "Summierte Sensorwerte fuer Treemap-Darstellung")
    @GetMapping("/dashboard/api/widget/treemap")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getTreemapData(
            @RequestParam(required = false) List<Long> sensorIds,
            @RequestParam(defaultValue = "24") int hours) {

        Map<String, Object> response = new HashMap<>();
        List<Map<String, Object>> data = new ArrayList<>();

        Instant end = Instant.now();
        Instant start = end.minus(hours, ChronoUnit.HOURS);

        if (sensorIds != null && !sensorIds.isEmpty()) {
            for (Long sensorId : sensorIds) {
                try {
                    Sensor sensor = sensorService.getSensorById(sensorId);
                    BigDecimal sum = measurementService.calculateSum(sensorId, start, end);

                    Map<String, Object> item = new HashMap<>();
                    item.put("name", sensor.getSensorName());
                    item.put("value", sum != null ? sum : BigDecimal.ZERO);
                    item.put("sensorId", sensorId);
                    item.put("unit", sensor.getUnit());
                    data.add(item);
                } catch (Exception e) {
                    // Skip invalid sensors
                }
            }
        } else {
            // Demo data - simulate energy production by different systems
            data.add(createTreemapItem("Hauptanlage Dach", 4250, "kWh"));
            data.add(createTreemapItem("Carport Ost", 1820, "kWh"));
            data.add(createTreemapItem("Carport West", 1650, "kWh"));
            data.add(createTreemapItem("Fassade Sued", 980, "kWh"));
            data.add(createTreemapItem("Lagergebaeude", 2340, "kWh"));
            data.add(createTreemapItem("Verwaltung", 1560, "kWh"));
        }

        response.put("data", data);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Karten-Daten", description = "PV-Anlagenstandorte fuer Kartenwidget")
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

    // === Dashboard View API Endpoints ===

    @Operation(summary = "Alle Ansichten laden", description = "Liefert alle Dashboard-Ansichten des angemeldeten Benutzers")
    @GetMapping("/dashboard/api/views")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getViews(@AuthenticationPrincipal UserDetails userDetails) {
        List<DashboardView> views = dashboardViewService.getViewsForUser(userDetails.getUsername());
        List<Map<String, Object>> result = new ArrayList<>();
        for (DashboardView v : views) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", v.getId());
            map.put("name", v.getName());
            map.put("isDefault", v.getIsDefault());
            result.add(map);
        }
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "Ansicht laden", description = "Liefert eine bestimmte Dashboard-Ansicht mit Layout")
    @GetMapping("/dashboard/api/views/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getView(@PathVariable Long id,
                                                        @AuthenticationPrincipal UserDetails userDetails) {
        DashboardView view = dashboardViewService.getView(id, userDetails.getUsername());
        Map<String, Object> result = new HashMap<>();
        result.put("id", view.getId());
        result.put("name", view.getName());
        result.put("layoutJson", view.getLayoutJson());
        result.put("isDefault", view.getIsDefault());
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "Ansicht erstellen", description = "Erstellt eine neue Dashboard-Ansicht")
    @PostMapping("/dashboard/api/views")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createView(@RequestBody Map<String, Object> body,
                                                           @AuthenticationPrincipal UserDetails userDetails) {
        String name = (String) body.get("name");
        String layoutJson = (String) body.get("layoutJson");
        boolean setAsDefault = Boolean.TRUE.equals(body.get("setAsDefault"));

        DashboardView view = dashboardViewService.createView(userDetails.getUsername(), name, layoutJson, setAsDefault);

        Map<String, Object> result = new HashMap<>();
        result.put("id", view.getId());
        result.put("name", view.getName());
        result.put("isDefault", view.getIsDefault());
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "Ansicht aktualisieren", description = "Aktualisiert Name und Layout einer Ansicht")
    @PutMapping("/dashboard/api/views/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateView(@PathVariable Long id,
                                                           @RequestBody Map<String, Object> body,
                                                           @AuthenticationPrincipal UserDetails userDetails) {
        String name = (String) body.get("name");
        String layoutJson = (String) body.get("layoutJson");

        DashboardView view = dashboardViewService.updateView(id, userDetails.getUsername(), name, layoutJson);

        Map<String, Object> result = new HashMap<>();
        result.put("id", view.getId());
        result.put("name", view.getName());
        result.put("isDefault", view.getIsDefault());
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "Layout speichern", description = "Speichert nur das Widget-Layout einer Ansicht")
    @PutMapping("/dashboard/api/views/{id}/layout")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveViewLayout(@PathVariable Long id,
                                                               @RequestBody Map<String, Object> body,
                                                               @AuthenticationPrincipal UserDetails userDetails) {
        String layoutJson = (String) body.get("layoutJson");
        dashboardViewService.saveLayout(id, userDetails.getUsername(), layoutJson);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "Standard-Ansicht setzen", description = "Setzt eine Ansicht als Standard fuer den Benutzer")
    @PutMapping("/dashboard/api/views/{id}/default")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> setViewAsDefault(@PathVariable Long id,
                                                                 @AuthenticationPrincipal UserDetails userDetails) {
        dashboardViewService.setDefault(id, userDetails.getUsername());

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "Ansicht loeschen", description = "Loescht eine Dashboard-Ansicht")
    @DeleteMapping("/dashboard/api/views/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteView(@PathVariable Long id,
                                                           @AuthenticationPrincipal UserDetails userDetails) {
        dashboardViewService.deleteView(id, userDetails.getUsername());

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        return ResponseEntity.ok(result);
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

    private Map<String, Object> createTreemapItem(String name, double value, String unit) {
        Map<String, Object> item = new HashMap<>();
        item.put("name", name);
        item.put("value", value);
        item.put("unit", unit);
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
