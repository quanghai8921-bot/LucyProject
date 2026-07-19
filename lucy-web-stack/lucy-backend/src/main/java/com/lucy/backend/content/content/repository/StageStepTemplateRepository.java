package com.lucy.backend.content.content.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.backend.content.content.model.StageStepTemplate;

public interface StageStepTemplateRepository extends JpaRepository<StageStepTemplate, String> {
    long countByStageId(String stageId);
}
