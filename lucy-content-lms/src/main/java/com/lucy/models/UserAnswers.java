package com.lucy.models;

import java.util.Date;

public class UserAnswers {
    private String UserAnswersId;
    private String UserId;
    private String SessionId;
    private String QuestionId;
    private String AnswerText;
    private String AudioUrl;
    private Date SubmittedAt;

    public UserAnswers() {
    }

    public UserAnswers(String UserAnswersId, String UserId, String SessionId, String QuestionId, String AnswerText,
            String AudioUrl, Date SubmittedAt) {
        this.UserAnswersId = UserAnswersId;
        this.UserId = UserId;
        this.SessionId = SessionId;
        this.QuestionId = QuestionId;
        this.AnswerText = AnswerText;
        this.AudioUrl = AudioUrl;
        this.SubmittedAt = SubmittedAt;
    }

    public String getUserAnswersId() {
        return this.UserAnswersId;
    }

    public void setUserAnswersId(String UserAnswersId) {
        this.UserAnswersId = UserAnswersId;
    }

    public String getUserId() {
        return this.UserId;
    }

    public void setUserId(String UserId) {
        this.UserId = UserId;
    }

    public String getSessionId() {
        return this.SessionId;
    }

    public void setSessionId(String SessionId) {
        this.SessionId = SessionId;
    }

    public String getQuestionId() {
        return this.QuestionId;
    }

    public void setQuestionId(String QuestionId) {
        this.QuestionId = QuestionId;
    }

    public String getAnswerText() {
        return this.AnswerText;
    }

    public void setAnswerText(String AnswerText) {
        this.AnswerText = AnswerText;
    }

    public String getAudioUrl() {
        return this.AudioUrl;
    }

    public void setAudioUrl(String AudioUrl) {
        this.AudioUrl = AudioUrl;
    }

    public Date getSubmittedAt() {
        return this.SubmittedAt;
    }

    public void setSubmittedAt(Date SubmittedAt) {
        this.SubmittedAt = SubmittedAt;
    }
}