package com.lucy.lms.mentor.dto;

import java.math.BigDecimal;

public class RoomQuizAttemptDto {
    private String attemptId;
    private String quizId;
    private String quizTitle;
    private String quizType;
    private Integer durationMinutes;
    private String attemptStatus;
    private BigDecimal scorePercent;
    private Boolean isPassed;

    public RoomQuizAttemptDto(String attemptId, String quizId, String quizTitle, String quizType, Integer durationMinutes, String attemptStatus, BigDecimal scorePercent, Boolean isPassed) {
        this.attemptId = attemptId;
        this.quizId = quizId;
        this.quizTitle = quizTitle;
        this.quizType = quizType;
        this.durationMinutes = durationMinutes;
        this.attemptStatus = attemptStatus;
        this.scorePercent = scorePercent;
        this.isPassed = isPassed;
    }

    public String getAttemptId() { return attemptId; }
    public String getQuizId() { return quizId; }
    public String getQuizTitle() { return quizTitle; }
    public String getQuizType() { return quizType; }
    public Integer getDurationMinutes() { return durationMinutes; }
    public String getAttemptStatus() { return attemptStatus; }
    public BigDecimal getScorePercent() { return scorePercent; }
    public Boolean getIsPassed() { return isPassed; }
}
