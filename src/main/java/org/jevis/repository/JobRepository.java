package org.jevis.repository;

import org.jevis.model.Job;
import org.jevis.model.JobPriority;
import org.jevis.model.JobStatus;
import org.jevis.model.JobType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;

public interface JobRepository extends JpaRepository<Job, Long> {

    List<Job> findByStatus(JobStatus status);

    List<Job> findByJobType(JobType jobType);

    @Query("SELECT j FROM Job j WHERE j.status = :status AND j.workerPool.id = :poolId " +
           "AND (j.scheduledFor IS NULL OR j.scheduledFor <= :now) " +
           "ORDER BY j.priority ASC, j.scheduledFor ASC, j.createdAt ASC")
    List<Job> findQueuedJobsForPool(@Param("poolId") Long poolId, @Param("status") JobStatus status, @Param("now") Instant now);

    @Query("SELECT j FROM Job j WHERE j.status = 'RUNNING' AND j.updatedAt < :timeout")
    List<Job> findTimedOutJobs(@Param("timeout") Instant timeout);

    @Query("SELECT j FROM Job j WHERE j.status = 'RETRY_SCHEDULED' AND j.scheduledFor <= :now")
    List<Job> findDueRetryJobs(@Param("now") Instant now);

    @Query("SELECT j FROM Job j WHERE j.isRecurring = true AND j.cronExpression IS NOT NULL")
    List<Job> findRecurringJobs();

    @Query("SELECT j FROM Job j WHERE " +
           "(:search IS NULL OR :search = '' OR LOWER(j.jobName) LIKE LOWER(CONCAT('%', :search, '%'))) AND " +
           "(:status IS NULL OR j.status = :status) AND " +
           "(:jobType IS NULL OR j.jobType = :jobType) AND " +
           "(:poolId IS NULL OR j.workerPool.id = :poolId)")
    Page<Job> searchJobs(@Param("search") String search,
                         @Param("status") JobStatus status,
                         @Param("jobType") JobType jobType,
                         @Param("poolId") Long poolId,
                         Pageable pageable);

    long countByStatus(JobStatus status);

    @Query("SELECT j FROM Job j WHERE j.status = 'RUNNING'")
    List<Job> findRunningJobs();
}
