package org.jevis.service;

import org.jevis.model.*;
import org.jevis.repository.JobRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Set;

@Service
@Transactional(readOnly = true)
public class JobStateMachineService {

    private static final Logger log = LoggerFactory.getLogger(JobStateMachineService.class);

    private final JobRepository jobRepository;

    private static final Map<JobStatus, Set<JobStatus>> VALID_TRANSITIONS = Map.ofEntries(
        Map.entry(JobStatus.CREATED, Set.of(JobStatus.QUEUED, JobStatus.CANCELLED)),
        Map.entry(JobStatus.QUEUED, Set.of(JobStatus.ASSIGNED, JobStatus.CANCELLED)),
        Map.entry(JobStatus.ASSIGNED, Set.of(JobStatus.RUNNING, JobStatus.CANCELLED)),
        Map.entry(JobStatus.RUNNING, Set.of(JobStatus.COMPLETED, JobStatus.FAILED, JobStatus.TIMED_OUT, JobStatus.CANCELLED)),
        Map.entry(JobStatus.FAILED, Set.of(JobStatus.RETRY_SCHEDULED, JobStatus.ALARM, JobStatus.CANCELLED)),
        Map.entry(JobStatus.TIMED_OUT, Set.of(JobStatus.RETRY_SCHEDULED, JobStatus.ALARM, JobStatus.CANCELLED)),
        Map.entry(JobStatus.RETRY_SCHEDULED, Set.of(JobStatus.QUEUED, JobStatus.CANCELLED)),
        Map.entry(JobStatus.COMPLETED, Set.of()),
        Map.entry(JobStatus.CANCELLED, Set.of()),
        Map.entry(JobStatus.ALARM, Set.of(JobStatus.CANCELLED))
    );

    public JobStateMachineService(JobRepository jobRepository) {
        this.jobRepository = jobRepository;
    }

    public boolean isValidTransition(JobStatus from, JobStatus to) {
        Set<JobStatus> allowed = VALID_TRANSITIONS.get(from);
        return allowed != null && allowed.contains(to);
    }

    @Transactional
    public Job transition(Job job, JobStatus newStatus) {
        JobStatus currentStatus = job.getStatus();
        if (!isValidTransition(currentStatus, newStatus)) {
            throw new IllegalStateException(
                "Invalid state transition: " + currentStatus + " -> " + newStatus + " for job " + job.getId());
        }
        log.info("Job {} transitioning: {} -> {}", job.getId(), currentStatus, newStatus);
        job.setStatus(newStatus);
        return jobRepository.save(job);
    }

    @Transactional
    public Job transitionById(Long jobId, JobStatus newStatus) {
        Job job = jobRepository.findById(jobId)
            .orElseThrow(() -> new IllegalArgumentException("Job not found: " + jobId));
        return transition(job, newStatus);
    }
}
