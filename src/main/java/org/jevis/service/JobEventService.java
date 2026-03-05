package org.jevis.service;

import org.jevis.model.*;
import org.jevis.repository.JobEventRepository;
import org.jevis.repository.JobRepository;
import org.jevis.repository.WorkerPoolRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Set;

@Service
@Transactional(readOnly = true)
public class JobEventService {

    private static final Logger log = LoggerFactory.getLogger(JobEventService.class);

    private static final Set<JobEventType> NOTIFICATION_TYPES = Set.of(
        JobEventType.JOB_COMPLETED, JobEventType.JOB_FAILED, JobEventType.JOB_ALARM, JobEventType.JOB_TIMEOUT
    );

    private final JobEventRepository eventRepository;
    private final JobRepository jobRepository;
    private final WorkerPoolRepository poolRepository;
    private final JobStateMachineService stateMachine;

    public JobEventService(JobEventRepository eventRepository, JobRepository jobRepository,
                            WorkerPoolRepository poolRepository, JobStateMachineService stateMachine) {
        this.eventRepository = eventRepository;
        this.jobRepository = jobRepository;
        this.poolRepository = poolRepository;
        this.stateMachine = stateMachine;
    }

    @Transactional
    public JobEvent createEvent(Job job, JobEventType eventType, String message, String data, String notifyUser) {
        JobEvent event = new JobEvent();
        event.setJob(job);
        event.setEventType(eventType);
        event.setEventMessage(message);
        event.setEventData(data);

        // Auto-notify job creator for important events
        if (notifyUser != null) {
            event.setNotifiedUser(notifyUser);
        } else if (NOTIFICATION_TYPES.contains(eventType) && job.getCreatedBy() != null) {
            event.setNotifiedUser(job.getCreatedBy());
        }

        return eventRepository.save(event);
    }

    @Transactional
    public void processCompletion(Job job) {
        createEvent(job, JobEventType.JOB_COMPLETED,
            "Job '" + job.getJobName() + "' erfolgreich abgeschlossen", null, null);

        // Event-Chain: trigger follow-up job on success
        if (job.getOnSuccessJobType() != null) {
            processEventChain(job);
        }
    }

    @Transactional
    public void processFailure(Job job) {
        createEvent(job, JobEventType.JOB_FAILED,
            "Job '" + job.getJobName() + "' fehlgeschlagen", null, null);

        // Check if retry is possible
        if (job.getRetryCount() < job.getMaxRetryAttempts()) {
            scheduleRetry(job);
        } else {
            escalateToAlarm(job);
        }
    }

    @Transactional
    public void processTimeout(Job job) {
        createEvent(job, JobEventType.JOB_TIMEOUT,
            "Job '" + job.getJobName() + "' Timeout nach " + job.getTimeoutSeconds() + "s", null, null);

        if (job.getRetryCount() < job.getMaxRetryAttempts()) {
            scheduleRetry(job);
        } else {
            escalateToAlarm(job);
        }
    }

    private void scheduleRetry(Job job) {
        job.setRetryCount(job.getRetryCount() + 1);
        int backoffSeconds = job.getRetryBackoffSeconds() * job.getRetryCount();
        job.setScheduledFor(Instant.now().plusSeconds(backoffSeconds));
        job.setPriority(JobPriority.RETRY);
        stateMachine.transition(job, JobStatus.RETRY_SCHEDULED);

        createEvent(job, JobEventType.JOB_RETRY_SCHEDULED,
            "Retry " + job.getRetryCount() + "/" + job.getMaxRetryAttempts() + " geplant in " + backoffSeconds + "s",
            null, null);

        log.info("Job {} retry scheduled ({}/{}), backoff: {}s",
            job.getId(), job.getRetryCount(), job.getMaxRetryAttempts(), backoffSeconds);
    }

    private void escalateToAlarm(Job job) {
        stateMachine.transition(job, JobStatus.ALARM);

        createEvent(job, JobEventType.JOB_ALARM,
            "ALARM: Job '" + job.getJobName() + "' nach " + job.getMaxRetryAttempts() + " Versuchen fehlgeschlagen",
            null, null);

        log.error("Job {} escalated to ALARM after {} retries", job.getId(), job.getMaxRetryAttempts());
    }

    private void processEventChain(Job job) {
        log.info("Processing event chain: Job {} -> creating {} job", job.getId(), job.getOnSuccessJobType());

        Job followUpJob = new Job();
        followUpJob.setJobName(job.getOnSuccessJobType().getDisplayName() + " (Chain von " + job.getJobName() + ")");
        followUpJob.setJobType(job.getOnSuccessJobType());
        followUpJob.setPriority(JobPriority.HIGH);
        followUpJob.setWorkerPool(job.getWorkerPool());
        followUpJob.setJobParameters(job.getOnSuccessJobParams());
        followUpJob.setParentJobId(job.getId());
        followUpJob.setCreatedBy("event-chain");
        followUpJob.setStatus(JobStatus.CREATED);
        followUpJob.setScheduledFor(Instant.now());
        followUpJob = jobRepository.save(followUpJob);

        stateMachine.transition(followUpJob, JobStatus.QUEUED);

        createEvent(followUpJob, JobEventType.JOB_CREATED,
            "Folge-Job erstellt durch Event-Chain von Job #" + job.getId(), null, null);
    }

    public List<JobEvent> getEventsForJob(Long jobId) {
        return eventRepository.findByJobIdOrderByCreatedAtDesc(jobId);
    }

    public List<JobEvent> getUnreadNotifications(String username) {
        return eventRepository.findUnreadNotifications(username);
    }

    public long countUnreadNotifications(String username) {
        return eventRepository.countUnreadNotifications(username);
    }

    public List<JobEvent> getNotificationsForUser(String username) {
        return eventRepository.findNotificationsForUser(username);
    }

    @Transactional
    public void markNotificationAsRead(Long eventId, String username) {
        eventRepository.markAsRead(eventId, username);
    }
}
