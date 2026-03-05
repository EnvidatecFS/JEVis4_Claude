package org.jevis.repository;

import org.jevis.model.TaskWorker;
import org.jevis.model.WorkerStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

public interface TaskWorkerRepository extends JpaRepository<TaskWorker, Long> {

    Optional<TaskWorker> findByWorkerIdentifier(String workerIdentifier);

    Optional<TaskWorker> findByApiKey(String apiKey);

    List<TaskWorker> findByStatus(WorkerStatus status);

    @Query("SELECT w FROM TaskWorker w WHERE w.workerPool.id = :poolId AND w.status = :status " +
           "AND w.currentJobCount < w.maxConcurrentJobs")
    List<TaskWorker> findAvailableWorkersInPool(@Param("poolId") Long poolId, @Param("status") WorkerStatus status);

    @Query("SELECT w FROM TaskWorker w WHERE w.status != 'OFFLINE' AND w.lastHeartbeatAt < :threshold")
    List<TaskWorker> findStaleWorkers(@Param("threshold") Instant threshold);
}
