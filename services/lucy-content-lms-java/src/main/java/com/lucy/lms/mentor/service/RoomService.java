package com.lucy.lms.mentor.service;

import com.lucy.lms.learner.repository.RoomParticipantRepository;
import com.lucy.lms.mentor.dto.CreateMentorRoomRequest;
import com.lucy.lms.mentor.entity.Room;
import com.lucy.lms.mentor.repository.RoomRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class RoomService {

    private final RoomRepository roomRepository;
    private final RoomParticipantRepository participantRepository;

    public RoomService(RoomRepository roomRepository, RoomParticipantRepository participantRepository) {
        this.roomRepository = roomRepository;
        this.participantRepository = participantRepository;
    }

    public Room createRoom(CreateMentorRoomRequest request) {

        Room room = new Room(
                UUID.randomUUID().toString(),
                request.getHostUserId(),
                "MENTOR",
                request.getLevelId(),
                request.getLanguageId(),
                request.getRoomTitle(),
                "LIVE",
                "FREE",
                BigDecimal.ZERO,
                request.getScheduledStartAt(),
                request.getRoomStatus() != null ? request.getRoomStatus() : "SCHEDULED",
                request.getMaxParticipants(),
                LocalDateTime.now());

        Room saved = roomRepository.save(room);
        enrichRoom(saved);
        return saved;
    }

    public List<Room> getAllRooms() {
        List<Room> rooms = roomRepository.findAll();
        rooms.forEach(this::enrichRoom);
        return rooms;
    }

    public List<Room> getRoomsByMentor(String hostUserId) {
        List<Room> rooms = roomRepository.findByHostUserId(hostUserId);
        rooms.forEach(this::enrichRoom);
        return rooms;
    }

    public Room endRoom(String roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Room not found: " + roomId));
        room.setRoomStatus("ENDED");
        room.setEndedAt(LocalDateTime.now());
        Room saved = roomRepository.save(room);
        enrichRoom(saved);
        return saved;
    }

    public Room openRoom(String roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Room not found: " + roomId));
        room.setRoomStatus("OPEN");
        if (room.getStudyStartedAt() == null) {
            room.setStudyStartedAt(LocalDateTime.now());
        }
        Room saved = roomRepository.save(room);
        enrichRoom(saved);
        return saved;
    }

    private void enrichRoom(Room room) {
        String mentorName = roomRepository.findMentorFullNameByUserId(room.getHostUserId());
        room.setHostUserName(mentorName != null ? mentorName : room.getHostUserId());
        room.setParticipantCount(participantRepository.countByRoomIdAndParticipantStatus(room.getRoomId(), "JOINED"));
    }
}
