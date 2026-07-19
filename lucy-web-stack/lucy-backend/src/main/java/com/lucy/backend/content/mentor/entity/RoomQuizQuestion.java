package com.lucy.backend.content.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "RoomQuizQuestions")
public class RoomQuizQuestion {

    @Id
    @Column(name = "RoomQuizQuestionId", length = 50)
    private String roomQuizQuestionId;

    @Column(name = "QuizId", length = 50, nullable = false)
    private String quizId;

    @Column(name = "QuestionText", nullable = false)
    private String questionText;

    @Column(name = "QuestionType", length = 50)
    private String questionType;

    @Column(name = "CorrectAnswerText")
    private String correctAnswerText;

    @Column(name = "QuestionOrder")
    private Integer questionOrder;

    protected RoomQuizQuestion() {
    }

    public RoomQuizQuestion(
            String roomQuizQuestionId,
            String quizId,
            String questionText,
            String questionType,
            String correctAnswerText,
            Integer questionOrder) {

        this.roomQuizQuestionId = roomQuizQuestionId;
        this.quizId = quizId;
        this.questionText = questionText;
        this.questionType = questionType;
        this.correctAnswerText = correctAnswerText;
        this.questionOrder = questionOrder;
    }

    public String getRoomQuizQuestionId() {
        return roomQuizQuestionId;
    }

    public String getQuizId() {
        return quizId;
    }

    public String getQuestionText() {
        return questionText;
    }

    public String getQuestionType() {
        return questionType;
    }

    public String getCorrectAnswerText() {
        return correctAnswerText;
    }

    public Integer getQuestionOrder() {
        return questionOrder;
    }
}
