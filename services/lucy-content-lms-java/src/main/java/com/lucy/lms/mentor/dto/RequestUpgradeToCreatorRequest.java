package com.lucy.lms.mentor.dto;

public class RequestUpgradeToCreatorRequest {

    private String mentorUserId;
    private String requestReason;

    public String getMentorUserId() {
        return mentorUserId;
    }

    public String getRequestReason() {
        return requestReason;
    }
}
