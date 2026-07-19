package com.lucy.backend.content.content.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;

@Entity
@Table(name = "StageDesignNotes")
public class StageDesignNote {
    @Id
    @Column(name = "NoteId", length = 50)
    private String noteId;

    @Column(name = "StageId", length = 50, nullable = false)
    private String stageId;

    @Column(name = "NoteType", length = 50, nullable = false)
    private String noteType;

    @Column(name = "NoteOrder")
    private Integer noteOrder;

    @Lob
    @Column(name = "ContentText", nullable = false)
    private String contentText;

    protected StageDesignNote() {
    }

    public StageDesignNote(String noteId, String stageId, String noteType, Integer noteOrder, String contentText) {
        this.noteId = noteId;
        this.stageId = stageId;
        this.noteType = noteType;
        this.noteOrder = noteOrder;
        this.contentText = contentText;
    }
}
