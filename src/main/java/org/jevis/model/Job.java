package org.jevis.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;

@Entity
@Table(name = "jobs", indexes = {
    @Index(name = "idx_jobs_status", columnList = "status"),
    @Index(name = "idx_jobs_type", columnList = "job_type"),
    @Index(name = "idx_jobs_priority_scheduled", columnList = "priority, scheduled_for"),
    @Index(name = "idx_jobs_worker_pool", columnList = "worker_pool_id"),
    @Index(name = "idx_jobs_parent", columnList = "parent_job_id")
})
public class Job {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Job name is required")
    @Column(name = "job_name", length = 255, nullable = false)
    private String jobName;

    @NotNull(message = "Job type is required")
    @Enumerated(EnumType.STRING)
    @Column(name = "job_type", length = 50, nullable = false)
    private JobType jobType;

    @NotNull(message = "Status is required")
    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private JobStatus status = JobStatus.CREATED;

    @NotNull(message = "Priority is required")
    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private JobPriority priority = JobPriority.NORMAL;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "worker_pool_id")
    private WorkerPool workerPool;

    @Column(name = "cron_expression", length = 100)
    private String cronExpression;

    @Column(name = "scheduled_for")
    private Instant scheduledFor;

    @Column(name = "is_recurring", nullable = false)
    private Boolean isRecurring = false;

    @Column(name = "timeout_seconds", nullable = false)
    private Integer timeoutSeconds = 3600;

    @Column(name = "max_retry_attempts", nullable = false)
    private Integer maxRetryAttempts = 3;

    @Column(name = "retry_count", nullable = false)
    private Integer retryCount = 0;

    @Column(name = "retry_backoff_seconds", nullable = false)
    private Integer retryBackoffSeconds = 300;

    @Column(name = "job_parameters", columnDefinition = "TEXT")
    private String jobParameters;

    @Column(name = "created_by", length = 100)
    private String createdBy;

    @Column(name = "parent_job_id")
    private Long parentJobId;

    @Enumerated(EnumType.STRING)
    @Column(name = "on_success_job_type", length = 50)
    private JobType onSuccessJobType;

    @Column(name = "on_success_job_params", columnDefinition = "TEXT")
    private String onSuccessJobParams;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    public Job() {
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getJobName() { return jobName; }
    public void setJobName(String jobName) { this.jobName = jobName; }

    public JobType getJobType() { return jobType; }
    public void setJobType(JobType jobType) { this.jobType = jobType; }

    public JobStatus getStatus() { return status; }
    public void setStatus(JobStatus status) { this.status = status; }

    public JobPriority getPriority() { return priority; }
    public void setPriority(JobPriority priority) { this.priority = priority; }

    public WorkerPool getWorkerPool() { return workerPool; }
    public void setWorkerPool(WorkerPool workerPool) { this.workerPool = workerPool; }

    public String getCronExpression() { return cronExpression; }
    public void setCronExpression(String cronExpression) { this.cronExpression = cronExpression; }

    public Instant getScheduledFor() { return scheduledFor; }
    public void setScheduledFor(Instant scheduledFor) { this.scheduledFor = scheduledFor; }

    public Boolean getIsRecurring() { return isRecurring; }
    public void setIsRecurring(Boolean isRecurring) { this.isRecurring = isRecurring; }

    public Integer getTimeoutSeconds() { return timeoutSeconds; }
    public void setTimeoutSeconds(Integer timeoutSeconds) { this.timeoutSeconds = timeoutSeconds; }

    public Integer getMaxRetryAttempts() { return maxRetryAttempts; }
    public void setMaxRetryAttempts(Integer maxRetryAttempts) { this.maxRetryAttempts = maxRetryAttempts; }

    public Integer getRetryCount() { return retryCount; }
    public void setRetryCount(Integer retryCount) { this.retryCount = retryCount; }

    public Integer getRetryBackoffSeconds() { return retryBackoffSeconds; }
    public void setRetryBackoffSeconds(Integer retryBackoffSeconds) { this.retryBackoffSeconds = retryBackoffSeconds; }

    public String getJobParameters() { return jobParameters; }
    public void setJobParameters(String jobParameters) { this.jobParameters = jobParameters; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public Long getParentJobId() { return parentJobId; }
    public void setParentJobId(Long parentJobId) { this.parentJobId = parentJobId; }

    public JobType getOnSuccessJobType() { return onSuccessJobType; }
    public void setOnSuccessJobType(JobType onSuccessJobType) { this.onSuccessJobType = onSuccessJobType; }

    public String getOnSuccessJobParams() { return onSuccessJobParams; }
    public void setOnSuccessJobParams(String onSuccessJobParams) { this.onSuccessJobParams = onSuccessJobParams; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "Job{id=" + id + ", jobName='" + jobName + "', type=" + jobType + ", status=" + status + ", priority=" + priority + "}";
    }
}
