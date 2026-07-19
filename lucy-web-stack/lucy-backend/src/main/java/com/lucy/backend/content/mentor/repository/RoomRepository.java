package com.lucy.backend.content.mentor.repository;

import com.lucy.backend.content.mentor.entity.Room;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface RoomRepository extends JpaRepository<Room, String> {

    List<Room> findByHostUserId(String hostUserId);

    List<Room> findByRoomStatus(String roomStatus);

    @Query(value = "SELECT FullName FROM Users WHERE UserId = :userId LIMIT 1", nativeQuery = true)
    String findMentorFullNameByUserId(@Param("userId") String userId);
}
