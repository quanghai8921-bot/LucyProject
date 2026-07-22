package com.lucy.backend.content.learner.repository;

import com.lucy.backend.content.learner.entity.RoomParticipant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RoomParticipantRepository extends JpaRepository<RoomParticipant, String> {

    Optional<RoomParticipant> findFirstByRoomIdAndUserIdAndParticipantStatusOrderByJoinedAtDesc(
            String roomId,
            String userId,
            String participantStatus);

    Optional<RoomParticipant> findFirstByRoomIdAndUserIdOrderByJoinedAtDesc(
            String roomId,
            String userId);

    List<RoomParticipant> findByRoomIdAndParticipantStatus(String roomId, String participantStatus);

    List<RoomParticipant> findByRoomId(String roomId);

    Integer countByRoomIdAndParticipantStatus(String roomId, String participantStatus);

    List<RoomParticipant> findByUserIdOrderByJoinedAtDesc(String userId);
}
