package org.jevis.scheduler;

import org.jevis.model.*;
import org.jevis.repository.JobRepository;
import org.jevis.repository.MeasurementRepository;
import org.jevis.repository.NodeRedDataPointRepository;
import org.jevis.repository.WorkerPoolRepository;
import org.jevis.service.JobQueueService;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.quartz.QuartzJobBean;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.List;

@Component
public class QuartzJobExecutor extends QuartzJobBean {

    private static final Logger log = LoggerFactory.getLogger(QuartzJobExecutor.class);

    private final JobRepository jobRepository;
    private final JobQueueService jobQueueService;
    private final WorkerPoolRepository poolRepository;
    private final NodeRedDataPointRepository dataPointRepository;
    private final MeasurementRepository measurementRepository;

    public QuartzJobExecutor(JobRepository jobRepository, JobQueueService jobQueueService,
                              WorkerPoolRepository poolRepository,
                              NodeRedDataPointRepository dataPointRepository,
                              MeasurementRepository measurementRepository) {
        this.jobRepository = jobRepository;
        this.jobQueueService = jobQueueService;
        this.poolRepository = poolRepository;
        this.dataPointRepository = dataPointRepository;
        this.measurementRepository = measurementRepository;
    }

    @Override
    protected void executeInternal(JobExecutionContext context) throws JobExecutionException {
        String jobIdStr = context.getMergedJobDataMap().getString("jobId");
        if (jobIdStr == null) {
            log.error("No jobId found in Quartz job data");
            return;
        }

        Long jobId = Long.parseLong(jobIdStr);
        jobRepository.findById(jobId).ifPresent(job -> {
            if (!job.getIsRecurring()) {
                return;
            }

            String jobParameters = job.getJobParameters();
            Long dataPointId = extractDataPointId(jobParameters);

            if (dataPointId != null) {
                String paramFragment = "\"dataPointId\":" + dataPointId;
                NodeRedDataPoint dp = dataPointRepository.findById(dataPointId).orElse(null);

                // Guard 1 – Messpunkt aktiv
                if (dp == null || !Boolean.TRUE.equals(dp.getIsActive())) {
                    log.debug("Überspringe Job '{}': Messpunkt ID={} ist nicht aktiv oder nicht gefunden",
                            job.getJobName(), dataPointId);
                    return;
                }

                // Guard 2 – Gerät aktiv
                if (dp.getDevice() == null || !Boolean.TRUE.equals(dp.getDevice().getIsActive())) {
                    log.debug("Überspringe Job '{}': Gerät für Messpunkt ID={} ist nicht aktiv",
                            job.getJobName(), dataPointId);
                    return;
                }

                // Guard 3 – Kein Duplikat in der Queue
                List<Job> activeInstances = jobRepository.findActiveQueueInstancesByParameterFragment(paramFragment);
                if (!activeInstances.isEmpty()) {
                    log.debug("Überspringe Job '{}': bereits {} aktiver Queue-Job(s) für Messpunkt ID={}",
                            job.getJobName(), activeInstances.size(), dataPointId);
                    return;
                }

                // Guard 4 – Daten veraltet
                Long sensorId = dp.getSensor() != null ? dp.getSensor().getId() : null;
                if (sensorId != null) {
                    Measurement latest = measurementRepository.findLatestMeasurement(sensorId);
                    if (latest != null) {
                        int intervalMinutes = dp.getFetchIntervalMinutes() != null ? dp.getFetchIntervalMinutes() : 15;
                        Instant threshold = Instant.now().minusSeconds((long) intervalMinutes * 60);
                        if (latest.getId().getMeasuredAt().isAfter(threshold)) {
                            log.debug("Überspringe Job '{}': Daten für Messpunkt ID={} sind noch aktuell (letzter Messwert: {})",
                                    job.getJobName(), dataPointId, latest.getId().getMeasuredAt());
                            return;
                        }
                    }
                }
            }

            WorkerPool pool = job.getWorkerPool();
            jobQueueService.createAndEnqueue(
                job.getJobName(),
                job.getJobType(),
                job.getPriority(),
                pool,
                job.getJobParameters(),
                "scheduler"
            );
            log.info("Scheduled recurring job created: {} (type: {})", job.getJobName(), job.getJobType());
        });
    }

    private Long extractDataPointId(String jobParameters) {
        if (jobParameters == null) {
            return null;
        }
        String key = "\"dataPointId\":";
        int idx = jobParameters.indexOf(key);
        if (idx < 0) {
            return null;
        }
        int start = idx + key.length();
        int end = start;
        while (end < jobParameters.length() && Character.isDigit(jobParameters.charAt(end))) {
            end++;
        }
        if (end == start) {
            return null;
        }
        try {
            return Long.parseLong(jobParameters.substring(start, end));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
