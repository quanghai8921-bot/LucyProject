package com.lucy.lms.mentor.dto;

import java.util.List;

public class CreateRoomQuizQuestionDto {
    private String questionText;
    private String questionType;
    private String correctAnswerText;
    private List<CreateRoomQuizOptionDto> options;

    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public String getQuestionType() {
        return questionType;
    }

    public void setQuestionType(String questionType) {
        this.questionType = questionType;
    }

    public String getCorrectAnswerText() {
        return correctAnswerText;
    }

    public void setCorrectAnswerText(String correctAnswerText) {
        this.correctAnswerText = correctAnswerText;
    }

    public List<CreateRoomQuizOptionDto> getOptions() {
        return options;
    }

    public void setOptions(List<CreateRoomQuizOptionDto> options) {
        this.options = options;
    }
}
