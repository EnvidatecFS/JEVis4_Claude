package org.jevis.controller;

import org.jevis.config.TenantContext;
import org.jevis.model.Measurement;
import org.jevis.model.ScadaImage;
import org.jevis.repository.ScadaImageRepository;
import org.jevis.service.FileUploadService;
import org.jevis.service.MeasurementService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

@Controller
@RequestMapping("/scada")
public class ScadaController {

    private static final Logger log = LoggerFactory.getLogger(ScadaController.class);

    private final ScadaImageRepository scadaImageRepository;
    private final FileUploadService fileUploadService;
    private final MeasurementService measurementService;

    @Value("${jevis.upload.dir:./uploads}")
    private String uploadDir;

    public ScadaController(ScadaImageRepository scadaImageRepository,
                           FileUploadService fileUploadService,
                           MeasurementService measurementService) {
        this.scadaImageRepository = scadaImageRepository;
        this.fileUploadService = fileUploadService;
        this.measurementService = measurementService;
    }

    private Long getActiveTenantId() {
        Long tenantId = TenantContext.getTenantId();
        return (tenantId != null) ? tenantId : 1L;
    }

    @PostMapping("/images/upload")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> uploadImage(@RequestParam("file") MultipartFile file) {
        Long tenantId = getActiveTenantId();
        String subDir = "scada/" + tenantId;

        try {
            String filePath = fileUploadService.store(file, subDir);

            ScadaImage image = new ScadaImage();
            image.setTenantId(tenantId);
            image.setFilePath(filePath);
            image.setOriginalName(file.getOriginalFilename());
            scadaImageRepository.save(image);

            Map<String, Object> result = new HashMap<>();
            result.put("id", image.getId());
            result.put("filePath", image.getFilePath());
            result.put("originalName", image.getOriginalName());
            return ResponseEntity.ok(result);
        } catch (IOException e) {
            log.error("SCADA image upload failed", e);
            return ResponseEntity.internalServerError().body(Map.of("error", "Upload fehlgeschlagen"));
        }
    }

    @GetMapping("/images")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> listImages() {
        Long tenantId = getActiveTenantId();
        List<ScadaImage> images = scadaImageRepository.findByTenantIdOrderByCreatedAtDesc(tenantId);

        List<Map<String, Object>> result = new ArrayList<>();
        for (ScadaImage img : images) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", img.getId());
            m.put("filePath", img.getFilePath());
            m.put("originalName", img.getOriginalName());
            result.add(m);
        }
        return ResponseEntity.ok(result);
    }

    @DeleteMapping("/images/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteImage(@PathVariable Long id) {
        Long tenantId = getActiveTenantId();
        Optional<ScadaImage> opt = scadaImageRepository.findByIdAndTenantId(id, tenantId);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ScadaImage image = opt.get();

        // Delete file from disk
        try {
            Path filePath = Paths.get(uploadDir, image.getFilePath());
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            log.warn("Could not delete SCADA image file: {}", image.getFilePath(), e);
        }

        scadaImageRepository.delete(image);
        return ResponseEntity.ok(Map.of("success", true));
    }

    @GetMapping("/values")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getValues(
            @RequestParam(required = false) List<Long> sensorIds) {

        Map<String, Object> values = new HashMap<>();

        if (sensorIds != null && !sensorIds.isEmpty()) {
            for (Long sensorId : sensorIds) {
                try {
                    Measurement latest = measurementService.getLatestMeasurement(sensorId);
                    if (latest != null && latest.getMeasurementValue() != null) {
                        values.put(String.valueOf(sensorId), latest.getMeasurementValue());
                    }
                } catch (Exception e) {
                    // Skip sensor with no data
                }
            }
        }

        return ResponseEntity.ok(values);
    }
}
