package com.lucy.backend.auth.dto;

import lombok.Data;

@Data
public class AdminUserDto {
    private String userId;
    private String fullName;
    private String email;
    private Integer isStatus;
}
