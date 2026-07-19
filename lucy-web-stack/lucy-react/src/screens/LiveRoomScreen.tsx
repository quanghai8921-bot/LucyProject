import React, { useEffect, useState, useRef } from 'react';
import { useParams, useNavigate, useLocation } from 'react-router-dom';
import { AppContext } from '../App';
import { Mic, MicOff, PhoneOff, Gift, Users, Hand, MessageSquare, Send, Pin, Music } from 'lucide-react';
import AgoraRTM from 'agora-rtm-sdk';
import AgoraRTC from "agora-rtc-sdk-ng";
import type { IAgoraRTCClient, IMicrophoneAudioTrack } from "agora-rtc-sdk-ng";


export const LiveRoomScreen: React.FC = () => {
  const { roomId } = useParams();
  const navigate = useNavigate();
  const location = useLocation();
  const { currentUser, currentRole } = React.useContext(AppContext);

  // Read room title from location state if passed, else fallback
  const roomTitle = (location.state as any)?.roomTitle || `Phòng học ${roomId}`;
  const languageId = (location.state as any)?.languageId;
  const levelNumber = (location.state as any)?.levelNumber;

  const [isMicOn, setIsMicOn] = useState(false);
  const [isHandRaised, setIsHandRaised] = useState(false);
  const [isChatOpen, setIsChatOpen] = useState(true);

  const [donateAmount, setDonateAmount] = useState(10000);
  const [profile, setProfile] = useState<any>(null);
  const [levelContent, setLevelContent] = useState<any>(null);
  const [currentSubLevelIndex, setCurrentSubLevelIndex] = useState(0);
  const [gifts, setGifts] = useState<any[]>([]);
  const [selectedGiftId, setSelectedGiftId] = useState<string | null>(null);
  const [giftQuantity, setGiftQuantity] = useState<number>(1);
  const [giftMessage, setGiftMessage] = useState<string>("");
  const [isGiftModalOpen, setIsGiftModalOpen] = useState(false);

  // Pinned materials states
  const [pinnedMaterials, setPinnedMaterials] = useState<any[]>([]);
  const [isPinnedMaterialsOpen, setIsPinnedMaterialsOpen] = useState(false);
  const [newPinTitle, setNewPinTitle] = useState("");
  const [pinFile, setPinFile] = useState<File | null>(null);

  // Chat states
  const [messages, setMessages] = useState<any[]>([]);
  const [chatInput, setChatInput] = useState("");

  const stateMentor = (location.state as any)?.isMentor;
  const localRole = localStorage.getItem('currentRole') || '';
  // Lấy chính xác chuỗi Role từ Database trả về thông qua API Profile hoặc Context
  const dbRole = String(profile?.role || profile?.roleId || currentUser?.role || '').toLowerCase();
  // Xác định nghiêm ngặt nếu DB định danh là Học viên (learner, r001, r002)
  const isActualLearner = dbRole.includes('learner') || dbRole.includes('r001') || dbRole.includes('r002');

  // Quyền Mentor/Host: Chỉ kích hoạt nếu KHÔNG PHẢI học viên thực sự và khớp các mã quyền chủ phòng
  const isMentor = !!(
    !isActualLearner && (
      stateMentor ||
      dbRole.includes('r003') ||
      dbRole.includes('r004') ||
      dbRole.includes('mentor') ||
      dbRole.includes('creator') ||
      (!dbRole && (localRole.toLowerCase().includes('mentor') || localRole.toLowerCase().includes('creator') || localRole.toLowerCase().includes('r003')))
    )
  );

  // 🌟 ĐÂY LÀ NƠI DUY NHẤT ĐỂ 2 DÒNG NÀY:
  const isCreatorRoom = (location.state as any)?.roomType === 'CREATOR_CLASS' || dbRole.includes('creator');
  const isCreatorHost = isMentor && (dbRole.includes('creator') || localRole.toLowerCase().includes('creator') || (location.state as any)?.roomType === 'CREATOR_CLASS');

  const [participants, setParticipants] = useState<any[]>([]);
  const roleStr = JSON.stringify({ currentRole, localRole, role1: currentUser?.role, role2: profile?.role, role3: profile?.roleId, role4: profile?.roles }).toLowerCase();


  const rtmClientRef = useRef<any>(null);
  const currentUserIdRef = useRef<string | null>(null);
  const rtcClientRef = useRef<IAgoraRTCClient | null>(null);
  const localAudioTrackRef = useRef<IMicrophoneAudioTrack | null>(null);
  const isJoinedRef = useRef<boolean>(false);

  const [isRecording, setIsRecording] = useState(false);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const audioChunksRef = useRef<Blob[]>([]);

  // Hàm bắt đầu ghi âm thanh từ Micro của Creator
  const startAudioRecording = () => {
    if (!localAudioTrackRef.current) {
      alert("Vui lòng bật Mic trước khi bấm ghi âm!");
      return;
    }
    // Lấy luồng âm thanh native từ track Agora RTC
    const nativeTrack = localAudioTrackRef.current.getMediaStreamTrack();
    const mediaStream = new MediaStream([nativeTrack]);

    const options = { mimeType: 'audio/webm' };
    const recorder = new MediaRecorder(mediaStream, options);

    audioChunksRef.current = [];
    recorder.ondataavailable = (event) => {
      if (event.data.size > 0) {
        audioChunksRef.current.push(event.data);
      }
    };

    // Tự động kích hoạt tải tệp tin về máy khi bấm kết thúc
    recorder.onstop = () => {
      const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/webm' });
      const audioUrl = URL.createObjectURL(audioBlob);
      const link = document.createElement('a');
      link.href = audioUrl;
      link.download = `Ghi_Am_Room_${roomId}_${Date.now()}.webm`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    };

    recorder.start();
    mediaRecorderRef.current = recorder;
    setIsRecording(true);
  };

  // Hàm kết thúc ghi âm
  const stopAudioRecording = () => {
    if (mediaRecorderRef.current && mediaRecorderRef.current.state !== 'inactive') {
      mediaRecorderRef.current.stop();
      setIsRecording(false);
    }
  };

  useEffect(() => {
    currentUserIdRef.current = currentUser?.id || profile?.userId || profile?.id;
  }, [currentUser, profile]);

  const handleIncomingMessage = (payload: any) => {
    switch (payload.type) {
      case 'CHAT_MESSAGE':
        const curId = currentUserIdRef.current;
        if (String(payload.userId) !== String(curId)) {
          const incomingMsg = {
            id: Date.now(),
            sender: payload.sender || "Người khác",
            text: payload.text,
            isMe: false
          };
          setMessages(prev => [...prev, incomingMsg]);
        }
        break;
      case 'GIFT_DONATED':
        const isUserMentor = isMentor || (profile?.roleId === 'R003' || String(profile?.role).toLowerCase().includes('mentor') || String(profile?.role).toLowerCase().includes('creator'));
        if (isUserMentor) {
          alert(`Bạn vừa nhận được quà từ ${payload.displayName}. Lời nhắn: ${payload.messageText}`);
        }
        setMessages(prev => [...prev, {
          id: Date.now(),
          sender: "Hệ thống 🎁",
          //Đoạn hiển thị thông tin giao diện
          text: `${payload.displayName} đã tặng ${payload.quantity}x ${payload.giftName} với lời nhắn: ${payload.messageText}`,
          isMe: false
        }]);
        break;
      case 'MIC_TOGGLED':
        setParticipants(prev => prev.map(p =>
          String(p.userId) === String(payload.userId) ? { ...p, micStatus: payload.enabled ? 'ON' : 'OFF' } : p
        ));
        break;
      case 'HAND_RAISE':
        setParticipants(prev => prev.map(p =>
          String(p.userId) === String(payload.userId) ? { ...p, handRaiseStatus: payload.raised ? 'RAISED' : 'NONE' } : p
        ));
        break;
      case 'USER_JOINED':
      case 'USER_LEFT':
        fetchParticipants();
        break;
      case 'ROOM_ENDED':
        const stateMentor1 = (location.state as any)?.isMentor;
        const localRole1 = localStorage.getItem('currentRole');
        const roleStr1 = JSON.stringify({ currentRole, localRole1, role1: currentUser?.role, role2: profile?.roles }).toLowerCase();
        const isMentorRole = stateMentor1 || roleStr1.includes('r003') || roleStr1.includes('mentor') || roleStr1.includes('creator');
        if (!isMentorRole) {
          alert("Giảng viên đã kết thúc phòng học này.");
          navigate('/learner');
        }
        break;
      case 'PINNED_MATERIAL_UPDATED':
        fetchPinnedMaterials();
        break;
      default:
        break;
    }
  };

  useEffect(() => {
    if (isJoinedRef.current) return;
    isJoinedRef.current = true;

    const initRoom = async () => {
      try {
        const token = localStorage.getItem('token');

        // Fetch Profile
        const profileRes = await fetch(`http://localhost:8081/api/user/profile`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        let fetchedProfile: any = null;
        if (profileRes.ok) {
          const profileData = await profileRes.json();
          fetchedProfile = profileData.data || profileData;
          setProfile(fetchedProfile);
        }

        // Fetch Gifts
        try {
          const giftsRes = await fetch(`http://localhost:8081/api/payment/gifts`, {
            headers: { 'Authorization': `Bearer ${token}` }
          });
          if (giftsRes.ok) {
            const giftsData = await giftsRes.json();
            setGifts(giftsData);
          }
        } catch (e) {
          console.error("Failed to fetch gifts", e);
        }

        // Fetch Pinned Materials
        try {
          const pinRes = await fetch(`http://localhost:8081/api/mentor/rooms/${roomId}/pinned-materials`, {
            headers: { 'Authorization': `Bearer ${token}` }
          });
          if (pinRes.ok) {
            const pinData = await pinRes.json();
            setPinnedMaterials(pinData);
          }
        } catch (e) {
          console.error("Failed to fetch pinned materials", e);
        }

        // Fetch Level Content if languageId and levelNumber exist
        if (languageId && levelNumber) {
          try {
            const contentRes = await fetch(`http://localhost:8081/api/v1/content/level-details?languageName=${languageId}&levelNumber=${levelNumber}`, {
              headers: { 'Authorization': `Bearer ${token}` }
            });
            if (contentRes.ok) {
              const contentData = await contentRes.json();
              setLevelContent(contentData);
            }
          } catch (e) {
            console.error("Failed to fetch level details", e);
          }
        }

        // Ensure user is joined in DB (especially for StrictMode double-mounts)
        const currentUserId = fetchedProfile?.userId || fetchedProfile?.id || currentUser?.id;
        if (currentUser?.role === 'R001' || currentUser?.role === 'R002' || currentUser?.role === 'learner' || currentUser?.role === 1 || currentUser?.role === 2) {
          await fetch(`http://localhost:8081/api/learner/rooms/${roomId}/join`, {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({ userId: currentUserId })
          });
        }

        // Polling participants
        fetchParticipants();

        if (currentUserId && roomId) {
          try {
            const tokenRes = await fetch(`http://localhost:8081/api/agora/token`, {
              method: 'POST',
              headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
              },
              body: JSON.stringify({ roomId, userId: currentUserId })
            });

            if (tokenRes.ok) {
              const tokenData = await tokenRes.json();
              const { appId, token: rtcToken, rtmToken, channelName, uid } = tokenData.data;

              // Cài đặt RTC Client
              const rtcClient = AgoraRTC.createClient({ mode: "rtc", codec: "vp8" });
              rtcClientRef.current = rtcClient;

              rtcClient.on("user-published", async (user, mediaType) => {
                await rtcClient.subscribe(user, mediaType);
                if (mediaType === "audio") {
                  user.audioTrack?.play();
                }
              });

              rtcClient.on("user-unpublished", (user, mediaType) => {
                if (mediaType === "audio") {
                  user.audioTrack?.stop();
                }
              });

              // Convert uid sang Number nếu có thể (vì backend dùng uidInt = Integer.parseInt(uid))
              const numericUid = !isNaN(Number(uid)) ? Number(uid) : uid;
              try {
                await rtcClient.join(appId, channelName, rtcToken, numericUid);
                console.log("Joined RTC channel successfully with uid:", numericUid);
              } catch (e) {
                console.error("RTC Join Error:", e);
              }

              // @ts-ignore
              const rtmClient = new (AgoraRTM.RTM as any)(appId, String(currentUserId));

              rtmClient.addEventListener("message", (event: any) => {
                if (event.messageType === "STRING") {
                  try {
                    const payload = JSON.parse(event.message);
                    handleIncomingMessage(payload);
                  } catch (e) {
                    console.error("Failed to parse RTM message", e);
                  }
                }
              });

              await rtmClient.login({ token: rtmToken });
              await rtmClient.subscribe(roomId);
              rtmClientRef.current = rtmClient;

              // Publish USER_JOINED so others know
              await rtmClient.publish(roomId, JSON.stringify({
                type: 'USER_JOINED',
                userId: currentUserId
              }));

              fetchParticipants();
            }
          } catch (rtmErr) {
            console.error("Agora RTM init error", rtmErr);
          }
        }
      } catch (err) {
        console.error("Error initializing room", err);
      }
    };
    initRoom();

    const handleBeforeUnload = () => {
      handleLeaveRoom();
    };
    window.addEventListener('beforeunload', handleBeforeUnload);

    return () => {
      window.removeEventListener('beforeunload', handleBeforeUnload);
      if (rtmClientRef.current) {
        rtmClientRef.current.logout();
      }
      if (localAudioTrackRef.current) {
        localAudioTrackRef.current.close();
      }
      if (rtcClientRef.current) {
        rtcClientRef.current.leave();
      }
    };
  }, [roomId, currentUser]);

  const fetchPinnedMaterials = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`http://localhost:8081/api/mentor/rooms/${roomId}/pinned-materials`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setPinnedMaterials(data);
      }
    } catch (err) {
      console.error("Error fetching pinned materials", err);
    }
  };

  const handlePinMaterial = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!pinFile || !newPinTitle.trim()) return;
    try {
      const token = localStorage.getItem('token');
      const formData = new FormData();
      formData.append("file", pinFile);
      formData.append("title", newPinTitle);

      const res = await fetch(`http://localhost:8081/api/mentor/rooms/${roomId}/pinned-materials`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`
        },
        body: formData
      });
      if (res.ok) {
        setNewPinTitle("");
        setPinFile(null);
        fetchPinnedMaterials();

        // Publish RTM update
        if (rtmClientRef.current) {
          await rtmClientRef.current.publish(roomId, JSON.stringify({
            type: 'PINNED_MATERIAL_UPDATED'
          }));
        }
      }
    } catch (err) {
      console.error("Failed to pin material", err);
    }
  };

  const handleUnpinMaterial = async (materialId: string) => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`http://localhost:8081/api/mentor/rooms/${roomId}/pinned-materials/${materialId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (res.ok) {
        fetchPinnedMaterials();

        // Publish RTM update
        if (rtmClientRef.current) {
          await rtmClientRef.current.publish(roomId, JSON.stringify({
            type: 'PINNED_MATERIAL_UPDATED'
          }));
        }
      }
    } catch (err) {
      console.error("Failed to delete pinned material", err);
    }
  };

  const fetchParticipants = async () => {
    try {
      const stateMentor2 = (location.state as any)?.isMentor;
      const token = localStorage.getItem('token');
      const localRole2 = localStorage.getItem('currentRole');
      const roleStr2 = JSON.stringify({ currentRole, localRole2, role1: currentUser?.role, role2: profile?.role, role3: profile?.roleId, role4: profile?.roles }).toLowerCase();
      const isMentor = stateMentor2 || roleStr2.includes('r003') || roleStr2.includes('mentor') || roleStr2.includes('creator');
      const url = isMentor
        ? `http://localhost:8081/api/mentor/rooms/${roomId}/participants`
        : `http://localhost:8081/api/learner/rooms/${roomId}/participants`;

      const res = await fetch(url, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setParticipants(data.data || data || []);
      }
    } catch (err) {
      console.error("Error fetching participants", err);
    }
  };

  const handleLeaveRoom = async () => {
    try {
      const token = localStorage.getItem('token');
      const currentUserId = currentUserIdRef.current || currentUser?.id || profile?.userId || profile?.id;

      if (currentUserId) {
        await fetch(`http://localhost:8081/api/learner/rooms/${roomId}/leave`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ userId: currentUserId })
        });
      } else {
        console.warn("handleLeaveRoom: Missing currentUserId");
      }

      if (rtmClientRef.current && roomId) {
        rtmClientRef.current.publish(roomId, JSON.stringify({
          type: 'USER_LEFT',
          userId: currentUserId
        }));
      }
      if (localAudioTrackRef.current) {
        localAudioTrackRef.current.close();
        localAudioTrackRef.current = null;
      }
      if (rtcClientRef.current) {
        rtcClientRef.current.leave();
      }
    } catch (err) {
      console.error("Leave room error", err);
    }
  };

  const toggleMic = async () => {
    try {
      const token = localStorage.getItem('token');
      const newState = !isMicOn;

      // Nếu chưa có localAudioTrack thì tạo và publish
      if (!localAudioTrackRef.current) {
        try {
          localAudioTrackRef.current = await AgoraRTC.createMicrophoneAudioTrack();
          if (rtcClientRef.current) {
            await rtcClientRef.current.publish([localAudioTrackRef.current]);
            console.log("Published local audio track");
          }
        } catch (e) {
          console.error("Create or publish audio track error:", e);
        }
      }

      // Bật / tắt luồng âm thanh
      if (localAudioTrackRef.current) {
        await localAudioTrackRef.current.setEnabled(newState);
      }

      setIsMicOn(newState);

      const currentUserId = currentUser?.id || profile?.userId || profile?.id;

      await fetch(`http://localhost:8081/api/learner/rooms/${roomId}/mic`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ userId: currentUserId, enabled: newState })
      });

      if (rtmClientRef.current && roomId) {
        rtmClientRef.current.publish(roomId, JSON.stringify({
          type: 'MIC_TOGGLED',
          userId: currentUserId,
          enabled: newState
        }));
      }
    } catch (err) {
      console.error("Toggle mic error", err);
    }
  };

  const toggleHandRaise = async () => {
    try {
      const token = localStorage.getItem('token');
      const newState = !isHandRaised;
      setIsHandRaised(newState);

      const currentUserId = currentUser?.id || profile?.userId || profile?.id;

      await fetch(`http://localhost:8081/api/learner/rooms/${roomId}/hand-raise`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ userId: currentUserId, raised: newState })
      });

      if (rtmClientRef.current && roomId) {
        rtmClientRef.current.publish(roomId, JSON.stringify({
          type: 'HAND_RAISE',
          userId: currentUserId,
          raised: newState
        }));
      }
    } catch (err) {
      console.error("Toggle hand raise error", err);
    }
  };

  const handleDonate = async () => {
    try {
      const selectedGift = gifts.find(g => g.giftId === selectedGiftId);
      if (!selectedGift) {
        alert("Vui lòng chọn một món quà trước.");
        return;
      }
      if (giftQuantity <= 0) {
        alert("Vui lòng nhập số lượng hợp lệ.");
        return;
      }

      const totalAmount = Number(selectedGift.priceAmount) * giftQuantity;
      const token = localStorage.getItem('token');
      const finalMessage = giftMessage.trim() || `Tặng ${giftQuantity} ${selectedGift.giftName}`;

      const res = await fetch(`http://localhost:8081/api/payment/donate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          roomId,
          amount: totalAmount,
          messageText: finalMessage,
          giftId: selectedGiftId,
          quantity: giftQuantity
        })
      });
      if (res.ok) {
        const data = await res.json();
        if (data.isSuccess === false) {
          alert(data.message || "Donate thất bại. Vui lòng kiểm tra số dư.");
        } else {
          alert(`Tặng ${giftQuantity} ${selectedGift.giftName} thành công! Cảm ơn bạn.`);

          if (rtmClientRef.current && roomId) {
            rtmClientRef.current.publish(roomId, JSON.stringify({
              type: 'GIFT_DONATED',
              displayName: data.displayName || profile?.fullName || currentUser?.fullName || "Người dùng",
              iconUrl: data.iconUrl || selectedGift.iconUrl || '🎁',
              messageText: data.messageText || finalMessage,
              giftName: selectedGift.giftName,
              quantity: giftQuantity
            }));
          }

          setSelectedGiftId(null);
          setGiftQuantity(1);
          setGiftMessage("");
        }
      } else {
        alert("Donate thất bại. Vui lòng kiểm tra số dư.");
      }
    } catch (err) {
      console.error("Donate error", err);
      alert("Lỗi kết nối khi donate.");
    }
  };

  const endRoom = async () => {
    if (!window.confirm("Bạn có chắc chắn kết thúc phòng?")) return;
    try {
      const token = localStorage.getItem('token');
      await fetch(`http://localhost:8081/api/mentor/rooms/${roomId}/end`, {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${token}` }
      });

      if (rtmClientRef.current && roomId) {
        rtmClientRef.current.publish(roomId, JSON.stringify({
          type: 'ROOM_ENDED',
          userId: profile?.userId || currentUser?.id
        }));
      }

      navigate('/mentor');
    } catch (err) {
      console.error("End room error", err);
    }
  };

  const exitRoom = async () => {
    if (!window.confirm("Bạn có thật sự muốn rời phòng không?")) return;
    if (localAudioTrackRef.current) {
      localAudioTrackRef.current.close();
    }

    if (rtcClientRef.current) {
      await rtcClientRef.current.leave();
    }
    await handleLeaveRoom();
    if (isMentor) {
      navigate('/mentor');
    } else {
      navigate(-1);
    }
  };

  const sendMessage = (e: React.FormEvent) => {
    e.preventDefault();
    if (!chatInput.trim()) return;

    const senderName = profile?.fullName || currentUser?.fullName || 'Tôi';
    const currentUserId = currentUser?.id || profile?.userId || profile?.id;

    const newMsg = {
      id: Date.now(),
      sender: senderName,
      text: chatInput,
      isMe: true
    };
    setMessages(prev => [...prev, newMsg]);
    setChatInput("");

    if (rtmClientRef.current && roomId) {
      rtmClientRef.current.publish(roomId, JSON.stringify({
        type: 'CHAT_MESSAGE',
        userId: currentUserId,
        sender: senderName,
        text: newMsg.text
      }));
    }
  };

  // Removed duplicate isMentor definition

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100vh', background: '#F8FAFC', color: '#1E293B', fontFamily: 'Inter, sans-serif' }}>
      {/* Header */}
      <header style={{ padding: '16px 24px', background: 'white', display: 'flex', justifyContent: 'space-between', alignItems: 'center', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', zIndex: 10 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <h2 style={{ margin: 0, fontSize: '1.25rem', color: 'var(--primary, #10B981)', fontWeight: 700 }}>
            {roomTitle}
          </h2>
          <span style={{ padding: '4px 8px', background: '#FEF3C7', color: '#D97706', borderRadius: '12px', fontSize: '0.75rem', fontWeight: 600 }}>
            Audio Room
          </span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <span style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#64748B', fontWeight: 500 }}>
            <Users size={18} /> {participants.length + 1}
          </span>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ width: '32px', height: '32px', borderRadius: '50%', background: 'var(--primary, #10B981)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold', fontSize: '0.9rem' }}>
              {(profile?.fullName || currentUser?.fullName || 'U')[0]}
            </div>
            <span style={{ fontWeight: '600', color: '#334155' }}>{profile?.fullName || currentUser?.fullName || 'Người dùng'}</span>
          </div>
        </div>
      </header>

      {/* Main Content Area */}
      <main style={{ flex: 1, display: 'flex', overflow: 'hidden' }}>

        {/* Participants Audio Grid */}
        <div style={{ flex: 1, padding: '24px', display: 'flex', flexDirection: 'column', gap: '16px', overflowY: 'auto' }}>

          {/* Level Content Section */}
          {levelContent && (
            <div style={{ background: 'white', borderRadius: '16px', padding: '24px', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.05)' }}>
              <h3 style={{ margin: '0 0 16px 0', color: 'var(--primary, #10B981)', fontSize: '1.2rem', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <span>Level {levelContent.levelNumber}: {levelContent.levelTitle}</span>
                <span style={{ fontSize: '0.9rem', color: '#64748B', fontWeight: 'normal' }}>
                  Bài {currentSubLevelIndex + 1} / {levelContent.subLevels?.length || 0}
                </span>
              </h3>

              {levelContent.subLevels && levelContent.subLevels[currentSubLevelIndex] && (
                <div style={{ background: '#F8FAFC', padding: '16px', borderRadius: '12px', border: '1px solid #E2E8F0' }}>
                  <h4 style={{ margin: '0 0 8px 0', color: '#334155', fontSize: '1.1rem' }}>
                    {levelContent.subLevels[currentSubLevelIndex].subLevelTitle}
                  </h4>
                  {levelContent.subLevels[currentSubLevelIndex].mainTask && (
                    <p style={{ margin: '0 0 16px 0', color: '#475569', lineHeight: '1.5' }}>
                      <strong>Nhiệm vụ chính:</strong> {levelContent.subLevels[currentSubLevelIndex].mainTask}
                    </p>
                  )}

                  <div style={{ display: 'flex', gap: '12px', marginTop: '16px' }}>
                    <button
                      onClick={() => setCurrentSubLevelIndex(Math.max(0, currentSubLevelIndex - 1))}
                      disabled={currentSubLevelIndex === 0}
                      style={{ padding: '8px 16px', background: currentSubLevelIndex === 0 ? '#E2E8F0' : 'white', color: currentSubLevelIndex === 0 ? '#94A3B8' : '#334155', border: '1px solid #CBD5E1', borderRadius: '8px', cursor: currentSubLevelIndex === 0 ? 'not-allowed' : 'pointer', fontWeight: 600 }}
                    >
                      Bài trước
                    </button>
                    <button
                      onClick={() => setCurrentSubLevelIndex(Math.min((levelContent.subLevels?.length || 1) - 1, currentSubLevelIndex + 1))}
                      disabled={currentSubLevelIndex === (levelContent.subLevels?.length || 1) - 1}
                      style={{ padding: '8px 16px', background: currentSubLevelIndex === (levelContent.subLevels?.length || 1) - 1 ? '#E2E8F0' : 'var(--primary, #10B981)', color: currentSubLevelIndex === (levelContent.subLevels?.length || 1) - 1 ? '#94A3B8' : 'white', border: 'none', borderRadius: '8px', cursor: currentSubLevelIndex === (levelContent.subLevels?.length || 1) - 1 ? 'not-allowed' : 'pointer', fontWeight: 600 }}
                    >
                      Bài tiếp
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* 🌟 KHỐI THÔNG BÁO GIƠ TAY MỚI: GỌN GÀNG, HIỆN ĐẠI VÀ ĐẶT LÊN TRÊN ĐẦU DANH SÁCH */}
          {participants.some(p => p.handRaiseStatus === 'RAISED') && (
            <div style={{
              padding: '12px 20px',
              background: '#FFF7ED',
              border: '1px solid #FFEDD5',
              borderRadius: '12px',
              display: 'flex',
              alignItems: 'center',
              gap: '16px',
              boxShadow: '0 2px 8px rgba(245, 158, 11, 0.05)',
              marginBottom: '20px'
            }}>
              {/* Tiêu đề ngắn gọn một hàng */}
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#EA580C', fontWeight: 600, fontSize: '0.95rem', whiteSpace: 'nowrap' }}>
                <Hand size={18} style={{ color: '#F97316' }} />
                <span>Đang giơ tay ({participants.filter(p => p.handRaiseStatus === 'RAISED').length}):</span>
              </div>

              {/* Danh sách các tag tên xếp hàng ngang */}
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', alignItems: 'center' }}>
                {participants.filter(p => p.handRaiseStatus === 'RAISED').map((p, i) => (
                  <span key={i} style={{
                    background: 'white',
                    padding: '4px 12px',
                    borderRadius: '20px',
                    color: '#475569',
                    fontSize: '0.85rem',
                    fontWeight: 600,
                    border: '1px solid #FED7AA',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '6px',
                    boxShadow: '0 1px 2px rgba(0,0,0,0.02)'
                  }}>
                    <span style={{ width: '6px', height: '6px', borderRadius: '50%', background: '#F97316' }}></span>
                    {p.displayName || 'Học viên'}
                  </span>
                ))}
              </div>
            </div>
          )}

          <h3 style={{ margin: 0, color: '#475569' }}>Thành viên trong phòng</h3>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(120px, 1fr))', gap: '20px' }}>
            {/* The Current User */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px', padding: '20px', background: 'white', borderRadius: '16px', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.05)', border: isMicOn ? '2px solid var(--primary, #10B981)' : '2px solid transparent' }}>
              <div style={{ width: '64px', height: '64px', borderRadius: '50%', background: 'var(--primary, #10B981)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '1.5rem', fontWeight: 'bold', position: 'relative' }}>
                {(profile?.fullName || currentUser?.fullName || 'U')[0]}
                {isHandRaised && (
                  <div style={{ position: 'absolute', top: '-5px', right: '-5px', background: '#F59E0B', borderRadius: '50%', padding: '4px', display: 'flex', boxShadow: '0 2px 4px rgba(0,0,0,0.2)' }}>
                    <Hand size={14} color="white" />
                  </div>
                )}
                {!isMicOn && (
                  <div style={{ position: 'absolute', bottom: '-2px', right: '-2px', background: '#EF4444', borderRadius: '50%', padding: '4px', display: 'flex', border: '2px solid white' }}>
                    <MicOff size={12} color="white" />
                  </div>
                )}
              </div>
              <span style={{ fontWeight: 600, fontSize: '0.9rem', color: '#334155', textAlign: 'center', width: '100%', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                {profile?.fullName || currentUser?.fullName} (Bạn)
              </span>
            </div>

            {/* Other Participants */}
            {participants.filter(p => p.userId !== (profile?.userId || profile?.id || currentUser?.id)).map((p, i) => (
              <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px', padding: '20px', background: 'white', borderRadius: '16px', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.05)', border: p.micStatus === 'ON' ? '2px solid var(--primary, #10B981)' : '2px solid transparent' }}>
                <div style={{ width: '64px', height: '64px', borderRadius: '50%', background: '#CBD5E1', color: '#475569', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '1.5rem', fontWeight: 'bold', position: 'relative' }}>
                  {p.displayName?.[0] || 'H'}
                  {p.handRaiseStatus === 'RAISED' && (
                    <div style={{ position: 'absolute', top: '-5px', right: '-5px', background: '#F59E0B', borderRadius: '50%', padding: '4px', display: 'flex', boxShadow: '0 2px 4px rgba(0,0,0,0.2)' }}>
                      <Hand size={14} color="white" />
                    </div>
                  )}
                  {p.micStatus !== 'ON' && (
                    <div style={{ position: 'absolute', bottom: '-2px', right: '-2px', background: '#EF4444', borderRadius: '50%', padding: '4px', display: 'flex', border: '2px solid white' }}>
                      <MicOff size={12} color="white" />
                    </div>
                  )}
                </div>
                <span style={{ fontWeight: 500, fontSize: '0.9rem', color: '#475569', textAlign: 'center', width: '100%', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                  {p.displayName || 'Học viên'}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* Sidebar: Chat & Donate */}
        {isChatOpen && (
          <div style={{ width: '320px', background: 'white', borderLeft: '1px solid #E2E8F0', display: 'flex', flexDirection: 'column' }}>

            {/* Chat Messages */}
            <div style={{ padding: '16px', borderBottom: '1px solid #E2E8F0', background: '#F8FAFC' }}>
              <h3 style={{ margin: 0, fontSize: '1rem', color: '#334155', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <MessageSquare size={18} /> Khung nhắn tin
              </h3>
            </div>

            <div style={{ flex: 1, padding: '16px', overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {messages.length === 0 && (
                <p style={{ textAlign: 'center', color: '#94A3B8', fontSize: '0.9rem', marginTop: '40px' }}>Chưa có tin nhắn nào. Hãy nói xin chào!</p>
              )}
              {messages.map((msg) => (
                <div key={msg.id} style={{ display: 'flex', flexDirection: 'column', alignItems: msg.isMe ? 'flex-end' : 'flex-start' }}>
                  <span style={{ fontSize: '0.75rem', color: '#94A3B8', marginBottom: '4px', padding: '0 4px' }}>{msg.sender}</span>
                  <div style={{ padding: '8px 12px', background: msg.isMe ? 'var(--primary, #10B981)' : '#F1F5F9', color: msg.isMe ? 'white' : '#334155', borderRadius: '12px', borderBottomRightRadius: msg.isMe ? '0' : '12px', borderBottomLeftRadius: msg.isMe ? '12px' : '0', maxWidth: '90%', wordBreak: 'break-word', fontSize: '0.9rem' }}>
                    {msg.text}
                  </div>
                </div>
              ))}
            </div>

            {/* Chat Input */}
            <div style={{ padding: '16px', borderTop: '1px solid #E2E8F0' }}>
              <form onSubmit={sendMessage} style={{ display: 'flex', gap: '8px' }}>
                <input
                  type="text"
                  value={chatInput}
                  onChange={(e) => setChatInput(e.target.value)}
                  placeholder="Nhập tin nhắn..."
                  style={{ flex: 1, padding: '10px 12px', borderRadius: '20px', border: '1px solid #E2E8F0', outline: 'none', background: '#F8FAFC' }}
                />
                <button type="submit" style={{ width: '40px', height: '40px', borderRadius: '50%', background: 'var(--primary, #10B981)', color: 'white', border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
                  <Send size={16} />
                </button>
              </form>
            </div>

            {/* Donate Section (Learner only) */}
            {!isMentor && (
              <div style={{ padding: '16px', borderTop: '1px solid #E2E8F0', background: '#FDFBFB' }}>
                <button
                  onClick={() => setIsGiftModalOpen(true)}
                  style={{
                    width: '100%',
                    padding: '10px',
                    background: 'linear-gradient(to right, #F59E0B, #D97706)',
                    color: 'white',
                    border: 'none',
                    borderRadius: '8px',
                    cursor: 'pointer',
                    fontWeight: 'bold',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '8px',
                    transition: 'all 0.2s',
                    boxShadow: '0 4px 6px -1px rgba(217, 119, 6, 0.2)'
                  }}
                >
                  <Gift size={18} /> {isCreatorRoom ? "Tặng quà Nhà sáng tạo" : "Tặng quà Giảng viên"}
                </button>
              </div>
            )}
          </div>
        )}
      </main>

      {/* Action Bar (Footer Controls) */}
      <footer style={{ padding: '16px 24px', background: 'white', borderTop: '1px solid #E2E8F0', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '16px', zIndex: 10 }}>

        {/* Toggle Chat */}
        <button
          onClick={() => setIsChatOpen(!isChatOpen)}
          style={{ width: '48px', height: '48px', borderRadius: '50%', background: isChatOpen ? 'var(--primary, #10B981)' : '#F1F5F9', color: isChatOpen ? 'white' : '#64748B', border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', transition: 'all 0.2s' }}
          title="Bật/tắt khung nhắn tin"
        >
          <MessageSquare size={22} />
        </button>

        {/* Raise Hand */}
        {!isMentor && (
          <button
            onClick={toggleHandRaise}
            style={{ width: '48px', height: '48px', borderRadius: '50%', background: isHandRaised ? '#F59E0B' : '#F1F5F9', color: isHandRaised ? 'white' : '#64748B', border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', transition: 'all 0.2s' }}
            title="Giơ tay phát biểu"
          >
            <Hand size={22} />
          </button>
        )}

        {/* Mic Toggle */}
        <button
          onClick={toggleMic}
          style={{ width: '56px', height: '56px', borderRadius: '50%', background: isMicOn ? 'var(--primary, #10B981)' : '#EF4444', color: 'white', border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', transition: 'all 0.2s', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)' }}
          title={isMicOn ? "Tắt mic" : "Bật mic"}
        >
          {isMicOn ? <Mic size={24} /> : <MicOff size={24} />}
        </button>

        {/* Pinned Materials Toggle */}
        <button
          onClick={() => {
            setIsPinnedMaterialsOpen(true);
            fetchPinnedMaterials();
          }}
          style={{ width: '48px', height: '48px', borderRadius: '50%', background: isPinnedMaterialsOpen ? 'var(--primary, #10B981)' : '#F1F5F9', color: isPinnedMaterialsOpen ? 'white' : '#64748B', border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', transition: 'all 0.2s', position: 'relative' }}
          title="Tài liệu ghim của lớp học"
        >
          <Pin size={22} />
          {pinnedMaterials.length > 0 && (
            <div style={{
              position: 'absolute',
              top: '-2px',
              right: '-2px',
              background: '#EF4444',
              color: 'white',
              borderRadius: '50%',
              width: '18px',
              height: '18px',
              fontSize: '0.75rem',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: 'bold'
            }}>
              {pinnedMaterials.length}
            </div>
          )}
        </button>

        <div style={{ width: '1px', height: '30px', background: '#E2E8F0', margin: '0 8px' }}></div>

        {/* 🌟 NÚT BẤM GHI ÂM DÀNH RIÊNG CHO CONTENT CREATOR */}
        {isCreatorHost && (
          <button
            onClick={isRecording ? stopAudioRecording : startAudioRecording}
            style={{
              padding: '0 20px',
              height: '48px',
              borderRadius: '24px',
              background: isRecording ? '#EF4444' : '#3B82F6',
              color: 'white',
              border: 'none',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              cursor: 'pointer',
              fontWeight: 'bold',
              transition: 'all 0.2s',
              boxShadow: isRecording ? '0 4px 6px -1px rgba(239, 68, 68, 0.4)' : '0 4px 6px -1px rgba(59, 130, 246, 0.4)'
            }}
            title={isRecording ? "Bấm để dừng ghi và tải file về máy" : "Bấm để bắt đầu ghi âm"}
          >
            <Music size={20} />
            {isRecording ? "Kết thúc ghi âm thanh" : "Ghi âm thanh"}
          </button>
        )}
        <div style={{ width: '1px', height: '30px', background: '#E2E8F0', margin: '0 8px' }}></div>

        {/* Leave/End Room */}
        {isMentor ? (
          <div style={{ display: 'flex', gap: '12px' }}>
            {/* Nút 1: Rời tạm thời (Gọi hàm exitRoom vừa sửa) */}
            <button
              onClick={exitRoom}
              style={{ padding: '0 24px', height: '48px', borderRadius: '24px', background: '#64748B', color: 'white', border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', cursor: 'pointer', fontWeight: 'bold', transition: 'opacity 0.2s' }}
            >
              <PhoneOff size={20} /> Rời tạm thời
            </button>

            {/* Nút 2: Kết thúc phòng vĩnh viễn (Giữ nguyên nút cũ) */}
            <button
              onClick={endRoom}
              style={{ padding: '0 24px', height: '48px', borderRadius: '24px', background: '#EF4444', color: 'white', border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', cursor: 'pointer', fontWeight: 'bold', transition: 'opacity 0.2s' }}
            >
              <PhoneOff size={20} /> Kết thúc phòng
            </button>
          </div>
        ) : (
          /* Nút rời phòng của Học viên giữ nguyên không đổi */
          <button
            onClick={exitRoom}
            style={{ padding: '0 24px', height: '48px', borderRadius: '24px', background: '#EF4444', color: 'white', border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', cursor: 'pointer', fontWeight: 'bold', transition: 'opacity 0.2s' }}
          >
            <PhoneOff size={20} /> Rời phòng
          </button>
        )}
      </footer>

      {/* Gift Modal */}
      {isGiftModalOpen && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: 'rgba(15, 23, 42, 0.6)',
          backdropFilter: 'blur(4px)',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          zIndex: 1000
        }}>
          <div style={{
            background: 'white',
            borderRadius: '16px',
            width: '450px',
            maxWidth: '90%',
            padding: '24px',
            boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',
            display: 'flex',
            flexDirection: 'column',
            gap: '16px',
            position: 'relative'
          }}>
            {/* Close Button */}
            <button
              onClick={() => {
                setIsGiftModalOpen(false);
                setSelectedGiftId(null);
                setGiftQuantity(1);
              }}
              style={{
                position: 'absolute',
                top: '16px',
                right: '16px',
                background: 'transparent',
                border: 'none',
                fontSize: '1.25rem',
                cursor: 'pointer',
                color: '#94A3B8',
                transition: 'color 0.2s',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                padding: '4px',
                borderRadius: '50%'
              }}
            >
              ✕
            </button>

            <h3 style={{ margin: 0, fontSize: '1.15rem', color: '#1E293B', fontWeight: 700, textAlign: 'center', borderBottom: '1px solid #F1F5F9', paddingBottom: '12px' }}>
              🎁 Tặng quà Giảng viên
            </h3>

            {/* Scrollable Gifts Grid */}
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(3, 1fr)',
              gap: '12px',
              maxHeight: '280px',
              overflowY: 'auto',
              padding: '4px'
            }}>
              {gifts.map(gift => {
                const isSelected = selectedGiftId === gift.giftId;
                return (
                  <div
                    key={gift.giftId}
                    onClick={() => {
                      setSelectedGiftId(gift.giftId);
                      setGiftQuantity(1);
                    }}
                    style={{
                      padding: '12px 8px',
                      background: isSelected ? '#FEF3C7' : '#F8FAFC',
                      border: isSelected ? '2px solid #F59E0B' : '1px solid #E2E8F0',
                      borderRadius: '12px',
                      cursor: 'pointer',
                      textAlign: 'center',
                      transition: 'all 0.2s',
                      boxShadow: isSelected ? '0 0 12px rgba(245, 158, 11, 0.4)' : 'none',
                      display: 'flex',
                      flexDirection: 'column',
                      alignItems: 'center',
                      gap: '6px'
                    }}
                  >
                    {gift.iconUrl && (gift.iconUrl.startsWith('http') || gift.iconUrl.startsWith('/') || gift.iconUrl.startsWith('data:')) ? (
                      <img
                        src={gift.iconUrl}
                        alt={gift.giftName}
                        style={{ width: '48px', height: '48px', objectFit: 'contain' }}
                      />
                    ) : (
                      <span style={{ fontSize: '2rem' }}>{gift.iconUrl || '🎁'}</span>
                    )}
                    <span style={{ fontSize: '0.8rem', fontWeight: 600, color: '#334155', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden', textOverflow: 'ellipsis', height: '2.40em', lineHeight: '1.20em' }}>
                      {gift.giftName}
                    </span>
                    <span style={{ fontSize: '0.75rem', color: '#64748B', fontWeight: 500 }}>
                      {Number(gift.priceAmount).toLocaleString()}đ
                    </span>
                  </div>
                );
              })}
            </div>

            {/* Selected Gift Quantity Input and Confirm Button */}
            {selectedGiftId ? (
              <div style={{
                display: 'flex',
                flexDirection: 'column',
                gap: '12px',
                padding: '16px',
                border: '1px solid #FEF3C7',
                background: '#FFFDF9',
                borderRadius: '12px',
                marginTop: '4px'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '8px' }}>
                  <span style={{ fontSize: '0.85rem', color: '#475569', fontWeight: 500 }}>Số lượng muốn tặng:</span>
                  <input
                    type="number"
                    min="1"
                    value={giftQuantity}
                    onChange={(e) => setGiftQuantity(Math.max(1, parseInt(e.target.value) || 1))}
                    style={{
                      width: '80px',
                      padding: '6px 10px',
                      borderRadius: '6px',
                      border: '1px solid #CBD5E1',
                      outline: 'none',
                      fontSize: '0.9rem',
                      fontWeight: 600,
                      textAlign: 'center'
                    }}
                  />
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
                  <span style={{ fontSize: '0.85rem', color: '#475569', fontWeight: 500 }}>Lời nhắn:</span>
                  <input
                    type="text"
                    placeholder="Nhập lời nhắn gửi kèm..."
                    value={giftMessage}
                    onChange={(e) => setGiftMessage(e.target.value)}
                    style={{
                      width: '100%',
                      padding: '6px 10px',
                      borderRadius: '6px',
                      border: '1px solid #CBD5E1',
                      outline: 'none',
                      fontSize: '0.85rem',
                      boxSizing: 'border-box'
                    }}
                  />
                </div>
                <button
                  onClick={async () => {
                    await handleDonate();
                    setIsGiftModalOpen(false);
                  }}
                  style={{
                    width: '100%',
                    padding: '10px',
                    background: 'linear-gradient(to right, #F59E0B, #D97706)',
                    color: 'white',
                    border: 'none',
                    borderRadius: '8px',
                    cursor: 'pointer',
                    fontWeight: 'bold',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '8px',
                    fontSize: '0.9rem',
                    boxShadow: '0 4px 6px -1px rgba(217, 119, 6, 0.3)',
                    transition: 'all 0.2s'
                  }}
                >
                  <Gift size={18} /> Xác nhận tặng ({(Number(gifts.find(g => g.giftId === selectedGiftId)?.priceAmount || 0) * giftQuantity).toLocaleString()}đ)
                </button>
              </div>
            ) : (
              <p style={{ textAlign: 'center', color: '#94A3B8', fontSize: '0.85rem', margin: '8px 0' }}>Vui lòng chọn một món quà để tặng</p>
            )}
          </div>
        </div>
      )}

      {/* Pinned Materials Modal */}
      {isPinnedMaterialsOpen && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: 'rgba(15, 23, 42, 0.6)',
          backdropFilter: 'blur(4px)',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          zIndex: 1000
        }}>
          <div style={{
            background: 'white',
            borderRadius: '16px',
            width: '500px',
            maxWidth: '90%',
            padding: '24px',
            boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',
            display: 'flex',
            flexDirection: 'column',
            gap: '16px',
            position: 'relative',
            maxHeight: '85vh'
          }}>
            {/* Header */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid #E2E8F0', paddingBottom: '12px' }}>
              <h3 style={{ margin: 0, fontSize: '1.25rem', color: '#1E293B', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Pin size={20} style={{ transform: 'rotate(45deg)' }} /> Tài liệu ghim của lớp học
              </h3>
              <button
                onClick={() => setIsPinnedMaterialsOpen(false)}
                style={{ background: 'none', border: 'none', fontSize: '1.5rem', cursor: 'pointer', color: '#94A3B8' }}
              >
                &times;
              </button>
            </div>

            {/* Upload form for Mentor */}
            {isMentor && (
              <form onSubmit={handlePinMaterial} style={{ display: 'flex', flexDirection: 'column', gap: '12px', background: '#F8FAFC', padding: '16px', borderRadius: '12px', border: '1px solid #E2E8F0' }}>
                <h4 style={{ margin: 0, fontSize: '0.9rem', color: '#475569' }}>Ghim tài liệu mới</h4>
                <input
                  type="text"
                  placeholder="Tiêu đề tài liệu..."
                  value={newPinTitle}
                  onChange={(e) => setNewPinTitle(e.target.value)}
                  required
                  style={{ padding: '8px 12px', borderRadius: '6px', border: '1px solid #CBD5E1', outline: 'none', fontSize: '0.9rem' }}
                />
                <input
                  type="file"
                  onChange={(e) => setPinFile(e.target.files?.[0] || null)}
                  required
                  style={{ fontSize: '0.85rem' }}
                />
                <button
                  type="submit"
                  style={{ padding: '8px 16px', background: 'var(--primary, #10B981)', color: 'white', border: 'none', borderRadius: '6px', cursor: 'pointer', fontWeight: 'bold', fontSize: '0.9rem' }}
                >
                  Tải lên & Ghim
                </button>
              </form>
            )}

            {/* Materials List */}
            <div style={{ flex: 1, overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '12px', maxHeight: '40vh', paddingRight: '4px' }}>
              {pinnedMaterials.length === 0 ? (
                <p style={{ textAlign: 'center', color: '#94A3B8', fontSize: '0.9rem', margin: '20px 0' }}>Chưa có tài liệu nào được ghim trong lớp học này.</p>
              ) : (
                pinnedMaterials.map((mat) => (
                  <div key={mat.pinnedMaterialId} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px', background: '#F1F5F9', borderRadius: '8px', border: '1px solid #E2E8F0' }}>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '4px', maxWidth: '75%' }}>
                      <span style={{ fontWeight: 600, fontSize: '0.95rem', color: '#1E293B', wordBreak: 'break-word' }}>{mat.title}</span>
                      <span style={{ fontSize: '0.75rem', color: '#64748B' }}>
                        {mat.fileType || 'FILE'} • {(mat.fileSize / 1024).toFixed(1)} KB
                      </span>
                    </div>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      {!isMentor && (
                        <a
                          href={`http://localhost:8081${mat.fileUrl}`}
                          download
                          target="_blank"
                          rel="noopener noreferrer"
                          style={{ padding: '6px 12px', background: '#3B82F6', color: 'white', borderRadius: '6px', textDecoration: 'none', fontSize: '0.85rem', fontWeight: 'bold' }}
                        >
                          Tải xuống
                        </a>
                      )}
                      {isMentor && (
                        <button
                          onClick={() => handleUnpinMaterial(mat.pinnedMaterialId)}
                          style={{ padding: '6px 12px', background: '#EF4444', color: 'white', borderRadius: '6px', border: 'none', cursor: 'pointer', fontSize: '0.85rem', fontWeight: 'bold' }}
                        >
                          Gỡ
                        </button>
                      )}
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
