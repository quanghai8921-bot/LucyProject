package com.lucy.backend.content.content.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "SubLevel")
public class SubLevel {
    @Id
    @Column(name = "SubLevelId", length = 50)
    private String subLevelId;

    @Column(name = "LevelId", length = 50, nullable = false)
    private String levelId;

    @Column(name = "SubLevelNumber")
    private Integer subLevelNumber;

    @Column(name = "SublevelTitle", length = 100)
    private String sublevelTitle;

    @Column(name = "MainTask")
    private String mainTask;
    protected SubLevel() {
    }

    public SubLevel(String subLevelId, String levelId, Integer subLevelNumber, String sublevelTitle, String mainTask) {
        this.subLevelId = subLevelId;
        this.levelId = levelId;
        this.subLevelNumber = subLevelNumber;
        this.sublevelTitle = sublevelTitle;
        this.mainTask = mainTask;
        
        
    }

    public String getSubLevelId() {
        return subLevelId;
    }

    public String getLevelId() {
        return levelId;
    }

    public Integer getSubLevelNumber() {
        return subLevelNumber;
    }

    public String getSublevelTitle() {
        return sublevelTitle;
    }

    public String getMainTask() {
        return mainTask;
    }}
