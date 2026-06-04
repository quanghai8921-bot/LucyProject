package com.lucy.lms.mentor.dto;

import java.math.BigDecimal;
import java.util.List;

public class CreateFullQuizRequest {

    private String roomId;
    private String levelId;
    private String createdBy;
    private String quizTitle;
    private BigDecimal passingScorePercent;
    private List<QuestionRequest> questions;

    public String getRoomId() {
        return roomId;
    }

    public String getLevelId() {
        return levelId;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public String getQuizTitle() {
        return quizTitle;
    }

    public BigDecimal getPassingScorePercent() {
        return passingScorePercent;
    }

    public List<QuestionRequest> getQuestions() {
        return questions;
    }

    public static class QuestionRequest {
        private String questionText;
        private String questionType; // MULTIPLE_CHOICE etc.
        private Integer questionOrder;
        private List<OptionRequest> options;

        public String getQuestionText() {
            return questionText;
        }

        public String getQuestionType() {
            return questionType;
        }

        public Integer getQuestionOrder() {
            return questionOrder;
        }

        public List<OptionRequest> getOptions() {
            return options;
        }
    }

    public static class OptionRequest {
        private String optionText;
        private Boolean isCorrect;
        private Integer optionOrder;

        public String getOptionText() {
            return optionText;
        }

        public Boolean getIsCorrect() {
            return isCorrect;
        }

        public Integer getOptionOrder() {
            return optionOrder;
        }
    }
}
