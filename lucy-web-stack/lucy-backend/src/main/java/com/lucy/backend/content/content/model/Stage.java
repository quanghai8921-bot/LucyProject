package com.lucy.backend.content.content.model;

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

    @Column(name = "SubDurationMinutes")
    private Integer subDurationMinutes;

    @Column(name = "SubNumber")
    private Integer subNumber;

    @Column(name = "CompletionOutcome")
    private String completionOutcome;

    @Column(name = "Descriptions", columnDefinition = "TEXT")
    private String descriptions;

    protected Stage() {
    }

    public Stage(String stageId, String languageId, Integer stageNumber, Integer durationMinutes, String cefrStart,
            String cefrEnd, Integer levelStart, Integer levelEnd, Integer subDurationMinutes, Integer subNumber, 
            String completionOutcome, String descriptions) {
        this.stageId = stageId;
        this.languageId = languageId;
        this.stageNumber = stageNumber;
        this.durationMinutes = durationMinutes;
        this.cefrStart = cefrStart;
        this.cefrEnd = cefrEnd;
        this.levelStart = levelStart;
        this.levelEnd = levelEnd;
        this.subDurationMinutes = subDurationMinutes;
        this.subNumber = subNumber;
        this.completionOutcome = completionOutcome;
        this.descriptions = descriptions;
    }

    public String getStageId() {
        return stageId;
    }

    public String getLanguageId() {
        return languageId;
    }

    public Integer getStageNumber() {
        return stageNumber;
    }

    public Integer getDurationMinutes() {
        return durationMinutes;
    }

    public String getCefrStart() {
        return cefrStart;
    }

    public String getCefrEnd() {
        return cefrEnd;
    }

    public Integer getLevelStart() {
        return levelStart;
    }

    public Integer getLevelEnd() {
        return levelEnd;
    }

    public Integer getSubDurationMinutes() {
        return subDurationMinutes;
    }

    public Integer getSubNumber() {
        return subNumber;
    }

    public String getCompletionOutcome() {
        return completionOutcome;
    }

    public String getDescriptions() {
        return descriptions;
    }
}
