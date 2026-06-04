package com.lucy.lms.learner.repository;

import com.lucy.lms.learner.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, String> {
}
