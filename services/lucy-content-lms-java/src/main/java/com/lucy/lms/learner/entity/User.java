package com.lucy.lms.learner.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "Users")
public class User {

    @Id
    @Column(name = "UserId", length = 50)
    private String userId;

    @Column(name = "FullName", length = 50, nullable = false)
    private String fullName;

    @Column(name = "PhoneNumber", length = 10, nullable = false, unique = true)
    private String phoneNumber;

    @Column(name = "Email", length = 50, nullable = false, unique = true)
    private String email;

    @Column(name = "Passwords", length = 255, nullable = false)
    private String passwords;

    @Column(name = "CreatedAt")
    private LocalDateTime createdAt;

    @Column(name = "IsStatus", nullable = false)
    private Integer isStatus;

    protected User() {
    }

    public User(String userId, String fullName, String phoneNumber, String email, String passwords,
                LocalDateTime createdAt, Integer isStatus) {
        this.userId = userId;
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.email = email;
        this.passwords = passwords;
        this.createdAt = createdAt;
        this.isStatus = isStatus;
    }

    public String getUserId() {
        return userId;
    }

    public String getFullName() {
        return fullName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public String getEmail() {
        return email;
    }

    public String getPasswords() {
        return passwords;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public Integer getIsStatus() {
        return isStatus;
    }
}
