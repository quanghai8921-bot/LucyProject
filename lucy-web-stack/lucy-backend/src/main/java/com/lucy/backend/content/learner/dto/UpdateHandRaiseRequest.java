package com.lucy.backend.content.learner.dto;

public class UpdateHandRaiseRequest {

    private String userId;
    private Boolean raised;

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public Boolean getRaised() {
        return raised;
    }

    public void setRaised(Boolean raised) {
        this.raised = raised;
    }
}
