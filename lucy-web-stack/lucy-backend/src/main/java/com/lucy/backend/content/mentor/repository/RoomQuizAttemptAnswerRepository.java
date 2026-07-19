package com.lucy.backend.content.mentor.repository;

import com.lucy.backend.content.mentor.entity.RoomQuizAttemptAnswer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RoomQuizAttemptAnswerRepository extends JpaRepository<RoomQuizAttemptAnswer, String> {
    List<RoomQuizAttemptAnswer> findByAttemptId(String attemptId);
}
