package com.lucy.lms.content.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;

@Entity
@Table(name = "Levels")
public class LearningLevel {
    @Id
    @Column(name = "LevelId", length = 50)
    private String levelId;

    @Column(name = "GroupId", length = 50)
    private String groupId;

    @Column(name = "StageId", length = 50, nullable = false)
    private String stageId;

    @Column(name = "LevelTitle", length = 100)
    private String levelTitle;

    @Column(name = "LevelNumber", nullable = false)
    private Integer levelNumber;

    @Lob
    @Column(name = "LevelDescription")
    private String levelDescription;

    protected LearningLevel() {
    }

    public LearningLevel(String levelId, String groupId, String stageId, String levelTitle, Integer levelNumber,
            String levelDescription) {
        this.levelId = levelId;
        this.groupId = groupId;
        this.stageId = stageId;
        this.levelTitle = levelTitle;
        this.levelNumber = levelNumber;
        this.levelDescription = levelDescription;
    }

    public String getLevelId() {
        return levelId;
    }
}
