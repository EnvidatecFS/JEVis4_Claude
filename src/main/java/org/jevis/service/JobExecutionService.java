package org.jevis.service;

import org.jevis.model.*;
import org.jevis.repository.JobExecutionRepository;
import org.jevis.repository.JobRepository;
import org.jevis.repository.TaskWorkerRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class JobExecutionService {

    private static final Logger log = LoggerFactory.getLogger(JobExecutionService.class);

    private final JobExecutionRepository executionRepository;
    private final JobRepository jobRepository;
    private final TaskWorkerRepository taskWorkerRepository;
    private final JobStateMachineService stateMachine;

    public JobExecutionService(JobExecutionRepository executionRepository, JobRepository jobRepository,
                                TaskWorkerRepository taskWorkerRepository, JobStateMachineService stateMachine) {
        this.executionRepository = executionRepository;
        this.jobRepository = jobRepository;
        this.taskWorkerRepository = taskWorkerRepository;
        this.stateMachine = stateMachine;
    }

    @Transactional
    public JobExecution startExecution(Job job, TaskWorker worker) {
        stateMachine.transition(job, JobStatus.RUNNING);

        int nextNumber = executionRepository.findMaxExecutionNumber(job.getId()).orElse(0) + 1;

        JobExecution execution = new JobExecution();
        execution.setJob(job);
        execution.setWorker(worker);
        execution.setExecutionNumber(nextNumber);
        execution.setStatus(JobStatus.RUNNING);
        execution.setStartedAt(Instant.now());
        execution.setProgressPercent(0);

        return executionRepository.save(execution);
    }

    @Transactional
    public JobExecution updateProgress(Long executionId, Integer progressPercent, String progressMessage) {
        JobExecution execution = executionRepository.findById(executionId)
            .orElseThrow(() -> new IllegalArgumentException("Execution not found: " + executionId));
        execution.setProgressPercent(progressPercent);
        execution.setProgressMessage(progressMessage);
        return executionRepository.save(execution);
    }

    @Transactional
    public JobExecution completeExecution(Long executionId, String result) {
        JobExecution execution = executionRepository.findById(executionId)
            .orElseThrow(() -> new IllegalArgumentException("Execution not found: " + executionId));

        Instant now = Instant.now();
        execution.setStatus(JobStatus.COMPLETED);
        execution.setFinishedAt(now);
        execution.setDurationMs(Duration.between(execution.getStartedAt(), now).toMillis());
        execution.setResult(result);
        execution.setProgressPercent(100);

        Job job = execution.getJob();
        stateMachine.transition(job, JobStatus.COMPLETED);

        decrementWorkerJobCount(execution.getWorker());

        return executionRepository.save(execution);
    }

    @Transactional
    public JobExecution failExecution(Long executionId, String errorMessage, String stackTrace) {
        JobExecution execution = executionRepository.findById(executionId)
            .orElseThrow(() -> new IllegalArgumentException("Execution not found: " + executionId));

        Instant now = Instant.now();
        execution.setStatus(JobStatus.FAILED);
        execution.setFinishedAt(now);
        execution.setDurationMs(Duration.between(execution.getStartedAt(), now).toMillis());
        execution.setErrorMessage(errorMessage);
        execution.setStackTrace(stackTrace);

        Job job = execution.getJob();
        stateMachine.transition(job, JobStatus.FAILED);

        decrementWorkerJobCount(execution.getWorker());

        return executionRepository.save(execution);
    }

    public List<JobExecution> getExecutionsForJob(Long jobId) {
        return executionRepository.findByJobIdOrderByExecutionNumberDesc(jobId);
    }

    private void decrementWorkerJobCount(TaskWorker worker) {
        if (worker != null) {
            worker.setCurrentJobCount(Math.max(0, worker.getCurrentJobCount() - 1));
            if (worker.getCurrentJobCount() < worker.getMaxConcurrentJobs()) {
                worker.setStatus(WorkerStatus.IDLE);
            }
            taskWorkerRepository.save(worker);
        }
    }
}
