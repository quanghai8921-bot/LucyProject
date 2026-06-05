package com.lucy.lms.content.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "StageStepTemplates")
public class StageStepTemplate {
    @Id
    @Column(name = "StageStepTemplateId", length = 50)
    private String stageStepTemplateId;

    @Column(name = "StageId", length = 50, nullable = false)
    private String stageId;

    @Column(name = "TemplateType", length = 50, nullable = false)
    private String templateType;

    @Column(name = "TemplateStepOrder", nullable = false)
    private Integer templateStepOrder;

    @Column(name = "TemplateStepTitle", length = 100, nullable = false)
    private String templateStepTitle;

    @Column(name = "TemplateDurationMinutes")
    private Integer templateDurationMinutes;

    @Column(name = "TemplateDescription")
    private String templateDescription;

    @Column(name = "IsStatus", nullable = false)
    private Integer isStatus;

    protected StageStepTemplate() {
    }

    public StageStepTemplate(String stageStepTemplateId, String stageId, String templateType,
            Integer templateStepOrder, String templateStepTitle, Integer templateDurationMinutes,
            String templateDescription, Integer isStatus) {
        this.stageStepTemplateId = stageStepTemplateId;
        this.stageId = stageId;
        this.templateType = templateType;
        this.templateStepOrder = templateStepOrder;
        this.templateStepTitle = templateStepTitle;
        this.templateDurationMinutes = templateDurationMinutes;
        this.templateDescription = templateDescription;
        this.isStatus = isStatus;
    }
}
