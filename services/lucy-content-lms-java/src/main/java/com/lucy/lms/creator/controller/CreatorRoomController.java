package com.lucy.lms.creator.controller;

import com.lucy.lms.creator.dto.CreateCreatorRoomRequest;
import com.lucy.lms.creator.dto.CreatePaidContentRequest;
import com.lucy.lms.creator.entity.PaidContent;
import com.lucy.lms.creator.service.CreatorRoomService;
import com.lucy.lms.mentor.entity.Room;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/creator/rooms")
public class CreatorRoomController {

    private final CreatorRoomService creatorRoomService;

    public CreatorRoomController(CreatorRoomService creatorRoomService) {
        this.creatorRoomService = creatorRoomService;
    }

    @PostMapping
    public Room createRoom(@RequestBody CreateCreatorRoomRequest request) {
        return creatorRoomService.createRoom(request);
    }

    @PostMapping("/{roomId}/start")
    public Room startRoom(@PathVariable String roomId) {
        return creatorRoomService.startRoom(roomId);
    }

    @PostMapping("/{roomId}/end")
    public Room endRoom(@PathVariable String roomId,
                        @RequestParam(defaultValue = "true") boolean convertToPodcast) {
        return creatorRoomService.endRoom(roomId, convertToPodcast);
    }

    @PostMapping("/contents")
    public PaidContent createPaidContent(@RequestBody CreatePaidContentRequest request) {
        return creatorRoomService.createPaidContent(request);
    }

    @GetMapping("/contents")
    public List<PaidContent> getCreatorContents(@RequestParam String creatorId) {
        return creatorRoomService.getContentsByCreator(creatorId);
    }

    @GetMapping("/podcasts")
    public List<PaidContent> getPodcasts(@RequestParam String creatorId) {
        return creatorRoomService.getPodcastsByCreator(creatorId);
    }

    @PostMapping("/podcasts/{contentId}/publish")
    public PaidContent publishPodcast(@PathVariable String contentId,
                                      @RequestParam(required = false) BigDecimal price) {
        return creatorRoomService.publishPodcast(contentId, price);
    }

    // === Mentor Features for Creator (Level Up Support) ===

    @GetMapping("/level-details")
    public java.util.Map<String, Object> getLevelDetails(
            @RequestParam String languageId,
            @RequestParam Integer levelNumber) {
        return creatorRoomService.getLevelDetailsByLanguageAndNumber(languageId, levelNumber);
    }

    @GetMapping("/my-rooms")
    public List<Room> getCreatorRooms(@RequestParam String creatorId) {
        return creatorRoomService.getRoomsByCreator(creatorId);
    }

    @GetMapping("/{roomId}")
    public Room getRoomDetail(@PathVariable String roomId) {
        return creatorRoomService.getMentorRoom(roomId);
    }
}
