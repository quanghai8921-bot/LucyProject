package com.lucy.lms.creator.controller;

import com.lucy.lms.creator.dto.UpdatePaidContentRequest;
import com.lucy.lms.creator.entity.PaidContent;
import com.lucy.lms.creator.service.CreatorContentService;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/creator/contents")
public class CreatorContentController {

    private final CreatorContentService creatorContentService;

    public CreatorContentController(CreatorContentService creatorContentService) {
        this.creatorContentService = creatorContentService;
    }

    @PostMapping("/videos")
    public PaidContent uploadVideo(
            @RequestParam String creatorUserId,
            @RequestParam String title,
            @RequestParam(required = false) String descriptionText,
            @RequestParam(required = false) BigDecimal priceAmount,
            @RequestPart("file") MultipartFile file) throws IOException {
        return creatorContentService.uploadVideo(creatorUserId, title, descriptionText, priceAmount, file);
    }

    @GetMapping("/creator/{creatorUserId}/videos")
    public List<PaidContent> getCreatorVideos(@PathVariable String creatorUserId) {
        return creatorContentService.getCreatorVideos(creatorUserId);
    }

    @GetMapping("/videos")
    public List<PaidContent> getPublishedVideos() {
        return creatorContentService.getPublishedVideos();
    }

    @GetMapping("/learner/{buyerUserId}/videos")
    public List<PaidContent> getPurchasedVideos(@PathVariable String buyerUserId) {
        return creatorContentService.getPurchasedVideos(buyerUserId);
    }

    @PatchMapping("/videos/{contentId}")
    public PaidContent updateVideo(@PathVariable String contentId, @RequestBody UpdatePaidContentRequest request) {
        return creatorContentService.updateVideo(contentId, request);
    }

    @PutMapping("/videos/{contentId}/file")
    public PaidContent replaceVideoFile(@PathVariable String contentId, @RequestPart("file") MultipartFile file)
            throws IOException {
        return creatorContentService.replaceVideoFile(contentId, file);
    }

    @DeleteMapping("/videos/{contentId}")
    public void deleteVideo(@PathVariable String contentId) {
        creatorContentService.deleteVideo(contentId);
    }
}
