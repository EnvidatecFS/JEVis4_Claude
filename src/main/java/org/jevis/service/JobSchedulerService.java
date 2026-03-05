package org.jevis.service;

import org.jevis.model.Job;
import org.jevis.scheduler.QuartzJobExecutor;
import org.quartz.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class JobSchedulerService {

    private static final Logger log = LoggerFactory.getLogger(JobSchedulerService.class);

    private final Scheduler scheduler;

    public JobSchedulerService(Scheduler scheduler) {
        this.scheduler = scheduler;
    }

    public void scheduleRecurringJob(Job job) {
        if (job.getCronExpression() == null || job.getCronExpression().isBlank()) {
            throw new IllegalArgumentException("Cron expression is required for recurring jobs");
        }

        try {
            String jobKey = "job-" + job.getId();
            String triggerKey = "trigger-" + job.getId();

            JobDetail jobDetail = JobBuilder.newJob(QuartzJobExecutor.class)
                .withIdentity(jobKey, "jevis-jobs")
                .usingJobData("jobId", String.valueOf(job.getId()))
                .storeDurably()
                .build();

            CronTrigger trigger = TriggerBuilder.newTrigger()
                .withIdentity(triggerKey, "jevis-triggers")
                .withSchedule(CronScheduleBuilder.cronSchedule(job.getCronExpression()))
                .build();

            if (scheduler.checkExists(new JobKey(jobKey, "jevis-jobs"))) {
                scheduler.rescheduleJob(new TriggerKey(triggerKey, "jevis-triggers"), trigger);
                log.info("Rescheduled recurring job: {} with cron: {}", job.getJobName(), job.getCronExpression());
            } else {
                scheduler.scheduleJob(jobDetail, trigger);
                log.info("Scheduled recurring job: {} with cron: {}", job.getJobName(), job.getCronExpression());
            }
        } catch (SchedulerException e) {
            log.error("Failed to schedule job: {}", job.getJobName(), e);
            throw new RuntimeException("Failed to schedule job", e);
        }
    }

    public void unscheduleJob(Long jobId) {
        try {
            String triggerKey = "trigger-" + jobId;
            scheduler.unscheduleJob(new TriggerKey(triggerKey, "jevis-triggers"));
            log.info("Unscheduled job: {}", jobId);
        } catch (SchedulerException e) {
            log.error("Failed to unschedule job: {}", jobId, e);
        }
    }
}
