package com.lucy.models;

import java.math.BigDecimal;
import java.util.Date;

public class Wallets {
    private String UserId;
    private BigDecimal Balance;
    private Date UpdatedAt;
    private int IsStatus;

    public Wallets() {
    }

    public Wallets(String UserId, BigDecimal Balance, Date UpdatedAt, int IsStatus) {
        this.UserId = UserId;
        this.Balance = Balance;
        this.UpdatedAt = UpdatedAt;
        this.IsStatus = IsStatus;
    }

    public String getUserId() {
        return this.UserId;
    }

    public void setUserId(String UserId) {
        this.UserId = UserId;
    }

    public BigDecimal getBalance() {
        return this.Balance;
    }

    public void setBalance(BigDecimal Balance) {
        this.Balance = Balance;
    }

    public Date getUpdatedAt() {
        return this.UpdatedAt;
    }

    public void setUpdatedAt(Date UpdatedAt) {
        this.UpdatedAt = UpdatedAt;
    }

    public int getIsStatus() {
        return this.IsStatus;
    }

    public void setIsStatus(int IsStatus) {
        this.IsStatus = IsStatus;
    }
}