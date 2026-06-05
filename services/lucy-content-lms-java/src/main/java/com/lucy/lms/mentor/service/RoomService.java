package com.lucy.lms.mentor.service;

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

    public RoomService(RoomRepository roomRepository) {
        this.roomRepository = roomRepository;
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
                "SCHEDULED",
                request.getMaxParticipants(),
                LocalDateTime.now());

        return roomRepository.save(room);
    }

    public List<Room> getAllRooms() {
        return roomRepository.findAll();
    }

    public List<Room> getRoomsByMentor(String hostUserId) {
        return roomRepository.findByHostUserId(hostUserId);
    }
}