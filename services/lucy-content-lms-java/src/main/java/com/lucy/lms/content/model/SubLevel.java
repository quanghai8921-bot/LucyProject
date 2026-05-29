package com.lucy.lms.content.model;

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

    @Column(name = "PromptHint")
    private String promptHint;

    @Column(name = "SubDurationMins")
    private Integer subDurationMins;

    protected SubLevel() {
    }

    public SubLevel(String subLevelId, String levelId, Integer subLevelNumber, String sublevelTitle, String mainTask,
            String promptHint, Integer subDurationMins) {
        this.subLevelId = subLevelId;
        this.levelId = levelId;
        this.subLevelNumber = subLevelNumber;
        this.sublevelTitle = sublevelTitle;
        this.mainTask = mainTask;
        this.promptHint = promptHint;
        this.subDurationMins = subDurationMins;
    }

    public String getSubLevelId() {
        return subLevelId;
    }
}
