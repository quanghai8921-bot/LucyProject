package com.lucy.lms.common.repository;

import com.lucy.lms.common.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NotificationRepository extends JpaRepository<Notification, String> {
}
