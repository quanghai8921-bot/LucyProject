package com.lucy.backend.content.learner.service;

import com.lucy.backend.content.learner.dto.LearnerRoomDto;
import com.lucy.backend.content.learner.dto.AttendanceEligibilityDto;
import com.lucy.backend.content.learner.dto.QuizSubmitRequest;
import com.lucy.backend.content.learner.dto.QuizSubmitResultDto;
import com.lucy.backend.content.learner.entity.AttendanceCheck;
import com.lucy.backend.content.learner.entity.LearningSession;
import com.lucy.backend.content.learner.dto.RoomParticipantDto;
import com.lucy.backend.content.learner.entity.UserProgress;
import com.lucy.backend.content.learner.entity.RoomParticipant;
import com.lucy.backend.content.learner.repository.AttendanceCheckRepository;
import com.lucy.backend.content.learner.repository.LearningSessionRepository;
import com.lucy.backend.content.learner.repository.RoomParticipantRepository;
import com.lucy.backend.auth.repository.AvatarPersonaRepository;
import com.lucy.backend.auth.entity.AvatarPersona;
import com.lucy.backend.content.learner.repository.UserProgressRepository;
import com.lucy.backend.content.common.entity.Notification;
import com.lucy.backend.content.common.repository.NotificationRepository;
import com.lucy.backend.content.content.repository.LanguageRepository;
import com.lucy.backend.content.content.repository.SubLevelRepository;
import com.lucy.backend.content.mentor.entity.Room;
import com.lucy.backend.content.mentor.entity.RoomQuiz;
import com.lucy.backend.content.mentor.entity.RoomQuizAttempt;
import com.lucy.backend.content.mentor.entity.RoomQuizAttemptAnswer;
import com.lucy.backend.content.mentor.entity.RoomQuizOption;
import com.lucy.backend.content.mentor.entity.RoomQuizQuestion;
import com.lucy.backend.content.mentor.repository.RoomRepository;
import com.lucy.backend.content.mentor.repository.RoomQuizAttemptAnswerRepository;
import com.lucy.backend.content.mentor.repository.RoomQuizAttemptRepository;
import com.lucy.backend.content.mentor.repository.RoomQuizOptionRepository;
import com.lucy.backend.content.mentor.repository.RoomQuizQuestionRepository;
import com.lucy.backend.content.mentor.repository.RoomQuizRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.text.Normalizer;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class LearnerRoomService {

    private static final String JOINED = "JOINED";

    private final RoomRepository roomRepository;
    private final RoomParticipantRepository participantRepository;
    private final LearningSessionRepository learningSessionRepository;
    private final AttendanceCheckRepository attendanceCheckRepository;
    private final RoomQuizRepository roomQuizRepository;
    private final RoomQuizQuestionRepository roomQuizQuestionRepository;
    private final RoomQuizOptionRepository roomQuizOptionRepository;
    private final RoomQuizAttemptRepository roomQuizAttemptRepository;
    private final RoomQuizAttemptAnswerRepository roomQuizAttemptAnswerRepository;
    private final UserProgressRepository userProgressRepository;
    private final SubLevelRepository subLevelRepository;
    private final NotificationRepository notificationRepository;
    private final AvatarPersonaRepository avatarPersonaRepository;
    private final LanguageRepository languageRepository;

    public LearnerRoomService(
            RoomRepository roomRepository,
            RoomParticipantRepository participantRepository,
            LearningSessionRepository learningSessionRepository,
            AttendanceCheckRepository attendanceCheckRepository,
            RoomQuizRepository roomQuizRepository,
            RoomQuizQuestionRepository roomQuizQuestionRepository,
            RoomQuizOptionRepository roomQuizOptionRepository,
            RoomQuizAttemptRepository roomQuizAttemptRepository,
            RoomQuizAttemptAnswerRepository roomQuizAttemptAnswerRepository,
            UserProgressRepository userProgressRepository,
            SubLevelRepository subLevelRepository,
            NotificationRepository notificationRepository,
            AvatarPersonaRepository avatarPersonaRepository,
            LanguageRepository languageRepository) {
        this.roomRepository = roomRepository;
        this.participantRepository = participantRepository;
        this.learningSessionRepository = learningSessionRepository;
        this.attendanceCheckRepository = attendanceCheckRepository;
        this.roomQuizRepository = roomQuizRepository;
        this.roomQuizQuestionRepository = roomQuizQuestionRepository;
        this.roomQuizOptionRepository = roomQuizOptionRepository;
        this.roomQuizAttemptRepository = roomQuizAttemptRepository;
        this.roomQuizAttemptAnswerRepository = roomQuizAttemptAnswerRepository;
        this.userProgressRepository = userProgressRepository;
        this.subLevelRepository = subLevelRepository;
        this.notificationRepository = notificationRepository;
        this.avatarPersonaRepository = avatarPersonaRepository;
        this.languageRepository = languageRepository;
    }

    public List<LearnerRoomDto> getAvailableRooms() {
        return roomRepository.findAll().stream()
                .filter(this::canLearnerJoin)
                .sorted(Comparator.comparing(Room::getScheduledStartAt))
                .map(this::toRoomDto)
                .toList();
    }

    public List<LearnerRoomDto> getJoinedRoomHistory(String userId) {
        requireText(userId, "userId is required.");
        List<String> roomIds = participantRepository.findByUserIdOrderByJoinedAtDesc(userId).stream()
                .map(RoomParticipant::getRoomId)
                .distinct()
                .toList();
        return roomIds.stream()
                .map(roomId -> roomRepository.findById(roomId).orElse(null))
                .filter(room -> room != null)
                .map(this::toRoomDto)
                .toList();
    }

    @Transactional
    public RoomParticipantDto joinRoom(String roomId, String userId) {
        requireText(userId, "userId is required.");
        Room room = getRoom(roomId);
        if (!canLearnerJoin(room)) {
            throw new ResponseStatusException(BAD_REQUEST, "Room is not open for learners.");
        }

        LocalDateTime now = LocalDateTime.now();
        var existingParticipant = participantRepository
                .findFirstByRoomIdAndUserIdOrderByJoinedAtDesc(roomId, userId);
        if (existingParticipant.isPresent()) {
            RoomParticipant participant = existingParticipant.get();
            participant.rejoin(now);
            return new RoomParticipantDto(participantRepository.save(participant));
        }

        Integer currentCount = participantRepository.countByRoomIdAndParticipantStatus(roomId, JOINED);
        if (currentCount >= 50) {
            throw new ResponseStatusException(BAD_REQUEST, "Room is full.");
        }

        RoomParticipant participant = new RoomParticipant(UUID.randomUUID().toString(), roomId, userId, now);
        return new RoomParticipantDto(participantRepository.save(participant));
    }

    @Transactional
    public RoomParticipantDto leaveRoom(String roomId, String userId) {
        RoomParticipant participant = getJoinedParticipant(roomId, userId);
        participant.leave(LocalDateTime.now());
        return new RoomParticipantDto(participantRepository.save(participant));
    }

    @Transactional
    public RoomParticipantDto updateMic(String roomId, String userId, Boolean enabled) {
        RoomParticipant participant = getJoinedParticipant(roomId, userId);
        participant.setMicStatus(Boolean.TRUE.equals(enabled) ? "ON" : "OFF", LocalDateTime.now());
        return new RoomParticipantDto(participantRepository.save(participant));
    }

    @Transactional
    public RoomParticipantDto updateHandRaise(String roomId, String userId, Boolean raised) {
        RoomParticipant participant = getJoinedParticipant(roomId, userId);
        participant.setHandRaiseStatus(Boolean.TRUE.equals(raised) ? "RAISED" : "NONE", LocalDateTime.now());
        return new RoomParticipantDto(participantRepository.save(participant));
    }

    public List<RoomParticipantDto> getRoomParticipants(String roomId) {
        return participantRepository.findByRoomIdAndParticipantStatus(roomId, JOINED).stream()
                .map(p -> {
                    RoomParticipantDto dto = new RoomParticipantDto(p);
                    avatarPersonaRepository.findById(p.getUserId()).ifPresent(persona -> {
                        dto.setDisplayName(persona.getDisplayName());
                        dto.setAvatarUrl(persona.getAvatarUrl());
                    });
                    if (dto.getDisplayName() == null) {
                        dto.setDisplayName("Học viên " + p.getUserId());
                    }
                    return dto;
                })
                .toList();
    }

    @Transactional
    public AttendanceCheck askAttendance(String roomId, String userId, String levelId, String subLevelId) {
        requireText(userId, "userId is required.");
        requireText(levelId, "levelId is required.");
        requireText(subLevelId, "subLevelId is required.");
        getRoom(roomId);

        LearningSession session = learningSessionRepository
                .findFirstByUserIdAndRoomIdAndLevelIdAndSubLevelIdOrderByStartedAtDesc(
                        userId, roomId, levelId, subLevelId)
                .orElseGet(
                        () -> new LearningSession(UUID.randomUUID().toString(), userId, roomId, levelId, subLevelId));
        session.askAttendance();
        learningSessionRepository.save(session);

        AttendanceCheck check = new AttendanceCheck(UUID.randomUUID().toString(), session.getLearningSessionId());
        return attendanceCheckRepository.save(check);
    }

    @Transactional
    public AttendanceCheck confirmAttendance(String checkId) {
        AttendanceCheck check = attendanceCheckRepository.findById(checkId)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Attendance check not found."));
        boolean alreadyConfirmed = Boolean.TRUE.equals(check.getIsConfirmed());
        check.confirm();
        AttendanceCheck saved = attendanceCheckRepository.save(check);
        if (!alreadyConfirmed) {
            LearningSession session = learningSessionRepository.findById(check.getLearningSessionId())
                    .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Learning session not found."));
            session.confirmAttendance();
            learningSessionRepository.save(session);
        }
        return saved;
    }

    @Transactional(readOnly = true)
    public AttendanceEligibilityDto getEligibility(String roomId, String userId, String levelId) {
        List<String> sessionIds = learningSessionRepository.findByUserIdAndRoomIdAndLevelId(userId, roomId, levelId)
                .stream()
                .map(LearningSession::getLearningSessionId)
                .toList();
        long asked = sessionIds.isEmpty() ? 0 : attendanceCheckRepository.countByLearningSessionIdIn(sessionIds);
        long confirmed = sessionIds.isEmpty() ? 0
                : attendanceCheckRepository.countByLearningSessionIdInAndIsConfirmed(sessionIds, true);
        long offline = Math.max(0, asked - confirmed);
        return new AttendanceEligibilityDto(userId, roomId, levelId, asked, confirmed, offline, offline <= 2);
    }

    @Transactional
    public QuizSubmitResultDto submitQuiz(String quizId, QuizSubmitRequest request) {
        requireText(request.getUserId(), "userId is required.");
        RoomQuiz quiz = roomQuizRepository.findById(quizId)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Quiz not found."));
        if (!"PUBLISHED".equalsIgnoreCase(quiz.getQuizStatus())) {
            throw new ResponseStatusException(BAD_REQUEST, "Quiz has not been published.");
        }

        List<RoomQuizQuestion> questions = roomQuizQuestionRepository.findByQuizId(quizId);
        Map<String, RoomQuizQuestion> questionById = questions.stream()
                .collect(Collectors.toMap(RoomQuizQuestion::getRoomQuizQuestionId, Function.identity()));
        Map<String, RoomQuizOption> optionById = questions.stream()
                .flatMap(question -> roomQuizOptionRepository
                        .findByRoomQuizQuestionId(question.getRoomQuizQuestionId())
                        .stream())
                .collect(Collectors.toMap(RoomQuizOption::getOptionId, Function.identity()));
        Map<String, QuizSubmitRequest.Answer> answerByQuestionId = (request.getAnswers() == null
                ? List.<QuizSubmitRequest.Answer>of()
                : request.getAnswers())
                .stream()
                .filter(answer -> answer.getRoomQuizQuestionId() != null)
                .collect(Collectors.toMap(
                        QuizSubmitRequest.Answer::getRoomQuizQuestionId,
                        Function.identity(),
                        (first, second) -> second));

        RoomQuizAttempt attempt = new RoomQuizAttempt(UUID.randomUUID().toString(), quizId, request.getUserId());
        roomQuizAttemptRepository.save(attempt);

        int correctCount = 0;
        List<QuizSubmitResultDto.QuestionResult> results = questions.stream()
                .map(question -> {
                    QuizSubmitRequest.Answer answer = answerByQuestionId.get(question.getRoomQuizQuestionId());
                    boolean correct = isAnswerCorrect(question, answer, optionById);
                    return new QuizSubmitResultDto.QuestionResult(question.getRoomQuizQuestionId(), correct);
                })
                .toList();
        for (QuizSubmitResultDto.QuestionResult result : results) {
            if (result.getCorrect()) {
                correctCount++;
            }
            QuizSubmitRequest.Answer answer = answerByQuestionId.get(result.getRoomQuizQuestionId());
            roomQuizAttemptAnswerRepository.save(new RoomQuizAttemptAnswer(
                    UUID.randomUUID().toString(),
                    attempt.getAttemptId(),
                    result.getRoomQuizQuestionId(),
                    answer == null ? null : answer.getSelectedOptionId(),
                    answer == null ? null : answer.getAnswerText(),
                    result.getCorrect()));
        }

        BigDecimal scorePercent = questions.isEmpty()
                ? BigDecimal.ZERO
                : BigDecimal.valueOf(correctCount)
                        .multiply(BigDecimal.valueOf(100))
                        .divide(BigDecimal.valueOf(questions.size()), 2, RoundingMode.HALF_UP);
        BigDecimal passingScore = quiz.getPassingScorePercent() == null ? BigDecimal.valueOf(80)
                : quiz.getPassingScorePercent();
        boolean passed = scorePercent.compareTo(passingScore) >= 0;
        attempt.submit(scorePercent, passed);
        roomQuizAttemptRepository.save(attempt);
        completeLearningSessions(request, passed);
        if (passed) {
            markProgressPassed(request);
            Notification notification = new Notification(
                    UUID.randomUUID().toString(),
                    request.getUserId(),
                    "Hoàn thành xuất sắc",
                    "Bạn đủ điều kiện nâng lên 1 level mới.",
                    "LEVEL_UP_ELIGIBLE",
                    "ROOM");
            notificationRepository.save(notification);
        } else {
            Notification notification = new Notification(
                    UUID.randomUUID().toString(),
                    request.getUserId(),
                    "Chưa đủ điểm vượt qua",
                    "Bạn không đủ điều kiện nâng level mới do điểm số chưa đạt mức yêu cầu.",
                    "LEVEL_UP_FAILED",
                    "ROOM");
            notificationRepository.save(notification);
        }
        return new QuizSubmitResultDto(attempt.getAttemptId(), scorePercent, passed, results);
    }

    private LearnerRoomDto toRoomDto(Room room) {
        String mentorName = roomRepository.findMentorFullNameByUserId(room.getHostUserId());
        room.setHostUserName(mentorName != null ? mentorName : room.getHostUserId());
        LearnerRoomDto dto = new LearnerRoomDto(room,
                participantRepository.countByRoomIdAndParticipantStatus(room.getRoomId(), JOINED));
        String languageName = languageRepository.findLanguageNameByLanguageId(room.getLanguageId());
        dto.setLanguageName(languageName);
        if (room.getLevelNumber() != null) {
            dto.setLevelNumber(room.getLevelNumber());
        } else {
            dto.setLevelNumber(1);
        }
        return dto;
    }

    private Room getRoom(String roomId) {
        requireText(roomId, "roomId is required.");
        return roomRepository.findById(roomId)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Room not found."));
    }

    private RoomParticipant getJoinedParticipant(String roomId, String userId) {
        requireText(userId, "userId is required.");
        return participantRepository
                .findFirstByRoomIdAndUserIdAndParticipantStatusOrderByJoinedAtDesc(roomId, userId, JOINED)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Learner has not joined this room."));
    }

    private boolean canLearnerJoin(Room room) {
        String status = room.getRoomStatus();
        if (status == null) {
            return false;
        }
        String normalized = status.toUpperCase(Locale.ROOT);
        return normalized.equals("OPEN")
                || normalized.equals("OPENED")
                || normalized.equals("LIVE")
                || normalized.equals("STUDYING")
                || normalized.equals("SCHEDULED");
    }

    private void requireText(String value, String message) {
        if (value == null || value.trim().isEmpty()) {
            throw new ResponseStatusException(BAD_REQUEST, message);
        }
    }

    private boolean isAnswerCorrect(RoomQuizQuestion question, QuizSubmitRequest.Answer answer,
            Map<String, RoomQuizOption> optionById) {
        if (answer == null) {
            return false;
        }
        if ("MULTIPLE_CHOICE".equalsIgnoreCase(question.getQuestionType())) {
            RoomQuizOption option = optionById.get(answer.getSelectedOptionId());
            return option != null && Boolean.TRUE.equals(option.getIsCorrect());
        }
        String expected = normalizeAnswer(question.getCorrectAnswerText());
        return !expected.isBlank() && normalizeAnswer(answer.getAnswerText()).equals(expected);
    }

    private String normalizeAnswer(String value) {
        if (value == null) {
            return "";
        }
        String normalized = Normalizer.normalize(value, Normalizer.Form.NFKC)
                .trim()
                .toLowerCase(Locale.ROOT)
                .replaceAll("\\s+", " ");
        return normalized;
    }

    private void completeLearningSessions(QuizSubmitRequest request, boolean passed) {
        if (request.getRoomId() == null || request.getLevelId() == null) {
            return;
        }
        learningSessionRepository.findByUserIdAndRoomIdAndLevelId(
                request.getUserId(),
                request.getRoomId(),
                request.getLevelId())
                .forEach(session -> {
                    session.complete(passed);
                    learningSessionRepository.save(session);
                });
    }

    private void markProgressPassed(QuizSubmitRequest request) {
        if (request.getLanguageId() == null || request.getLevelId() == null) {
            return;
        }
        int completedSubLevels = subLevelRepository.findByLevelIdOrderBySubLevelNumberAsc(request.getLevelId()).size();
        UserProgress progress = userProgressRepository
                .findFirstByUserIdAndLanguageIdAndLevelId(request.getUserId(), request.getLanguageId(),
                        request.getLevelId())
                .orElseGet(() -> new UserProgress(
                        UUID.randomUUID().toString(),
                        request.getUserId(),
                        request.getLanguageId(),
                        request.getLevelId()));
        progress.markLevelPassed(completedSubLevels);
        userProgressRepository.save(progress);
    }
}
