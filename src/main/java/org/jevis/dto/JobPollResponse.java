package org.jevis.dto;

public class JobPollResponse {

    private Long jobId;
    private String jobName;
    private String jobType;
    private String priority;
    private String jobParameters;
    private Long executionId;
    private Integer timeoutSeconds;

    public JobPollResponse() {
    }

    public Long getJobId() { return jobId; }
    public void setJobId(Long jobId) { this.jobId = jobId; }

    public String getJobName() { return jobName; }
    public void setJobName(String jobName) { this.jobName = jobName; }

    public String getJobType() { return jobType; }
    public void setJobType(String jobType) { this.jobType = jobType; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getJobParameters() { return jobParameters; }
    public void setJobParameters(String jobParameters) { this.jobParameters = jobParameters; }

    public Long getExecutionId() { return executionId; }
    public void setExecutionId(Long executionId) { this.executionId = executionId; }

    public Integer getTimeoutSeconds() { return timeoutSeconds; }
    public void setTimeoutSeconds(Integer timeoutSeconds) { this.timeoutSeconds = timeoutSeconds; }
}
