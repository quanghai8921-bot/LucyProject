package com.lucy.backend.content.mentor.repository;

import com.lucy.backend.content.mentor.entity.RoomQuiz;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RoomQuizRepository extends JpaRepository<RoomQuiz, String> {

    List<RoomQuiz> findByRoomId(String roomId);
    List<RoomQuiz> findByCreatedBy(String createdBy);
}
