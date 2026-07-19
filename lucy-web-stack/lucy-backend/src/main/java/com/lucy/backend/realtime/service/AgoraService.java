package com.lucy.backend.realtime.service;

import com.lucy.backend.realtime.dto.TokenRequestDto;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class AgoraService {

    @Value("${lucy.agora.appId}")
    private String appId;

    @Value("${lucy.agora.appCertificate}")
    private String appCertificate;

    @Value("${lucy.agora.tokenExpiresIn}")
    private Integer defaultExpiresIn;

    public Map<String, Object> createRtcToken(TokenRequestDto payload) {
        String channelName = (payload.getChannelName() != null) ? payload.getChannelName().trim() : 
                             (payload.getRoomId() != null ? payload.getRoomId().trim() : "");
        String uid = (payload.getUid() != null) ? payload.getUid().trim() : 
                     (payload.getUserId() != null ? payload.getUserId().trim() : "");
        Integer expiresIn = payload.getExpiresIn() != null ? payload.getExpiresIn() : defaultExpiresIn;

        if (appId == null || appCertificate == null) {
            throw new RuntimeException("Agora app id/certificate is not configured");
        }
        if (channelName.isEmpty()) {
            throw new IllegalArgumentException("channelName or roomId is required");
        }
        if (uid.isEmpty()) {
            throw new IllegalArgumentException("uid or userId is required");
        }

        long now = Instant.now().getEpochSecond();
        long privilegeExpireTime = now + expiresIn;
        
        io.agora.media.RtcTokenBuilder tokenBuilder = new io.agora.media.RtcTokenBuilder();
        String token;
        try {
            int uidInt = Integer.parseInt(uid);
            token = tokenBuilder.buildTokenWithUid(appId, appCertificate, channelName, uidInt,
                    io.agora.media.RtcTokenBuilder.Role.Role_Publisher, (int) privilegeExpireTime);
        } catch (NumberFormatException e) {
            token = tokenBuilder.buildTokenWithUserAccount(appId, appCertificate, channelName, uid,
                    io.agora.media.RtcTokenBuilder.Role.Role_Publisher, (int) privilegeExpireTime);
        }

        // RTM Token
        io.agora.rtm.RtmTokenBuilder rtmTokenBuilder = new io.agora.rtm.RtmTokenBuilder();
        String rtmToken = "";
        try {
            rtmToken = rtmTokenBuilder.buildToken(appId, appCertificate, uid, 
                    io.agora.rtm.RtmTokenBuilder.Role.Rtm_User, (int) privilegeExpireTime);
        } catch (Exception e) {
            System.err.println("Failed to build RTM token: " + e.getMessage());
        }

        Map<String, Object> result = new HashMap<>();
        result.put("appId", appId);
        result.put("channelName", channelName);
        result.put("uid", uid);
        result.put("token", token);
        result.put("rtmToken", rtmToken);
        result.put("expiresIn", expiresIn);
        result.put("expireAt", Instant.ofEpochSecond(privilegeExpireTime).toString());

        return result;
    }
}
