package org.jevis.scheduler;

import org.jevis.model.*;
import org.jevis.repository.JobRepository;
import org.jevis.repository.WorkerPoolRepository;
import org.jevis.service.JobQueueService;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.quartz.QuartzJobBean;
import org.springframework.stereotype.Component;

@Component
public class QuartzJobExecutor extends QuartzJobBean {

    private static final Logger log = LoggerFactory.getLogger(QuartzJobExecutor.class);

    private final JobRepository jobRepository;
    private final JobQueueService jobQueueService;
    private final WorkerPoolRepository poolRepository;

    public QuartzJobExecutor(JobRepository jobRepository, JobQueueService jobQueueService,
                              WorkerPoolRepository poolRepository) {
        this.jobRepository = jobRepository;
        this.jobQueueService = jobQueueService;
        this.poolRepository = poolRepository;
    }

    @Override
    protected void executeInternal(JobExecutionContext context) throws JobExecutionException {
        String jobIdStr = context.getMergedJobDataMap().getString("jobId");
        if (jobIdStr == null) {
            log.error("No jobId found in Quartz job data");
            return;
        }

        Long jobId = Long.parseLong(jobIdStr);
        jobRepository.findById(jobId).ifPresent(job -> {
            if (job.getIsRecurring()) {
                // Create a new instance for this scheduled run
                WorkerPool pool = job.getWorkerPool();
                jobQueueService.createAndEnqueue(
                    job.getJobName(),
                    job.getJobType(),
                    job.getPriority(),
                    pool,
                    job.getJobParameters(),
                    "scheduler"
                );
                log.info("Scheduled recurring job created: {} (type: {})", job.getJobName(), job.getJobType());
            }
        });
    }
}
