package com.lucy.lms.creator.controller;

import com.lucy.lms.creator.dto.CreateCreatorRoomRequest;
import com.lucy.lms.creator.dto.UpdateCreatorRoomRequest;
import com.lucy.lms.creator.entity.CreatorRoom;
import com.lucy.lms.creator.service.CreatorRoomService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/creator/rooms")
public class CreatorRoomController {

    private final CreatorRoomService creatorRoomService;

    public CreatorRoomController(CreatorRoomService creatorRoomService) {
        this.creatorRoomService = creatorRoomService;
    }

    @PostMapping
    public CreatorRoom createRoom(@RequestBody CreateCreatorRoomRequest request) {
        return creatorRoomService.createRoom(request);
    }

    @PutMapping
    public CreatorRoom updateRoom(@RequestBody UpdateCreatorRoomRequest request) {
        return creatorRoomService.updateRoom(request);
    }

    @PostMapping("/{roomId}/start")
    public CreatorRoom startRoom(@PathVariable String roomId) {
        return creatorRoomService.startRoom(roomId);
    }

    @PostMapping("/{roomId}/end")
    public CreatorRoom endRoom(@PathVariable String roomId) {
        return creatorRoomService.endRoom(roomId);
    }

    @GetMapping("/host/{hostUserId}")
    public List<CreatorRoom> getRoomsByHost(@PathVariable String hostUserId) {
        return creatorRoomService.getRoomsByHost(hostUserId);
    }

    @GetMapping("/{roomId}")
    public CreatorRoom getRoomById(@PathVariable String roomId) {
        return creatorRoomService.getRoomById(roomId);
    }
}
