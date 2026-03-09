package org.jevis.service;

import org.jevis.model.*;
import org.jevis.repository.JobRepository;
import org.jevis.repository.NodeRedDataPointRepository;
import org.jevis.repository.WorkerPoolRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Registriert beim Anwendungsstart alle aktiven NodeRed-Messpunkte
 * als wiederkehrende Quartz-Jobs basierend auf ihrem fetch_interval_minutes.
 */
@Service
public class DataPointSchedulerService {

    private static final Logger log = LoggerFactory.getLogger(DataPointSchedulerService.class);

    private final NodeRedDataPointRepository dataPointRepository;
    private final JobRepository jobRepository;
    private final WorkerPoolRepository poolRepository;
    private final JobSchedulerService schedulerService;

    public DataPointSchedulerService(NodeRedDataPointRepository dataPointRepository,
                                     JobRepository jobRepository,
                                     WorkerPoolRepository poolRepository,
                                     JobSchedulerService schedulerService) {
        this.dataPointRepository = dataPointRepository;
        this.jobRepository = jobRepository;
        this.poolRepository = poolRepository;
        this.schedulerService = schedulerService;
    }

    /**
     * Wird nach vollständigem Start der Anwendung aufgerufen.
     * Registriert alle aktiven Messpunkte im Quartz-Scheduler.
     */
    @EventListener(ApplicationReadyEvent.class)
    @Transactional
    public void onApplicationReady() {
        log.info("Initialisiere automatische Messpunkt-Abfrage-Jobs...");
        scheduleAllActiveDataPoints();
    }

    /**
     * Lädt alle aktiven Messpunkte und plant deren Abfrage-Jobs.
     */
    @Transactional
    public void scheduleAllActiveDataPoints() {
        List<NodeRedDataPoint> activePoints = dataPointRepository.findByIsActiveTrue();
        int scheduled = 0;
        for (NodeRedDataPoint dp : activePoints) {
            try {
                scheduleDataPoint(dp);
                scheduled++;
            } catch (Exception e) {
                log.error("Fehler beim Planen von Messpunkt {} (ID={}): {}", dp.getRemoteName(), dp.getId(), e.getMessage());
            }
        }
        log.info("{} von {} aktiven Messpunkten erfolgreich geplant", scheduled, activePoints.size());
    }

    /**
     * Plant einen einzelnen Messpunkt als wiederkehrenden Job.
     * Erstellt den Job falls noch nicht vorhanden, aktualisiert Cron und Namen bei Änderung.
     */
    @Transactional
    public void scheduleDataPoint(NodeRedDataPoint dp) {
        String jobName = buildJobName(dp);
        String cronExpression = buildCronExpression(dp.getFetchIntervalMinutes());
        String paramFragment = "\"dataPointId\":" + dp.getId();

        Job job = jobRepository.findRecurringByParameterFragment(paramFragment)
                .orElseGet(() -> createRecurringFetchJob(dp, jobName, cronExpression));

        boolean changed = false;

        // Namen synchronisieren falls Gerät/Messpunkt umbenannt wurde
        if (!jobName.equals(job.getJobName())) {
            log.info("Aktualisiere Job-Namen für Messpunkt {} von '{}' auf '{}'",
                    dp.getId(), job.getJobName(), jobName);
            job.setJobName(jobName);
            changed = true;
        }

        // Cron aktualisieren falls sich das Intervall geändert hat
        if (!cronExpression.equals(job.getCronExpression())) {
            log.info("Aktualisiere Cron-Ausdruck für Messpunkt {} von '{}' auf '{}'",
                    dp.getRemoteName(), job.getCronExpression(), cronExpression);
            job.setCronExpression(cronExpression);
            changed = true;
        }

        if (changed) {
            job = jobRepository.save(job);
        }

        schedulerService.scheduleRecurringJob(job);
        log.debug("Messpunkt {} (ID={}) geplant mit Intervall {}min (Cron: '{}')",
                dp.getRemoteName(), dp.getId(), dp.getFetchIntervalMinutes(), cronExpression);
    }

    /**
     * Entfernt einen Messpunkt-Job aus dem Scheduler (z.B. bei Deaktivierung).
     */
    @Transactional
    public void unscheduleDataPoint(Long dataPointId) {
        String paramFragment = "\"dataPointId\":" + dataPointId;
        jobRepository.findRecurringByParameterFragment(paramFragment).ifPresent(job -> {
            schedulerService.unscheduleJob(job.getId());
            log.info("Abfrage-Job für Messpunkt ID={} deaktiviert", dataPointId);
        });
    }

    /**
     * Neu planen nach Änderung (z.B. anderes Intervall oder Reaktivierung).
     */
    @Transactional
    public void rescheduleDataPoint(NodeRedDataPoint dp) {
        if (Boolean.TRUE.equals(dp.getIsActive())) {
            scheduleDataPoint(dp);
        } else {
            unscheduleDataPoint(dp.getId());
        }
    }

    private String buildJobName(NodeRedDataPoint dp) {
        String device = dp.getDevice() != null ? dp.getDevice().getDeviceName() : "Unknown Device";
        String point  = dp.getRemoteName() != null ? dp.getRemoteName() : dp.getRemoteId();
        return device + " - " + point;
    }

    private Job createRecurringFetchJob(NodeRedDataPoint dp, String jobName, String cronExpression) {
        WorkerPool pool = poolRepository.findByPoolName("data-fetch-pool")
                .orElseGet(() -> poolRepository.findByIsDefaultTrue()
                        .orElseThrow(() -> new IllegalStateException("Kein Worker-Pool gefunden")));

        Job job = new Job();
        job.setJobName(jobName);
        job.setJobType(JobType.DATA_FETCH);
        job.setPriority(JobPriority.NORMAL);
        job.setStatus(JobStatus.CREATED);
        job.setIsRecurring(true);
        job.setCronExpression(cronExpression);
        job.setWorkerPool(pool);
        job.setJobParameters("{\"dataPointId\":" + dp.getId() + ",\"scope\":\"datapoint\"}");
        job.setCreatedBy("scheduler");
        job.setTimeoutSeconds(300); // 5 Minuten Timeout für Datenimport
        job.setMaxRetryAttempts(3);

        Job saved = jobRepository.save(job);
        log.info("Neuer wiederkehrender Abfrage-Job erstellt: '{}' (ID={}, Cron='{}')",
                jobName, saved.getId(), cronExpression);
        return saved;
    }

    /**
     * Erzeugt einen Quartz-CRON-Ausdruck (6 Felder: Sekunden Minuten Stunden Tag Monat Wochentag)
     * aus einem Intervall in Minuten.
     *
     * Beispiele:
     *  15 min  =&gt; "0 SLASH15 * * * ?"
     *  60 min  =&gt; "0 0 * * * ?"
     *  120 min =&gt; "0 0 SLASH2 * * ?"
     * (SLASH steht für den Cron-Divisions-Operator)
     */
    private String buildCronExpression(int intervalMinutes) {
        if (intervalMinutes <= 0) {
            throw new IllegalArgumentException("Intervall muss größer als 0 sein");
        }
        if (intervalMinutes >= 60 && intervalMinutes % 60 == 0) {
            int intervalHours = intervalMinutes / 60;
            if (intervalHours == 1) {
                return "0 0 * * * ?";
            }
            return "0 0 */" + intervalHours + " * * ?";
        }
        return "0 */" + intervalMinutes + " * * * ?";
    }
}
