package com.lucy.backend.content.mentor.entity;

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
    private Boolean isCorrect;

    protected RoomQuizAttemptAnswer() {
    }

    public RoomQuizAttemptAnswer(String attemptAnswerId, String attemptId, String roomQuizQuestionId,
            String selectedOptionId, String answerText, Boolean isCorrect) {
        this.attemptAnswerId = attemptAnswerId;
        this.attemptId = attemptId;
        this.roomQuizQuestionId = roomQuizQuestionId;
        this.selectedOptionId = selectedOptionId;
        this.answerText = answerText;
        this.isCorrect = isCorrect;
    }

    public String getRoomQuizQuestionId() {
        return roomQuizQuestionId;
    }

    public Boolean getIsCorrect() {
        return isCorrect;
    }
}
