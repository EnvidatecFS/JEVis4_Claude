package org.jevis.service;

import org.jevis.model.TaskWorker;
import org.jevis.model.WorkerPool;
import org.jevis.model.WorkerStatus;
import org.jevis.repository.TaskWorkerRepository;
import org.jevis.repository.WorkerPoolRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class WorkerRegistrationService {

    private static final Logger log = LoggerFactory.getLogger(WorkerRegistrationService.class);

    private final TaskWorkerRepository workerRepository;
    private final WorkerPoolRepository poolRepository;

    public WorkerRegistrationService(TaskWorkerRepository workerRepository, WorkerPoolRepository poolRepository) {
        this.workerRepository = workerRepository;
        this.poolRepository = poolRepository;
    }

    @Transactional
    public TaskWorker registerWorker(String workerName, String poolName, String capabilities,
                                      String hostName, String ipAddress, Integer maxConcurrentJobs) {
        WorkerPool pool = poolRepository.findByPoolName(poolName)
            .orElseThrow(() -> new IllegalArgumentException("Worker pool not found: " + poolName));

        String identifier = UUID.randomUUID().toString();
        String apiKey = UUID.randomUUID().toString();

        TaskWorker worker = new TaskWorker();
        worker.setWorkerIdentifier(identifier);
        worker.setWorkerName(workerName);
        worker.setWorkerPool(pool);
        worker.setCapabilities(capabilities);
        worker.setHostName(hostName);
        worker.setIpAddress(ipAddress);
        worker.setMaxConcurrentJobs(maxConcurrentJobs != null ? maxConcurrentJobs : 1);
        worker.setStatus(WorkerStatus.IDLE);
        worker.setLastHeartbeatAt(Instant.now());
        worker.setApiKey(apiKey);

        worker = workerRepository.save(worker);
        log.info("Worker registered: {} ({}), pool: {}", worker.getWorkerName(), worker.getWorkerIdentifier(), poolName);
        return worker;
    }

    @Transactional
    public TaskWorker heartbeat(Long workerId) {
        TaskWorker worker = workerRepository.findById(workerId)
            .orElseThrow(() -> new IllegalArgumentException("Worker not found: " + workerId));
        worker.setLastHeartbeatAt(Instant.now());
        if (worker.getStatus() == WorkerStatus.OFFLINE) {
            worker.setStatus(worker.getCurrentJobCount() > 0 ? WorkerStatus.BUSY : WorkerStatus.IDLE);
        }
        return workerRepository.save(worker);
    }

    @Transactional
    public void deregister(Long workerId) {
        TaskWorker worker = workerRepository.findById(workerId)
            .orElseThrow(() -> new IllegalArgumentException("Worker not found: " + workerId));
        worker.setStatus(WorkerStatus.OFFLINE);
        workerRepository.save(worker);
        log.info("Worker deregistered: {} ({})", worker.getWorkerName(), worker.getWorkerIdentifier());
    }

    @Transactional
    public void markStaleWorkersOffline(Instant threshold) {
        List<TaskWorker> staleWorkers = workerRepository.findStaleWorkers(threshold);
        for (TaskWorker worker : staleWorkers) {
            log.warn("Worker {} has not sent heartbeat since {}, marking OFFLINE",
                worker.getWorkerIdentifier(), worker.getLastHeartbeatAt());
            worker.setStatus(WorkerStatus.OFFLINE);
            workerRepository.save(worker);
        }
    }

    public Optional<TaskWorker> findById(Long id) {
        return workerRepository.findById(id);
    }

    public Optional<TaskWorker> findByApiKey(String apiKey) {
        return workerRepository.findByApiKey(apiKey);
    }

    public List<TaskWorker> getAllWorkers() {
        return workerRepository.findAll();
    }
}
