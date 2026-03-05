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

    public void processDataFetchJob(Job job) {
        log.info("Processing Node-Red DATA_FETCH job: {}", job.getJobName());

        try {
            JsonNode params = objectMapper.readTree(job.getJobParameters());

            String scope = params.has("scope") ? params.get("scope").asText("device") : "device";
            int imported;

            if ("datapoint".equals(scope) && params.has("dataPointId")) {
                Long dataPointId = params.get("dataPointId").asLong();
                imported = fetchService.fetchDataPoint(dataPointId);
            } else if (params.has("deviceId")) {
                Long deviceId = params.get("deviceId").asLong();
                imported = fetchService.fetchDevice(deviceId);
            } else {
                throw new IllegalArgumentException("Job parameters must contain 'deviceId' or 'dataPointId'");
            }

            job.setStatus(JobStatus.COMPLETED);
            jobRepository.save(job);
            log.info("Node-Red DATA_FETCH job completed: {} measurements imported", imported);

        } catch (Exception e) {
            log.error("Node-Red DATA_FETCH job failed: {}", e.getMessage(), e);
            job.setStatus(JobStatus.FAILED);
            jobRepository.save(job);
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
