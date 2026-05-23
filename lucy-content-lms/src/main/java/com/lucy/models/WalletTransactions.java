package com.lucy.models;

import java.math.BigDecimal;
import java.util.Date;

public class WalletTransactions {
    private String TransactionId;
    private String WalletId;
    private String TransactionType;
    private BigDecimal Amount;
    private String ReferenceId;
    private Date CreatedAt;
    private String TransactionStatus;

    public WalletTransactions() {
    }

    public WalletTransactions(String TransactionId, String WalletId, String TransactionType, BigDecimal Amount,
            String ReferenceId, Date CreatedAt, String TransactionStatus) {
        this.TransactionId = TransactionId;
        this.WalletId = WalletId;
        this.TransactionType = TransactionType;
        this.Amount = Amount;
        this.ReferenceId = ReferenceId;
        this.CreatedAt = CreatedAt;
        this.TransactionStatus = TransactionStatus;
    }

    public String getTransactionId() {
        return this.TransactionId;
    }

    public void setTransactionId(String TransactionId) {
        this.TransactionId = TransactionId;
    }

    public String getWalletId() {
        return this.WalletId;
    }

    public void setWalletId(String WalletId) {
        this.WalletId = WalletId;
    }

    public String getTransactionType() {
        return this.TransactionType;
    }

    public void setTransactionType(String TransactionType) {
        this.TransactionType = TransactionType;
    }

    public BigDecimal getAmount() {
        return this.Amount;
    }

    public void setAmount(BigDecimal Amount) {
        this.Amount = Amount;
    }

    public String getReferenceId() {
        return this.ReferenceId;
    }

    public void setReferenceId(String ReferenceId) {
        this.ReferenceId = ReferenceId;
    }

    public Date getCreatedAt() {
        return this.CreatedAt;
    }

    public void setCreatedAt(Date CreatedAt) {
        this.CreatedAt = CreatedAt;
    }

    public String getTransactionStatus() {
        return this.TransactionStatus;
    }

    public void setTransactionStatus(String TransactionStatus) {
        this.TransactionStatus = TransactionStatus;
    }
}