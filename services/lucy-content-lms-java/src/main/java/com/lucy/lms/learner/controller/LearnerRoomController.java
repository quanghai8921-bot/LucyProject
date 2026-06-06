package com.lucy.lms.learner.controller;

import com.lucy.lms.learner.dto.JoinRoomRequest;
import com.lucy.lms.learner.dto.LearnerRoomDto;
import com.lucy.lms.learner.dto.RoomParticipantDto;
import com.lucy.lms.learner.dto.UpdateHandRaiseRequest;
import com.lucy.lms.learner.dto.UpdateMicRequest;
import com.lucy.lms.learner.service.LearnerRoomService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/learner/rooms")
public class LearnerRoomController {

    private final LearnerRoomService learnerRoomService;

    public LearnerRoomController(LearnerRoomService learnerRoomService) {
        this.learnerRoomService = learnerRoomService;
    }

    @GetMapping
    public List<LearnerRoomDto> getAvailableRooms() {
        return learnerRoomService.getAvailableRooms();
    }

    @PostMapping("/{roomId}/join")
    public RoomParticipantDto joinRoom(@PathVariable String roomId, @RequestBody JoinRoomRequest request) {
        return learnerRoomService.joinRoom(roomId, request.getUserId());
    }

    @PostMapping("/{roomId}/leave")
    public RoomParticipantDto leaveRoom(@PathVariable String roomId, @RequestBody JoinRoomRequest request) {
        return learnerRoomService.leaveRoom(roomId, request.getUserId());
    }

    @PatchMapping("/{roomId}/mic")
    public RoomParticipantDto updateMic(@PathVariable String roomId, @RequestBody UpdateMicRequest request) {
        return learnerRoomService.updateMic(roomId, request.getUserId(), request.getEnabled());
    }

    @PatchMapping("/{roomId}/hand-raise")
    public RoomParticipantDto updateHandRaise(
            @PathVariable String roomId,
            @RequestBody UpdateHandRaiseRequest request) {
        return learnerRoomService.updateHandRaise(roomId, request.getUserId(), request.getRaised());
    }

    @GetMapping("/{roomId}/participants")
    public List<RoomParticipantDto> getRoomParticipants(@PathVariable String roomId) {
        return learnerRoomService.getRoomParticipants(roomId);
    }
}
