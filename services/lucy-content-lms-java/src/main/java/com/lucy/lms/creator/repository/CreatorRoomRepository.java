package com.lucy.lms.creator.repository;

import com.lucy.lms.creator.entity.CreatorRoom;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CreatorRoomRepository extends JpaRepository<CreatorRoom, String> {
    List<CreatorRoom> findByHostUserId(String hostUserId);
}
