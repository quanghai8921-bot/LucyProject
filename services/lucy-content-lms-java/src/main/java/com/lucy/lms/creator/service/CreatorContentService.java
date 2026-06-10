package com.lucy.lms.creator.service;

import com.lucy.lms.creator.dto.UpdatePaidContentRequest;
import com.lucy.lms.creator.entity.ContentPurchase;
import com.lucy.lms.creator.entity.PaidContent;
import com.lucy.lms.creator.repository.ContentPurchaseRepository;
import com.lucy.lms.creator.repository.PaidContentRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class CreatorContentService {

    private static final String VIDEO_TYPE = "VIDEO";
    private static final String PUBLISHED = "PUBLISHED";

    private final PaidContentRepository paidContentRepository;
    private final ContentPurchaseRepository contentPurchaseRepository;
    private final Path uploadRoot = Path.of("uploads", "creator-videos");

    public CreatorContentService(
            PaidContentRepository paidContentRepository,
            ContentPurchaseRepository contentPurchaseRepository) {
        this.paidContentRepository = paidContentRepository;
        this.contentPurchaseRepository = contentPurchaseRepository;
    }

    public PaidContent uploadVideo(
            String creatorUserId,
            String title,
            String descriptionText,
            BigDecimal priceAmount,
            MultipartFile file) throws IOException {
        String mediaUrl = storeVideoFile(file);
        PaidContent content = new PaidContent(
                UUID.randomUUID().toString(),
                creatorUserId,
                VIDEO_TYPE,
                title,
                descriptionText,
                mediaUrl,
                priceAmount != null ? priceAmount : BigDecimal.ZERO,
                PUBLISHED,
                LocalDateTime.now());
        return paidContentRepository.save(content);
    }

    public List<PaidContent> getCreatorVideos(String creatorUserId) {
        return paidContentRepository.findByCreatorUserIdOrderByPublishedAtDesc(creatorUserId);
    }

    public List<PaidContent> getPublishedVideos() {
        return paidContentRepository.findByContentTypeAndContentStatusOrderByPublishedAtDesc(VIDEO_TYPE, PUBLISHED);
    }

    public List<PaidContent> getPurchasedVideos(String buyerUserId) {
        List<ContentPurchase> purchases = contentPurchaseRepository.findByBuyerUserIdOrderByPurchasedAtDesc(buyerUserId);
        List<PaidContent> videos = new ArrayList<>();
        for (ContentPurchase purchase : purchases) {
            paidContentRepository.findById(purchase.getContentId())
                    .filter(content -> VIDEO_TYPE.equalsIgnoreCase(content.getContentType()))
                    .ifPresent(videos::add);
        }
        return videos;
    }

    public PaidContent updateVideo(String contentId, UpdatePaidContentRequest request) {
        PaidContent content = paidContentRepository.findById(contentId)
                .orElseThrow(() -> new IllegalArgumentException("Content not found: " + contentId));
        if (request.getTitle() != null && !request.getTitle().isBlank()) {
            content.setTitle(request.getTitle().trim());
        }
        if (request.getDescriptionText() != null) {
            content.setDescriptionText(request.getDescriptionText());
        }
        if (request.getPriceAmount() != null) {
            content.setPriceAmount(request.getPriceAmount());
        }
        if (request.getContentStatus() != null && !request.getContentStatus().isBlank()) {
            content.setContentStatus(request.getContentStatus().trim().toUpperCase());
        }
        return paidContentRepository.save(content);
    }

    public PaidContent replaceVideoFile(String contentId, MultipartFile file) throws IOException {
        PaidContent content = paidContentRepository.findById(contentId)
                .orElseThrow(() -> new IllegalArgumentException("Content not found: " + contentId));
        content.setMediaUrl(storeVideoFile(file));
        return paidContentRepository.save(content);
    }

    public void deleteVideo(String contentId) {
        paidContentRepository.deleteById(contentId);
    }

    private String storeVideoFile(MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("Video file is required.");
        }
        Files.createDirectories(uploadRoot);
        String originalName = file.getOriginalFilename() == null ? "video" : Path.of(file.getOriginalFilename()).getFileName().toString();
        String storedName = UUID.randomUUID() + "_" + originalName.replaceAll("[^a-zA-Z0-9._-]", "_");
        Path target = uploadRoot.resolve(storedName).normalize();
        if (!target.startsWith(uploadRoot)) {
            throw new IllegalArgumentException("Invalid file name.");
        }
        Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
        return "/uploads/creator-videos/" + storedName;
    }
}
