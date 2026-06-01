package com.lucy.lms.mentor.controller;

import com.lucy.lms.mentor.dto.CreateMentorRoomRequest;
import com.lucy.lms.mentor.entity.Room;
import com.lucy.lms.mentor.service.RoomService;
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
}