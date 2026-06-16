package com.lucy.lms.learner.controller;

import com.lucy.lms.learner.dto.SubmitQuizRequest;
import com.lucy.lms.learner.dto.SubmitQuizResponse;
import com.lucy.lms.mentor.entity.RoomQuizAttempt;
import com.lucy.lms.mentor.service.RoomQuizService;
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
    public List<com.lucy.lms.mentor.dto.RoomQuizAttemptDto> getLearnerAssignedQuizzes(@PathVariable String userId) {
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
