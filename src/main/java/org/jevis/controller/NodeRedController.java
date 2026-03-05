package org.jevis.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.jevis.model.NodeRedDataPoint;
import org.jevis.model.NodeRedDevice;
import org.jevis.model.Sensor;
import org.jevis.repository.NodeRedDataPointRepository;
import org.jevis.repository.NodeRedDeviceRepository;
import org.jevis.service.NodeRedFetchService;
import org.jevis.service.NodeRedJobProcessor;
import org.jevis.service.SensorService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/devices")
public class NodeRedController {

    private final NodeRedDeviceRepository deviceRepository;
    private final NodeRedDataPointRepository dataPointRepository;
    private final NodeRedFetchService fetchService;
    private final NodeRedJobProcessor jobProcessor;
    private final SensorService sensorService;

    public NodeRedController(NodeRedDeviceRepository deviceRepository,
                              NodeRedDataPointRepository dataPointRepository,
                              NodeRedFetchService fetchService,
                              NodeRedJobProcessor jobProcessor,
                              SensorService sensorService) {
        this.deviceRepository = deviceRepository;
        this.dataPointRepository = dataPointRepository;
        this.fetchService = fetchService;
        this.jobProcessor = jobProcessor;
        this.sensorService = sensorService;
    }

    @GetMapping
    public String devicesPage(@AuthenticationPrincipal UserDetails userDetails,
                               HttpServletRequest request, Model model) {
        model.addAttribute("username", userDetails.getUsername());
        CsrfToken csrfToken = (CsrfToken) request.getAttribute(CsrfToken.class.getName());
        model.addAttribute("_csrf", csrfToken);
        return "pages/devices";
    }

    @GetMapping("/table")
    public String devicesTable(Model model) {
        List<NodeRedDevice> devices = deviceRepository.findAll();
        model.addAttribute("devices", devices);
        return "pages/devices-table";
    }

    @GetMapping("/new")
    public String newDeviceForm(Model model) {
        model.addAttribute("device", new NodeRedDevice());
        return "pages/device-form";
    }

    @PostMapping
    public String createDevice(@ModelAttribute NodeRedDevice device, Model model) {
        try {
            NodeRedDevice saved = deviceRepository.save(device);
            model.addAttribute("device", saved);
            model.addAttribute("success", true);
            model.addAttribute("message", "Gerät erfolgreich erstellt");
        } catch (Exception e) {
            model.addAttribute("device", device);
            model.addAttribute("success", false);
            model.addAttribute("message", "Fehler: " + e.getMessage());
        }
        return "pages/device-form";
    }

    @GetMapping("/{id}")
    public String deviceDetail(@PathVariable Long id,
                                @AuthenticationPrincipal UserDetails userDetails,
                                HttpServletRequest request, Model model) {
        NodeRedDevice device = deviceRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Gerät nicht gefunden: " + id));
        List<NodeRedDataPoint> dataPoints = dataPointRepository.findByDeviceId(id);

        model.addAttribute("device", device);
        model.addAttribute("dataPoints", dataPoints);
        model.addAttribute("username", userDetails.getUsername());
        CsrfToken csrfToken = (CsrfToken) request.getAttribute(CsrfToken.class.getName());
        model.addAttribute("_csrf", csrfToken);
        return "pages/device-detail";
    }

    @GetMapping("/{id}/edit")
    public String editDeviceForm(@PathVariable Long id, Model model) {
        NodeRedDevice device = deviceRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Gerät nicht gefunden: " + id));
        model.addAttribute("device", device);
        return "pages/device-form";
    }

    @PutMapping("/{id}")
    public String updateDevice(@PathVariable Long id, @ModelAttribute NodeRedDevice deviceData, Model model) {
        try {
            NodeRedDevice existing = deviceRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Gerät nicht gefunden: " + id));
            existing.setDeviceName(deviceData.getDeviceName());
            existing.setApiUrl(deviceData.getApiUrl());
            existing.setUsername(deviceData.getUsername());
            existing.setPassword(deviceData.getPassword());
            existing.setDefaultLimit(deviceData.getDefaultLimit());
            existing.setIsActive(deviceData.getIsActive());
            NodeRedDevice saved = deviceRepository.save(existing);
            model.addAttribute("device", saved);
            model.addAttribute("success", true);
            model.addAttribute("message", "Gerät erfolgreich aktualisiert");
        } catch (Exception e) {
            model.addAttribute("device", deviceData);
            model.addAttribute("success", false);
            model.addAttribute("message", "Fehler: " + e.getMessage());
        }
        return "pages/device-form";
    }

    @DeleteMapping("/{id}")
    @ResponseBody
    public String deleteDevice(@PathVariable Long id) {
        try {
            deviceRepository.deleteById(id);
            return "";
        } catch (Exception e) {
            return "<div class=\"alert alert-danger\">" + e.getMessage() + "</div>";
        }
    }

    @PostMapping("/{id}/fetch")
    @ResponseBody
    public String fetchDevice(@PathVariable Long id) {
        try {
            NodeRedDevice device = deviceRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Gerät nicht gefunden: " + id));
            jobProcessor.createFetchJob(id, device.getDeviceName());
            int count = fetchService.fetchDevice(id);
            return "<div class=\"alert alert-success\">Erfolgreich " + count + " Messwerte importiert</div>";
        } catch (Exception e) {
            return "<div class=\"alert alert-danger\">Fehler: " + e.getMessage() + "</div>";
        }
    }

    @GetMapping("/{id}/datapoints/table")
    public String dataPointsTable(@PathVariable Long id, Model model) {
        List<NodeRedDataPoint> dataPoints = dataPointRepository.findByDeviceId(id);
        model.addAttribute("dataPoints", dataPoints);
        model.addAttribute("deviceId", id);
        return "pages/device-datapoints-table";
    }

    @GetMapping("/{id}/datapoints/new")
    public String newDataPointForm(@PathVariable Long id, Model model) {
        NodeRedDevice device = deviceRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Gerät nicht gefunden: " + id));
        List<Sensor> sensors = sensorService.getActiveSensors();
        model.addAttribute("device", device);
        model.addAttribute("sensors", sensors);
        model.addAttribute("dataPoint", new NodeRedDataPoint());
        return "pages/device-datapoint-form";
    }

    @PostMapping("/{id}/datapoints")
    public String createDataPoint(@PathVariable Long id,
                                   @RequestParam String remoteId,
                                   @RequestParam(required = false) String remoteName,
                                   @RequestParam Long sensorId,
                                   Model model) {
        try {
            NodeRedDevice device = deviceRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Gerät nicht gefunden: " + id));
            Sensor sensor = sensorService.getSensorById(sensorId);

            NodeRedDataPoint dp = new NodeRedDataPoint();
            dp.setDevice(device);
            dp.setSensor(sensor);
            dp.setRemoteId(remoteId);
            dp.setRemoteName(remoteName);
            dp.setIsActive(true);
            dataPointRepository.save(dp);

            model.addAttribute("success", true);
            model.addAttribute("message", "Messpunkt-Mapping erfolgreich erstellt");
        } catch (Exception e) {
            model.addAttribute("success", false);
            model.addAttribute("message", "Fehler: " + e.getMessage());
        }

        NodeRedDevice device = deviceRepository.findById(id).orElse(null);
        List<Sensor> sensors = sensorService.getActiveSensors();
        model.addAttribute("device", device);
        model.addAttribute("sensors", sensors);
        model.addAttribute("dataPoint", new NodeRedDataPoint());
        return "pages/device-datapoint-form";
    }

    @DeleteMapping("/{deviceId}/datapoints/{dpId}")
    @ResponseBody
    public String deleteDataPoint(@PathVariable Long deviceId, @PathVariable Long dpId) {
        try {
            dataPointRepository.deleteById(dpId);
            return "";
        } catch (Exception e) {
            return "<div class=\"alert alert-danger\">" + e.getMessage() + "</div>";
        }
    }

    @PostMapping("/{deviceId}/datapoints/{dpId}/fetch")
    @ResponseBody
    public String fetchDataPoint(@PathVariable Long deviceId, @PathVariable Long dpId) {
        try {
            int count = fetchService.fetchDataPoint(dpId);
            return "<div class=\"alert alert-success\">Erfolgreich " + count + " Messwerte importiert</div>";
        } catch (Exception e) {
            return "<div class=\"alert alert-danger\">Fehler: " + e.getMessage() + "</div>";
        }
    }
}
