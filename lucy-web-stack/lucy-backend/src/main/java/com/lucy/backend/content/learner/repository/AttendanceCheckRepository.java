package com.lucy.backend.content.learner.repository;

import com.lucy.backend.content.learner.entity.AttendanceCheck;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;

public interface AttendanceCheckRepository extends JpaRepository<AttendanceCheck, String> {
    long countByLearningSessionIdInAndIsConfirmed(Collection<String> learningSessionIds, Boolean isConfirmed);

    long countByLearningSessionIdIn(Collection<String> learningSessionIds);
}
