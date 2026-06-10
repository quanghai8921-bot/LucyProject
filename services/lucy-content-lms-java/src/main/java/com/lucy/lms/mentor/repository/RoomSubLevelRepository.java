package com.lucy.lms.mentor.repository;

import com.lucy.lms.mentor.entity.RoomSubLevel;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RoomSubLevelRepository extends JpaRepository<RoomSubLevel, String> {
    List<RoomSubLevel> findByRoomIdOrderByStepOrderAsc(String roomId);

    Optional<RoomSubLevel> findByRoomIdAndSubLevelId(String roomId, String subLevelId);

    long countByRoomId(String roomId);
}
