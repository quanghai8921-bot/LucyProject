package com.lucy.lms.mentor.repository;

import com.lucy.lms.mentor.entity.RoomQuizOption;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RoomQuizOptionRepository extends JpaRepository<RoomQuizOption, String> {

    List<RoomQuizOption> findByRoomQuizQuestionId(String roomQuizQuestionId);
}