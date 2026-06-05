package com.lucy.lms.content.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.lms.content.model.LearningLevel;

public interface LearningLevelRepository extends JpaRepository<LearningLevel, String> {
    long countByStageId(String stageId);

    long countByStageIdAndGroupIdIsNotNull(String stageId);

    List<LearningLevel> findByStageId(String stageId);
}
