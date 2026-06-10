package com.lucy.lms.creator.repository;

import com.lucy.lms.creator.entity.ContentPurchase;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ContentPurchaseRepository extends JpaRepository<ContentPurchase, String> {
    List<ContentPurchase> findByBuyerUserIdOrderByPurchasedAtDesc(String buyerUserId);
}
