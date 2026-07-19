package com.lucy.backend.payment.repository;

import com.lucy.backend.payment.entity.WithdrawalRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WithdrawalRequestRepository extends JpaRepository<WithdrawalRequest, String> {
    List<WithdrawalRequest> findAllByOrderByRequestedAtDesc();
}
