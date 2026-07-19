package com.lucy.backend.content.content.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Languages")
public class Language {
    @Id
    @Column(name = "LanguageId", length = 50)
    private String languageId;

    @Column(name = "LanguageName", length = 50, nullable = false)
    private String languageName;

    protected Language() {
    }

    public Language(String languageId, String languageName) {
        this.languageId = languageId;
        this.languageName = languageName;
    }

    public String getLanguageId() {
        return languageId;
    }

    public String getLanguageName() {
        return languageName;
    }
}
