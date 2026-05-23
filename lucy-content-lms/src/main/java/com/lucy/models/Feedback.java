package com.lucy.models;

import java.util.Date;

public class Feedback {
    private String UserAnswerId;
    private float FluencyScore;
    private float PronunciationScore;
    private float GrammarScore;
    private float VocabularyScore;
    private float OverallScore;
    private String FeedbackText;
    private Date CreatedAt;

    public Feedback() {
    }

    public Feedback(String UserAnswerId, float FluencyScore, float PronunciationScore, float GrammarScore,
            float VocabularyScore, float OverallScore, String FeedbackText, Date CreatedAt) {
        this.UserAnswerId = UserAnswerId;
        this.FluencyScore = FluencyScore;
        this.PronunciationScore = PronunciationScore;
        this.GrammarScore = GrammarScore;
        this.VocabularyScore = VocabularyScore;
        this.OverallScore = OverallScore;
        this.FeedbackText = FeedbackText;
        this.CreatedAt = CreatedAt;
    }

    public String getUserAnswerId() {
        return this.UserAnswerId;
    }

    public void setUserAnswerId(String UserAnswerId) {
        this.UserAnswerId = UserAnswerId;
    }

    public float getFluencyScore() {
        return this.FluencyScore;
    }

    public void setFluencyScore(float FluencyScore) {
        this.FluencyScore = FluencyScore;
    }

    public float getPronunciationScore() {
        return this.PronunciationScore;
    }

    public void setPronunciationScore(float PronunciationScore) {
        this.PronunciationScore = PronunciationScore;
    }

    public float getGrammarScore() {
        return this.GrammarScore;
    }

    public void setGrammarScore(float GrammarScore) {
        this.GrammarScore = GrammarScore;
    }

    public float getVocabularyScore() {
        return this.VocabularyScore;
    }

    public void setVocabularyScore(float VocabularyScore) {
        this.VocabularyScore = VocabularyScore;
    }

    public float getOverallScore() {
        return this.OverallScore;
    }

    public void setOverallScore(float OverallScore) {
        this.OverallScore = OverallScore;
    }

    public String getFeedbackText() {
        return this.FeedbackText;
    }

    public void setFeedbackText(String FeedbackText) {
        this.FeedbackText = FeedbackText;
    }

    public Date getCreatedAt() {
        return this.CreatedAt;
    }

    public void setCreatedAt(Date CreatedAt) {
        this.CreatedAt = CreatedAt;
    }
}
