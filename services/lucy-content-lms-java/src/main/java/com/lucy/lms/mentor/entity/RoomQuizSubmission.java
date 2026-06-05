package com.lucy.lms.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "RoomQuizSubmissions")
public class RoomQuizSubmission {

    @Id
    @Column(name = "SubmissionId", length = 50)
    private String submissionId;

    @Column(name = "QuizId", length = 50, nullable = false)
    private String quizId;

    @Column(name = "LearnerId", length = 50, nullable = false)
    private String learnerId;

    @Column(name = "SubmittedAt", nullable = false)
    private LocalDateTime submittedAt;

    @Column(name = "Score", precision = 5, scale = 2)
    private BigDecimal score;

    @Column(name = "Passed", nullable = false)
    private Integer passed;

    @Column(name = "Status", length = 50, nullable = false)
    private String status;

    protected RoomQuizSubmission() {
    }

    public RoomQuizSubmission(String submissionId, String quizId, String learnerId,
                              LocalDateTime submittedAt, BigDecimal score, Integer passed, String status) {
        this.submissionId = submissionId;
        this.quizId = quizId;
        this.learnerId = learnerId;
        this.submittedAt = submittedAt;
        this.score = score;
        this.passed = passed;
        this.status = status;
    }

    public String getSubmissionId() {
        return submissionId;
    }

    public String getQuizId() {
        return quizId;
    }

    public String getLearnerId() {
        return learnerId;
    }

    public LocalDateTime getSubmittedAt() {
        return submittedAt;
    }

    public BigDecimal getScore() {
        return score;
    }

    public Integer getPassed() {
        return passed;
    }

    public String getStatus() {
        return status;
    }
}
