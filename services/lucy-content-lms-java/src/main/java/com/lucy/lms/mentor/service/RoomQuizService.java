package com.lucy.lms.mentor.service;

import com.lucy.lms.mentor.dto.*;
import com.lucy.lms.mentor.entity.*;
import com.lucy.lms.mentor.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class RoomQuizService {

    private final RoomQuizRepository roomQuizRepository;
    private final RoomQuizQuestionRepository roomQuizQuestionRepository;
    private final RoomQuizOptionRepository roomQuizOptionRepository;
    private final RoomQuizSubmissionRepository roomQuizSubmissionRepository;
    private final RoomQuizAttemptAnswerRepository roomQuizAttemptAnswerRepository;

    public RoomQuizService(
            RoomQuizRepository roomQuizRepository,
            RoomQuizQuestionRepository roomQuizQuestionRepository,
            RoomQuizOptionRepository roomQuizOptionRepository,
            RoomQuizSubmissionRepository roomQuizSubmissionRepository,
            RoomQuizAttemptAnswerRepository roomQuizAttemptAnswerRepository) {
        this.roomQuizRepository = roomQuizRepository;
        this.roomQuizQuestionRepository = roomQuizQuestionRepository;
        this.roomQuizOptionRepository = roomQuizOptionRepository;
        this.roomQuizSubmissionRepository = roomQuizSubmissionRepository;
        this.roomQuizAttemptAnswerRepository = roomQuizAttemptAnswerRepository;
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
                passingScore,
                "DRAFT",
                LocalDateTime.now());

        return roomQuizRepository.save(quiz);
    }

    @Transactional
    public RoomQuiz createFullQuiz(CreateFullQuizRequest request) {
        BigDecimal passingScore = request.getPassingScorePercent() != null
                ? request.getPassingScorePercent()
                : BigDecimal.valueOf(80);

        String quizId = UUID.randomUUID().toString();
        RoomQuiz quiz = new RoomQuiz(
                quizId,
                request.getRoomId(),
                request.getLevelId(),
                request.getCreatedBy(),
                request.getQuizTitle(),
                passingScore,
                "PUBLISHED",
                LocalDateTime.now());

        RoomQuiz savedQuiz = roomQuizRepository.save(quiz);

        if (request.getQuestions() != null) {
            for (CreateFullQuizRequest.QuestionRequest qReq : request.getQuestions()) {
                String questionId = UUID.randomUUID().toString();
                RoomQuizQuestion question = new RoomQuizQuestion(
                        questionId,
                        quizId,
                        qReq.getQuestionText(),
                        qReq.getQuestionType() != null ? qReq.getQuestionType() : "MULTIPLE_CHOICE",
                        qReq.getQuestionOrder()
                );
                roomQuizQuestionRepository.save(question);

                if (qReq.getOptions() != null) {
                    for (CreateFullQuizRequest.OptionRequest oReq : qReq.getOptions()) {
                        RoomQuizOption option = new RoomQuizOption(
                                UUID.randomUUID().toString(),
                                questionId,
                                oReq.getOptionText(),
                                oReq.getIsCorrect() != null ? oReq.getIsCorrect() : false,
                                oReq.getOptionOrder()
                        );
                        roomQuizOptionRepository.save(option);
                    }
                }
            }
        }

        return savedQuiz;
    }

    @Transactional
    public RoomQuizSubmission submitQuiz(String quizId, SubmitQuizRequest request) {
        RoomQuiz quiz = roomQuizRepository.findById(quizId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bài kiểm tra: " + quizId));

        List<RoomQuizQuestion> questions = roomQuizQuestionRepository.findByQuizId(quizId);
        int totalQuestions = questions.size();
        if (totalQuestions == 0) {
            throw new IllegalStateException("Bài kiểm tra không có câu hỏi nào.");
        }

        String attemptId = UUID.randomUUID().toString();
        int correctCount = 0;

        if (request.getAnswers() != null) {
            for (SubmitQuizRequest.AnswerSelection ansSel : request.getAnswers()) {
                boolean isCorrect = false;
                if (ansSel.getSelectedOptionId() != null) {
                    Optional<RoomQuizOption> opt = roomQuizOptionRepository.findById(ansSel.getSelectedOptionId());
                    if (opt.isPresent() && opt.get().getIsCorrect()) {
                        isCorrect = true;
                        correctCount++;
                    }
                }

                RoomQuizAttemptAnswer attemptAnswer = new RoomQuizAttemptAnswer(
                        UUID.randomUUID().toString(),
                        attemptId,
                        ansSel.getQuestionId(),
                        ansSel.getSelectedOptionId(),
                        ansSel.getAnswerText(),
                        isCorrect ? 1 : 0
                );
                roomQuizAttemptAnswerRepository.save(attemptAnswer);
            }
        }

        BigDecimal scorePercent = BigDecimal.valueOf(correctCount)
                .multiply(BigDecimal.valueOf(100))
                .divide(BigDecimal.valueOf(totalQuestions), 2, RoundingMode.HALF_UP);

        int isPassed = scorePercent.compareTo(quiz.getPassingScorePercent()) >= 0 ? 1 : 0;

        RoomQuizSubmission attempt = new RoomQuizSubmission(
                attemptId,
                quizId,
                request.getLearnerId(),
                scorePercent,
                isPassed,
                LocalDateTime.now().minusMinutes(5), // giả sử làm bài khoảng 5 phút trước
                LocalDateTime.now()
        );

        attempt.setCorrectAnswers(correctCount);
        attempt.setTotalQuestions(totalQuestions);

        return roomQuizSubmissionRepository.save(attempt);
    }

    public RoomQuizQuestion createQuestion(CreateRoomQuizQuestionRequest request) {
        RoomQuizQuestion question = new RoomQuizQuestion(
                UUID.randomUUID().toString(),
                request.getQuizId(),
                request.getQuestionText(),
                request.getQuestionType() != null ? request.getQuestionType() : "MULTIPLE_CHOICE",
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
}