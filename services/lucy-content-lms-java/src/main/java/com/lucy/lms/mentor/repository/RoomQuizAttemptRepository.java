package com.lucy.lms.mentor.repository;

import com.lucy.lms.mentor.entity.RoomQuizAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RoomQuizAttemptRepository extends JpaRepository<RoomQuizAttempt, String> {
    List<RoomQuizAttempt> findByQuizId(String quizId);

    List<RoomQuizAttempt> findByUserId(String userId);
}
