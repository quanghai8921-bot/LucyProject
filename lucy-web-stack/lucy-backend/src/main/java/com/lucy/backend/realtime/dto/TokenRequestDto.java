package com.lucy.backend.realtime.dto;

import lombok.Data;

@Data
public class TokenRequestDto {
    private String channelName;
    private String roomId;
    private String uid;
    private String userId;
    private Integer expiresIn;
}
