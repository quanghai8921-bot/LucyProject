package com.lucy.models;

public class Languages {
    private String LanguageId;
    private String LanguageName;

    public Languages() {
    }

    public Languages(String LanguageId, String LanguageName) {
        this.LanguageId = LanguageId;
        this.LanguageName = LanguageName;
    }

    public String getLanguageId() {
        return this.LanguageId;
    }

    public void setLanguageId(String LanguageId) {
        this.LanguageId = LanguageId;
    }

    public String getLanguageName() {
        return this.LanguageName;
    }

    public void setLanguageName(String LanguageName) {
        this.LanguageName = LanguageName;
    }
}