package com.lucy.backend.content.learner.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "LearningSessions")
public class LearningSession {

    @Id
    @Column(name = "SessionId", length = 50)
    private String sessionId;

    @Column(name = "UserId", length = 50)
    private String userId;

    @Column(name = "LevelNumber", length = 50)
    private String levelNumber;

    public LearningSession() {
    }

    public LearningSession(String sessionId, String userId, String levelNumber) {
        this.sessionId = sessionId;
        this.userId = userId;
        this.levelNumber = levelNumber;
    }

    // Getters and Setters
    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getLevelNumber() {
        return levelNumber;
    }

    public void setLevelNumber(String levelNumber) {
        this.levelNumber = levelNumber;
    }
}