import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { AppContext } from '../App';
import { Card } from '../components/Card';
import { Input } from '../components/Input';
import { Button } from '../components/Button';
import {
  PlusCircle,
  Video,
  CheckCircle,
  Clock,
  Upload,
  Music,
  Layers,
  DollarSign,
  Play
} from 'lucide-react';

export const CreatorHome: React.FC = () => {
  const navigate = useNavigate();
  const { currentUser } = React.useContext(AppContext);

  // Tab State
  const [activeTab, setActiveTab] = useState<'rooms' | 'paid_contents'>('rooms');

  // Creator Room features state
  const [roomName, setRoomName] = useState('');
  const [roomAccessType, setRoomAccessType] = useState<'FREE' | 'PAID'>('FREE'); // Trả phí hoặc Free
  const [roomPrice, setRoomPrice] = useState('0'); // Giá xu của phòng học
  const [roomTypeMode, setRoomTypeMode] = useState<'LANGUAGE' | 'FREE'>('FREE'); // Dạy ngoại ngữ hoặc Tự do
  const [lang, setLang] = useState('English');
  const [level, setLevel] = useState('1');

  const [openRooms, setOpenRooms] = useState<any[]>([]);
  const [endedRooms, setEndedRooms] = useState<any[]>([]);
  const [isSubmittingRoom, setIsSubmittingRoom] = useState(false);
  const [profile, setProfile] = useState<any>(null);
  const [avatar, setAvatar] = useState<string>('');

  // Paid contents state
  const [paidContents, setPaidContents] = useState<any[]>([]);
  const [contentTitle, setContentTitle] = useState('');
  const [contentBaseType, setContentBaseType] = useState('PODCAST');
  const [accessType, setAccessType] = useState<'FREE' | 'PAID'>('FREE');
  const [contentDesc, setContentDesc] = useState('');
  const [contentPrice, setContentPrice] = useState('0');
  const [contentStatus, setContentStatus] = useState('PRIVATE');
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [isSubmittingContent, setIsSubmittingContent] = useState(false);

  useEffect(() => {
    const initData = async () => {
      try {
        const token = sessionStorage.getItem('token');
        if (!token) {
          navigate('/login');
          return;
        }

        const profileRes = await fetch(`http://localhost:8081/api/user/profile`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });

        let currentUserId = currentUser?.id;
        if (profileRes.ok) {
          const profileData = await profileRes.json();
          const realProfile = profileData.data || profileData;
          setProfile(realProfile);
          currentUserId = realProfile.userId || realProfile.id;
        }

        if (currentUserId) {
          fetchRooms(currentUserId, token);
          fetchPaidContents(currentUserId, token);
        }

        const avaRes = await fetch('http://localhost:8081/api/user/profile/avatar', {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (avaRes.ok) {
          const avaData = await avaRes.json();
          setAvatar(avaData.data?.url || avaData.url || avaData);
        }
      } catch (err) {
        console.error("Init creator data error", err);
      }
    };

    initData();
  }, [currentUser]);

  const fetchRooms = async (userId: string, token: string) => {
    try {
      const response = await fetch(`http://localhost:8081/api/mentor/rooms/mentor/${userId}`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (response.ok) {
        const data = await response.json();
        const allRooms = data.data || data || [];
        setOpenRooms(allRooms.filter((r: any) => r.roomStatus !== 'ENDED'));
        setEndedRooms(allRooms.filter((r: any) => r.roomStatus === 'ENDED'));
      }
    } catch (err) {
      console.error("Error fetching rooms", err);
    }
  };

  const fetchPaidContents = async (userId: string, token: string) => {
    try {
      const response = await fetch(`http://localhost:8081/api/creator/contents?creatorUserId=${userId}`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (response.ok) {
        const data = await response.json();
        setPaidContents(data || []);
      }
    } catch (err) {
      console.error("Error fetching paid contents", err);
    }
  };

  const createRoom = async (e: React.FormEvent) => {
    e.preventDefault();
    if (isSubmittingRoom) return;
    setIsSubmittingRoom(true);
    try {
      const token = sessionStorage.getItem('token');
      const actualUserId = profile?.userId || profile?.id || currentUser?.id;
      const actualRole = profile?.role || profile?.roles?.[0] || currentUser?.role || 'R003';

      // 🌟 ĐÓNG GÓI PAYLOAD THEO YÊU CẦU MỚI CỦA CREATOR
      const payload = {
        roomTitle: roomName || 'Phòng học của ' + (profile?.fullName || currentUser?.fullName || 'Creator'),
        hostUserId: actualUserId,
        hostRole: actualRole,
        languageId: null,
        levelId: null,
        levelNumber: null,
        scheduledStartAt: new Date().toISOString().slice(0, 19),
        maxParticipants: 50,
        roomStatus: 'OPENED',
        accessType: roomAccessType,           // 🌟 PAID hoặc FREE dựa theo Radio button công khai
        priceAmount: roomAccessType === 'PAID' ? parseFloat(roomPrice) : 0,
        roomType: 'CREATOR_CLASS'             // 🌟 Cập nhật cứng thành CREATOR_CLASS theo yêu cầu
      };

      const createReq = await fetch('http://localhost:8081/api/mentor/rooms', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(payload)
      });

      if (createReq.ok) {
        setRoomName('');
        setRoomPrice('0');
        if (actualUserId && token) {
          fetchRooms(actualUserId, token);
        }
        alert("Khởi tạo phòng thành công!");
      } else {
        const errorText = await createReq.text();
        alert("Không thể tạo phòng: " + errorText);
      }
    } catch (err: any) {
      alert("Lỗi kết nối Server: " + err.message);
    } finally {
      setIsSubmittingRoom(false);
    }
  };

  const endRoom = async (room: any) => {
    if (!window.confirm("Bạn có chắc chắn muốn kết thúc phòng này? Hành động này không thể hoàn tác.")) return;
    const endLevel = false; // Phòng của Creator là phòng tự do, không nâng Level của học viên theo lộ trình
    try {
      const token = sessionStorage.getItem('token');
      const response = await fetch(`http://localhost:8081/api/mentor/rooms/${room.roomId}/end?endLevel=${endLevel}`, {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (response.ok) {
        const actualUserId = profile?.userId || profile?.id || currentUser?.id;
        if (actualUserId) {
          fetchRooms(actualUserId, token || '');
        }
      }
    } catch (err) {
      alert("Lỗi khi kết thúc phòng");
    }
  };

  const handleUploadContent = async (e: React.FormEvent) => {
    e.preventDefault();
    if (isSubmittingContent) return;
    setIsSubmittingContent(true);

    try {
      const token = sessionStorage.getItem('token');
      const actualUserId = profile?.userId || profile?.id || currentUser?.id;

      const finalContentType = `${contentBaseType}_${accessType}`;
      const finalPrice = accessType === 'FREE' ? '0' : contentPrice;

      const formData = new FormData();
      formData.append('creatorUserId', actualUserId || '');
      formData.append('contentType', finalContentType);
      formData.append('title', contentTitle);
      formData.append('descriptionText', contentDesc);
      formData.append('priceAmount', finalPrice);
      formData.append('contentStatus', contentStatus);
      if (selectedFile) {
        formData.append('file', selectedFile);
      }

      const res = await fetch('http://localhost:8081/api/creator/contents', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`
        },
        body: formData
      });

      if (res.ok) {
        alert("Đăng tải nội dung thành công!");
        setContentTitle('');
        setContentDesc('');
        setContentPrice('0');
        setContentStatus('PRIVATE');
        setSelectedFile(null);
        const fileInput = document.getElementById('file-upload') as HTMLInputElement;
        if (fileInput) fileInput.value = '';

        fetchPaidContents(actualUserId, token || '');
      } else {
        const errText = await res.text();
        alert("Lỗi đăng tải: " + errText);
      }
    } catch (err: any) {
      alert("Lỗi kết nối: " + err.message);
    } finally {
      setIsSubmittingContent(false);
    }
  };

  const handleLogout = () => {
    sessionStorage.removeItem('token');
    sessionStorage.removeItem('currentRole');
    navigate('/login');
  };

  const getContentTypeIcon = (type: string) => {
    if (type?.toUpperCase().startsWith('PODCAST')) {
      return <Music size={18} color="#A78BFA" />;
    } else {
      return <Video size={18} color="#F43F5E" />;
    }
  };

  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg-gradient-start)', fontFamily: 'Inter, sans-serif' }}>
      {/* Header */}
      <header style={{
        background: 'var(--primary)',
        padding: '20px 40px',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        color: 'white',
        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <h1 style={{ margin: 0, fontSize: '1.5rem', fontWeight: 700, letterSpacing: '-0.025em' }}>Lucy</h1>
          <nav style={{ display: 'flex', gap: '10px', marginLeft: '20px' }}>
            <button
              onClick={() => setActiveTab('rooms')}
              style={{
                background: activeTab === 'rooms' ? 'rgba(255, 255, 255, 0.2)' : 'transparent',
                border: 'none',
                color: 'white',
                padding: '8px 16px',
                borderRadius: '6px',
                cursor: 'pointer',
                fontWeight: 600,
                fontSize: '0.9rem',
                transition: 'background 0.2s'
              }}
            >
              Phòng học (Live Rooms)
            </button>
            <button
              onClick={() => setActiveTab('paid_contents')}
              style={{
                background: activeTab === 'paid_contents' ? 'rgba(255, 255, 255, 0.2)' : 'transparent',
                border: 'none',
                color: 'white',
                padding: '8px 16px',
                borderRadius: '6px',
                cursor: 'pointer',
                fontWeight: 600,
                fontSize: '0.9rem',
                transition: 'background 0.2s'
              }}
            >
              Nội dung sáng tạo (Contents)
            </button>
          </nav>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <div
            style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer', padding: '4px 8px', borderRadius: '8px', transition: 'background 0.2s' }}
            onClick={() => navigate('/mentor-profile')}
            onMouseEnter={(e) => e.currentTarget.style.background = 'rgba(255,255,255,0.1)'}
            onMouseLeave={(e) => e.currentTarget.style.background = 'transparent'}
          >
            {avatar ? (
              <img src={avatar} alt="avatar" style={{ width: '40px', height: '40px', borderRadius: '50%', border: '2px solid white', objectFit: 'cover' }} />
            ) : (
              <div style={{ width: '40px', height: '40px', borderRadius: '50%', background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>
                {profile?.fullName?.[0] || currentUser?.fullName?.[0] || 'C'}
              </div>
            )}
            <span style={{ fontWeight: '500' }}>Creator: {profile?.fullName || currentUser?.fullName || ''}</span>
          </div>
          <button onClick={handleLogout} style={{ padding: '8px 16px', background: 'rgba(255,255,255,0.2)', color: 'white', border: '1px solid rgba(255,255,255,0.4)', borderRadius: '8px', cursor: 'pointer', backdropFilter: 'blur(4px)', transition: 'all 0.2s', fontWeight: 600 }}>
            Đăng xuất
          </button>
        </div>
      </header>

      {/* Main Content Areas */}
      {activeTab === 'rooms' ? (
        <main style={{ padding: '40px', maxWidth: '1200px', margin: '0 auto', display: 'grid', gridTemplateColumns: '1fr 2fr', gap: '40px' }}>
          {/* Sidebar: Create Room */}
          <section>
            <Card style={{ padding: '24px', position: 'sticky', top: '40px' }}>
              <h2 style={{ marginTop: 0, display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-primary)' }}>
                <PlusCircle size={24} color="var(--primary)" /> Tạo phòng mới
              </h2>
              <form onSubmit={createRoom} style={{ marginTop: '24px' }}>
                <div style={{ marginBottom: '16px' }}>
                  <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontWeight: 500, fontSize: '0.9rem' }}>Tên phòng</label>
                  <Input value={roomName} onChange={(e: any) => setRoomName(e.target.value)} placeholder="Nhập tên phòng..." required />
                </div>

                {/* 🌟 FORM CHỌN TRẢ PHÍ HOẶC FREE */}
                <div style={{ marginBottom: '16px' }}>
                  <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontWeight: 500, fontSize: '0.9rem' }}>Chế độ phòng</label>
                  <div style={{ display: 'flex', gap: '24px', padding: '4px 0' }}>
                    <label style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-primary)', cursor: 'pointer', fontWeight: 500 }}>
                      <input type="radio" name="roomAccessType" checked={roomAccessType === 'FREE'} onChange={() => setRoomAccessType('FREE')} style={{ width: '18px', height: '18px' }} />
                      Miễn phí (Free)
                    </label>
                    <label style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-primary)', cursor: 'pointer', fontWeight: 500 }}>
                      <input type="radio" name="roomAccessType" checked={roomAccessType === 'PAID'} onChange={() => setRoomAccessType('PAID')} style={{ width: '18px', height: '18px' }} />
                      Trả phí (Paid)
                    </label>
                  </div>
                </div>

                {/* HIỂN THỊ Ô NHẬP GIÁ XU NẾU LÀ PHÒNG TRẢ PHÍ */}
                {roomAccessType === 'PAID' && (
                  <div style={{ marginBottom: '16px' }}>
                    <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontWeight: 500, fontSize: '0.9rem' }}>Giá phòng (Xu)</label>
                    <div style={{ position: 'relative' }}>
                      <Input
                        type="number"
                        min="1"
                        value={roomPrice}
                        onChange={(e: any) => setRoomPrice(e.target.value)}
                        placeholder="VD: 50 xu"
                        style={{ paddingLeft: '32px' }}
                        required
                      />
                      <DollarSign size={16} color="var(--text-secondary)" style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)' }} />
                    </div>
                  </div>
                )}


                <Button type="submit" disabled={isSubmittingRoom} style={{ width: '100%', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', opacity: isSubmittingRoom ? 0.7 : 1 }}>
                  <Video size={18} /> Khởi tạo Phòng
                </Button>
              </form>
            </Card>
          </section>

          {/* Main: Room Lists */}
          <section style={{ display: 'flex', flexDirection: 'column', gap: '40px' }}>
            {/* Open Rooms */}
            <div>
              <h2 style={{ marginTop: 0, alignItems: 'center', gap: '8px', color: 'var(--text-primary)', borderBottom: '2px solid var(--primary)', paddingBottom: '12px', display: 'inline-flex' }}>
                <Clock size={24} color="var(--primary)" /> Danh sách phòng đang mở
              </h2>
              {openRooms.length === 0 ? (
                <p style={{ color: 'var(--text-secondary)', background: 'white', padding: '24px', borderRadius: '12px', textAlign: 'center', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>Bạn chưa mở phòng nào.</p>
              ) : (
                <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '16px', marginTop: '16px' }}>
                  {openRooms.map((room, idx) => (
                    <Card key={idx} style={{ padding: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <div>
                        <h3 style={{ margin: '0 0 8px 0', color: 'var(--text-primary)', fontSize: '1.2rem' }}>{room.roomTitle || 'Phòng ' + room.roomId}</h3>
                        <div style={{ display: 'flex', gap: '12px' }}>
                          <span style={{ padding: '4px 10px', background: 'rgba(100, 195, 165, 0.15)', color: 'var(--primary-dark)', borderRadius: '12px', fontSize: '0.75rem', fontWeight: 700 }}>
                            {room.languageName || 'Tự do'} {room.levelNumber ? `• Lvl ${room.levelNumber}` : ''}
                          </span>
                          <span style={{ padding: '4px 10px', background: room.accessType === 'PAID' ? '#FEF3C7' : '#DBEAFE', color: room.accessType === 'PAID' ? '#D97706' : '#1E40AF', borderRadius: '12px', fontSize: '0.75rem', fontWeight: 700 }}>
                            {room.accessType === 'PAID' ? `${room.priceAmount} Xu` : 'Miễn phí'}
                          </span>
                          <span style={{ padding: '4px 10px', background: '#E2E8F0', color: '#334155', borderRadius: '12px', fontSize: '0.75rem', fontWeight: 700 }}>
                            Loại: {room.roomType}
                          </span>
                        </div>
                      </div>
                      {room.roomStatus === 'OPENED' || room.roomStatus === 'SCHEDULED' || room.roomStatus === 'OPEN' ? (
                        <div style={{ display: 'flex', gap: '8px' }}>
                          <button onClick={() => navigate(`/live-room/${room.roomId}`, {
                            state: {
                              roomTitle: room.roomTitle,
                              languageId: room.languageId,
                              levelNumber: room.levelNumber,
                              isMentor: true
                            }
                          })} style={{ padding: '8px 16px', background: 'var(--primary)', color: 'white', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold', transition: 'opacity 0.2s' }}>
                            Vào lại phòng
                          </button>
                          <button onClick={() => endRoom(room)} style={{ padding: '8px 16px', background: 'transparent', color: '#EF4444', border: '1px solid #EF4444', borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold', transition: 'all 0.2s' }}>
                            Kết thúc
                          </button>
                        </div>
                      ) : null}
                    </Card>
                  ))}
                </div>
              )}
            </div>

            {/* Ended Rooms */}
            <div>
              <h2 style={{ marginTop: 0, alignItems: 'center', gap: '8px', color: 'var(--text-secondary)', borderBottom: '2px solid #CBD5E1', paddingBottom: '12px', display: 'inline-flex' }}>
                <CheckCircle size={24} color="#64748B" /> Danh sách phòng đã kết thúc
              </h2>
              {endedRooms.length === 0 ? (
                <p style={{ color: 'var(--text-secondary)', background: 'transparent', padding: '12px 0' }}>Chưa có phòng nào kết thúc.</p>
              ) : (
                <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '16px', marginTop: '16px', opacity: 0.8 }}>
                  {endedRooms.map((room, idx) => (
                    <div key={idx} style={{ padding: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: '#F1F5F9', borderRadius: '12px', border: '1px solid #E2E8F0' }}>
                      <div>
                        <h4 style={{ margin: '0 0 6px 0', color: '#334155', fontSize: '1rem' }}>{room.roomTitle || 'Phòng ' + room.roomId}</h4>
                        <p style={{ margin: 0, color: '#64748B', fontSize: '0.8rem' }}>{room.languageName || 'Tự do'} {room.levelNumber ? `• Lvl ${room.levelNumber}` : ''} ({room.accessType})</p>
                      </div>
                      <span style={{ fontSize: '0.8rem', color: '#94A3B8', fontWeight: 600 }}>Đã đóng</span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </section>
        </main>
      ) : (
        /* Paid Contents tab view */
        <main style={{ padding: '40px', maxWidth: '1200px', margin: '0 auto', display: 'grid', gridTemplateColumns: '1fr 2fr', gap: '40px' }}>
          <section>
            <Card style={{ padding: '24px', position: 'sticky', top: '40px' }}>
              <h2 style={{ marginTop: 0, display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-primary)' }}>
                <Upload size={24} color="var(--primary)" /> Đăng tải nội dung trả phí
              </h2>
              <form onSubmit={handleUploadContent} style={{ marginTop: '24px' }}>
                <div style={{ marginBottom: '16px' }}>
                  <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontWeight: 500, fontSize: '0.9rem' }}>Tiêu đề</label>
                  <Input value={contentTitle} onChange={(e: any) => setContentTitle(e.target.value)} placeholder="Nhập tiêu đề..." required />
                </div>

                <div style={{ marginBottom: '16px' }}>
                  <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontWeight: 500, fontSize: '0.9rem' }}>Loại nội dung</label>
                  <select value={contentBaseType} onChange={(e: any) => setContentBaseType(e.target.value)} style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid #E5E7EB', outline: 'none', background: 'white' }}>
                    <option value="PODCAST">Podcast (Bản ghi âm)</option>
                    <option value="VIDEO">Video</option>
                  </select>
                </div>

                <div style={{ marginBottom: '16px' }}>
                  <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontWeight: 500, fontSize: '0.9rem' }}>Chế độ truy cập</label>
                  <div style={{ display: 'flex', gap: '24px', padding: '4px 0' }}>
                    <label style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-primary)', cursor: 'pointer', fontWeight: 500 }}>
                      <input type="radio" name="accessType" checked={accessType === 'FREE'} onChange={() => setAccessType('FREE')} style={{ width: '18px', height: '18px' }} />
                      Miễn phí (Free)
                    </label>
                    <label style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-primary)', cursor: 'pointer', fontWeight: 500 }}>
                      <input type="radio" name="accessType" checked={accessType === 'PAID'} onChange={() => setAccessType('PAID')} style={{ width: '18px', height: '18px' }} />
                      Trả phí (Paid)
                    </label>
                  </div>
                </div>

                {accessType === 'PAID' && (
                  <div style={{ marginBottom: '16px' }}>
                    <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontWeight: 500, fontSize: '0.9rem' }}>Giá bán (Xu)</label>
                    <div style={{ position: 'relative' }}>
                      <Input
                        type="number"
                        min="1"
                        value={contentPrice}
                        onChange={(e: any) => setContentPrice(e.target.value)}
                        placeholder="VD: 50 xu"
                        style={{ paddingLeft: '32px' }}
                        required
                      />
                      <DollarSign size={16} color="var(--text-secondary)" style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)' }} />
                    </div>
                  </div>
                )}

                <div style={{ marginBottom: '16px' }}>
                  <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontWeight: 500, fontSize: '0.9rem' }}>Trạng thái hiển thị</label>
                  <select value={contentStatus} onChange={(e: any) => setContentStatus(e.target.value)} style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid #E5E7EB', outline: 'none', background: 'white' }}>
                    <option value="PRIVATE">Riêng tư (Private)</option>
                    <option value="PUBLISHED">Công khai (Published)</option>
                  </select>
                </div>

                <div style={{ marginBottom: '16px' }}>
                  <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontWeight: 500, fontSize: '0.9rem' }}>Mô tả chi tiết</label>
                  <textarea
                    value={contentDesc}
                    onChange={(e: any) => setContentDesc(e.target.value)}
                    placeholder="Mô tả nội dung..."
                    rows={4}
                    style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid #E5E7EB', outline: 'none', background: 'white', boxSizing: 'border-box', resize: 'vertical', fontFamily: 'inherit' }}
                  />
                </div>

                <div style={{ marginBottom: '24px' }}>
                  <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontWeight: 500, fontSize: '0.9rem' }}>Tệp âm thanh / Video</label>
                  <input
                    id="file-upload"
                    type="file"
                    accept="audio/*,video/*"
                    onChange={(e) => setSelectedFile(e.target.files?.[0] || null)}
                    style={{ width: '100%', padding: '8px 0', outline: 'none' }}
                  />
                </div>

                <Button type="submit" disabled={isSubmittingContent} style={{ width: '100%', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', opacity: isSubmittingContent ? 0.7 : 1 }}>
                  <Upload size={18} /> Đăng nội dung
                </Button>
              </form>
            </Card>
          </section>

          <section style={{ display: 'flex', flexDirection: 'column', gap: '40px' }}>
            <div>
              <h2 style={{ marginTop: 0, alignItems: 'center', gap: '8px', color: 'var(--text-primary)', borderBottom: '2px solid var(--primary)', paddingBottom: '12px', display: 'inline-flex' }}>
                <Layers size={24} color="var(--primary)" /> Danh sách nội dung sáng tạo
              </h2>

              {paidContents.length === 0 ? (
                <p style={{ color: 'var(--text-secondary)', background: 'white', padding: '24px', borderRadius: '12px', textAlign: 'center', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>Chưa có nội dung trả phí nào được tải lên.</p>
              ) : (
                <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '16px', marginTop: '16px' }}>
                  {paidContents.map((content, idx) => (
                    <Card key={idx} style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                        <div>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
                            {getContentTypeIcon(content.contentType)}
                            <span style={{ fontSize: '0.8rem', fontWeight: 700, color: '#6B7280' }}>
                              {content.contentType}
                            </span>
                          </div>
                          <h3 style={{ margin: '0 0 4px 0', color: 'var(--text-primary)', fontSize: '1.2rem' }}>
                            {content.title}
                          </h3>
                          <p style={{ margin: 0, color: 'var(--text-secondary)', fontSize: '0.9rem', whiteSpace: 'pre-line' }}>
                            {content.descriptionText || 'Không có mô tả.'}
                          </p>
                        </div>
                        <div style={{ textAlign: 'right' }}>
                          <span style={{ padding: '6px 12px', background: '#FEF3C7', color: '#D97706', borderRadius: '12px', fontSize: '0.85rem', fontWeight: 700, display: 'inline-block', marginBottom: '8px' }}>
                            {content.priceAmount} Xu
                          </span>
                          <div>
                            <span style={{
                              padding: '4px 10px',
                              background: content.contentStatus === 'PUBLISHED' ? '#D1FAE5' : '#FEE2E2',
                              color: content.contentStatus === 'PUBLISHED' ? '#065F46' : '#991B1B',
                              borderRadius: '12px',
                              fontSize: '0.75rem',
                              fontWeight: 700
                            }}>
                              {content.contentStatus === 'PUBLISHED' ? 'Đã đăng (Published)' : 'Riêng tư (Private)'}
                            </span>
                          </div>
                        </div>
                      </div>

                      {content.mediaUrl && (
                        <div style={{ marginTop: '12px', background: '#F9FAFB', padding: '12px', borderRadius: '8px', border: '1px solid #E5E7EB' }}>
                          <p style={{ margin: '0 0 8px 0', fontSize: '0.8rem', color: '#6B7280', display: 'flex', alignItems: 'center', gap: '4px' }}>
                            <Play size={12} /> Tệp đính kèm:
                          </p>
                          {content.mediaUrl.endsWith('.mp3') || content.mediaUrl.endsWith('.wav') || content.mediaUrl.toLowerCase().includes('audio') || content.contentType?.startsWith('PODCAST') ? (
                            <audio controls src={`http://localhost:8081${content.mediaUrl}`} style={{ width: '100%' }} />
                          ) : (
                            <video controls src={`http://localhost:8081${content.mediaUrl}`} style={{ width: '100%', maxHeight: '200px', borderRadius: '6px' }} />
                          )}
                        </div>
                      )}
                    </Card>
                  ))}
                </div>
              )}
            </div>
          </section>
        </main>
      )}
    </div>
  );
};
