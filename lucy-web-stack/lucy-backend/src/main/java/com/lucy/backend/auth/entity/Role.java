package com.lucy.backend.auth.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "Roles")
@Data
public class Role {
    @Id
    @Column(name = "RoleId", length = 50)
    private String roleId;

    @Column(name = "RoleName", length = 50)
    private String roleName;
}
