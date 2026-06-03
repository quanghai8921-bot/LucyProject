package com.lucy.lms.mentor.dto;

public class CreateRoomQuizQuestionRequest {

    private String quizId;
    private String questionText;
    private String questionType;
    private Integer questionOrder;

    public String getQuizId() {
        return quizId;
    }

    public String getQuestionText() {
        return questionText;
    }

    public String getQuestionType() {
        return questionType;
    }

    public Integer getQuestionOrder() {
        return questionOrder;
    }
}