package com.lucy.lms.learner.repository;

import com.lucy.lms.learner.entity.RoomParticipant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RoomParticipantRepository extends JpaRepository<RoomParticipant, String> {

    Optional<RoomParticipant> findFirstByRoomIdAndUserIdAndParticipantStatusOrderByJoinedAtDesc(
            String roomId,
            String userId,
            String participantStatus);

    List<RoomParticipant> findByRoomIdAndParticipantStatus(String roomId, String participantStatus);

    Integer countByRoomIdAndParticipantStatus(String roomId, String participantStatus);

    List<RoomParticipant> findByUserIdOrderByJoinedAtDesc(String userId);
}
