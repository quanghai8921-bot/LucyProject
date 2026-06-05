package com.lucy.lms.creator.service;

import com.lucy.lms.creator.dto.CreateCreatorRoomRequest;
import com.lucy.lms.creator.dto.UpdateCreatorRoomRequest;
import com.lucy.lms.creator.entity.CreatorRoom;
import com.lucy.lms.creator.repository.CreatorRoomRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class CreatorRoomService {

    private final CreatorRoomRepository creatorRoomRepository;

    public CreatorRoomService(CreatorRoomRepository creatorRoomRepository) {
        this.creatorRoomRepository = creatorRoomRepository;
    }

    public CreatorRoom createRoom(CreateCreatorRoomRequest request) {
        CreatorRoom room = new CreatorRoom(
                UUID.randomUUID().toString(),
                request.getHostUserId(),
                request.getRoomTitle(),
                request.getScheduledStartAt(),
                request.getAccessType(),
                request.getPriceAmount(),
                request.getRecordOption(),
                request.getMaxParticipants(),
                "CREATED"
        );
        return creatorRoomRepository.save(room);
    }

    public CreatorRoom updateRoom(UpdateCreatorRoomRequest request) {
        CreatorRoom room = creatorRoomRepository.findById(request.getRoomId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng Creator: " + request.getRoomId()));

        room.setRoomTitle(request.getRoomTitle());
        room.setScheduledStartAt(request.getScheduledStartAt());
        room.setAccessType(request.getAccessType());
        room.setPriceAmount(request.getPriceAmount());
        room.setRecordOption(request.getRecordOption());
        room.setMaxParticipants(request.getMaxParticipants());
        return creatorRoomRepository.save(room);
    }

    @Transactional
    public CreatorRoom startRoom(String roomId) {
        CreatorRoom room = creatorRoomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng Creator: " + roomId));
        room.setStatus("LIVE");
        return creatorRoomRepository.save(room);
    }

    @Transactional
    public CreatorRoom endRoom(String roomId) {
        CreatorRoom room = creatorRoomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng Creator: " + roomId));
        room.setStatus("ENDED");
        return creatorRoomRepository.save(room);
    }

    public List<CreatorRoom> getRoomsByHost(String hostUserId) {
        return creatorRoomRepository.findByHostUserId(hostUserId);
    }

    public CreatorRoom getRoomById(String roomId) {
        return creatorRoomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng Creator: " + roomId));
    }
}
