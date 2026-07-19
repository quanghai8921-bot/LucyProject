package com.lucy.backend.realtime.controller;

import com.lucy.backend.realtime.dto.TokenRequestDto;
import com.lucy.backend.realtime.service.AgoraService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/agora")
public class AgoraController {

    private final AgoraService agoraService;

    public AgoraController(AgoraService agoraService) {
        this.agoraService = agoraService;
    }

    @PostMapping("/token")
    public ResponseEntity<Map<String, Object>> createToken(@RequestBody TokenRequestDto request) {
        try {
            Map<String, Object> tokenData = agoraService.createRtcToken(request);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", tokenData);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
}
