package com.lucy.models;

import java.util.Date;

public class LearningSessions {
    private String LearningSessionsId;
    private String UserId;
    private String LevelId;
    private String SubLevelId;
    private Date StartedAt;
    private Date EndedAt;
    private Integer DurationSeconds;
    private String SessionStatus;

    public LearningSessions() {
    }

    public LearningSessions(String LearningSessionsId, String UserId, String LevelId, String SubLevelId, Date StartedAt,
            Date EndedAt, Integer DurationSeconds, String SessionStatus) {
        this.LearningSessionsId = LearningSessionsId;
        this.UserId = UserId;
        this.LevelId = LevelId;
        this.SubLevelId = SubLevelId;
        this.StartedAt = StartedAt;
        this.EndedAt = EndedAt;
        this.DurationSeconds = DurationSeconds;
        this.SessionStatus = SessionStatus;
    }

    public String getLearningSessionsId() {
        return this.LearningSessionsId;
    }

    public void setLearningSessionsId(String LearningSessionsId) {
        this.LearningSessionsId = LearningSessionsId;
    }

    public String getUserId() {
        return this.UserId;
    }

    public void setUserId(String UserId) {
        this.UserId = UserId;
    }

    public String getLevelId() {
        return this.LevelId;
    }

    public void setLevelId(String LevelId) {
        this.LevelId = LevelId;
    }

    public String getSubLevelId() {
        return this.SubLevelId;
    }

    public void setSubLevelId(String SubLevelId) {
        this.SubLevelId = SubLevelId;
    }

    public Date getStartedAt() {
        return this.StartedAt;
    }

    public void setStartedAt(Date StartedAt) {
        this.StartedAt = StartedAt;
    }

    public Date getEndedAt() {
        return this.EndedAt;
    }

    public void setEndedAt(Date EndedAt) {
        this.EndedAt = EndedAt;
    }

    public Integer getDurationSeconds() {
        return this.DurationSeconds;
    }

    public void setDurationSeconds(Integer DurationSeconds) {
        this.DurationSeconds = DurationSeconds;
    }

    public String getSessionStatus() {
        return this.SessionStatus;
    }

    public void setSessionStatus(String SessionStatus) {
        this.SessionStatus = SessionStatus;
    }
}