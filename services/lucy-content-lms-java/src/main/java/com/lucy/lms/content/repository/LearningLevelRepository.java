package com.lucy.lms.content.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.lms.content.model.LearningLevel;

public interface LearningLevelRepository extends JpaRepository<LearningLevel, String> {
    long countByStageId(String stageId);

    long countByStageIdAndGroupIdIsNotNull(String stageId);

    List<LearningLevel> findByStageId(String stageId);

    @org.springframework.data.jpa.repository.Query("SELECT l FROM LearningLevel l WHERE l.levelNumber = :levelNumber AND l.stageId LIKE CONCAT(:languageId, '_STAGE_%')")
    List<LearningLevel> findByLanguageAndLevelNumber(
            @org.springframework.data.repository.query.Param("languageId") String languageId,
            @org.springframework.data.repository.query.Param("levelNumber") Integer levelNumber);
}
