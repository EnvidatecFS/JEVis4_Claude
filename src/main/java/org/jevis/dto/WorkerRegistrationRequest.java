package org.jevis.dto;

import jakarta.validation.constraints.NotBlank;

public class WorkerRegistrationRequest {

    @NotBlank(message = "Worker name is required")
    private String workerName;

    @NotBlank(message = "Pool name is required")
    private String poolName;

    private String capabilities;
    private String hostName;
    private String ipAddress;
    private Integer maxConcurrentJobs;

    public String getWorkerName() { return workerName; }
    public void setWorkerName(String workerName) { this.workerName = workerName; }

    public String getPoolName() { return poolName; }
    public void setPoolName(String poolName) { this.poolName = poolName; }

    public String getCapabilities() { return capabilities; }
    public void setCapabilities(String capabilities) { this.capabilities = capabilities; }

    public String getHostName() { return hostName; }
    public void setHostName(String hostName) { this.hostName = hostName; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public Integer getMaxConcurrentJobs() { return maxConcurrentJobs; }
    public void setMaxConcurrentJobs(Integer maxConcurrentJobs) { this.maxConcurrentJobs = maxConcurrentJobs; }
}
