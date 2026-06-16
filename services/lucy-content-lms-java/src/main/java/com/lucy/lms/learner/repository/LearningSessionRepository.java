package com.lucy.lms.learner.repository;

import com.lucy.lms.learner.entity.LearningSession;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface LearningSessionRepository extends JpaRepository<LearningSession, String> {
    Optional<LearningSession> findFirstByUserIdAndRoomIdAndLevelIdAndSubLevelIdOrderByStartedAtDesc(
            String userId,
            String roomId,
            String levelId,
            String subLevelId);

    List<LearningSession> findByUserIdAndRoomIdAndLevelId(String userId, String roomId, String levelId);

    List<LearningSession> findByUserIdAndRoomId(String userId, String roomId);
}
