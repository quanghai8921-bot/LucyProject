package com.lucy.models;

import java.util.Date;
import java.math.BigDecimal;

public class UserProgress {
    private String ProgressId;
    private String UserId;
    private String LevelId;
    private String SubLevelId;
    private BigDecimal ProgressPercent;
    private String Status;
    private Date LastAccessedAt;
    private Date CompletedAt;

    public UserProgress() {
    }

    public UserProgress(String ProgressId, String UserId, String LevelId, String SubLevelId, BigDecimal ProgressPercent,
            String Status, Date LastAccessedAt, Date CompletedAt) {
        this.ProgressId = ProgressId;
        this.UserId = UserId;
        this.LevelId = LevelId;
        this.SubLevelId = SubLevelId;
        this.ProgressPercent = ProgressPercent;
        this.Status = Status;
        this.LastAccessedAt = LastAccessedAt;
        this.CompletedAt = CompletedAt;
    }

    public String getProgressId() {
        return this.ProgressId;
    }

    public void setProgressId(String ProgressId) {
        this.ProgressId = ProgressId;
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

    public BigDecimal getProgressPercent() {
        return this.ProgressPercent;
    }

    public void setProgressPercent(BigDecimal ProgressPercent) {
        this.ProgressPercent = ProgressPercent;
    }

    public String getStatus() {
        return this.Status;
    }

    public void setStatus(String Status) {
        this.Status = Status;
    }

    public Date getLastAccessedAt() {
        return this.LastAccessedAt;
    }

    public void setLastAccessedAt(Date LastAccessedAt) {
        this.LastAccessedAt = LastAccessedAt;
    }

    public Date getCompletedAt() {
        return this.CompletedAt;
    }

    public void setCompletedAt(Date CompletedAt) {
        this.CompletedAt = CompletedAt;
    }
}