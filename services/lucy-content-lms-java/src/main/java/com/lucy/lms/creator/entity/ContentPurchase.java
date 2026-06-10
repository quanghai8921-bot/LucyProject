package com.lucy.lms.creator.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "ContentPurchases")
public class ContentPurchase {

    @Id
    @Column(name = "PurchaseId", length = 50)
    private String purchaseId;

    @Column(name = "ContentId", length = 50, nullable = false)
    private String contentId;

    @Column(name = "BuyerUserId", length = 50, nullable = false)
    private String buyerUserId;

    @Column(name = "SellerUserId", length = 50, nullable = false)
    private String sellerUserId;

    @Column(name = "PriceAmount", nullable = false)
    private BigDecimal priceAmount;

    @Column(name = "PurchasedAt", nullable = false)
    private LocalDateTime purchasedAt;

    protected ContentPurchase() {
    }

    public String getPurchaseId() {
        return purchaseId;
    }

    public String getContentId() {
        return contentId;
    }

    public String getBuyerUserId() {
        return buyerUserId;
    }

    public String getSellerUserId() {
        return sellerUserId;
    }

    public BigDecimal getPriceAmount() {
        return priceAmount;
    }

    public LocalDateTime getPurchasedAt() {
        return purchasedAt;
    }
}
