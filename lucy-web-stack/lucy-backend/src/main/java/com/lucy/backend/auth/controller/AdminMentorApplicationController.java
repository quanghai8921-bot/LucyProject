package com.lucy.backend.auth.controller;

import com.lucy.backend.auth.dto.AdminMentorApplicationDto;
import com.lucy.backend.auth.entity.MentorApplication;
import com.lucy.backend.auth.entity.User;
import com.lucy.backend.auth.repository.MentorApplicationRepository;
import com.lucy.backend.auth.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/mentor-applications")
@CrossOrigin(originPatterns = "*")
public class AdminMentorApplicationController {

    private final MentorApplicationRepository mentorAppRepo;
    private final UserRepository userRepository;

    public AdminMentorApplicationController(MentorApplicationRepository mentorAppRepo, UserRepository userRepository) {
        this.mentorAppRepo = mentorAppRepo;
        this.userRepository = userRepository;
    }

    @GetMapping
    public ResponseEntity<?> getAllApplications() {
        List<MentorApplication> apps = mentorAppRepo.findAllByOrderBySubmittedAtDesc();
        List<AdminMentorApplicationDto> dtos = apps.stream().map(app -> {
            AdminMentorApplicationDto dto = new AdminMentorApplicationDto();
            dto.setApplicationId(app.getApplicationId());
            dto.setUserId(app.getUserId());
            dto.setLanguageId(app.getLanguageId());
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
        Optional<MentorApplication> appOpt = mentorAppRepo.findById(id);
        if (appOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("isSuccess", false, "message", "Application not found"));
        }
        MentorApplication app = appOpt.get();
        app.setStatus("APPROVED");
        mentorAppRepo.save(app);
        
        return ResponseEntity.ok(Map.of("isSuccess", true, "message", "Approved successfully"));
    }

    @PostMapping("/{id}/reject")
    public ResponseEntity<?> rejectApplication(@PathVariable String id, @RequestBody Map<String, String> body) {
        Optional<MentorApplication> appOpt = mentorAppRepo.findById(id);
        if (appOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("isSuccess", false, "message", "Application not found"));
        }
        MentorApplication app = appOpt.get();
        app.setStatus("REJECTED");
        app.setRejectReason(body.getOrDefault("reason", ""));
        mentorAppRepo.save(app);
        
        return ResponseEntity.ok(Map.of("isSuccess", true, "message", "Rejected successfully"));
    }
}
