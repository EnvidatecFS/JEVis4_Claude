package org.jevis.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.jevis.model.*;
import org.jevis.repository.MeasurementRepository;
import org.jevis.repository.NodeRedDataPointRepository;
import org.jevis.repository.NodeRedDeviceRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

@Service
public class NodeRedFetchService {

    private static final Logger log = LoggerFactory.getLogger(NodeRedFetchService.class);
    private static final DateTimeFormatter API_DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final Instant DEFAULT_FROM = LocalDateTime.of(1980, 1, 1, 0, 0, 0).toInstant(ZoneOffset.UTC);

    private final NodeRedDeviceRepository deviceRepository;
    private final NodeRedDataPointRepository dataPointRepository;
    private final MeasurementRepository measurementRepository;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    public NodeRedFetchService(NodeRedDeviceRepository deviceRepository,
                                NodeRedDataPointRepository dataPointRepository,
                                MeasurementRepository measurementRepository) {
        this.deviceRepository = deviceRepository;
        this.dataPointRepository = dataPointRepository;
        this.measurementRepository = measurementRepository;
        this.restTemplate = new RestTemplate();
        this.objectMapper = new ObjectMapper();
    }

    @Transactional
    public int fetchDevice(Long deviceId) {
        NodeRedDevice device = deviceRepository.findById(deviceId)
            .orElseThrow(() -> new IllegalArgumentException("Device not found: " + deviceId));

        List<NodeRedDataPoint> activeDataPoints = dataPointRepository.findByDeviceIdAndIsActiveTrue(deviceId);
        if (activeDataPoints.isEmpty()) {
            log.warn("No active data points for device {}", device.getDeviceName());
            return 0;
        }

        int totalImported = 0;
        boolean deviceReached = false;

        for (NodeRedDataPoint dp : activeDataPoints) {
            try {
                int count = fetchSingleDataPoint(device, dp);
                totalImported += count;
                deviceReached = true;
            } catch (Exception e) {
                log.error("Error fetching data point {} (remoteId={}) from device {}: {}",
                    dp.getId(), dp.getRemoteId(), device.getDeviceName(), e.getMessage());
            }
        }

        if (deviceReached) {
            device.setLastReachedAt(Instant.now());
        }
        if (totalImported > 0) {
            device.setLastDataImportAt(Instant.now());
        }
        deviceRepository.save(device);

        log.info("Device '{}': imported {} measurements from {} data points",
            device.getDeviceName(), totalImported, activeDataPoints.size());
        return totalImported;
    }

    @Transactional
    public int fetchDataPoint(Long dataPointId) {
        NodeRedDataPoint dp = dataPointRepository.findById(dataPointId)
            .orElseThrow(() -> new IllegalArgumentException("DataPoint not found: " + dataPointId));

        NodeRedDevice device = dp.getDevice();
        int count = fetchSingleDataPoint(device, dp);

        if (count > 0) {
            device.setLastReachedAt(Instant.now());
            device.setLastDataImportAt(Instant.now());
            deviceRepository.save(device);
        }

        return count;
    }

    private int fetchSingleDataPoint(NodeRedDevice device, NodeRedDataPoint dp) {
        Instant from = dp.getLastDataTimestamp() != null ? dp.getLastDataTimestamp() : DEFAULT_FROM;
        Instant until = LocalDateTime.now().withHour(23).withMinute(59).withSecond(59)
            .toInstant(ZoneOffset.UTC);

        String fromStr = API_DATE_FORMAT.format(from.atZone(ZoneOffset.UTC));
        String untilStr = API_DATE_FORMAT.format(until.atZone(ZoneOffset.UTC));

        String responseBody = callApi(device, dp.getRemoteId(), fromStr, untilStr, device.getDefaultLimit());

        List<Measurement> measurements = parseAndCreateMeasurements(responseBody, dp);

        if (!measurements.isEmpty()) {
            measurementRepository.saveAll(measurements);

            Instant maxTimestamp = measurements.stream()
                .map(m -> m.getId().getMeasuredAt())
                .max(Instant::compareTo)
                .orElse(null);

            dp.setLastSuccessAt(Instant.now());
            dp.setLastDataTimestamp(maxTimestamp);
            dp.setLastImportCount(measurements.size());
            dataPointRepository.save(dp);
        }

        log.info("DataPoint '{}' (remoteId={}): imported {} measurements",
            dp.getRemoteName(), dp.getRemoteId(), measurements.size());
        return measurements.size();
    }

    private String callApi(NodeRedDevice device, String remoteId, String from, String until, Integer limit) {
        String url = UriComponentsBuilder.fromHttpUrl(device.getApiUrl())
            .queryParam("id", remoteId)
            .queryParam("from", from)
            .queryParam("until", until)
            .queryParam("limit", limit)
            .toUriString();

        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(List.of(MediaType.APPLICATION_JSON));

        if (device.getUsername() != null && !device.getUsername().isBlank()) {
            String auth = device.getUsername() + ":" + (device.getPassword() != null ? device.getPassword() : "");
            String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes(StandardCharsets.UTF_8));
            headers.set("Authorization", "Basic " + encodedAuth);
        }

        HttpEntity<Void> entity = new HttpEntity<>(headers);
        log.debug("Calling Node-Red API: {}", url);

        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        if (response.getStatusCode() != HttpStatus.OK) {
            throw new RuntimeException("API returned status " + response.getStatusCode() + " for URL: " + url);
        }

        return response.getBody();
    }

    private List<Measurement> parseAndCreateMeasurements(String json, NodeRedDataPoint dp) {
        List<Measurement> measurements = new ArrayList<>();

        try {
            JsonNode root = objectMapper.readTree(json);
            JsonNode dataArray;

            if (root.isArray()) {
                dataArray = root;
            } else if (root.has("data") && root.get("data").isArray()) {
                dataArray = root.get("data");
            } else {
                log.warn("Unexpected JSON structure for dataPoint {}", dp.getRemoteId());
                return measurements;
            }

            Long sensorId = dp.getSensor().getId();

            for (JsonNode entry : dataArray) {
                try {
                    BigDecimal value = new BigDecimal(entry.get("value").asText());
                    String dateTimeStr = entry.get("date_time").asText();
                    Instant measuredAt = LocalDateTime.parse(dateTimeStr, API_DATE_FORMAT)
                        .toInstant(ZoneOffset.UTC);

                    short qualityFlag = 0;
                    if (entry.has("status") && !entry.get("status").isNull()) {
                        qualityFlag = (short) entry.get("status").asInt(0);
                    }

                    short priority = 0;
                    MeasurementId measurementId = new MeasurementId(sensorId, measuredAt, priority);
                    Measurement measurement = new Measurement(measurementId, value);
                    measurement.setSourceType("automatic");
                    measurement.setQualityFlag(qualityFlag);
                    measurement.setCreatedBy("nodered-import");

                    measurements.add(measurement);
                } catch (Exception e) {
                    log.warn("Failed to parse measurement entry for dataPoint {}: {}",
                        dp.getRemoteId(), e.getMessage());
                }
            }
        } catch (Exception e) {
            log.error("Failed to parse JSON response for dataPoint {}: {}", dp.getRemoteId(), e.getMessage());
        }

        return measurements;
    }
}
