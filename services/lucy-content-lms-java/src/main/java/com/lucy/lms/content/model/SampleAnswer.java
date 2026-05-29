package com.lucy.lms.content.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;

@Entity
@Table(name = "SampleAnswers")
public class SampleAnswer {
    @Id
    @Column(name = "AnswerId", length = 50)
    private String answerId;

    @Column(name = "QuestionId", length = 50, nullable = false)
    private String questionId;

    @Column(name = "LanguageId", length = 50, nullable = false)
    private String languageId;

    @Lob
    @Column(name = "AnswerText")
    private String answerText;

    @Lob
    @Column(name = "AnsRomanization")
    private String ansRomanization;

    @Lob
    @Column(name = "Translation")
    private String translation;

    @Column(name = "AnswerOrder")
    private Integer answerOrder;

    protected SampleAnswer() {
    }

    public SampleAnswer(String answerId, String questionId, String languageId, String answerText,
            String ansRomanization, String translation, Integer answerOrder) {
        this.answerId = answerId;
        this.questionId = questionId;
        this.languageId = languageId;
        this.answerText = answerText;
        this.ansRomanization = ansRomanization;
        this.translation = translation;
        this.answerOrder = answerOrder;
    }
}
