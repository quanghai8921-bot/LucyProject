package com.lucy.lms.learner.dto;

import java.util.List;

public class QuizSubmitRequest {
    private String userId;
    private String roomId;
    private String languageId;
    private String levelId;
    private List<Answer> answers;

    public String getUserId() {
        return userId;
    }

    public String getRoomId() {
        return roomId;
    }

    public String getLanguageId() {
        return languageId;
    }

    public String getLevelId() {
        return levelId;
    }

    public List<Answer> getAnswers() {
        return answers;
    }

    public static class Answer {
        private String roomQuizQuestionId;
        private String selectedOptionId;
        private String answerText;

        public String getRoomQuizQuestionId() {
            return roomQuizQuestionId;
        }

        public String getSelectedOptionId() {
            return selectedOptionId;
        }

        public String getAnswerText() {
            return answerText;
        }
    }
}
