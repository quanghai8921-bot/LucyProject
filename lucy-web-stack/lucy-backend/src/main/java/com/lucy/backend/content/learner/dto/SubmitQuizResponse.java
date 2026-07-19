package com.lucy.backend.content.learner.dto;

import java.math.BigDecimal;

public class SubmitQuizResponse {
    private BigDecimal scorePercent;
    private Boolean isPassed;

    public SubmitQuizResponse(BigDecimal scorePercent, Boolean isPassed) {
        this.scorePercent = scorePercent;
        this.isPassed = isPassed;
    }

    public BigDecimal getScorePercent() {
        return scorePercent;
    }

    public void setScorePercent(BigDecimal scorePercent) {
        this.scorePercent = scorePercent;
    }

    public Boolean getIsPassed() {
        return isPassed;
    }

    public void setIsPassed(Boolean isPassed) {
        this.isPassed = isPassed;
    }
}
