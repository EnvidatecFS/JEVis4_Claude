package org.jevis.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.jevis.model.Sensor;
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

import java.util.List;

@Controller
@RequestMapping("/sensors")
public class SensorController {

    private final SensorService sensorService;

    public SensorController(SensorService sensorService) {
        this.sensorService = sensorService;
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
        return "pages/sensor-edit-form";
    }

    @PutMapping("/{id}")
    public String updateSensor(
            @PathVariable Long id,
            @ModelAttribute Sensor sensorData,
            Model model
    ) {
        try {
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
}
