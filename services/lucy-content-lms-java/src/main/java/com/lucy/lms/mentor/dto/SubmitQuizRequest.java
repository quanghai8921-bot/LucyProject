package com.lucy.lms.mentor.dto;

import java.util.List;

public class SubmitQuizRequest {

    private String learnerId;
    private List<AnswerSelection> answers;

    public String getLearnerId() {
        return learnerId;
    }

    public List<AnswerSelection> getAnswers() {
        return answers;
    }

    public static class AnswerSelection {
        private String questionId;
        private String selectedOptionId;
        private String answerText;

        public String getQuestionId() {
            return questionId;
        }

        public String getSelectedOptionId() {
            return selectedOptionId;
        }

        public String getAnswerText() {
            return answerText;
        }
    }
}
