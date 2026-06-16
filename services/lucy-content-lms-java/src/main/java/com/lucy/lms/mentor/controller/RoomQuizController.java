package com.lucy.lms.mentor.controller;

import com.lucy.lms.mentor.dto.CreateRoomQuizOptionRequest;
import com.lucy.lms.mentor.dto.CreateRoomQuizQuestionRequest;
import com.lucy.lms.mentor.dto.CreateRoomQuizRequest;
import com.lucy.lms.mentor.entity.RoomQuiz;
import com.lucy.lms.mentor.entity.RoomQuizOption;
import com.lucy.lms.mentor.entity.RoomQuizQuestion;
import com.lucy.lms.mentor.service.RoomQuizService;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.util.List;

@RestController
@RequestMapping("/api/mentor/room-quizzes")
public class RoomQuizController {

    private final RoomQuizService roomQuizService;

    public RoomQuizController(RoomQuizService roomQuizService) {
        this.roomQuizService = roomQuizService;
    }

    @PostMapping
    public RoomQuiz createQuiz(@RequestBody CreateRoomQuizRequest request) {
        return roomQuizService.createQuiz(request);
    }

    @PostMapping("/questions")
    public RoomQuizQuestion createQuestion(@RequestBody CreateRoomQuizQuestionRequest request) {
        return roomQuizService.createQuestion(request);
    }

    @PostMapping("/options")
    public RoomQuizOption createOption(@RequestBody CreateRoomQuizOptionRequest request) {
        return roomQuizService.createOption(request);
    }

    @GetMapping("/mentor/{mentorId}")
    public List<RoomQuiz> getQuizzesByMentor(@PathVariable String mentorId) {
        return roomQuizService.getQuizzesByMentor(mentorId);
    }

    @GetMapping("/{quizId}/questions")
    public List<RoomQuizQuestion> getQuestionsByQuiz(@PathVariable String quizId) {
        return roomQuizService.getQuestionsByQuiz(quizId);
    }

    @GetMapping("/questions/{roomQuizQuestionId}/options")
    public List<RoomQuizOption> getOptionsByQuestion(@PathVariable String roomQuizQuestionId) {
        return roomQuizService.getOptionsByQuestion(roomQuizQuestionId);
    }

    @PostMapping("/{quizId}/publish")
    public RoomQuiz publishQuiz(@PathVariable String quizId) {
        return roomQuizService.publishQuiz(quizId);
    }

    @PostMapping("/{quizId}/send/{roomId}")
    public ResponseEntity<Void> sendQuiz(@PathVariable String quizId, @PathVariable String roomId) {
        roomQuizService.sendQuizToLearners(quizId, roomId);
        return ResponseEntity.ok().build();
    }
}
