package com.lucy.lms.content.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.lms.content.model.StageStepTemplate;

public interface StageStepTemplateRepository extends JpaRepository<StageStepTemplate, String> {
    long countByStageId(String stageId);
}
