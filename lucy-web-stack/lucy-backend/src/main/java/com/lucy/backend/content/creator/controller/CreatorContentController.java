package com.lucy.backend.content.creator.controller;

import com.lucy.backend.content.creator.dto.UpdatePaidContentRequest;
import com.lucy.backend.content.creator.entity.PaidContent;
import com.lucy.backend.content.creator.service.CreatorContentService;

import org.springframework.http.ResponseEntity;
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

    // 🌟 1. GỘP VÀ CHUẨN HÓA API GỐC VỀ ĐÚNG ĐƯỜNG DẪN /api/creator/contents
    @GetMapping("")
    public ResponseEntity<?> getCreatorContents(
            @RequestParam(value = "creatorUserId", required = false) String creatorUserId) {

        // Nếu phía Frontend có truyền creatorUserId lên, lọc nội dung của riêng Creator
        // đó
        if (creatorUserId != null && !creatorUserId.isBlank()) {
            List<PaidContent> myContents = creatorContentService.getContentsByCreatorId(creatorUserId);
            return ResponseEntity.ok(myContents);
        }

        // Ngược lại nếu không truyền (Ví dụ bên LearnerHome gọi), trả về tất cả để
        // người học xem và tự lọc PUBLISHED
        List<PaidContent> allContents = creatorContentService.getAllContents();
        return ResponseEntity.ok(allContents);
    }

    @PostMapping("")
    public PaidContent createContent(
            @RequestParam String creatorUserId,
            @RequestParam String contentType,
            @RequestParam String title,
            @RequestParam(required = false) String descriptionText,
            @RequestParam(required = false) BigDecimal priceAmount,
            @RequestParam(required = false) String contentStatus,
            @RequestPart(value = "file", required = false) MultipartFile file) throws java.io.IOException {
        return creatorContentService.createContent(creatorUserId, contentType, title, descriptionText, priceAmount,
                contentStatus, file);
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

    @GetMapping("/learner/{buyerUserId}/purchased")
    public List<PaidContent> getPurchasedContents(@PathVariable String buyerUserId) {
        return creatorContentService.getPurchasedContents(buyerUserId);
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