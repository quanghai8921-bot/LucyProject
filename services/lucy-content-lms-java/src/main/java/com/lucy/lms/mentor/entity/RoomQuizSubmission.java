package com.lucy.lms.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Lượt thử làm bài kiểm tra của learner (RoomQuizAttempts).
 */
@Entity
@Table(name = "RoomQuizAttempts")
public class RoomQuizSubmission {

    @Id
    @Column(name = "AttemptId", length = 50)
    private String submissionId;

    @Column(name = "QuizId", length = 50, nullable = false)
    private String quizId;

    @Column(name = "UserId", length = 50, nullable = false)
    private String learnerId;

    @Column(name = "ScorePercent", nullable = false)
    private BigDecimal scorePercent;

    @Column(name = "IsPassed", nullable = false)
    private Integer isPassed;

    @Column(name = "StartedAt", nullable = false)
    private LocalDateTime startedAt;

    @Column(name = "SubmittedAt")
    private LocalDateTime submittedAt;

    /** Lưu trữ trong bộ nhớ tạm (không map xuống DB). */
    @Transient
    private Integer correctAnswers;

    @Transient
    private Integer totalQuestions;

    protected RoomQuizSubmission() {
    }

    public RoomQuizSubmission(String submissionId, String quizId, String learnerId,
                              BigDecimal scorePercent, Integer isPassed, LocalDateTime startedAt,
                              LocalDateTime submittedAt) {
        this.submissionId = submissionId;
        this.quizId = quizId;
        this.learnerId = learnerId;
        this.scorePercent = scorePercent;
        this.isPassed = isPassed;
        this.startedAt = startedAt;
        this.submittedAt = submittedAt;
    }

    public String getSubmissionId() { return submissionId; }
    public String getQuizId() { return quizId; }
    public String getLearnerId() { return learnerId; }
    public BigDecimal getScorePercent() { return scorePercent; }
    public Integer getIsPassed() { return isPassed; }
    public LocalDateTime getStartedAt() { return startedAt; }
    public LocalDateTime getSubmittedAt() { return submittedAt; }

    public Integer getCorrectAnswers() { return correctAnswers; }
    public void setCorrectAnswers(Integer correctAnswers) { this.correctAnswers = correctAnswers; }

    public Integer getTotalQuestions() { return totalQuestions; }
    public void setTotalQuestions(Integer totalQuestions) { this.totalQuestions = totalQuestions; }
}
