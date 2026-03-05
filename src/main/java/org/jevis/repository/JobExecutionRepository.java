package org.jevis.repository;

import org.jevis.model.JobExecution;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface JobExecutionRepository extends JpaRepository<JobExecution, Long> {

    List<JobExecution> findByJobIdOrderByExecutionNumberDesc(Long jobId);

    @Query("SELECT MAX(e.executionNumber) FROM JobExecution e WHERE e.job.id = :jobId")
    Optional<Integer> findMaxExecutionNumber(@Param("jobId") Long jobId);

    Optional<JobExecution> findByJobIdAndWorkerIdAndStatus(Long jobId, Long workerId, org.jevis.model.JobStatus status);
}
