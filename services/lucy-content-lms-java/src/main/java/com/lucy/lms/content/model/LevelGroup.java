package com.lucy.lms.content.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "LevelGroups")
public class LevelGroup {
    @Id
    @Column(name = "GroupId", length = 50)
    private String groupId;

    @Column(name = "StageId", length = 50, nullable = false)
    private String stageId;

    @Column(name = "GroupTitle", length = 100)
    private String groupTitle;

    @Column(name = "GrCefrLevel", length = 50)
    private String grCefrLevel;

    @Column(name = "GrLevelStart")
    private Integer grLevelStart;

    @Column(name = "GrLevelEnd")
    private Integer grLevelEnd;

    protected LevelGroup() {
    }

    public LevelGroup(String groupId, String stageId, String groupTitle, String grCefrLevel, Integer grLevelStart,
            Integer grLevelEnd) {
        this.groupId = groupId;
        this.stageId = stageId;
        this.groupTitle = groupTitle;
        this.grCefrLevel = grCefrLevel;
        this.grLevelStart = grLevelStart;
        this.grLevelEnd = grLevelEnd;
    }
}
