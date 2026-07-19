package com.lucy.backend.content.mentor.dto;

public class CreateRoomQuizOptionRequest {

    private String roomQuizQuestionId;
    private String optionText;
    private Boolean isCorrect;
    private Integer optionOrder;

    public String getRoomQuizQuestionId() {
        return roomQuizQuestionId;
    }

    public String getOptionText() {
        return optionText;
    }

    public Boolean getIsCorrect() {
        return isCorrect;
    }

    public Integer getOptionOrder() {
        return optionOrder;
    }
}
