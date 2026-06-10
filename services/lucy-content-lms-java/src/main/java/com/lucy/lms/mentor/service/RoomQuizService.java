package com.lucy.lms.mentor.service;

import com.lucy.lms.mentor.dto.CreateRoomQuizOptionRequest;
import com.lucy.lms.mentor.dto.CreateRoomQuizQuestionRequest;
import com.lucy.lms.mentor.dto.CreateRoomQuizRequest;
import com.lucy.lms.mentor.entity.RoomQuiz;
import com.lucy.lms.mentor.entity.RoomQuizOption;
import com.lucy.lms.mentor.entity.RoomQuizQuestion;
import com.lucy.lms.mentor.repository.RoomQuizOptionRepository;
import com.lucy.lms.mentor.repository.RoomQuizQuestionRepository;
import com.lucy.lms.mentor.repository.RoomQuizRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class RoomQuizService {

    private final RoomQuizRepository roomQuizRepository;
    private final RoomQuizQuestionRepository roomQuizQuestionRepository;
    private final RoomQuizOptionRepository roomQuizOptionRepository;

    public RoomQuizService(
            RoomQuizRepository roomQuizRepository,
            RoomQuizQuestionRepository roomQuizQuestionRepository,
            RoomQuizOptionRepository roomQuizOptionRepository) {
        this.roomQuizRepository = roomQuizRepository;
        this.roomQuizQuestionRepository = roomQuizQuestionRepository;
        this.roomQuizOptionRepository = roomQuizOptionRepository;
    }

    public RoomQuiz createQuiz(CreateRoomQuizRequest request) {
        BigDecimal passingScore = request.getPassingScorePercent() != null
                ? request.getPassingScorePercent()
                : BigDecimal.valueOf(80);

        RoomQuiz quiz = new RoomQuiz(
                UUID.randomUUID().toString(),
                request.getRoomId(),
                request.getLevelId(),
                request.getCreatedBy(),
                request.getQuizTitle(),
                request.getDurationMinutes(),
                passingScore,
                "DRAFT",
                LocalDateTime.now());

        return roomQuizRepository.save(quiz);
    }

    public RoomQuizQuestion createQuestion(CreateRoomQuizQuestionRequest request) {
        RoomQuizQuestion question = new RoomQuizQuestion(
                UUID.randomUUID().toString(),
                request.getQuizId(),
                request.getQuestionText(),
                request.getQuestionType() != null ? request.getQuestionType() : "MULTIPLE_CHOICE",
                request.getCorrectAnswerText(),
                request.getQuestionOrder());

        return roomQuizQuestionRepository.save(question);
    }

    public RoomQuizOption createOption(CreateRoomQuizOptionRequest request) {
        RoomQuizOption option = new RoomQuizOption(
                UUID.randomUUID().toString(),
                request.getRoomQuizQuestionId(),
                request.getOptionText(),
                request.getIsCorrect() != null ? request.getIsCorrect() : false,
                request.getOptionOrder());

        return roomQuizOptionRepository.save(option);
    }

    public List<RoomQuiz> getQuizzesByRoom(String roomId) {
        return roomQuizRepository.findByRoomId(roomId);
    }

    public List<RoomQuizQuestion> getQuestionsByQuiz(String quizId) {
        return roomQuizQuestionRepository.findByQuizId(quizId);
    }

    public List<RoomQuizOption> getOptionsByQuestion(String roomQuizQuestionId) {
        return roomQuizOptionRepository.findByRoomQuizQuestionId(roomQuizQuestionId);
    }

    public RoomQuiz publishQuiz(String quizId) {
        RoomQuiz quiz = roomQuizRepository.findById(quizId)
                .orElseThrow(() -> new IllegalArgumentException("Quiz not found: " + quizId));
        quiz.publish(LocalDateTime.now());
        return roomQuizRepository.save(quiz);
    }
}
