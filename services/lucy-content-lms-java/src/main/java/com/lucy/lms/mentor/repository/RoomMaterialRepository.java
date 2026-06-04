package com.lucy.lms.mentor.repository;

import com.lucy.lms.mentor.entity.RoomMaterial;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RoomMaterialRepository extends JpaRepository<RoomMaterial, String> {

    List<RoomMaterial> findByRoomId(String roomId);
}