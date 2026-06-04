package com.lucy.lms.mentor.controller;

import com.lucy.lms.mentor.dto.SendGiftRequest;
import com.lucy.lms.mentor.entity.RoomGiftEvent;
import com.lucy.lms.mentor.repository.RoomGiftEventRepository;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/mentor/rooms/{roomId}/gifts")
public class RoomGiftController {

    private final RoomGiftEventRepository roomGiftEventRepository;

    public RoomGiftController(RoomGiftEventRepository roomGiftEventRepository) {
        this.roomGiftEventRepository = roomGiftEventRepository;
    }

    @PostMapping
    public RoomGiftEvent sendGift(@PathVariable String roomId,
                                  @RequestBody SendGiftRequest request) {
        RoomGiftEvent event = new RoomGiftEvent(
                UUID.randomUUID().toString(),
                roomId,
                request.getSenderId(),
                request.getToUserId(),
                request.getAmount(),
                request.getMessageText(),
                LocalDateTime.now()
        );

        event.setGiftName(request.getGiftName());
        event.setGiftType(request.getGiftType() != null ? request.getGiftType() : "DONATE");
        event.setSenderDisplayName(request.getSenderDisplayName());

        return roomGiftEventRepository.save(event);
    }

    @GetMapping
    public List<RoomGiftEvent> getRoomGifts(@PathVariable String roomId) {
        return roomGiftEventRepository.findByRoomId(roomId);
    }
}
