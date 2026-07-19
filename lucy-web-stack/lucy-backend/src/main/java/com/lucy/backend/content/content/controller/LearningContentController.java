package com.lucy.backend.content.content.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.lucy.backend.content.content.dto.LevelContentDto;
import com.lucy.backend.content.content.service.LearningContentService;

@RestController
@RequestMapping("/api/v1/content")
public class LearningContentController {

    private final LearningContentService learningContentService;

    public LearningContentController(LearningContentService learningContentService) {
        this.learningContentService = learningContentService;
    }

    @GetMapping("/level-details")
    public ResponseEntity<LevelContentDto> getLevelDetails(
            @RequestParam String languageName,
            @RequestParam Integer levelNumber) {
        
        try {
            LevelContentDto result = learningContentService.getLevelContent(languageName, levelNumber);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
