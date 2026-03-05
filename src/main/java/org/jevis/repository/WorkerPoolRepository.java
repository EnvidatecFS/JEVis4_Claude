package org.jevis.repository;

import org.jevis.model.WorkerPool;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface WorkerPoolRepository extends JpaRepository<WorkerPool, Long> {

    Optional<WorkerPool> findByPoolName(String poolName);

    Optional<WorkerPool> findByIsDefaultTrue();
}
