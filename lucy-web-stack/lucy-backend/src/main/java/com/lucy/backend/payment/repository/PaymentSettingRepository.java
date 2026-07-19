package com.lucy.backend.payment.repository;

import com.lucy.backend.payment.entity.PaymentSetting;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PaymentSettingRepository extends JpaRepository<PaymentSetting, String> {
    Optional<PaymentSetting> findByProviderCode(String providerCode);
}
