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

import com.lucy.lms.common.entity.Notification;
import com.lucy.lms.common.repository.NotificationRepository;
import com.lucy.lms.learner.entity.LearningSession;
import com.lucy.lms.learner.entity.RoomParticipant;
import com.lucy.lms.learner.repository.AttendanceCheckRepository;
import com.lucy.lms.learner.repository.LearningSessionRepository;
import com.lucy.lms.learner.repository.RoomParticipantRepository;
import com.lucy.lms.mentor.entity.RoomQuizAttempt;
import com.lucy.lms.mentor.repository.RoomQuizAttemptRepository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class RoomQuizService {

    private final RoomQuizRepository roomQuizRepository;
    private final RoomQuizQuestionRepository roomQuizQuestionRepository;
    private final RoomQuizOptionRepository roomQuizOptionRepository;
    private final RoomParticipantRepository roomParticipantRepository;
    private final LearningSessionRepository learningSessionRepository;
    private final AttendanceCheckRepository attendanceCheckRepository;
    private final RoomQuizAttemptRepository roomQuizAttemptRepository;
    private final NotificationRepository notificationRepository;

    public RoomQuizService(
            RoomQuizRepository roomQuizRepository,
            RoomQuizQuestionRepository roomQuizQuestionRepository,
            RoomQuizOptionRepository roomQuizOptionRepository,
            RoomParticipantRepository roomParticipantRepository,
            LearningSessionRepository learningSessionRepository,
            AttendanceCheckRepository attendanceCheckRepository,
            RoomQuizAttemptRepository roomQuizAttemptRepository,
            NotificationRepository notificationRepository) {
        this.roomQuizRepository = roomQuizRepository;
        this.roomQuizQuestionRepository = roomQuizQuestionRepository;
        this.roomQuizOptionRepository = roomQuizOptionRepository;
        this.roomParticipantRepository = roomParticipantRepository;
        this.learningSessionRepository = learningSessionRepository;
        this.attendanceCheckRepository = attendanceCheckRepository;
        this.roomQuizAttemptRepository = roomQuizAttemptRepository;
        this.notificationRepository = notificationRepository;
    }

    @org.springframework.beans.factory.annotation.Autowired
    private org.springframework.jdbc.core.JdbcTemplate jdbcTemplate;

    @jakarta.annotation.PostConstruct
    public void dropLevelIdForeignKey() {
        try {
            String query = "SELECT CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE " +
                           "WHERE TABLE_SCHEMA = 'lucyProject' AND TABLE_NAME = 'RoomQuizzes' " +
                           "AND COLUMN_NAME = 'LevelId' AND REFERENCED_TABLE_NAME = 'Levels'";
            List<String> fkNames = jdbcTemplate.queryForList(query, String.class);
            for (String fkName : fkNames) {
                jdbcTemplate.execute("ALTER TABLE RoomQuizzes DROP FOREIGN KEY " + fkName);
            }
        } catch (Exception e) {
            // Ignore if constraint doesn't exist
        }
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

        RoomQuiz savedQuiz = roomQuizRepository.save(quiz);

        if (request.getQuestions() != null) {
            for (int i = 0; i < request.getQuestions().size(); i++) {
                var qDto = request.getQuestions().get(i);
                RoomQuizQuestion question = new RoomQuizQuestion(
                        UUID.randomUUID().toString(),
                        savedQuiz.getQuizId(),
                        qDto.getQuestionText(),
                        qDto.getQuestionType() != null ? qDto.getQuestionType() : request.getQuizType(),
                        qDto.getCorrectAnswerText(),
                        i + 1
                );
                roomQuizQuestionRepository.save(question);

                if (qDto.getOptions() != null) {
                    for (int j = 0; j < qDto.getOptions().size(); j++) {
                        var oDto = qDto.getOptions().get(j);
                        RoomQuizOption option = new RoomQuizOption(
                                UUID.randomUUID().toString(),
                                question.getRoomQuizQuestionId(),
                                oDto.getOptionText(),
                                oDto.getIsCorrect() != null ? oDto.getIsCorrect() : false,
                                j + 1
                        );
                        roomQuizOptionRepository.save(option);
                    }
                }
            }
        }
        return savedQuiz;
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

    public List<RoomQuiz> getQuizzesByMentor(String mentorId) {
        return roomQuizRepository.findByCreatedBy(mentorId);
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

    public void sendQuizToLearners(String quizId, String roomId) {
        RoomQuiz quiz = roomQuizRepository.findById(quizId)
                .orElseThrow(() -> new IllegalArgumentException("Quiz not found: " + quizId));

        List<RoomParticipant> participants = roomParticipantRepository.findByRoomIdAndParticipantStatus(roomId, "JOINED");

        for (RoomParticipant participant : participants) {
            List<LearningSession> sessions = learningSessionRepository.findByUserIdAndRoomId(
                    participant.getUserId(), roomId);

            List<String> sessionIds = sessions.stream()
                    .map(LearningSession::getLearningSessionId)
                    .collect(Collectors.toList());

            long attendanceCount = attendanceCheckRepository.countByLearningSessionIdInAndIsConfirmed(sessionIds, true);

            if (attendanceCount >= 3) {
                RoomQuizAttempt attempt = new RoomQuizAttempt(
                        UUID.randomUUID().toString(),
                        quiz.getQuizId(),
                        participant.getUserId()
                );
                roomQuizAttemptRepository.save(attempt);

                Notification notification = new Notification(
                        UUID.randomUUID().toString(),
                        participant.getUserId(),
                        "Bài kiểm tra mới",
                        "Bạn đã nhận được bài kiểm tra " + quiz.getQuizTitle() + " do đủ điều kiện online.",
                        "QUIZ_ASSIGNED",
                        "ROOM"
                );
                notificationRepository.save(notification);
            } else {
                Notification notification = new Notification(
                        UUID.randomUUID().toString(),
                        participant.getUserId(),
                        "Không đủ điều kiện kiểm tra",
                        "Bạn không đủ điều kiện (vắng quá nhiều), không được nhận bài kiểm tra và không thể nâng cấp level.",
                        "QUIZ_REJECTED",
                        "ROOM"
                );
                notificationRepository.save(notification);
            }
        }
    }

    public List<com.lucy.lms.mentor.dto.RoomQuizAttemptDto> getLearnerAssignedQuizzes(String userId) {
        return roomQuizAttemptRepository.findByUserId(userId).stream()
                .filter(a -> "ASSIGNED".equals(a.getAttemptStatus()) || "IN_PROGRESS".equals(a.getAttemptStatus()))
                .map(a -> {
                    RoomQuiz quiz = roomQuizRepository.findById(a.getQuizId()).orElse(null);
                    return new com.lucy.lms.mentor.dto.RoomQuizAttemptDto(
                            a.getAttemptId(),
                            a.getQuizId(),
                            quiz != null ? quiz.getQuizTitle() : "Unknown",
                            "MULTIPLE_CHOICE",
                            quiz != null ? quiz.getDurationMinutes() : 15,
                            a.getAttemptStatus(),
                            a.getScorePercent(),
                            a.getIsPassed()
                    );
                })
                .collect(Collectors.toList());
    }

    public RoomQuizAttempt startQuiz(String attemptId) {
        RoomQuizAttempt attempt = roomQuizAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new IllegalArgumentException("Attempt not found: " + attemptId));
        if ("ASSIGNED".equals(attempt.getAttemptStatus())) {
            attempt.start();
            return roomQuizAttemptRepository.save(attempt);
        }
        return attempt;
    }

    public com.lucy.lms.learner.dto.SubmitQuizResponse submitQuiz(String attemptId, com.lucy.lms.learner.dto.SubmitQuizRequest request) {
        RoomQuizAttempt attempt = roomQuizAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new IllegalArgumentException("Attempt not found: " + attemptId));

        if ("SUBMITTED".equals(attempt.getAttemptStatus())) {
            throw new IllegalStateException("Attempt is already submitted.");
        }

        RoomQuiz quiz = roomQuizRepository.findById(attempt.getQuizId())
                .orElseThrow(() -> new IllegalArgumentException("Quiz not found"));

        List<RoomQuizQuestion> questions = roomQuizQuestionRepository.findByQuizId(quiz.getQuizId());

        int totalQuestions = questions.size();
        int correctAnswers = 0;

        if (totalQuestions > 0) {
            for (RoomQuizQuestion question : questions) {
                String learnerAnswer = request.getAnswers() != null ? request.getAnswers().get(question.getRoomQuizQuestionId()) : null;
                
                if (learnerAnswer == null || learnerAnswer.trim().isEmpty()) {
                    continue;
                }

                if ("MULTIPLE_CHOICE".equalsIgnoreCase(question.getQuestionType())) {
                    List<RoomQuizOption> options = roomQuizOptionRepository.findByRoomQuizQuestionId(question.getRoomQuizQuestionId());
                    for (RoomQuizOption opt : options) {
                        if (Boolean.TRUE.equals(opt.getIsCorrect()) && opt.getOptionId().equals(learnerAnswer)) {
                            correctAnswers++;
                            break;
                        }
                    }
                } else if ("ESSAY".equalsIgnoreCase(question.getQuestionType())) {
                    if (question.getCorrectAnswerText() != null && 
                        question.getCorrectAnswerText().trim().equalsIgnoreCase(learnerAnswer.trim())) {
                        correctAnswers++;
                    }
                }
            }
        }

        BigDecimal scorePercent = totalQuestions > 0 ? 
            BigDecimal.valueOf((double) correctAnswers / totalQuestions * 100) : 
            BigDecimal.ZERO;
            
        boolean isPassed = scorePercent.compareTo(quiz.getPassingScorePercent()) >= 0;

        attempt.submit(scorePercent, isPassed);

        roomQuizAttemptRepository.save(attempt);

        return new com.lucy.lms.learner.dto.SubmitQuizResponse(scorePercent, isPassed);
    }
}
