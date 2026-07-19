package com.lucy.backend.realtime.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AgoraTokenResponse {
    private String token;
    private String uid;
    private String channelName;
}
