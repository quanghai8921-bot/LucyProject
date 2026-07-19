package com.lucy.backend.content.learner.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "AttendanceChecks")
public class AttendanceCheck {
    @Id
    @Column(name = "CheckId", length = 50)
    private String checkId;

    @Column(name = "LearningSessionId", length = 50, nullable = false)
    private String learningSessionId;

    @Column(name = "AskedAt", nullable = false)
    private LocalDateTime askedAt;

    @Column(name = "ConfirmedAt")
    private LocalDateTime confirmedAt;

    @Column(name = "IsConfirmed", nullable = false)
    private Boolean isConfirmed;

    protected AttendanceCheck() {
    }

    public AttendanceCheck(String checkId, String learningSessionId) {
        this.checkId = checkId;
        this.learningSessionId = learningSessionId;
        this.askedAt = LocalDateTime.now();
        this.isConfirmed = false;
    }

    public void confirm() {
        if (!Boolean.TRUE.equals(isConfirmed)) {
            this.isConfirmed = true;
            this.confirmedAt = LocalDateTime.now();
        }
    }

    public String getCheckId() {
        return checkId;
    }

    public String getLearningSessionId() {
        return learningSessionId;
    }

    public Boolean getIsConfirmed() {
        return isConfirmed;
    }
}
