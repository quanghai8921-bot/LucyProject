package com.lucy.backend.content.content.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.lucy.backend.content.content.model.LearningLevel;

public interface LearningLevelRepository extends JpaRepository<LearningLevel, String> {
    long countByStageId(String stageId);

    long countByStageIdAndGroupIdIsNotNull(String stageId);

    List<LearningLevel> findByStageId(String stageId);

    List<LearningLevel> findByStageIdOrderByLevelNumberAsc(String stageId);

    Optional<LearningLevel> findFirstByStageIdAndLevelNumber(String stageId, Integer levelNumber);

    Optional<LearningLevel> findFirstByStageIdStartingWithAndLevelNumberOrderByStageIdAsc(String stageIdPrefix,
            Integer levelNumber);

    List<LearningLevel> findByStageIdStartingWithOrderByStageIdAscLevelNumberAsc(String stageIdPrefix);

    @Query(value = "SELECT lv.* FROM Levels lv JOIN Stages s ON lv.StageId = s.StageId JOIN Languages l ON s.LanguageId = l.LanguageId WHERE l.LanguageName = :languageName AND lv.LevelNumber = :levelNumber LIMIT 1", nativeQuery = true)
    Optional<LearningLevel> findByLanguageNameAndLevelNumber(@Param("languageName") String languageName, @Param("levelNumber") Integer levelNumber);
}
