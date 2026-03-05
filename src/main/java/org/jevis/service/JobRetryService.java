package org.jevis.service;

import org.jevis.model.Job;
import org.jevis.model.JobPriority;
import org.jevis.model.JobStatus;
import org.jevis.repository.JobRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
@Transactional(readOnly = true)
public class JobRetryService {

    private static final Logger log = LoggerFactory.getLogger(JobRetryService.class);

    private final JobRepository jobRepository;
    private final JobStateMachineService stateMachine;
    private final JobEventService eventService;

    public JobRetryService(JobRepository jobRepository, JobStateMachineService stateMachine,
                            JobEventService eventService) {
        this.jobRepository = jobRepository;
        this.stateMachine = stateMachine;
        this.eventService = eventService;
    }

    @Transactional
    public void handleFailedJob(Job job) {
        if (job.getRetryCount() < job.getMaxRetryAttempts()) {
            eventService.processFailure(job);
        } else {
            eventService.processFailure(job); // Will escalate to alarm
        }
    }

    @Transactional
    public void handleTimedOutJob(Job job) {
        eventService.processTimeout(job);
    }
}
