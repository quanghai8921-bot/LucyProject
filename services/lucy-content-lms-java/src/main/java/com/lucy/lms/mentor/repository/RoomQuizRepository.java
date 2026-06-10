package com.lucy.lms.mentor.repository;

import com.lucy.lms.mentor.entity.RoomQuiz;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RoomQuizRepository extends JpaRepository<RoomQuiz, String> {

    List<RoomQuiz> findByRoomId(String roomId);
}