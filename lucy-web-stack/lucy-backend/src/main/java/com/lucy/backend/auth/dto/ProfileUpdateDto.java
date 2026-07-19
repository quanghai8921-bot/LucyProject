package com.lucy.backend.auth.dto;

import lombok.Data;

@Data
public class ProfileUpdateDto {
    private String displayName;
    private String avatarUrl;
}
