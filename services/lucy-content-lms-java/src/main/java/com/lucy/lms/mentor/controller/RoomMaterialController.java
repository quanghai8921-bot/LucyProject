package com.lucy.lms.mentor.controller;

import com.lucy.lms.mentor.dto.CreateRoomMaterialRequest;
import com.lucy.lms.mentor.entity.RoomMaterial;
import com.lucy.lms.mentor.service.RoomMaterialService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/mentor/room-materials")
public class RoomMaterialController {

    private final RoomMaterialService roomMaterialService;

    public RoomMaterialController(RoomMaterialService roomMaterialService) {
        this.roomMaterialService = roomMaterialService;
    }

    @PostMapping
    public RoomMaterial createMaterial(@RequestBody CreateRoomMaterialRequest request) {
        return roomMaterialService.createMaterial(request);
    }

    @GetMapping("/room/{roomId}")
    public List<RoomMaterial> getMaterialsByRoom(@PathVariable String roomId) {
        return roomMaterialService.getMaterialsByRoom(roomId);
    }
}