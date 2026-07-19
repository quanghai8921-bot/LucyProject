package com.lucy.backend.auth.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "Users")
@Data
public class User {
    @Id
    @Column(name = "UserId", length = 50)
    private String userId;

    @Column(name = "FullName", length = 100)
    private String fullName;

    @Column(name = "Email", length = 100)
    private String email;

    @Column(name = "Passwords", length = 255)
    private String passwords;

    @Column(name = "IsStatus")
    private Integer isStatus = 1;
}
