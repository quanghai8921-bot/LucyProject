package com.lucy.lms.content.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.lms.content.model.LearningLevel;

public interface LearningLevelRepository extends JpaRepository<LearningLevel, String> {
    long countByStageId(String stageId);

    long countByStageIdAndGroupIdIsNotNull(String stageId);

    List<LearningLevel> findByStageId(String stageId);

    List<LearningLevel> findByStageIdOrderByLevelNumberAsc(String stageId);

    Optional<LearningLevel> findFirstByStageIdStartingWithAndLevelNumberOrderByStageIdAsc(String stageIdPrefix,
            Integer levelNumber);
}
