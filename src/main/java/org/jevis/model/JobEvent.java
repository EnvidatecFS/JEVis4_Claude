package org.jevis.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;

@Entity
@Table(name = "job_events", indexes = {
    @Index(name = "idx_job_events_job", columnList = "job_id"),
    @Index(name = "idx_job_events_type", columnList = "event_type"),
    @Index(name = "idx_job_events_user_read", columnList = "notified_user, notification_read")
})
public class JobEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "job_id", nullable = false)
    private Job job;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "event_type", length = 30, nullable = false)
    private JobEventType eventType;

    @Column(name = "event_message", length = 500)
    private String eventMessage;

    @Column(name = "event_data", columnDefinition = "TEXT")
    private String eventData;

    @Column(name = "notified_user", length = 100)
    private String notifiedUser;

    @Column(name = "notification_read", nullable = false)
    private Boolean notificationRead = false;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    public JobEvent() {
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Job getJob() { return job; }
    public void setJob(Job job) { this.job = job; }

    public JobEventType getEventType() { return eventType; }
    public void setEventType(JobEventType eventType) { this.eventType = eventType; }

    public String getEventMessage() { return eventMessage; }
    public void setEventMessage(String eventMessage) { this.eventMessage = eventMessage; }

    public String getEventData() { return eventData; }
    public void setEventData(String eventData) { this.eventData = eventData; }

    public String getNotifiedUser() { return notifiedUser; }
    public void setNotifiedUser(String notifiedUser) { this.notifiedUser = notifiedUser; }

    public Boolean getNotificationRead() { return notificationRead; }
    public void setNotificationRead(Boolean notificationRead) { this.notificationRead = notificationRead; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
