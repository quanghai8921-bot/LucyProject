package com.lucy.lms.learner.repository;

import com.lucy.lms.learner.entity.UserProgress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserProgressRepository extends JpaRepository<UserProgress, String> {
    Optional<UserProgress> findFirstByUserIdAndLanguageIdAndLevelId(String userId, String languageId, String levelId);
}
