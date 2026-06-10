package com.lucy.lms.learner.dto;

public class AttendanceRequest {
    private String userId;
    private String levelId;
    private String subLevelId;

    public String getUserId() {
        return userId;
    }

    public String getLevelId() {
        return levelId;
    }

    public String getSubLevelId() {
        return subLevelId;
    }
}
