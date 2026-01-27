package org.jevis.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.jevis.model.Measurement;
import org.jevis.model.Sensor;
import org.jevis.service.MeasurementService;
import org.jevis.service.SensorService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/monitoring")
public class MonitoringController {

    private final SensorService sensorService;
    private final MeasurementService measurementService;

    public MonitoringController(SensorService sensorService, MeasurementService measurementService) {
        this.sensorService = sensorService;
        this.measurementService = measurementService;
    }

    @GetMapping
    public String monitoringPage(@AuthenticationPrincipal UserDetails userDetails,
                                  HttpServletRequest request, Model model) {
        model.addAttribute("username", userDetails.getUsername());
        CsrfToken csrfToken = (CsrfToken) request.getAttribute(CsrfToken.class.getName());
        model.addAttribute("_csrf", csrfToken);

        // Get all active sensors for selection
        List<Sensor> sensors = sensorService.getActiveSensors();
        model.addAttribute("sensors", sensors);

        // Group sensors by measurement type
        Map<String, List<Sensor>> sensorsByType = sensors.stream()
                .collect(Collectors.groupingBy(Sensor::getMeasurementType));
        model.addAttribute("sensorsByType", sensorsByType);

        return "pages/monitoring";
    }

    /**
     * REST API endpoint to fetch measurement data for charts.
     * Returns data in a format optimized for Apache ECharts.
     */
    @GetMapping("/api/measurements")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getMeasurements(
            @RequestParam List<Long> sensorIds,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {

        ZoneId zoneId = ZoneId.systemDefault();
        Instant startInstant = start.atZone(zoneId).toInstant();
        Instant endInstant = end.atZone(zoneId).toInstant();

        Map<String, Object> response = new HashMap<>();
        List<Map<String, Object>> series = new ArrayList<>();

        for (Long sensorId : sensorIds) {
            try {
                Sensor sensor = sensorService.getSensorById(sensorId);
                List<Measurement> measurements = measurementService.getCurrentMeasurements(
                        sensorId, startInstant, endInstant);

                // Convert to ECharts format: [[timestamp, value], ...]
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
                seriesData.put("sensorId", sensorId);
                seriesData.put("sensorName", sensor.getSensorName());
                seriesData.put("sensorCode", sensor.getSensorCode());
                seriesData.put("unit", sensor.getUnit());
                seriesData.put("measurementType", sensor.getMeasurementType());
                seriesData.put("data", data);
                seriesData.put("count", data.size());

                series.add(seriesData);
            } catch (Exception e) {
                // Skip sensors that cannot be loaded
            }
        }

        response.put("series", series);
        response.put("start", startInstant.toEpochMilli());
        response.put("end", endInstant.toEpochMilli());

        return ResponseEntity.ok(response);
    }

    /**
     * Get quick time range presets.
     */
    @GetMapping("/api/timeranges")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getTimeRanges() {
        List<Map<String, Object>> ranges = new ArrayList<>();

        Instant now = Instant.now();

        ranges.add(createTimeRange("1h", "Letzte Stunde", now.minus(1, ChronoUnit.HOURS), now));
        ranges.add(createTimeRange("6h", "Letzte 6 Stunden", now.minus(6, ChronoUnit.HOURS), now));
        ranges.add(createTimeRange("24h", "Letzte 24 Stunden", now.minus(24, ChronoUnit.HOURS), now));
        ranges.add(createTimeRange("7d", "Letzte 7 Tage", now.minus(7, ChronoUnit.DAYS), now));
        ranges.add(createTimeRange("30d", "Letzte 30 Tage", now.minus(30, ChronoUnit.DAYS), now));

        return ResponseEntity.ok(ranges);
    }

    private Map<String, Object> createTimeRange(String id, String label, Instant start, Instant end) {
        Map<String, Object> range = new HashMap<>();
        range.put("id", id);
        range.put("label", label);
        range.put("start", start.toEpochMilli());
        range.put("end", end.toEpochMilli());
        return range;
    }
}
