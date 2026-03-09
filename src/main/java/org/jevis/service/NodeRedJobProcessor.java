package org.jevis.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.jevis.model.*;
import org.jevis.repository.JobRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class NodeRedJobProcessor {

    private static final Logger log = LoggerFactory.getLogger(NodeRedJobProcessor.class);

    private final NodeRedFetchService fetchService;
    private final JobRepository jobRepository;
    private final ObjectMapper objectMapper;

    public NodeRedJobProcessor(NodeRedFetchService fetchService, JobRepository jobRepository) {
        this.fetchService = fetchService;
        this.jobRepository = jobRepository;
        this.objectMapper = new ObjectMapper();
    }

    public FetchResult processDataFetchJob(Job job) {
        log.info("Processing Node-Red DATA_FETCH job: {}", job.getJobName());

        JsonNode params;
        try {
            params = objectMapper.readTree(job.getJobParameters());
        } catch (Exception e) {
            throw new IllegalArgumentException("Failed to parse job parameters: " + e.getMessage(), e);
        }

        String scope = params.has("scope") ? params.get("scope").asText("device") : "device";

        if ("datapoint".equals(scope) && params.has("dataPointId")) {
            Long dataPointId = params.get("dataPointId").asLong();
            FetchResult result = fetchService.fetchDataPoint(dataPointId);
            log.info("Node-Red DATA_FETCH job completed: {} measurements imported", result.count());
            return result;
        } else if (params.has("deviceId")) {
            Long deviceId = params.get("deviceId").asLong();
            FetchResult result = fetchService.fetchDevice(deviceId);
            log.info("Node-Red DATA_FETCH job completed: {} measurements imported", result.count());
            return result;
        } else {
            throw new IllegalArgumentException("Job parameters must contain 'deviceId' or 'dataPointId'");
        }
    }

    public Job createFetchJob(Long deviceId, String deviceName) {
        Job job = new Job();
        job.setJobName("Node-Red Import: " + deviceName);
        job.setJobType(JobType.DATA_FETCH);
        job.setPriority(JobPriority.HIGH);
        job.setStatus(JobStatus.CREATED);
        job.setJobParameters("{\"deviceId\":" + deviceId + ",\"scope\":\"device\"}");
        job.setCreatedBy("nodered-ui");
        return jobRepository.save(job);
    }

    public Job createDataPointFetchJob(Long dataPointId, String description) {
        Job job = new Job();
        job.setJobName("Node-Red Import: " + description);
        job.setJobType(JobType.DATA_FETCH);
        job.setPriority(JobPriority.NORMAL);
        job.setStatus(JobStatus.CREATED);
        job.setJobParameters("{\"dataPointId\":" + dataPointId + ",\"scope\":\"datapoint\"}");
        job.setCreatedBy("nodered-ui");
        return jobRepository.save(job);
    }
}
