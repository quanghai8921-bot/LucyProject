package com.lucy.models;

public class QuestionContent {
    private String QuestionContentId;
    private String QuestionId;
    private String LanguageId;
    private String QuestionText;
    private String GrammarNote;
    private String PronunciationNote;
    private String ExampleContext;

    public QuestionContent() {
    }

    public QuestionContent(String QuestionContentId, String QuestionId, String LanguageId, String QuestionText,
            String GrammarNote, String PronunciationNote, String ExampleContext) {
        this.QuestionContentId = QuestionContentId;
        this.QuestionId = QuestionId;
        this.LanguageId = LanguageId;
        this.QuestionText = QuestionText;
        this.GrammarNote = GrammarNote;
        this.PronunciationNote = PronunciationNote;
        this.ExampleContext = ExampleContext;
    }

    public String getQuestionContentId() {
        return this.QuestionContentId;
    }

    public void setQuestionContentId(String QuestionContentId) {
        this.QuestionContentId = QuestionContentId;
    }

    public String getQuestionId() {
        return this.QuestionId;
    }

    public void setQuestionId(String QuestionId) {
        this.QuestionId = QuestionId;
    }

    public String getLanguageId() {
        return this.LanguageId;
    }

    public void setLanguageId(String LanguageId) {
        this.LanguageId = LanguageId;
    }

    public String getQuestionText() {
        return this.QuestionText;
    }

    public void setQuestionText(String QuestionText) {
        this.QuestionText = QuestionText;
    }

    public String getGrammarNote() {
        return this.GrammarNote;
    }

    public void setGrammarNote(String GrammarNote) {
        this.GrammarNote = GrammarNote;
    }

    public String getPronunciationNote() {
        return this.PronunciationNote;
    }

    public void setPronunciationNote(String PronunciationNote) {
        this.PronunciationNote = PronunciationNote;
    }

    public String getExampleContext() {
        return this.ExampleContext;
    }

    public void setExampleContext(String ExampleContext) {
        this.ExampleContext = ExampleContext;
    }
}