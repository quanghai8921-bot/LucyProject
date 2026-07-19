package com.lucy.backend.content.common.repository;

import com.lucy.backend.content.common.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NotificationRepository extends JpaRepository<Notification, String> {
}
