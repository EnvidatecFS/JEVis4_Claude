package org.jevis.service;

import org.jevis.model.*;
import org.jevis.repository.JobRepository;
import org.jevis.repository.TaskWorkerRepository;
import org.jevis.repository.WorkerPoolRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Service
@Transactional(readOnly = true)
public class JobQueueService {

    private static final Logger log = LoggerFactory.getLogger(JobQueueService.class);

    private final JobRepository jobRepository;
    private final TaskWorkerRepository taskWorkerRepository;
    private final WorkerPoolRepository workerPoolRepository;
    private final JobStateMachineService stateMachine;

    public JobQueueService(JobRepository jobRepository, TaskWorkerRepository taskWorkerRepository,
                           WorkerPoolRepository workerPoolRepository, JobStateMachineService stateMachine) {
        this.jobRepository = jobRepository;
        this.taskWorkerRepository = taskWorkerRepository;
        this.workerPoolRepository = workerPoolRepository;
        this.stateMachine = stateMachine;
    }

    @Transactional
    public Job enqueue(Job job) {
        if (job.getWorkerPool() == null) {
            WorkerPool defaultPool = workerPoolRepository.findByIsDefaultTrue()
                .orElseThrow(() -> new IllegalStateException("No default worker pool configured"));
            job.setWorkerPool(defaultPool);
        }
        if (job.getScheduledFor() == null) {
            job.setScheduledFor(Instant.now());
        }
        return stateMachine.transition(job, JobStatus.QUEUED);
    }

    @Transactional
    public Job createAndEnqueue(String jobName, JobType jobType, JobPriority priority,
                                 WorkerPool pool, String parameters, String createdBy) {
        Job job = new Job();
        job.setJobName(jobName);
        job.setJobType(jobType);
        job.setPriority(priority);
        job.setWorkerPool(pool);
        job.setJobParameters(parameters);
        job.setCreatedBy(createdBy);
        job.setStatus(JobStatus.CREATED);
        job = jobRepository.save(job);
        return enqueue(job);
    }

    public Optional<Job> pollNextJob(TaskWorker worker) {
        if (worker.getWorkerPool() == null) {
            return Optional.empty();
        }

        List<Job> queuedJobs = jobRepository.findQueuedJobsForPool(
            worker.getWorkerPool().getId(), JobStatus.QUEUED, Instant.now());

        for (Job job : queuedJobs) {
            if (canWorkerHandle(worker, job)) {
                return Optional.of(job);
            }
        }
        return Optional.empty();
    }

    @Transactional
    public Job assignToWorker(Job job, TaskWorker worker) {
        job = stateMachine.transition(job, JobStatus.ASSIGNED);
        worker.setCurrentJobCount(worker.getCurrentJobCount() + 1);
        if (worker.getCurrentJobCount() >= worker.getMaxConcurrentJobs()) {
            worker.setStatus(WorkerStatus.BUSY);
        }
        taskWorkerRepository.save(worker);
        return job;
    }

    private boolean canWorkerHandle(TaskWorker worker, Job job) {
        if (worker.getCurrentJobCount() >= worker.getMaxConcurrentJobs()) {
            return false;
        }
        String capabilities = worker.getCapabilities();
        if (capabilities == null || capabilities.isBlank()) {
            return true; // Worker can handle all job types
        }
        return capabilities.contains(job.getJobType().name());
    }
}
