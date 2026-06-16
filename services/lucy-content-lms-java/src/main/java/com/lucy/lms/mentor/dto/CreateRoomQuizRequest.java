package com.lucy.lms.mentor.dto;

import java.math.BigDecimal;
import java.util.List;

public class CreateRoomQuizRequest {

    private String roomId;
    private String levelId;
    private String createdBy;
    private String quizTitle;
    private Integer durationMinutes;
    private BigDecimal passingScorePercent;
    private String quizType;
    private List<CreateRoomQuizQuestionDto> questions;

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

    public Integer getDurationMinutes() {
        return durationMinutes;
    }

    public BigDecimal getPassingScorePercent() {
        return passingScorePercent;
    }

    public String getQuizType() {
        return quizType;
    }

    public List<CreateRoomQuizQuestionDto> getQuestions() {
        return questions;
    }
}
