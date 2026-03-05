package org.jevis.dto;

public class JobCompleteRequest {

    private Long executionId;
    private String result;

    public Long getExecutionId() { return executionId; }
    public void setExecutionId(Long executionId) { this.executionId = executionId; }

    public String getResult() { return result; }
    public void setResult(String result) { this.result = result; }
}
