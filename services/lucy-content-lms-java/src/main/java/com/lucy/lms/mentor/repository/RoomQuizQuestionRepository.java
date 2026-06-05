package com.lucy.lms.mentor.repository;

import com.lucy.lms.mentor.entity.RoomQuizQuestion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RoomQuizQuestionRepository extends JpaRepository<RoomQuizQuestion, String> {

    List<RoomQuizQuestion> findByQuizId(String quizId);
}