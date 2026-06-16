package com.lucy.lms.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "RoomQuizAttempts")
public class RoomQuizAttempt {
    @Id
    @Column(name = "AttemptId", length = 50)
    private String attemptId;

    @Column(name = "QuizId", length = 50, nullable = false)
    private String quizId;

    @Column(name = "UserId", length = 50, nullable = false)
    private String userId;

    @Column(name = "ScorePercent", nullable = false)
    private BigDecimal scorePercent;

    @Column(name = "IsPassed", nullable = false)
    private Boolean isPassed;

    @Column(name = "AttemptStatus", length = 30, nullable = false)
    private String attemptStatus;

    @Column(name = "StartedAt")
    private LocalDateTime startedAt;

    @Column(name = "SubmittedAt")
    private LocalDateTime submittedAt;

    protected RoomQuizAttempt() {
    }

    public RoomQuizAttempt(String attemptId, String quizId, String userId) {
        this.attemptId = attemptId;
        this.quizId = quizId;
        this.userId = userId;
        this.scorePercent = BigDecimal.ZERO;
        this.isPassed = false;
        this.attemptStatus = "ASSIGNED";
    }

    public void start() {
        this.attemptStatus = "IN_PROGRESS";
        this.startedAt = LocalDateTime.now();
    }

    public void submit(BigDecimal scorePercent, boolean passed) {
        this.scorePercent = scorePercent;
        this.isPassed = passed;
        this.attemptStatus = "SUBMITTED";
        this.submittedAt = LocalDateTime.now();
    }

    public String getAttemptId() {
        return attemptId;
    }

    public BigDecimal getScorePercent() {
        return scorePercent;
    }

    public Boolean getIsPassed() {
        return isPassed;
    }

    public String getAttemptStatus() {
        return attemptStatus;
    }

    public LocalDateTime getStartedAt() {
        return startedAt;
    }

    public String getQuizId() {
        return quizId;
    }
}
