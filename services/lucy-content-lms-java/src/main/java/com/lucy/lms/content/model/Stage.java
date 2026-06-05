package com.lucy.lms.content.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Stages")
public class Stage {
    @Id
    @Column(name = "StageId", length = 50)
    private String stageId;

    @Column(name = "LanguageId", length = 50, nullable = false)
    private String languageId;

    @Column(name = "StageNumber")
    private Integer stageNumber;

    @Column(name = "DurationMinutes")
    private Integer durationMinutes;

    @Column(name = "CefrStart", length = 20)
    private String cefrStart;

    @Column(name = "CefrEnd", length = 20)
    private String cefrEnd;

    @Column(name = "LevelStart", nullable = false)
    private Integer levelStart;

    @Column(name = "LevelEnd", nullable = false)
    private Integer levelEnd;

    @Column(name = "CompletionOutcome")
    private String completionOutcome;

    @Column(name = "Descriptions")
    private String descriptions;

    @Column(name = "IsStatus", nullable = false)
    private Integer isStatus;

    protected Stage() {
    }

    public Stage(String stageId, String languageId, Integer stageNumber, Integer durationMinutes, String cefrStart,
            String cefrEnd, Integer levelStart, Integer levelEnd, String completionOutcome, String descriptions,
            Integer isStatus) {
        this.stageId = stageId;
        this.languageId = languageId;
        this.stageNumber = stageNumber;
        this.durationMinutes = durationMinutes;
        this.cefrStart = cefrStart;
        this.cefrEnd = cefrEnd;
        this.levelStart = levelStart;
        this.levelEnd = levelEnd;
        this.completionOutcome = completionOutcome;
        this.descriptions = descriptions;
        this.isStatus = isStatus;
    }

    public String getStageId() {
        return stageId;
    }
}
