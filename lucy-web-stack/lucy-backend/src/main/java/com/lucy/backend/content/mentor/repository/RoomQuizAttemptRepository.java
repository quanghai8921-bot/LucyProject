package com.lucy.backend.content.mentor.repository;

import com.lucy.backend.content.mentor.entity.RoomQuizAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RoomQuizAttemptRepository extends JpaRepository<RoomQuizAttempt, String> {
    List<RoomQuizAttempt> findByQuizId(String quizId);

    List<RoomQuizAttempt> findByUserId(String userId);
}
