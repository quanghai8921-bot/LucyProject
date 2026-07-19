package com.lucy.backend.auth.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "UserRoles")
@Data
@IdClass(UserRoleId.class)
public class UserRole {
    @Id
    @Column(name = "UserId", length = 50)
    private String userId;

    @Id
    @Column(name = "RoleId", length = 50)
    private String roleId;
}
