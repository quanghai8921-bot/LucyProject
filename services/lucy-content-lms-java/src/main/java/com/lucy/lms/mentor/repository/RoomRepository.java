package com.lucy.lms.mentor.repository;

import com.lucy.lms.mentor.entity.Room;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface RoomRepository extends JpaRepository<Room, String> {

    List<Room> findByHostUserId(String hostUserId);

    List<Room> findByRoomStatus(String roomStatus);

    @Query(value = "SELECT u.FullName FROM Users u INNER JOIN UserRoles ur ON u.UserId = ur.UserId WHERE u.UserId = :userId AND ur.RoleId = 'R003' LIMIT 1", nativeQuery = true)
    String findMentorFullNameByUserId(@Param("userId") String userId);
}