package com.lucy.lms.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "RoomQuizzes")
public class RoomQuiz {

    @Id
    @Column(name = "QuizId", length = 50)
    private String quizId;

    @Column(name = "RoomId", length = 50, nullable = false)
    private String roomId;

    @Column(name = "LevelId", length = 50, nullable = false)
    private String levelId;

    @Column(name = "CreatedBy", length = 50, nullable = false)
    private String createdBy;

    @Column(name = "QuizTitle", length = 150, nullable = false)
    private String quizTitle;

    @Column(name = "PassingScorePercent")
    private BigDecimal passingScorePercent;

    @Column(name = "QuizStatus", length = 30)
    private String quizStatus;

    @Column(name = "CreatedAt")
    private LocalDateTime createdAt;

    protected RoomQuiz() {
    }

    public RoomQuiz(
            String quizId,
            String roomId,
            String levelId,
            String createdBy,
            String quizTitle,
            BigDecimal passingScorePercent,
            String quizStatus,
            LocalDateTime createdAt) {

        this.quizId = quizId;
        this.roomId = roomId;
        this.levelId = levelId;
        this.createdBy = createdBy;
        this.quizTitle = quizTitle;
        this.passingScorePercent = passingScorePercent;
        this.quizStatus = quizStatus;
        this.createdAt = createdAt;
    }

    public String getQuizId() {
        return quizId;
    }

    public String getRoomId() {
        return roomId;
    }

    public String getLevelId() {
        return levelId;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public String getQuizTitle() {
        return quizTitle;
    }

    public BigDecimal getPassingScorePercent() {
        return passingScorePercent;
    }

    public String getQuizStatus() {
        return quizStatus;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}