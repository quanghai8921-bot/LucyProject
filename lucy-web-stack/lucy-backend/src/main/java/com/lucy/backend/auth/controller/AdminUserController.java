package com.lucy.backend.auth.controller;

import com.lucy.backend.auth.dto.AdminUserDto;
import com.lucy.backend.auth.entity.User;
import com.lucy.backend.auth.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/users")
@CrossOrigin(originPatterns = "*")
public class AdminUserController {

    private final UserRepository userRepository;

    public AdminUserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping
    public ResponseEntity<?> getAllUsers() {
        List<User> users = userRepository.findAll();
        List<AdminUserDto> dtos = users.stream().map(u -> {
            AdminUserDto dto = new AdminUserDto();
            dto.setUserId(u.getUserId());
            dto.setFullName(u.getFullName());
            dto.setEmail(u.getEmail());
            dto.setIsStatus(u.getIsStatus());
            return dto;
        }).collect(Collectors.toList());
        
        Map<String, Object> response = new HashMap<>();
        response.put("isSuccess", true);
        response.put("data", dtos);
        
        return ResponseEntity.ok(response);
    }
}
