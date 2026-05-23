package com.lucy.models;

public class Levels {
    private String LevelId;
    private String StageId;
    private String LevelTitle;
    private int LevelNumber;
    private String CefrLevel;

    public Levels() {
    }

    public Levels(String LevelId, String StageId, String LevelTitle, int LevelNumber, String CefrLevel) {
        this.LevelId = LevelId;
        this.StageId = StageId;
        this.LevelTitle = LevelTitle;
        this.LevelNumber = LevelNumber;
        this.CefrLevel = CefrLevel;
    }

    public String getLevelId() {
        return this.LevelId;
    }

    public void setLevelId(String LevelId) {
        this.LevelId = LevelId;
    }

    public String getStageId() {
        return this.StageId;
    }

    public void setStageId(String StageId) {
        this.StageId = StageId;
    }

    public String getLevelTitle() {
        return this.LevelTitle;
    }

    public void setLevelTitle(String LevelTitle) {
        this.LevelTitle = LevelTitle;
    }

    public int getLevelNumber() {
        return this.LevelNumber;
    }

    public void setLevelNumber(int LevelNumber) {
        this.LevelNumber = LevelNumber;
    }

    public String getCefrLevel() {
        return this.CefrLevel;
    }

    public void setCefrLevel(String CefrLevel) {
        this.CefrLevel = CefrLevel;
    }
}