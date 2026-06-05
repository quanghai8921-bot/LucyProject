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

    public CreateFullQuizRequest() {
    }

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public String getLevelId() {
        return levelId;
    }

    public void setLevelId(String levelId) {
        this.levelId = levelId;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public String getQuizTitle() {
        return quizTitle;
    }

    public void setQuizTitle(String quizTitle) {
        this.quizTitle = quizTitle;
    }

    public BigDecimal getPassingScorePercent() {
        return passingScorePercent;
    }

    public void setPassingScorePercent(BigDecimal passingScorePercent) {
        this.passingScorePercent = passingScorePercent;
    }

    public List<QuestionRequest> getQuestions() {
        return questions;
    }

    public void setQuestions(List<QuestionRequest> questions) {
        this.questions = questions;
    }

    public static class QuestionRequest {
        private String questionText;
        private String questionType;
        private Integer questionOrder;
        private List<OptionRequest> options;

        public QuestionRequest() {
        }

        public String getQuestionText() {
            return questionText;
        }

        public void setQuestionText(String questionText) {
            this.questionText = questionText;
        }

        public String getQuestionType() {
            return questionType;
        }

        public void setQuestionType(String questionType) {
            this.questionType = questionType;
        }

        public Integer getQuestionOrder() {
            return questionOrder;
        }

        public void setQuestionOrder(Integer questionOrder) {
            this.questionOrder = questionOrder;
        }

        public List<OptionRequest> getOptions() {
            return options;
        }

        public void setOptions(List<OptionRequest> options) {
            this.options = options;
        }
    }

    public static class OptionRequest {
        private String optionText;
        private Boolean isCorrect;
        private Integer optionOrder;

        public OptionRequest() {
        }

        public String getOptionText() {
            return optionText;
        }

        public void setOptionText(String optionText) {
            this.optionText = optionText;
        }

        public Boolean getIsCorrect() {
            return isCorrect;
        }

        public void setIsCorrect(Boolean isCorrect) {
            this.isCorrect = isCorrect;
        }

        public Integer getOptionOrder() {
            return optionOrder;
        }

        public void setOptionOrder(Integer optionOrder) {
            this.optionOrder = optionOrder;
        }
    }
}
