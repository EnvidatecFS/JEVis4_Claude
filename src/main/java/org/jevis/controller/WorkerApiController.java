package org.jevis.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.jevis.dto.*;
import org.jevis.model.*;
import org.jevis.service.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/workers")
@Tag(name = "Worker API", description = "REST API for task workers")
public class WorkerApiController {

    private final WorkerRegistrationService workerService;
    private final JobQueueService jobQueueService;
    private final JobExecutionService executionService;
    private final JobEventService eventService;

    public WorkerApiController(WorkerRegistrationService workerService, JobQueueService jobQueueService,
                                JobExecutionService executionService, JobEventService eventService) {
        this.workerService = workerService;
        this.jobQueueService = jobQueueService;
        this.executionService = executionService;
        this.eventService = eventService;
    }

    @PostMapping("/register")
    @Operation(summary = "Register a new worker")
    public ResponseEntity<?> registerWorker(@Valid @RequestBody WorkerRegistrationRequest request) {
        try {
            TaskWorker worker = workerService.registerWorker(
                request.getWorkerName(), request.getPoolName(), request.getCapabilities(),
                request.getHostName(), request.getIpAddress(), request.getMaxConcurrentJobs()
            );
            return ResponseEntity.ok(new WorkerRegistrationResponse(
                worker.getId(), worker.getWorkerIdentifier(), worker.getApiKey()
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/{id}/heartbeat")
    @Operation(summary = "Send worker heartbeat")
    public ResponseEntity<?> heartbeat(@PathVariable Long id, @RequestHeader("X-Worker-Api-Key") String apiKey) {
        if (!validateWorker(id, apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid API key"));
        }
        workerService.heartbeat(id);
        return ResponseEntity.ok(Map.of("status", "ok"));
    }

    @GetMapping("/{id}/poll")
    @Operation(summary = "Poll for next available job")
    public ResponseEntity<?> pollJob(@PathVariable Long id, @RequestHeader("X-Worker-Api-Key") String apiKey) {
        if (!validateWorker(id, apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid API key"));
        }

        TaskWorker worker = workerService.findById(id).orElse(null);
        if (worker == null) {
            return ResponseEntity.notFound().build();
        }

        Optional<Job> jobOpt = jobQueueService.pollNextJob(worker);
        if (jobOpt.isEmpty()) {
            return ResponseEntity.noContent().build();
        }

        Job job = jobOpt.get();
        job = jobQueueService.assignToWorker(job, worker);
        JobExecution execution = executionService.startExecution(job, worker);

        eventService.createEvent(job, JobEventType.JOB_ASSIGNED,
            "Job assigned to worker: " + worker.getWorkerName(), null, null);

        JobPollResponse response = new JobPollResponse();
        response.setJobId(job.getId());
        response.setJobName(job.getJobName());
        response.setJobType(job.getJobType().name());
        response.setPriority(job.getPriority().name());
        response.setJobParameters(job.getJobParameters());
        response.setExecutionId(execution.getId());
        response.setTimeoutSeconds(job.getTimeoutSeconds());

        return ResponseEntity.ok(response);
    }

    @PostMapping("/{id}/jobs/{jobId}/start")
    @Operation(summary = "Report job start")
    public ResponseEntity<?> reportStart(@PathVariable Long id, @PathVariable Long jobId,
                                          @RequestHeader("X-Worker-Api-Key") String apiKey) {
        if (!validateWorker(id, apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid API key"));
        }
        return ResponseEntity.ok(Map.of("status", "ok"));
    }

    @PostMapping("/{id}/jobs/{jobId}/progress")
    @Operation(summary = "Report job progress")
    public ResponseEntity<?> reportProgress(@PathVariable Long id, @PathVariable Long jobId,
                                             @RequestBody JobProgressRequest request,
                                             @RequestHeader("X-Worker-Api-Key") String apiKey) {
        if (!validateWorker(id, apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid API key"));
        }
        executionService.updateProgress(request.getExecutionId(), request.getProgressPercent(), request.getProgressMessage());
        return ResponseEntity.ok(Map.of("status", "ok"));
    }

    @PostMapping("/{id}/jobs/{jobId}/complete")
    @Operation(summary = "Report job completion")
    public ResponseEntity<?> reportComplete(@PathVariable Long id, @PathVariable Long jobId,
                                             @RequestBody JobCompleteRequest request,
                                             @RequestHeader("X-Worker-Api-Key") String apiKey) {
        if (!validateWorker(id, apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid API key"));
        }
        JobExecution execution = executionService.completeExecution(request.getExecutionId(), request.getResult());
        eventService.processCompletion(execution.getJob());
        return ResponseEntity.ok(Map.of("status", "completed"));
    }

    @PostMapping("/{id}/jobs/{jobId}/fail")
    @Operation(summary = "Report job failure")
    public ResponseEntity<?> reportFail(@PathVariable Long id, @PathVariable Long jobId,
                                         @RequestBody JobFailRequest request,
                                         @RequestHeader("X-Worker-Api-Key") String apiKey) {
        if (!validateWorker(id, apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid API key"));
        }
        JobExecution execution = executionService.failExecution(
            request.getExecutionId(), request.getErrorMessage(), request.getStackTrace());
        eventService.processFailure(execution.getJob());
        return ResponseEntity.ok(Map.of("status", "failed"));
    }

    @PostMapping("/{id}/deregister")
    @Operation(summary = "Deregister worker")
    public ResponseEntity<?> deregister(@PathVariable Long id, @RequestHeader("X-Worker-Api-Key") String apiKey) {
        if (!validateWorker(id, apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid API key"));
        }
        workerService.deregister(id);
        return ResponseEntity.ok(Map.of("status", "deregistered"));
    }

    private boolean validateWorker(Long workerId, String apiKey) {
        return workerService.findById(workerId)
            .map(w -> apiKey != null && apiKey.equals(w.getApiKey()))
            .orElse(false);
    }
}
