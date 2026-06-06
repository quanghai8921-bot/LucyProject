package com.lucy.lms.learner.service;

import com.lucy.lms.learner.dto.LearnerRoomDto;
import com.lucy.lms.learner.dto.RoomParticipantDto;
import com.lucy.lms.learner.entity.RoomParticipant;
import com.lucy.lms.learner.repository.RoomParticipantRepository;
import com.lucy.lms.mentor.entity.Room;
import com.lucy.lms.mentor.repository.RoomRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class LearnerRoomService {

    private static final String JOINED = "JOINED";

    private final RoomRepository roomRepository;
    private final RoomParticipantRepository participantRepository;

    public LearnerRoomService(RoomRepository roomRepository, RoomParticipantRepository participantRepository) {
        this.roomRepository = roomRepository;
        this.participantRepository = participantRepository;
    }

    public List<LearnerRoomDto> getAvailableRooms() {
        return roomRepository.findAll().stream()
                .filter(this::canLearnerJoin)
                .sorted(Comparator.comparing(Room::getScheduledStartAt))
                .map(this::toRoomDto)
                .toList();
    }

    @Transactional
    public RoomParticipantDto joinRoom(String roomId, String userId) {
        requireText(userId, "userId is required.");
        Room room = getRoom(roomId);
        if (!canLearnerJoin(room)) {
            throw new ResponseStatusException(BAD_REQUEST, "Room is not open for learners.");
        }

        LocalDateTime now = LocalDateTime.now();
        var existingParticipant = participantRepository
                .findFirstByRoomIdAndUserIdAndParticipantStatusOrderByJoinedAtDesc(roomId, userId, JOINED);
        if (existingParticipant.isPresent()) {
            RoomParticipant participant = existingParticipant.get();
            participant.markSeen(now);
            return new RoomParticipantDto(participantRepository.save(participant));
        }

        Integer currentCount = participantRepository.countByRoomIdAndParticipantStatus(roomId, JOINED);
        if (room.getMaxParticipants() != null && currentCount >= room.getMaxParticipants()) {
            throw new ResponseStatusException(BAD_REQUEST, "Room is full.");
        }

        RoomParticipant participant = new RoomParticipant(UUID.randomUUID().toString(), roomId, userId, now);
        return new RoomParticipantDto(participantRepository.save(participant));
    }

    @Transactional
    public RoomParticipantDto leaveRoom(String roomId, String userId) {
        RoomParticipant participant = getJoinedParticipant(roomId, userId);
        participant.leave(LocalDateTime.now());
        return new RoomParticipantDto(participantRepository.save(participant));
    }

    @Transactional
    public RoomParticipantDto updateMic(String roomId, String userId, Boolean enabled) {
        RoomParticipant participant = getJoinedParticipant(roomId, userId);
        participant.setMicStatus(Boolean.TRUE.equals(enabled) ? "ON" : "OFF", LocalDateTime.now());
        return new RoomParticipantDto(participantRepository.save(participant));
    }

    @Transactional
    public RoomParticipantDto updateHandRaise(String roomId, String userId, Boolean raised) {
        RoomParticipant participant = getJoinedParticipant(roomId, userId);
        participant.setHandRaiseStatus(Boolean.TRUE.equals(raised) ? "RAISED" : "NONE", LocalDateTime.now());
        return new RoomParticipantDto(participantRepository.save(participant));
    }

    public List<RoomParticipantDto> getRoomParticipants(String roomId) {
        return participantRepository.findByRoomIdAndParticipantStatus(roomId, JOINED).stream()
                .map(RoomParticipantDto::new)
                .toList();
    }

    private LearnerRoomDto toRoomDto(Room room) {
        String mentorName = roomRepository.findMentorFullNameByUserId(room.getHostUserId());
        room.setHostUserName(mentorName != null ? mentorName : room.getHostUserId());
        return new LearnerRoomDto(room, participantRepository.countByRoomIdAndParticipantStatus(room.getRoomId(), JOINED));
    }

    private Room getRoom(String roomId) {
        requireText(roomId, "roomId is required.");
        return roomRepository.findById(roomId)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Room not found."));
    }

    private RoomParticipant getJoinedParticipant(String roomId, String userId) {
        requireText(userId, "userId is required.");
        return participantRepository
                .findFirstByRoomIdAndUserIdAndParticipantStatusOrderByJoinedAtDesc(roomId, userId, JOINED)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Learner has not joined this room."));
    }

    private boolean canLearnerJoin(Room room) {
        String status = room.getRoomStatus();
        if (status == null) {
            return false;
        }
        String normalized = status.toUpperCase(Locale.ROOT);
        return normalized.equals("OPEN")
                || normalized.equals("LIVE")
                || normalized.equals("STUDYING")
                || normalized.equals("SCHEDULED");
    }

    private void requireText(String value, String message) {
        if (value == null || value.trim().isEmpty()) {
            throw new ResponseStatusException(BAD_REQUEST, message);
        }
    }
}
