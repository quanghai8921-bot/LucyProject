package com.lucy.models;

public class Stages {
    private String StageId;
    private String LanguageId;
    private int StageNumber;
    private int DurationMinutes;
    private String CeftStart;
    private String CeftEnd;
    private int LevelStart;
    private int LevelEnd;
    private String TargetOutcome;
    private String Descriptions;
    private int IsStatus;

    public Stages() {
    }

    public Stages(String StageId, String LanguageId, int StageNumber, int DurationMinutes, String CeftStart,
            String CeftEnd, int LevelStart, int LevelEnd, String TargetOutcome, String Descriptions, int IsStatus) {
        this.StageId = StageId;
        this.LanguageId = LanguageId;
        this.StageNumber = StageNumber;
        this.DurationMinutes = DurationMinutes;
        this.CeftStart = CeftStart;
        this.CeftEnd = CeftEnd;
        this.LevelStart = LevelStart;
        this.LevelEnd = LevelEnd;
        this.TargetOutcome = TargetOutcome;
        this.Descriptions = Descriptions;
        this.IsStatus = IsStatus;
    }

    public String getStageId() {
        return this.StageId;
    }

    public void setStageId(String StageId) {
        this.StageId = StageId;
    }

    public String getLanguageId() {
        return this.LanguageId;
    }

    public void setLanguageId(String LanguageId) {
        this.LanguageId = LanguageId;
    }

    public int getStageNumber() {
        return this.StageNumber;
    }

    public void setStageNumber(int StageNumber) {
        this.StageNumber = StageNumber;
    }

    public int getDurationMinutes() {
        return this.DurationMinutes;
    }

    public void setDurationMinutes(int DurationMinutes) {
        this.DurationMinutes = DurationMinutes;
    }

    public String getCeftStart() {
        return this.CeftStart;
    }

    public void setCeftStart(String CeftStart) {
        this.CeftStart = CeftStart;
    }

    public String getCeftEnd() {
        return this.CeftEnd;
    }

    public void setCeftEnd(String CeftEnd) {
        this.CeftEnd = CeftEnd;
    }

    public int getLevelStart() {
        return this.LevelStart;
    }

    public void setLevelStart(int LevelStart) {
        this.LevelStart = LevelStart;
    }

    public int getLevelEnd() {
        return this.LevelEnd;
    }

    public void setLevelEnd(int LevelEnd) {
        this.LevelEnd = LevelEnd;
    }

    public String getTargetOutcome() {
        return this.TargetOutcome;
    }

    public void setTargetOutcome(String TargetOutcome) {
        this.TargetOutcome = TargetOutcome;
    }

    public String getDescriptions() {
        return this.Descriptions;
    }

    public void setDescriptions(String Descriptions) {
        this.Descriptions = Descriptions;
    }

    public int getIsStatus() {
        return this.IsStatus;
    }

    public void setIsStatus(int IsStatus) {
        this.IsStatus = IsStatus;
    }
}