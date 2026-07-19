package com.lucy.backend.content.learner.dto;

import java.math.BigDecimal;
import java.util.List;

public class QuizSubmitResultDto {
    private final String attemptId;
    private final BigDecimal scorePercent;
    private final boolean passed;
    private final List<QuestionResult> questionResults;

    public QuizSubmitResultDto(String attemptId, BigDecimal scorePercent, boolean passed,
            List<QuestionResult> questionResults) {
        this.attemptId = attemptId;
        this.scorePercent = scorePercent;
        this.passed = passed;
        this.questionResults = questionResults;
    }

    public String getAttemptId() {
        return attemptId;
    }

    public BigDecimal getScorePercent() {
        return scorePercent;
    }

    public boolean getPassed() {
        return passed;
    }

    public List<QuestionResult> getQuestionResults() {
        return questionResults;
    }

    public static class QuestionResult {
        private final String roomQuizQuestionId;
        private final boolean correct;

        public QuestionResult(String roomQuizQuestionId, boolean correct) {
            this.roomQuizQuestionId = roomQuizQuestionId;
            this.correct = correct;
        }

        public String getRoomQuizQuestionId() {
            return roomQuizQuestionId;
        }

        public boolean getCorrect() {
            return correct;
        }
    }
}
