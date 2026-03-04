package org.jevis.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.time.LocalDate;

/**
 * Entity representing a CSR (Corporate Social Responsibility) action plan item.
 */
@Entity
@Table(name = "csr_actions", indexes = {
    @Index(name = "idx_csr_actions_category", columnList = "category"),
    @Index(name = "idx_csr_actions_status", columnList = "status"),
    @Index(name = "idx_csr_actions_deadline", columnList = "deadline")
})
public class CsrAction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Title is required")
    @Column(length = 255, nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @NotNull(message = "Category is required")
    @Enumerated(EnumType.STRING)
    @Column(length = 50, nullable = false)
    private CsrCategory category;

    @NotNull(message = "Status is required")
    @Enumerated(EnumType.STRING)
    @Column(length = 50, nullable = false)
    private CsrStatus status = CsrStatus.PLANNED;

    @Column(name = "responsible_person", length = 255)
    private String responsiblePerson;

    @Column(name = "deadline")
    private LocalDate deadline;

    @Min(0)
    @Max(100)
    @Column(name = "progress_percent")
    private Integer progressPercent = 0;

    @Column(length = 20)
    private String priority = "MEDIUM";

    @Column(name = "estimated_impact", columnDefinition = "TEXT")
    private String estimatedImpact;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Column(name = "created_by", length = 255)
    private String createdBy;

    // Constructors
    public CsrAction() {
    }

    public CsrAction(String title, CsrCategory category) {
        this.title = title;
        this.category = category;
        this.status = CsrStatus.PLANNED;
    }

    // Getters and setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public CsrCategory getCategory() {
        return category;
    }

    public void setCategory(CsrCategory category) {
        this.category = category;
    }

    public CsrStatus getStatus() {
        return status;
    }

    public void setStatus(CsrStatus status) {
        this.status = status;
    }

    public String getResponsiblePerson() {
        return responsiblePerson;
    }

    public void setResponsiblePerson(String responsiblePerson) {
        this.responsiblePerson = responsiblePerson;
    }

    public LocalDate getDeadline() {
        return deadline;
    }

    public void setDeadline(LocalDate deadline) {
        this.deadline = deadline;
    }

    public Integer getProgressPercent() {
        return progressPercent;
    }

    public void setProgressPercent(Integer progressPercent) {
        this.progressPercent = progressPercent;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public String getEstimatedImpact() {
        return estimatedImpact;
    }

    public void setEstimatedImpact(String estimatedImpact) {
        this.estimatedImpact = estimatedImpact;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    @Override
    public String toString() {
        return "CsrAction{" +
               "id=" + id +
               ", title='" + title + '\'' +
               ", category=" + category +
               ", status=" + status +
               ", deadline=" + deadline +
               ", progressPercent=" + progressPercent +
               '}';
    }
}
