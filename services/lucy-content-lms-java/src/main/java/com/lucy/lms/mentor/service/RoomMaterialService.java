package com.lucy.lms.mentor.service;

import com.lucy.lms.mentor.dto.CreateRoomMaterialRequest;
import com.lucy.lms.mentor.entity.RoomMaterial;
import com.lucy.lms.mentor.repository.RoomMaterialRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class RoomMaterialService {

    private final RoomMaterialRepository roomMaterialRepository;

    public RoomMaterialService(RoomMaterialRepository roomMaterialRepository) {
        this.roomMaterialRepository = roomMaterialRepository;
    }

    public RoomMaterial createMaterial(CreateRoomMaterialRequest request) {
        RoomMaterial material = new RoomMaterial(
                UUID.randomUUID().toString(),
                request.getRoomId(),
                request.getUploadedBy(),
                request.getFileName(),
                request.getFileUrl(),
                request.getFileType(),
                LocalDateTime.now(),
                true);

        return roomMaterialRepository.save(material);
    }

    public List<RoomMaterial> getMaterialsByRoom(String roomId) {
        return roomMaterialRepository.findByRoomId(roomId);
    }
}