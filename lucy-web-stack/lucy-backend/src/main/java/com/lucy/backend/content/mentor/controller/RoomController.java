package com.lucy.backend.content.mentor.controller;

import com.lucy.backend.content.mentor.dto.CreateMentorRoomRequest;
import com.lucy.backend.content.mentor.entity.Room;
import com.lucy.backend.content.mentor.entity.RoomSubLevel;
import com.lucy.backend.content.mentor.service.RoomService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/mentor/rooms")
public class RoomController {

    private final RoomService roomService;

    public RoomController(RoomService roomService) {
        this.roomService = roomService;
    }

    @PostMapping
    public Room createRoom(@RequestBody CreateMentorRoomRequest request) {
        return roomService.createRoom(request);
    }

    @GetMapping
    public List<Room> getAllRooms() {
        return roomService.getAllRooms();
    }

    @GetMapping("/mentor/{hostUserId}")
    public List<Room> getRoomsByMentor(@PathVariable String hostUserId) {
        return roomService.getRoomsByMentor(hostUserId);
    }

    @PostMapping("/{roomId}/end")
    public Room endRoom(
            @PathVariable String roomId,
            @RequestParam(value = "endLevel", required = false, defaultValue = "false") boolean endLevel) {
        return roomService.endRoom(roomId, endLevel);
    }

    @GetMapping("/{roomId}/participants")
    public List<com.lucy.backend.content.learner.dto.RoomParticipantDto> getRoomParticipants(
            @PathVariable String roomId) {
        return roomService.getRoomParticipants(roomId);
    }

    @PostMapping("/{roomId}/open")
    public Room openRoom(@PathVariable String roomId) {
        return roomService.openRoom(roomId);
    }

    @PostMapping("/{roomId}/sublevels/{subLevelId}/complete")
    public RoomSubLevel completeSubLevel(@PathVariable String roomId, @PathVariable String subLevelId) {
        return roomService.completeSubLevel(roomId, subLevelId);
    }

}
