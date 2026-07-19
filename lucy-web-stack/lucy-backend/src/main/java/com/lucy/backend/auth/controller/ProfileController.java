package com.lucy.backend.auth.controller;

import com.lucy.backend.auth.dto.ProfileDto;
import com.lucy.backend.auth.dto.ProfileUpdateDto;
import com.lucy.backend.auth.entity.AvatarPersona;
import com.lucy.backend.auth.entity.User;
import com.lucy.backend.auth.repository.AvatarPersonaRepository;
import com.lucy.backend.auth.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/user/profile")
public class ProfileController {

    private final UserRepository userRepository;
    private final AvatarPersonaRepository avatarPersonaRepository;

    public ProfileController(UserRepository userRepository, AvatarPersonaRepository avatarPersonaRepository) {
        this.userRepository = userRepository;
        this.avatarPersonaRepository = avatarPersonaRepository;
    }

    private String getCurrentUserId() {
        return SecurityContextHolder.getContext().getAuthentication().getName();
    }

    @GetMapping
    public ResponseEntity<ProfileDto> getProfile() {
        String userId = getCurrentUserId();
        User user = userRepository.findById(userId).orElseThrow();
        
        ProfileDto dto = new ProfileDto();
        dto.setUserId(user.getUserId());
        dto.setFullName(user.getFullName());
        
        Optional<AvatarPersona> personaOpt = avatarPersonaRepository.findById(userId);
        if (personaOpt.isPresent()) {
            dto.setDisplayName(personaOpt.get().getDisplayName());
            dto.setAvatarUrl(personaOpt.get().getAvatarUrl());
        } else {
            dto.setDisplayName(user.getFullName()); // Fallback
        }
        
        return ResponseEntity.ok(dto);
    }

    @PutMapping
    public ResponseEntity<ProfileDto> updateProfile(@RequestBody ProfileUpdateDto updateDto) {
        String userId = getCurrentUserId();
        User user = userRepository.findById(userId).orElseThrow();
        
        AvatarPersona persona = avatarPersonaRepository.findById(userId)
                .orElseGet(() -> {
                    AvatarPersona p = new AvatarPersona();
                    p.setUserId(userId);
                    return p;
                });
                
        persona.setDisplayName(updateDto.getDisplayName());
        if (updateDto.getAvatarUrl() != null) {
            persona.setAvatarUrl(updateDto.getAvatarUrl());
        }
        avatarPersonaRepository.save(persona);
        
        ProfileDto dto = new ProfileDto();
        dto.setUserId(user.getUserId());
        dto.setFullName(user.getFullName());
        dto.setDisplayName(persona.getDisplayName());
        dto.setAvatarUrl(persona.getAvatarUrl());
        
        return ResponseEntity.ok(dto);
    }

    @PostMapping("/avatar")
    public ResponseEntity<String> uploadAvatar(@RequestParam("file") org.springframework.web.multipart.MultipartFile file) {
        try {
            String uploadsDir = "uploads/avatars/";
            java.io.File dir = new java.io.File(uploadsDir);
            if (!dir.exists()) dir.mkdirs();
            
            String filename = System.currentTimeMillis() + "_" + file.getOriginalFilename();
            java.nio.file.Path path = java.nio.file.Paths.get(uploadsDir + filename);
            java.nio.file.Files.write(path, file.getBytes());
            
            // update db directly here or return URL
            String avatarUrl = "http://localhost:8081/" + uploadsDir + filename;
            
            String userId = getCurrentUserId();
            AvatarPersona persona = avatarPersonaRepository.findById(userId)
                    .orElseGet(() -> {
                        AvatarPersona p = new AvatarPersona();
                        p.setUserId(userId);
                        return p;
                    });
            persona.setAvatarUrl(avatarUrl);
            avatarPersonaRepository.save(persona);
            
            return ResponseEntity.ok(avatarUrl);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Error uploading file");
        }
    }

    @GetMapping("/avatar")
    public ResponseEntity<java.util.Map<String, String>> getAvatar() {
        String userId = getCurrentUserId();
        Optional<AvatarPersona> personaOpt = avatarPersonaRepository.findById(userId);
        java.util.Map<String, String> response = new java.util.HashMap<>();
        if (personaOpt.isPresent() && personaOpt.get().getAvatarUrl() != null) {
            response.put("url", personaOpt.get().getAvatarUrl());
        } else {
            response.put("url", "");
        }
        return ResponseEntity.ok(response);
    }
}
