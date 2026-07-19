package com.lucy.backend.content.content.model;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Questions")
public class Question {
    @Id
    @Column(name = "QuestionId", length = 50)
    private String questionId;

    @Column(name = "SubLevelId", length = 50, nullable = false)
    private String subLevelId;

    @Column(name = "QuestionNumber")
    private Integer questionNumber;

    @Column(name = "QuestionType", length = 50)
    private String questionType;

    @CreationTimestamp
    @Column(name = "CreatedAt", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    protected Question() {
    }

    public Question(String questionId, String subLevelId, Integer questionNumber, String questionType) {
        this.questionId = questionId;
        this.subLevelId = subLevelId;
        this.questionNumber = questionNumber;
        this.questionType = questionType;
    }

    public String getQuestionId() {
        return questionId;
    }
}
