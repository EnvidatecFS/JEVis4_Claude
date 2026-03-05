package org.jevis.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;

@Entity
@Table(name = "task_workers", indexes = {
    @Index(name = "idx_task_workers_identifier", columnList = "worker_identifier"),
    @Index(name = "idx_task_workers_pool", columnList = "worker_pool_id"),
    @Index(name = "idx_task_workers_status", columnList = "status")
})
public class TaskWorker {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Worker identifier is required")
    @Column(name = "worker_identifier", length = 255, unique = true, nullable = false)
    private String workerIdentifier;

    @Column(name = "worker_name", length = 255)
    private String workerName;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "worker_pool_id")
    private WorkerPool workerPool;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private WorkerStatus status = WorkerStatus.IDLE;

    @Column(length = 500)
    private String capabilities;

    @Column(name = "host_name", length = 255)
    private String hostName;

    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    @Column(name = "max_concurrent_jobs", nullable = false)
    private Integer maxConcurrentJobs = 1;

    @Column(name = "current_job_count", nullable = false)
    private Integer currentJobCount = 0;

    @Column(name = "last_heartbeat_at")
    private Instant lastHeartbeatAt;

    @Column(name = "api_key", length = 255)
    private String apiKey;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    public TaskWorker() {
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getWorkerIdentifier() { return workerIdentifier; }
    public void setWorkerIdentifier(String workerIdentifier) { this.workerIdentifier = workerIdentifier; }

    public String getWorkerName() { return workerName; }
    public void setWorkerName(String workerName) { this.workerName = workerName; }

    public WorkerPool getWorkerPool() { return workerPool; }
    public void setWorkerPool(WorkerPool workerPool) { this.workerPool = workerPool; }

    public WorkerStatus getStatus() { return status; }
    public void setStatus(WorkerStatus status) { this.status = status; }

    public String getCapabilities() { return capabilities; }
    public void setCapabilities(String capabilities) { this.capabilities = capabilities; }

    public String getHostName() { return hostName; }
    public void setHostName(String hostName) { this.hostName = hostName; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public Integer getMaxConcurrentJobs() { return maxConcurrentJobs; }
    public void setMaxConcurrentJobs(Integer maxConcurrentJobs) { this.maxConcurrentJobs = maxConcurrentJobs; }

    public Integer getCurrentJobCount() { return currentJobCount; }
    public void setCurrentJobCount(Integer currentJobCount) { this.currentJobCount = currentJobCount; }

    public Instant getLastHeartbeatAt() { return lastHeartbeatAt; }
    public void setLastHeartbeatAt(Instant lastHeartbeatAt) { this.lastHeartbeatAt = lastHeartbeatAt; }

    public String getApiKey() { return apiKey; }
    public void setApiKey(String apiKey) { this.apiKey = apiKey; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "TaskWorker{id=" + id + ", identifier='" + workerIdentifier + "', status=" + status + "}";
    }
}
