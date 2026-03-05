package org.jevis.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.jevis.model.*;
import org.jevis.repository.JobRepository;
import org.jevis.repository.WorkerPoolRepository;
import org.jevis.service.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.Map;

@Controller
public class JobController {

    private final JobRepository jobRepository;
    private final WorkerPoolRepository poolRepository;
    private final JobQueueService jobQueueService;
    private final JobEventService eventService;
    private final JobExecutionService executionService;
    private final WorkerRegistrationService workerService;

    public JobController(JobRepository jobRepository, WorkerPoolRepository poolRepository,
                          JobQueueService jobQueueService, JobEventService eventService,
                          JobExecutionService executionService, WorkerRegistrationService workerService) {
        this.jobRepository = jobRepository;
        this.poolRepository = poolRepository;
        this.jobQueueService = jobQueueService;
        this.eventService = eventService;
        this.executionService = executionService;
        this.workerService = workerService;
    }

    @GetMapping("/jobs")
    public String jobsPage(@AuthenticationPrincipal UserDetails userDetails, HttpServletRequest request, Model model) {
        model.addAttribute("username", userDetails.getUsername());
        CsrfToken csrfToken = (CsrfToken) request.getAttribute(CsrfToken.class.getName());
        model.addAttribute("_csrf", csrfToken);
        return "pages/jobs";
    }

    @GetMapping("/jobs/table")
    public String jobsTable(
            @RequestParam(defaultValue = "") String search,
            @RequestParam(defaultValue = "") String statusFilter,
            @RequestParam(defaultValue = "") String typeFilter,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "15") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            Model model) {

        Sort sort = sortDir.equalsIgnoreCase("asc")
            ? Sort.by(sortBy).ascending()
            : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);

        JobStatus status = statusFilter.isEmpty() ? null : JobStatus.valueOf(statusFilter);
        JobType type = typeFilter.isEmpty() ? null : JobType.valueOf(typeFilter);

        Page<Job> jobsPage = jobRepository.searchJobs(search, status, type, null, pageable);

        model.addAttribute("jobs", jobsPage.getContent());
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", jobsPage.getTotalPages());
        model.addAttribute("totalElements", jobsPage.getTotalElements());
        model.addAttribute("search", search);
        model.addAttribute("statusFilter", statusFilter);
        model.addAttribute("typeFilter", typeFilter);
        model.addAttribute("sortBy", sortBy);
        model.addAttribute("sortDir", sortDir);

        return "pages/jobs-table";
    }

    @GetMapping("/jobs/{id}")
    public String jobDetail(@PathVariable Long id, @AuthenticationPrincipal UserDetails userDetails,
                             HttpServletRequest request, Model model) {
        Job job = jobRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Job not found: " + id));

        model.addAttribute("job", job);
        model.addAttribute("executions", executionService.getExecutionsForJob(id));
        model.addAttribute("events", eventService.getEventsForJob(id));
        model.addAttribute("username", userDetails.getUsername());
        CsrfToken csrfToken = (CsrfToken) request.getAttribute(CsrfToken.class.getName());
        model.addAttribute("_csrf", csrfToken);

        return "pages/job-detail";
    }

    @PostMapping("/jobs/create")
    @ResponseBody
    public ResponseEntity<?> createJob(@RequestParam String jobName,
                                        @RequestParam String jobType,
                                        @RequestParam(defaultValue = "NORMAL") String priority,
                                        @RequestParam(required = false) Long poolId,
                                        @RequestParam(required = false) String jobParameters,
                                        @AuthenticationPrincipal UserDetails userDetails) {
        try {
            WorkerPool pool = poolId != null
                ? poolRepository.findById(poolId).orElse(null)
                : poolRepository.findByIsDefaultTrue().orElse(null);

            Job job = jobQueueService.createAndEnqueue(
                jobName,
                JobType.valueOf(jobType),
                JobPriority.valueOf(priority),
                pool,
                jobParameters,
                userDetails.getUsername()
            );
            return ResponseEntity.ok(Map.of("id", job.getId(), "status", "created"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/jobs/{id}/cancel")
    @ResponseBody
    public ResponseEntity<?> cancelJob(@PathVariable Long id) {
        try {
            Job job = jobRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Job not found: " + id));
            job.setStatus(JobStatus.CANCELLED);
            jobRepository.save(job);
            eventService.createEvent(job, JobEventType.JOB_CANCELLED, "Job manuell abgebrochen", null, null);
            return ResponseEntity.ok(Map.of("status", "cancelled"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Workers page
    @GetMapping("/workers")
    public String workersPage(@AuthenticationPrincipal UserDetails userDetails, HttpServletRequest request, Model model) {
        model.addAttribute("username", userDetails.getUsername());
        CsrfToken csrfToken = (CsrfToken) request.getAttribute(CsrfToken.class.getName());
        model.addAttribute("_csrf", csrfToken);
        return "pages/workers";
    }

    @GetMapping("/workers/table")
    public String workersTable(Model model) {
        model.addAttribute("workers", workerService.getAllWorkers());
        model.addAttribute("pools", poolRepository.findAll());
        return "pages/workers-table";
    }

    // Notifications API
    @GetMapping("/api/notifications")
    @ResponseBody
    public ResponseEntity<?> getNotifications(@AuthenticationPrincipal UserDetails userDetails) {
        List<JobEvent> notifications = eventService.getNotificationsForUser(userDetails.getUsername());
        long unreadCount = eventService.countUnreadNotifications(userDetails.getUsername());
        return ResponseEntity.ok(Map.of("notifications", notifications, "unreadCount", unreadCount));
    }

    @PostMapping("/api/notifications/{id}/read")
    @ResponseBody
    public ResponseEntity<?> markNotificationRead(@PathVariable Long id,
                                                    @AuthenticationPrincipal UserDetails userDetails) {
        eventService.markNotificationAsRead(id, userDetails.getUsername());
        return ResponseEntity.ok(Map.of("status", "ok"));
    }

    @GetMapping("/api/notifications/count")
    @ResponseBody
    public ResponseEntity<?> getNotificationCount(@AuthenticationPrincipal UserDetails userDetails) {
        long count = eventService.countUnreadNotifications(userDetails.getUsername());
        return ResponseEntity.ok(Map.of("count", count));
    }
}
