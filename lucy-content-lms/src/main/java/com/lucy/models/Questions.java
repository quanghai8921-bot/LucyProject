package com.lucy.models;

import java.util.Date;

public class Questions {
    private String QuestionId;
    private String SubLevelId;
    private String QuestionType;
    private String DifficultyLevel;
    private String SkillTarget;
    private Date CreatedAt;

    public Questions() {
    }

    public Questions(String QuestionId, String SubLevelId, String QuestionType, String DifficultyLevel,
            String SkillTarget, Date CreatedAt) {
        this.QuestionId = QuestionId;
        this.SubLevelId = SubLevelId;
        this.QuestionType = QuestionType;
        this.DifficultyLevel = DifficultyLevel;
        this.SkillTarget = SkillTarget;
        this.CreatedAt = CreatedAt;
    }

    public String getQuestionId() {
        return this.QuestionId;
    }

    public void setQuestionId(String QuestionId) {
        this.QuestionId = QuestionId;
    }

    public String getSubLevelId() {
        return this.SubLevelId;
    }

    public void setSubLevelId(String SubLevelId) {
        this.SubLevelId = SubLevelId;
    }

    public String getQuestionType() {
        return this.QuestionType;
    }

    public void setQuestionType(String QuestionType) {
        this.QuestionType = QuestionType;
    }

    public String getDifficultyLevel() {
        return this.DifficultyLevel;
    }

    public void setDifficultyLevel(String DifficultyLevel) {
        this.DifficultyLevel = DifficultyLevel;
    }

    public String getSkillTarget() {
        return this.SkillTarget;
    }

    public void setSkillTarget(String SkillTarget) {
        this.SkillTarget = SkillTarget;
    }

    public Date getCreatedAt() {
        return this.CreatedAt;
    }

    public void setCreatedAt(Date CreatedAt) {
        this.CreatedAt = CreatedAt;
    }
}