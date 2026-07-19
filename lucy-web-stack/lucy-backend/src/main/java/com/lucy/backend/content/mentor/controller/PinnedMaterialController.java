package com.lucy.backend.content.mentor.controller;

import com.lucy.backend.content.mentor.entity.PinnedMaterial;
import com.lucy.backend.content.mentor.repository.PinnedMaterialRepository;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/mentor/rooms/{roomId}/pinned-materials")
@CrossOrigin(originPatterns = "*")
public class PinnedMaterialController {

    private final PinnedMaterialRepository pinnedMaterialRepository;
    private final Path uploadRoot = Path.of("uploads");

    public PinnedMaterialController(PinnedMaterialRepository pinnedMaterialRepository) {
        this.pinnedMaterialRepository = pinnedMaterialRepository;
    }

    @GetMapping
    public ResponseEntity<List<PinnedMaterial>> getPinnedMaterials(@PathVariable String roomId) {
        return ResponseEntity.ok(pinnedMaterialRepository.findByRoomIdOrderByDisplayOrderAsc(roomId));
    }

    @PostMapping
    public ResponseEntity<?> uploadAndPin(
            HttpServletRequest request,
            @PathVariable String roomId,
            @RequestParam("file") MultipartFile file,
            @RequestParam("title") String title) {
        try {
            if (file == null || file.isEmpty()) {
                return ResponseEntity.badRequest().body("File is empty");
            }

            // Resolve current user id
            String userId = null;
            if (org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication() != null) {
                userId = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication().getName();
            }
            if (userId == null || userId.trim().isEmpty() || "anonymousUser".equals(userId)) {
                userId = request.getHeader("X-User-Id");
            }
            if (userId == null || userId.trim().isEmpty()) {
                return ResponseEntity.badRequest().body("Missing User ID");
            }

            // Save file
            Files.createDirectories(uploadRoot);
            String originalName = file.getOriginalFilename() == null ? "file" : Path.of(file.getOriginalFilename()).getFileName().toString();
            String fileExtension = "";
            int dotIdx = originalName.lastIndexOf('.');
            if (dotIdx > 0) {
                fileExtension = originalName.substring(dotIdx + 1).toUpperCase();
            }

            String storedName = UUID.randomUUID() + "_" + originalName.replaceAll("[^a-zA-Z0-9._-]", "_");
            Path target = uploadRoot.resolve(storedName).normalize();
            file.transferTo(target);

            // Save pinned material record
            PinnedMaterial material = new PinnedMaterial();
            material.setPinnedMaterialId(UUID.randomUUID().toString());
            material.setRoomId(roomId);
            material.setUploadedByUserId(userId);
            material.setTitle(title);
            material.setFileUrl("/uploads/" + storedName);
            material.setFileType(fileExtension);
            material.setFileSize(file.getSize());
            material.setDisplayOrder(1);
            material.setIsActive(1);
            material.setCreatedAt(LocalDateTime.now());

            pinnedMaterialRepository.save(material);

            return ResponseEntity.ok(material);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().body("Failed to store file: " + e.getMessage());
        }
    }

    @DeleteMapping("/{pinnedMaterialId}")
    public ResponseEntity<?> unpinMaterial(@PathVariable String roomId, @PathVariable String pinnedMaterialId) {
        pinnedMaterialRepository.deleteById(pinnedMaterialId);
        return ResponseEntity.ok().build();
    }
}
