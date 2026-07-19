package com.lucy.backend.auth.controller;

import com.lucy.backend.auth.dto.AuthResponse;
import com.lucy.backend.auth.dto.LoginRequest;
import com.lucy.backend.auth.dto.RegisterRequest;
import com.lucy.backend.auth.service.AuthService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(originPatterns = "*")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    // 🌟 BƯỚC 1: API Nhận Email và yêu cầu gửi mã xác nhận
    @PostMapping("/forgot-password/request")
    public ResponseEntity<?> requestForgotPasswordKey(@RequestBody Map<String, String> request) {
        try {
            String email = request.get("email");
            authService.requestForgotPasswordKey(email);
            return ResponseEntity.ok(Map.of("message", "Mã xác nhận đã được gửi thành công!"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", e.getMessage()));
        }
    }

    // 🌟 BƯỚC 2: API Xác minh mã Key người dùng nhập vào
    @PostMapping("/forgot-password/verify")
    public ResponseEntity<?> verifyForgotPasswordKey(@RequestBody Map<String, String> request) {
        try {
            String email = request.get("email");
            String key = request.get("key");
            authService.verifyForgotPasswordKey(email, key);
            return ResponseEntity.ok(Map.of("message", "Mã xác nhận chính xác!"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", e.getMessage()));
        }
    }

    // 🌟 BƯỚC 3: API Tiến hành đổi mật khẩu mới
    @PostMapping("/forgot-password/reset")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> request) {
        try {
            String email = request.get("email");
            String key = request.get("key");
            String newPassword = request.get("newPassword");
            authService.resetPassword(email, key, newPassword);
            return ResponseEntity.ok(Map.of("message", "Đặt lại mật khẩu thành công!"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody LoginRequest request) {
        System.out.println("REACHED CONTROLLER! Email: " + request.getEmail());
        try {
            AuthResponse response = authService.login(request);
            Map<String, Object> body = new HashMap<>();
            body.put("isSuccess", true);
            body.put("data", response);
            return ResponseEntity.ok(body);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("isSuccess", false);
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@RequestBody RegisterRequest request) {
        try {
            AuthResponse response = authService.register(request);
            Map<String, Object> body = new HashMap<>();
            body.put("isSuccess", true);
            body.put("data", response);
            return ResponseEntity.ok(body);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("isSuccess", false);
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
}
