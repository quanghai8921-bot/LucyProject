package com.lucy.backend.auth.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "AvatarPersonas")
public class AvatarPersona {
    
    @Id
    @Column(name = "UserId", length = 50)
    private String userId;

    @Column(name = "DisplayName", length = 50, nullable = false)
    private String displayName;

    @Column(name = "AvatarUrl", length = 255)
    private String avatarUrl;

    @Column(name = "IsAnonymous", nullable = false)
    private int isAnonymous = 1;
}
