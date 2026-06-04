package com.lucy.lms.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "RoomQuizAttemptAnswers")
public class RoomQuizAttemptAnswer {

    @Id
    @Column(name = "AttemptAnswerId", length = 50)
    private String attemptAnswerId;

    @Column(name = "AttemptId", length = 50, nullable = false)
    private String attemptId;

    @Column(name = "RoomQuizQuestionId", length = 50, nullable = false)
    private String roomQuizQuestionId;

    @Column(name = "SelectedOptionId", length = 50)
    private String selectedOptionId;

    @Column(name = "AnswerText")
    private String answerText;

    @Column(name = "IsCorrect", nullable = false)
    private Integer isCorrect;

    protected RoomQuizAttemptAnswer() {
    }

    public RoomQuizAttemptAnswer(String attemptAnswerId, String attemptId, String roomQuizQuestionId,
                                 String selectedOptionId, String answerText, Integer isCorrect) {
        this.attemptAnswerId = attemptAnswerId;
        this.attemptId = attemptId;
        this.roomQuizQuestionId = roomQuizQuestionId;
        this.selectedOptionId = selectedOptionId;
        this.answerText = answerText;
        this.isCorrect = isCorrect;
    }

    public String getAttemptAnswerId() {
        return attemptAnswerId;
    }

    public String getAttemptId() {
        return attemptId;
    }

    public String getRoomQuizQuestionId() {
        return roomQuizQuestionId;
    }

    public String getSelectedOptionId() {
        return selectedOptionId;
    }

    public String getAnswerText() {
        return answerText;
    }

    public Integer getIsCorrect() {
        return isCorrect;
    }
}
