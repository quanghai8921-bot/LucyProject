package com.lucy.lms.mentor.repository;

import com.lucy.lms.mentor.entity.RoomGiftEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface RoomGiftEventRepository extends JpaRepository<RoomGiftEvent, String> {
    List<RoomGiftEvent> findByRoomId(String roomId);
}
