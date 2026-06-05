package com.lucy.lms.mentor.service;

import com.lucy.lms.mentor.dto.CreateFullQuizRequest;
import com.lucy.lms.mentor.dto.CreateRoomQuizOptionRequest;
import com.lucy.lms.mentor.dto.CreateRoomQuizQuestionRequest;
import com.lucy.lms.mentor.dto.CreateRoomQuizRequest;
import com.lucy.lms.mentor.dto.SubmitQuizRequest;
import com.lucy.lms.mentor.entity.RoomQuiz;
import com.lucy.lms.mentor.entity.RoomQuizOption;
import com.lucy.lms.mentor.entity.RoomQuizQuestion;
import com.lucy.lms.mentor.entity.RoomQuizSubmission;
import com.lucy.lms.mentor.repository.RoomQuizOptionRepository;
import com.lucy.lms.mentor.repository.RoomQuizQuestionRepository;
import com.lucy.lms.mentor.repository.RoomQuizRepository;
import com.lucy.lms.mentor.repository.RoomQuizSubmissionRepository;
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
    private final RoomQuizSubmissionRepository roomQuizSubmissionRepository;

    public RoomQuizService(
            RoomQuizRepository roomQuizRepository,
            RoomQuizQuestionRepository roomQuizQuestionRepository,
            RoomQuizOptionRepository roomQuizOptionRepository,
            RoomQuizSubmissionRepository roomQuizSubmissionRepository) {
        this.roomQuizRepository = roomQuizRepository;
        this.roomQuizQuestionRepository = roomQuizQuestionRepository;
        this.roomQuizOptionRepository = roomQuizOptionRepository;
        this.roomQuizSubmissionRepository = roomQuizSubmissionRepository;
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

    public RoomQuiz createFullQuiz(CreateFullQuizRequest request) {
        RoomQuiz quiz = createQuiz(new CreateRoomQuizRequest(
                request.getRoomId(),
                request.getLevelId(),
                request.getCreatedBy(),
                request.getQuizTitle(),
                request.getPassingScorePercent()
        ));

        if (request.getQuestions() != null) {
            for (CreateFullQuizRequest.QuestionRequest qReq : request.getQuestions()) {
                RoomQuizQuestion question = new RoomQuizQuestion(
                        UUID.randomUUID().toString(),
                        quiz.getQuizId(),
                        qReq.getQuestionText(),
                        qReq.getQuestionType() != null ? qReq.getQuestionType() : "MULTIPLE_CHOICE",
                        qReq.getQuestionOrder());
                roomQuizQuestionRepository.save(question);

                if (qReq.getOptions() != null) {
                    for (CreateFullQuizRequest.OptionRequest oReq : qReq.getOptions()) {
                        RoomQuizOption option = new RoomQuizOption(
                                UUID.randomUUID().toString(),
                                question.getRoomQuizQuestionId(),
                                oReq.getOptionText(),
                                oReq.getIsCorrect() != null ? oReq.getIsCorrect() : false,
                                oReq.getOptionOrder());
                        roomQuizOptionRepository.save(option);
                    }
                }
            }
        }

        return quiz;
    }

    public RoomQuizSubmission submitQuiz(String quizId, SubmitQuizRequest request) {
        RoomQuizSubmission submission = new RoomQuizSubmission(
                UUID.randomUUID().toString(),
                quizId,
                request.getLearnerId(),
                LocalDateTime.now(),
                null,
                0,
                "SUBMITTED"
        );

        return roomQuizSubmissionRepository.save(submission);
    }
}