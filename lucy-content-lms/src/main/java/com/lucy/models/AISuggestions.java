package com.lucy.models;

import java.util.Date;

public class AISuggestions {
    private String SuggestionId;
    private String RoomId;
    private String SubLevelId;
    private String QuestionId;
    private String SuggestionText;
    private Date CreatedAt;
    private int IsUsed;

    public AISuggestions() {
    }

    public AISuggestions(String SuggestionId, String RoomId, String SubLevelId, String QuestionId,
            String SuggestionText, Date CreatedAt, int IsUsed) {
        this.SuggestionId = SuggestionId;
        this.RoomId = RoomId;
        this.SubLevelId = SubLevelId;
        this.QuestionId = QuestionId;
        this.SuggestionText = SuggestionText;
        this.CreatedAt = CreatedAt;
        this.IsUsed = IsUsed;
    }

    public String getSuggestionId() {
        return this.SuggestionId;
    }

    public void setSuggestionId(String SuggestionId) {
        this.SuggestionId = SuggestionId;
    }

    public String getRoomId() {
        return this.RoomId;
    }

    public void setRoomId(String RoomId) {
        this.RoomId = RoomId;
    }

    public String getSubLevelId() {
        return this.SubLevelId;
    }

    public void setSubLevelId(String SubLevelId) {
        this.SubLevelId = SubLevelId;
    }

    public String getQuestionId() {
        return this.QuestionId;
    }

    public void setQuestionId(String QuestionId) {
        this.QuestionId = QuestionId;
    }

    public String getSuggestionText() {
        return this.SuggestionText;
    }

    public void setSuggestionText(String SuggestionText) {
        this.SuggestionText = SuggestionText;
    }

    public Date getCreatedAt() {
        return this.CreatedAt;
    }

    public void setCreatedAt(Date CreatedAt) {
        this.CreatedAt = CreatedAt;
    }

    public int getIsUsed() {
        return this.IsUsed;
    }

    public void setIsUsed(int IsUsed) {
        this.IsUsed = IsUsed;
    }
}