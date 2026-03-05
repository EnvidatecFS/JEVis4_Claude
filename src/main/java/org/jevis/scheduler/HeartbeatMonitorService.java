package org.jevis.scheduler;

import org.jevis.service.WorkerRegistrationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

@Service
public class HeartbeatMonitorService {

    private static final Logger log = LoggerFactory.getLogger(HeartbeatMonitorService.class);

    private final WorkerRegistrationService workerRegistrationService;

    @Value("${jevis.jobs.heartbeat-timeout-minutes:5}")
    private int heartbeatTimeoutMinutes;

    public HeartbeatMonitorService(WorkerRegistrationService workerRegistrationService) {
        this.workerRegistrationService = workerRegistrationService;
    }

    @Scheduled(fixedDelayString = "60000")
    public void checkHeartbeats() {
        Instant threshold = Instant.now().minus(heartbeatTimeoutMinutes, ChronoUnit.MINUTES);
        workerRegistrationService.markStaleWorkersOffline(threshold);
    }
}
