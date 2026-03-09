package org.jevis.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.jevis.model.Measurement;
import org.jevis.model.MeasurementId;
import org.jevis.model.Sensor;
import org.jevis.service.FileUploadService;
import org.jevis.service.MeasurementService;
import org.jevis.service.MeterTypeService;
import org.jevis.service.SensorService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.Instant;
import java.util.List;

@Controller
@RequestMapping("/sensors")
public class SensorController {

    private final SensorService sensorService;
    private final MeasurementService measurementService;
    private final MeterTypeService meterTypeService;
    private final FileUploadService fileUploadService;

    public SensorController(SensorService sensorService, MeasurementService measurementService,
                            MeterTypeService meterTypeService, FileUploadService fileUploadService) {
        this.sensorService = sensorService;
        this.measurementService = measurementService;
        this.meterTypeService = meterTypeService;
        this.fileUploadService = fileUploadService;
    }

    @GetMapping
    public String sensorsPage(@AuthenticationPrincipal UserDetails userDetails, HttpServletRequest request, Model model) {
        model.addAttribute("username", userDetails.getUsername());
        CsrfToken csrfToken = (CsrfToken) request.getAttribute(CsrfToken.class.getName());
        model.addAttribute("_csrf", csrfToken);
        return "pages/sensors";
    }

    @GetMapping("/table")
    public String sensorsTable(
            @RequestParam(defaultValue = "") String search,
            @RequestParam(defaultValue = "") String type,
            @RequestParam(defaultValue = "") String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            Model model
    ) {
        Sort sort = sortDir.equalsIgnoreCase("asc")
            ? Sort.by(sortBy).ascending()
            : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<Sensor> sensorsPage;

        if (!search.isEmpty() || !type.isEmpty() || !status.isEmpty()) {
            // Filter sensors
            sensorsPage = sensorService.searchSensors(search, type, status, pageable);
        } else {
            sensorsPage = sensorService.getAllSensors(pageable);
        }

        model.addAttribute("sensors", sensorsPage.getContent());
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", sensorsPage.getTotalPages());
        model.addAttribute("totalElements", sensorsPage.getTotalElements());
        model.addAttribute("search", search);
        model.addAttribute("type", type);
        model.addAttribute("status", status);
        model.addAttribute("sortBy", sortBy);
        model.addAttribute("sortDir", sortDir);

        // Get all measurement types for filter dropdown
        List<String> measurementTypes = sensorService.getAllMeasurementTypes();
        model.addAttribute("measurementTypes", measurementTypes);

        return "pages/sensors-table";
    }

    @GetMapping("/{id}/edit")
    public String editSensorForm(@PathVariable Long id, Model model) {
        Sensor sensor = sensorService.getSensorById(id);
        model.addAttribute("sensor", sensor);
        List<String> measurementTypes = sensorService.getAllMeasurementTypes();
        model.addAttribute("measurementTypes", measurementTypes);
        model.addAttribute("allSensors", sensorService.getAllSensorsExcept(id));
        model.addAttribute("allMeterTypes", meterTypeService.getAllMeterTypes());
        model.addAttribute("defaultMeasurementDate", sensorService.findLatestMeasurementDate(id));
        return "pages/sensor-edit-form";
    }

    @PutMapping("/{id}")
    public String updateSensor(
            @PathVariable Long id,
            @ModelAttribute Sensor sensorData,
            @RequestParam(required = false) Long parentSensorId,
            @RequestParam(required = false) Long meterTypeId,
            @RequestParam(required = false) MultipartFile verificationDocument,
            @RequestParam(required = false) MultipartFile sensorImage,
            Model model
    ) {
        try {
            if (parentSensorId != null) {
                Sensor parentSensor = sensorService.getSensorById(parentSensorId);
                sensorData.setParentSensor(parentSensor);
            }
            if (meterTypeId != null) {
                sensorData.setMeterType(meterTypeService.getMeterTypeById(meterTypeId));
            }
            if (verificationDocument != null && !verificationDocument.isEmpty()) {
                sensorData.setVerificationDocumentPath(
                    fileUploadService.store(verificationDocument, "sensors/verification"));
            }
            if (sensorImage != null && !sensorImage.isEmpty()) {
                sensorData.setSensorImagePath(
                    fileUploadService.store(sensorImage, "sensors/images"));
            }
            Sensor updated = sensorService.updateSensor(id, sensorData);
            model.addAttribute("sensor", updated);
            model.addAttribute("success", true);
            model.addAttribute("message", "Messpunkt erfolgreich aktualisiert");
        } catch (Exception e) {
            Sensor sensor = sensorService.getSensorById(id);
            model.addAttribute("sensor", sensor);
            model.addAttribute("success", false);
            model.addAttribute("message", "Fehler: " + e.getMessage());
        }
        List<String> measurementTypes = sensorService.getAllMeasurementTypes();
        model.addAttribute("measurementTypes", measurementTypes);
        model.addAttribute("allSensors", sensorService.getAllSensorsExcept(id));
        model.addAttribute("allMeterTypes", meterTypeService.getAllMeterTypes());
        model.addAttribute("defaultMeasurementDate", sensorService.findLatestMeasurementDate(id));
        return "pages/sensor-edit-form";
    }

    @GetMapping("/{id}/row")
    public String getSensorRow(@PathVariable Long id, Model model) {
        Sensor sensor = sensorService.getSensorById(id);
        model.addAttribute("sensor", sensor);
        return "pages/sensor-row";
    }

    @PostMapping
    public String createSensor(
            @ModelAttribute Sensor sensorData,
            Model model
    ) {
        try {
            Sensor created = sensorService.createSensor(sensorData);
            model.addAttribute("sensor", created);
            model.addAttribute("success", true);
            model.addAttribute("message", "Messpunkt erfolgreich erstellt");
        } catch (Exception e) {
            model.addAttribute("sensor", sensorData);
            model.addAttribute("success", false);
            model.addAttribute("message", "Fehler: " + e.getMessage());
        }
        List<String> measurementTypes = sensorService.getAllMeasurementTypes();
        model.addAttribute("measurementTypes", measurementTypes);
        return "pages/sensor-create-form";
    }

    @GetMapping("/new")
    public String newSensorForm(Model model) {
        model.addAttribute("sensor", new Sensor());
        List<String> measurementTypes = sensorService.getAllMeasurementTypes();
        model.addAttribute("measurementTypes", measurementTypes);
        return "pages/sensor-create-form";
    }

    @DeleteMapping("/{id}")
    @ResponseBody
    public String deleteSensor(@PathVariable Long id) {
        try {
            sensorService.deleteSensor(id);
            return "";
        } catch (Exception e) {
            return "<div class=\"alert alert-danger\">" + e.getMessage() + "</div>";
        }
    }

    // === Measurement Tab Endpoints ===

    @GetMapping("/{id}/measurements")
    public String measurementsTab(
            @PathVariable Long id,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "25") int size,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String sourceType,
            Model model) {
        Instant fromInstant = (from != null && !from.isBlank())
            ? java.time.LocalDateTime.parse(from, java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"))
                .atZone(java.time.ZoneId.systemDefault()).toInstant()
            : null;
        Instant toInstant = (to != null && !to.isBlank())
            ? java.time.LocalDateTime.parse(to, java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"))
                .atZone(java.time.ZoneId.systemDefault()).toInstant()
            : null;
        String srcFilter = (sourceType != null && !sourceType.isBlank()) ? sourceType : null;

        Pageable pageable = PageRequest.of(page, size);
        Page<Measurement> measurementsPage = measurementService.getMeasurementsByFilter(
            id, fromInstant, toInstant, srcFilter, pageable);
        long filteredCount = measurementService.countByFilter(id, fromInstant, toInstant, srcFilter);
        long totalCount = measurementService.countMeasurementsBySensor(id);

        model.addAttribute("sensorId", id);
        model.addAttribute("measurements", measurementsPage.getContent());
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", measurementsPage.getTotalPages());
        model.addAttribute("filteredCount", filteredCount);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("pageSize", size);
        model.addAttribute("from", from != null ? from : "");
        model.addAttribute("to", to != null ? to : "");
        model.addAttribute("sourceType", sourceType != null ? sourceType : "");
        return "pages/sensor-measurements-tab";
    }

    @DeleteMapping("/{id}/measurements/single")
    @ResponseBody
    public String deleteSingleMeasurement(
            @PathVariable Long id,
            @RequestParam long t,
            @RequestParam short p) {
        try {
            MeasurementId measurementId = new MeasurementId(id, Instant.ofEpochMilli(t), p);
            measurementService.deleteMeasurement(measurementId);
            return "";
        } catch (Exception e) {
            return "<div class=\"alert alert-danger\" style=\"margin:0.5rem 0;\">" + e.getMessage() + "</div>";
        }
    }

    @DeleteMapping("/{id}/measurements/filtered")
    @ResponseBody
    public String deleteFilteredMeasurements(
            @PathVariable Long id,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String sourceType) {
        try {
            Instant fromInstant = (from != null && !from.isBlank())
                ? java.time.LocalDateTime.parse(from, java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"))
                    .atZone(java.time.ZoneId.systemDefault()).toInstant()
                : null;
            Instant toInstant = (to != null && !to.isBlank())
                ? java.time.LocalDateTime.parse(to, java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"))
                    .atZone(java.time.ZoneId.systemDefault()).toInstant()
                : null;
            String srcFilter = (sourceType != null && !sourceType.isBlank()) ? sourceType : null;
            long deleted = measurementService.deleteByFilter(id, fromInstant, toInstant, srcFilter);
            String params = "?from=" + (from != null ? from : "") + "&to=" + (to != null ? to : "") + "&sourceType=" + (sourceType != null ? sourceType : "");
            return "<div class=\"alert alert-success\" style=\"margin:0.5rem 0;\">"
                + deleted + " Messwerte wurden gelöscht."
                + "</div><div id=\"measurements-list\" hx-get=\"/sensors/" + id + "/measurements" + params + "\""
                + " hx-trigger=\"load\" hx-swap=\"innerHTML\"></div>";
        } catch (Exception e) {
            return "<div class=\"alert alert-danger\" style=\"margin:0.5rem 0;\">" + e.getMessage() + "</div>";
        }
    }

    @DeleteMapping("/{id}/measurements/all")
    @ResponseBody
    public String deleteAllMeasurements(@PathVariable Long id) {
        try {
            long deleted = measurementService.deleteAllBySensor(id);
            return "<div class=\"alert alert-success\" style=\"margin:0.5rem 0;\">"
                + deleted + " Messwerte wurden gelöscht."
                + "</div><div id=\"measurements-list\" hx-get=\"/sensors/" + id + "/measurements\""
                + " hx-trigger=\"load\" hx-swap=\"innerHTML\"></div>";
        } catch (Exception e) {
            return "<div class=\"alert alert-danger\" style=\"margin:0.5rem 0;\">" + e.getMessage() + "</div>";
        }
    }

    @GetMapping("/{id}/measurements/confirm-delete-all")
    public String confirmDeleteAll(@PathVariable Long id, Model model) {
        long count = measurementService.countMeasurementsBySensor(id);
        model.addAttribute("sensorId", id);
        model.addAttribute("count", count);
        return "pages/sensor-measurements-confirm-delete-all";
    }
}
