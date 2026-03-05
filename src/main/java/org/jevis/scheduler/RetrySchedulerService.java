package org.jevis.scheduler;

import org.jevis.model.Job;
import org.jevis.model.JobStatus;
import org.jevis.repository.JobRepository;
import org.jevis.service.JobStateMachineService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
public class RetrySchedulerService {

    private static final Logger log = LoggerFactory.getLogger(RetrySchedulerService.class);

    private final JobRepository jobRepository;
    private final JobStateMachineService stateMachine;

    public RetrySchedulerService(JobRepository jobRepository, JobStateMachineService stateMachine) {
        this.jobRepository = jobRepository;
        this.stateMachine = stateMachine;
    }

    @Scheduled(fixedDelayString = "60000")
    @Transactional
    public void processRetries() {
        List<Job> dueRetryJobs = jobRepository.findDueRetryJobs(Instant.now());

        for (Job job : dueRetryJobs) {
            log.info("Moving retry job {} back to queue (retry {}/{})",
                job.getId(), job.getRetryCount(), job.getMaxRetryAttempts());
            stateMachine.transition(job, JobStatus.QUEUED);
        }
    }
}
