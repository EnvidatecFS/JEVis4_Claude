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
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class TimeoutMonitorService {

    private static final Logger log = LoggerFactory.getLogger(TimeoutMonitorService.class);

    private final JobRepository jobRepository;
    private final JobStateMachineService stateMachine;

    public TimeoutMonitorService(JobRepository jobRepository, JobStateMachineService stateMachine) {
        this.jobRepository = jobRepository;
        this.stateMachine = stateMachine;
    }

    @Scheduled(fixedDelayString = "30000")
    @Transactional
    public void checkTimeouts() {
        List<Job> runningJobs = jobRepository.findRunningJobs();
        Instant now = Instant.now();

        for (Job job : runningJobs) {
            Instant deadline = job.getUpdatedAt().plus(job.getTimeoutSeconds(), ChronoUnit.SECONDS);
            if (now.isAfter(deadline)) {
                log.warn("Job {} timed out (timeout: {}s)", job.getId(), job.getTimeoutSeconds());
                stateMachine.transition(job, JobStatus.TIMED_OUT);
            }
        }
    }
}
