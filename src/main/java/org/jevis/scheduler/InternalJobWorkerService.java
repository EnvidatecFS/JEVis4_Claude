package org.jevis.scheduler;

import org.jevis.model.Job;
import org.jevis.model.JobStatus;
import org.jevis.model.JobType;
import org.jevis.repository.JobRepository;
import org.jevis.service.FetchResult;
import org.jevis.service.JobEventService;
import org.jevis.service.JobStateMachineService;
import org.jevis.service.NodeRedJobProcessor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Interner Worker-Dienst: fragt regelmäßig die Job-Queue ab
 * und führt fällige DATA_FETCH-Jobs direkt im Anwendungsprozess aus.
 *
 * Intervall konfigurierbar via: jevis.jobs.worker-poll-interval-ms (Standard: 60000ms)
 */
@Component
public class InternalJobWorkerService {

    private static final Logger log = LoggerFactory.getLogger(InternalJobWorkerService.class);

    private final JobRepository jobRepository;
    private final NodeRedJobProcessor jobProcessor;
    private final JobEventService jobEventService;
    private final JobStateMachineService stateMachine;

    // Self-reference so that @Transactional(REQUIRES_NEW) on processJob() is honoured by Spring's proxy
    @Autowired
    @Lazy
    private InternalJobWorkerService self;

    public InternalJobWorkerService(JobRepository jobRepository, NodeRedJobProcessor jobProcessor,
                                    JobEventService jobEventService, JobStateMachineService stateMachine) {
        this.jobRepository = jobRepository;
        this.jobProcessor = jobProcessor;
        this.jobEventService = jobEventService;
        this.stateMachine = stateMachine;
    }

    /**
     * Prüft die Queue auf wartende DATA_FETCH-Jobs und verarbeitet sie.
     * Läuft im konfigurierten Intervall (Standard: jede Minute).
     */
    @Scheduled(fixedDelayString = "${jevis.jobs.worker-poll-interval-ms:60000}")
    @Transactional(readOnly = true)
    public void processQueuedJobs() {
        List<Job> queuedJobs = jobRepository.findByStatusAndJobType(JobStatus.QUEUED, JobType.DATA_FETCH);

        if (queuedJobs.isEmpty()) {
            return;
        }

        log.info("Interner Worker: {} DATA_FETCH-Job(s) in der Queue gefunden", queuedJobs.size());

        for (Job job : queuedJobs) {
            // Call through proxy so REQUIRES_NEW creates a real separate transaction per job.
            // A failure in one job never rolls back completed jobs from the same batch.
            self.processJob(job.getId());
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void processJob(Long jobId) {
        Job job = jobRepository.findById(jobId).orElse(null);
        if (job == null) {
            log.warn("Job ID={} nicht gefunden – übersprungen", jobId);
            return;
        }

        log.info("Verarbeite Job: '{}' (ID={})", job.getJobName(), job.getId());
        try {
            stateMachine.transition(job, JobStatus.ASSIGNED);
            stateMachine.transition(job, JobStatus.RUNNING);

            FetchResult result = jobProcessor.processDataFetchJob(job);

            stateMachine.transition(job, JobStatus.COMPLETED);
            jobEventService.processCompletion(job, result);
            log.info("Job '{}' (ID={}) abgeschlossen: {} Messwerte importiert",
                    job.getJobName(), job.getId(), result.count());
        } catch (Exception e) {
            log.error("Fehler bei Job '{}' (ID={}): {}", job.getJobName(), job.getId(), e.getMessage(), e);
            try {
                stateMachine.transition(job, JobStatus.FAILED);
                jobEventService.processFailure(job);
            } catch (Exception ex) {
                log.error("Fehler beim Setzen des FAILED-Status für Job ID={}: {}", job.getId(), ex.getMessage());
            }
        }
    }
}
