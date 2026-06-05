package com.lucy.lms.mentor.dto;

public class RequestUpgradeToCreatorRequest {

    private String mentorUserId;
    private String requestReason;

    public RequestUpgradeToCreatorRequest() {
    }

    public String getMentorUserId() {
        return mentorUserId;
    }

    public void setMentorUserId(String mentorUserId) {
        this.mentorUserId = mentorUserId;
    }

    public String getRequestReason() {
        return requestReason;
    }

    public void setRequestReason(String requestReason) {
        this.requestReason = requestReason;
    }
}
