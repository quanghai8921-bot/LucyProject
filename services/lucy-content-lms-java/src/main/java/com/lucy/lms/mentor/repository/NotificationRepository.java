package com.lucy.lms.mentor.repository;

import com.lucy.lms.mentor.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NotificationRepository extends JpaRepository<Notification, String> {
}
