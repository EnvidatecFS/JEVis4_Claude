package org.jevis.dto;

public class WorkerRegistrationResponse {

    private Long workerId;
    private String workerIdentifier;
    private String apiKey;

    public WorkerRegistrationResponse(Long workerId, String workerIdentifier, String apiKey) {
        this.workerId = workerId;
        this.workerIdentifier = workerIdentifier;
        this.apiKey = apiKey;
    }

    public Long getWorkerId() { return workerId; }
    public void setWorkerId(Long workerId) { this.workerId = workerId; }

    public String getWorkerIdentifier() { return workerIdentifier; }
    public void setWorkerIdentifier(String workerIdentifier) { this.workerIdentifier = workerIdentifier; }

    public String getApiKey() { return apiKey; }
    public void setApiKey(String apiKey) { this.apiKey = apiKey; }
}
