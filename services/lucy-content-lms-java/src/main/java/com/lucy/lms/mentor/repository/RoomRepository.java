package com.lucy.lms.mentor.repository;

import com.lucy.lms.mentor.entity.Room;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RoomRepository extends JpaRepository<Room, String> {

    List<Room> findByHostUserId(String hostUserId);

    List<Room> findByRoomStatus(String roomStatus);
}