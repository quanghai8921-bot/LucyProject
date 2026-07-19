package com.lucy.backend.content.learner.controller;

import com.lucy.backend.content.learner.dto.SubmitQuizRequest;
import com.lucy.backend.content.learner.dto.SubmitQuizResponse;
import com.lucy.backend.content.mentor.entity.RoomQuizAttempt;
import com.lucy.backend.content.mentor.service.RoomQuizService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/learner/quizzes")
public class LearnerQuizController {

    private final RoomQuizService roomQuizService;

    public LearnerQuizController(RoomQuizService roomQuizService) {
        this.roomQuizService = roomQuizService;
    }

    @GetMapping("/{userId}")
    public List<com.lucy.backend.content.mentor.dto.RoomQuizAttemptDto> getLearnerAssignedQuizzes(@PathVariable String userId) {
        return roomQuizService.getLearnerAssignedQuizzes(userId);
    }

    @PostMapping("/attempt/{attemptId}/start")
    public RoomQuizAttempt startQuiz(@PathVariable String attemptId) {
        return roomQuizService.startQuiz(attemptId);
    }

    @PostMapping("/attempt/{attemptId}/submit")
    public SubmitQuizResponse submitQuiz(@PathVariable String attemptId, @RequestBody SubmitQuizRequest request) {
        return roomQuizService.submitQuiz(attemptId, request);
    }
}
