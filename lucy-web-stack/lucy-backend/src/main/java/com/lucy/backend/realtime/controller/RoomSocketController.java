package com.lucy.backend.realtime.controller;

import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;

import java.util.Map;

@Controller
@CrossOrigin(originPatterns = "*")
public class RoomSocketController {

    /**
     * Handles 'join-room' equivalent. Clients can subscribe to /topic/room/{roomId}
     * and also send a join notification here.
     */
    @MessageMapping("/room/{roomId}/join")
    @SendTo("/topic/room/{roomId}")
    public Map<String, Object> joinRoom(@DestinationVariable String roomId, @Payload Map<String, Object> payload) {
        payload.put("type", "USER_JOINED");
        return payload;
    }

    /**
     * Handles 'leave-room' equivalent.
     */
    @MessageMapping("/room/{roomId}/leave")
    @SendTo("/topic/room/{roomId}")
    public Map<String, Object> leaveRoom(@DestinationVariable String roomId, @Payload Map<String, Object> payload) {
        payload.put("type", "USER_LEFT");
        return payload;
    }

    /**
     * Handles 'send-message' equivalent for Chat.
     */
    @MessageMapping("/room/{roomId}/chat")
    @SendTo("/topic/room/{roomId}")
    public Map<String, Object> chatMessage(@DestinationVariable String roomId, @Payload Map<String, Object> payload) {
        payload.put("type", "CHAT_MESSAGE");
        return payload;
    }
    
    /**
     * Handles 'hand-raise' equivalent.
     */
    @MessageMapping("/room/{roomId}/hand")
    @SendTo("/topic/room/{roomId}")
    public Map<String, Object> handRaise(@DestinationVariable String roomId, @Payload Map<String, Object> payload) {
        payload.put("type", "HAND_RAISE");
        return payload;
    }

    /**
     * Handles 'mic-toggle' equivalent.
     */
    @MessageMapping("/room/{roomId}/mic")
    @SendTo("/topic/room/{roomId}")
    public Map<String, Object> toggleMic(@DestinationVariable String roomId, @Payload Map<String, Object> payload) {
        payload.put("type", "MIC_TOGGLED");
        return payload;
    }

    /**
     * WebRTC Signaling: Offer
     */
    @MessageMapping("/room/{roomId}/webrtc/offer")
    @SendTo("/topic/room/{roomId}")
    public Map<String, Object> handleOffer(@DestinationVariable String roomId, @Payload Map<String, Object> payload) {
        payload.put("type", "WEBRTC_OFFER");
        return payload;
    }

    /**
     * WebRTC Signaling: Answer
     */
    @MessageMapping("/room/{roomId}/webrtc/answer")
    @SendTo("/topic/room/{roomId}")
    public Map<String, Object> handleAnswer(@DestinationVariable String roomId, @Payload Map<String, Object> payload) {
        payload.put("type", "WEBRTC_ANSWER");
        return payload;
    }

    /**
     * WebRTC Signaling: ICE Candidate
     */
    @MessageMapping("/room/{roomId}/webrtc/ice")
    @SendTo("/topic/room/{roomId}")
    public Map<String, Object> handleIceCandidate(@DestinationVariable String roomId, @Payload Map<String, Object> payload) {
        payload.put("type", "WEBRTC_ICE");
        return payload;
    }

    /**
     * Handles room ended by mentor.
     */
    @MessageMapping("/room/{roomId}/end")
    @SendTo("/topic/room/{roomId}")
    public Map<String, Object> handleRoomEnded(@DestinationVariable String roomId, @Payload Map<String, Object> payload) {
        payload.put("type", "ROOM_ENDED");
        return payload;
    }
}
