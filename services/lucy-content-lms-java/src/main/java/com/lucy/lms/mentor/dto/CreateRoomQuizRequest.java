package com.lucy.lms.mentor.dto;

import java.math.BigDecimal;

public class CreateRoomQuizRequest {

    private String roomId;
    private String levelId;
    private String createdBy;
    private String quizTitle;
    private BigDecimal passingScorePercent;

    public CreateRoomQuizRequest() {
    }

    public CreateRoomQuizRequest(String roomId, String levelId, String createdBy,
                                 String quizTitle, BigDecimal passingScorePercent) {
        this.roomId = roomId;
        this.levelId = levelId;
        this.createdBy = createdBy;
        this.quizTitle = quizTitle;
        this.passingScorePercent = passingScorePercent;
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
}