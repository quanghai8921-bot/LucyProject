package com.lucy.backend.content.learner.repository;

import com.lucy.backend.content.learner.entity.LearningSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LearningSessionRepository extends JpaRepository<LearningSession, String> {
    Optional<LearningSession> findByUserId(String userId);
}