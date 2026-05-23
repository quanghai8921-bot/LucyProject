package com.lucy.models;

public class SampleAnswers {
    private String AnswerId;
    private String QuestionId;
    private String LanguageId;
    private String AnswerText;

    public SampleAnswers() {
    }

    public SampleAnswers(String AnswerId, String QuestionId, String LanguageId, String AnswerText) {
        this.AnswerId = AnswerId;
        this.QuestionId = QuestionId;
        this.LanguageId = LanguageId;
        this.AnswerText = AnswerText;
    }

    public String getAnswerId() {
        return this.AnswerId;
    }

    public void setAnswerId(String AnswerId) {
        this.AnswerId = AnswerId;
    }

    public String getQuestionId() {
        return this.QuestionId;
    }

    public void setQuestionId(String QuestionId) {
        this.QuestionId = QuestionId;
    }

    public String getLanguageId() {
        return this.LanguageId;
    }

    public void setLanguageId(String LanguageId) {
        this.LanguageId = LanguageId;
    }

    public String getAnswerText() {
        return this.AnswerText;
    }

    public void setAnswerText(String AnswerText) {
        this.AnswerText = AnswerText;
    }
}