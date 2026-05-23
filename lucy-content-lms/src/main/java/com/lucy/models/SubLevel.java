package com.lucy.models;

public class SubLevel {
    private String SubLevelId;
    private String LevelId;
    private String SublevelTitle;
    private String MainTask;
    private String PromptHint;
    private int DurationMinutes;

    public SubLevel() {
    }

    public SubLevel(String SubLevelId, String LevelId, String SublevelTitle, String MainTask, String PromptHint,
            int DurationMinutes) {
        this.SubLevelId = SubLevelId;
        this.LevelId = LevelId;
        this.SublevelTitle = SublevelTitle;
        this.MainTask = MainTask;
        this.PromptHint = PromptHint;
        this.DurationMinutes = DurationMinutes;
    }

    public String getSubLevelId() {
        return this.SubLevelId;
    }

    public void setSubLevelId(String SubLevelId) {
        this.SubLevelId = SubLevelId;
    }

    public String getLevelId() {
        return this.LevelId;
    }

    public void setLevelId(String LevelId) {
        this.LevelId = LevelId;
    }

    public String getSublevelTitle() {
        return this.SublevelTitle;
    }

    public void setSublevelTitle(String SublevelTitle) {
        this.SublevelTitle = SublevelTitle;
    }

    public String getMainTask() {
        return this.MainTask;
    }

    public void setMainTask(String MainTask) {
        this.MainTask = MainTask;
    }

    public String getPromptHint() {
        return this.PromptHint;
    }

    public void setPromptHint(String PromptHint) {
        this.PromptHint = PromptHint;
    }

    public int getDurationMinutes() {
        return this.DurationMinutes;
    }

    public void setDurationMinutes(int DurationMinutes) {
        this.DurationMinutes = DurationMinutes;
    }
}