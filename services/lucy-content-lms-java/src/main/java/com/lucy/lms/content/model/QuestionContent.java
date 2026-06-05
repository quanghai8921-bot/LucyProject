package com.lucy.lms.content.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;

@Entity
@Table(name = "QuestionContent")
public class QuestionContent {
    @Id
    @Column(name = "QuestionContentId", length = 50)
    private String questionContentId;

    @Column(name = "QuestionId", length = 50, nullable = false)
    private String questionId;

    @Column(name = "LanguageId", length = 50, nullable = false)
    private String languageId;

    @Lob
    @Column(name = "QuestionText", nullable = false)
    private String questionText;

    @Lob
    @Column(name = "QueRomanization")
    private String queRomanization;

    @Lob
    @Column(name = "Translation")
    private String translation;

    @Column(name = "GrammarNote")
    private String grammarNote;

    @Column(name = "PronunciationNote")
    private String pronunciationNote;

    @Column(name = "ExampleContext")
    private String exampleContext;

    protected QuestionContent() {
    }

    public QuestionContent(String questionContentId, String questionId, String languageId, String questionText,
            String queRomanization, String translation, String grammarNote, String pronunciationNote,
            String exampleContext) {
        this.questionContentId = questionContentId;
        this.questionId = questionId;
        this.languageId = languageId;
        this.questionText = questionText;
        this.queRomanization = queRomanization;
        this.translation = translation;
        this.grammarNote = grammarNote;
        this.pronunciationNote = pronunciationNote;
        this.exampleContext = exampleContext;
    }
}
