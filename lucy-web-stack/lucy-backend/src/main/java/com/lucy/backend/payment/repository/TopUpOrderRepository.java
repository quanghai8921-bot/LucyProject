package com.lucy.backend.payment.repository;

import com.lucy.backend.payment.entity.TopUpOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TopUpOrderRepository extends JpaRepository<TopUpOrder, String> {
    List<TopUpOrder> findAllByOrderByCreatedAtDesc();
}
