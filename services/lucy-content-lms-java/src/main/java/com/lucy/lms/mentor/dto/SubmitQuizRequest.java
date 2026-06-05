package com.lucy.lms.mentor.dto;

import java.util.List;

public class SubmitQuizRequest {

    private String learnerId;
    private List<AnswerSelection> answers;

    public SubmitQuizRequest() {
    }

    public String getLearnerId() {
        return learnerId;
    }

    public void setLearnerId(String learnerId) {
        this.learnerId = learnerId;
    }

    public List<AnswerSelection> getAnswers() {
        return answers;
    }

    public void setAnswers(List<AnswerSelection> answers) {
        this.answers = answers;
    }

    public static class AnswerSelection {
        private String questionId;
        private String selectedOptionId;
        private String answerText;

        public AnswerSelection() {
        }

        public String getQuestionId() {
            return questionId;
        }

        public void setQuestionId(String questionId) {
            this.questionId = questionId;
        }

        public String getSelectedOptionId() {
            return selectedOptionId;
        }

        public void setSelectedOptionId(String selectedOptionId) {
            this.selectedOptionId = selectedOptionId;
        }

        public String getAnswerText() {
            return answerText;
        }

        public void setAnswerText(String answerText) {
            this.answerText = answerText;
        }
    }
}
