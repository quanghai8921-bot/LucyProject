package com.lucy.backend.payment.repository;

import com.lucy.backend.payment.entity.Gift;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GiftRepository extends JpaRepository<Gift, String> {
}
