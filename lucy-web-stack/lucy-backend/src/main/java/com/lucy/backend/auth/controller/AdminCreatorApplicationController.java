package com.lucy.backend.auth.controller;

import com.lucy.backend.auth.dto.AdminCreatorApplicationDto;
import com.lucy.backend.auth.entity.ContentCreatorApplication;
import com.lucy.backend.auth.entity.User;
import com.lucy.backend.auth.repository.ContentCreatorApplicationRepository;
import com.lucy.backend.auth.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/creator-applications")
@CrossOrigin(originPatterns = "*")
public class AdminCreatorApplicationController {

    private final ContentCreatorApplicationRepository creatorAppRepo;
    private final UserRepository userRepository;

    public AdminCreatorApplicationController(ContentCreatorApplicationRepository creatorAppRepo, UserRepository userRepository) {
        this.creatorAppRepo = creatorAppRepo;
        this.userRepository = userRepository;
    }

    @GetMapping
    public ResponseEntity<?> getAllApplications() {
        List<ContentCreatorApplication> apps = creatorAppRepo.findAllByOrderBySubmittedAtDesc();
        List<AdminCreatorApplicationDto> dtos = apps.stream().map(app -> {
            AdminCreatorApplicationDto dto = new AdminCreatorApplicationDto();
            dto.setApplicationId(app.getApplicationId());
            dto.setUserId(app.getUserId());
            dto.setCertificateUrl(app.getCertificateUrl());
            dto.setStatus(app.getStatus());
            dto.setRejectReason(app.getRejectReason());
            dto.setSubmittedAt(app.getSubmittedAt());
            
            Optional<User> userOpt = userRepository.findById(app.getUserId());
            if (userOpt.isPresent()) {
                dto.setFullName(userOpt.get().getFullName());
                dto.setEmail(userOpt.get().getEmail());
            }
            return dto;
        }).collect(Collectors.toList());
        
        Map<String, Object> response = new HashMap<>();
        response.put("isSuccess", true);
        response.put("data", dtos);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{id}/approve")
    public ResponseEntity<?> approveApplication(@PathVariable String id) {
        Optional<ContentCreatorApplication> appOpt = creatorAppRepo.findById(id);
        if (appOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("isSuccess", false, "message", "Application not found"));
        }
        ContentCreatorApplication app = appOpt.get();
        app.setStatus("APPROVED");
        creatorAppRepo.save(app);
        
        return ResponseEntity.ok(Map.of("isSuccess", true, "message", "Approved successfully"));
    }

    @PostMapping("/{id}/reject")
    public ResponseEntity<?> rejectApplication(@PathVariable String id, @RequestBody Map<String, String> body) {
        Optional<ContentCreatorApplication> appOpt = creatorAppRepo.findById(id);
        if (appOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("isSuccess", false, "message", "Application not found"));
        }
        ContentCreatorApplication app = appOpt.get();
        app.setStatus("REJECTED");
        app.setRejectReason(body.getOrDefault("reason", ""));
        creatorAppRepo.save(app);
        
        return ResponseEntity.ok(Map.of("isSuccess", true, "message", "Rejected successfully"));
    }
}
