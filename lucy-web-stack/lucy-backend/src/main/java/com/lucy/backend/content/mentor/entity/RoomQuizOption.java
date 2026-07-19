package com.lucy.backend.content.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "RoomQuizOptions")
public class RoomQuizOption {

    @Id
    @Column(name = "OptionId", length = 50)
    private String optionId;

    @Column(name = "RoomQuizQuestionId", length = 50, nullable = false)
    private String roomQuizQuestionId;

    @Column(name = "OptionText", nullable = false)
    private String optionText;

    @Column(name = "IsCorrect")
    private Boolean isCorrect;

    @Column(name = "OptionOrder")
    private Integer optionOrder;

    protected RoomQuizOption() {
    }

    public RoomQuizOption(
            String optionId,
            String roomQuizQuestionId,
            String optionText,
            Boolean isCorrect,
            Integer optionOrder) {

        this.optionId = optionId;
        this.roomQuizQuestionId = roomQuizQuestionId;
        this.optionText = optionText;
        this.isCorrect = isCorrect;
        this.optionOrder = optionOrder;
    }

    public String getOptionId() {
        return optionId;
    }

    public String getRoomQuizQuestionId() {
        return roomQuizQuestionId;
    }

    public String getOptionText() {
        return optionText;
    }

    public Boolean getIsCorrect() {
        return isCorrect;
    }

    public Integer getOptionOrder() {
        return optionOrder;
    }
}
