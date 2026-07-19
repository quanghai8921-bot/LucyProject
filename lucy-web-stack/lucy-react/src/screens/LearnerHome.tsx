import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { AppContext } from '../App';
import { Card } from '../components/Card';
import { Play, Music, Video } from 'lucide-react';

export const LearnerHome: React.FC = () => {
  const navigate = useNavigate();
  const { currentUser, setCurrentUser } = React.useContext(AppContext);
  const [profile, setProfile] = useState<any>(null);
  const [openRooms, setOpenRooms] = useState<any[]>([]);
  const [historyRooms, setHistoryRooms] = useState<any[]>([]);
  const [paidContents, setPaidContents] = useState<any[]>([]);
  const [purchasedContents, setPurchasedContents] = useState<any[]>([]);
  const [purchasedContentIds, setPurchasedContentIds] = useState<Set<string>>(new Set());
  const [avatar, setAvatar] = useState<string>('');

  // Tab states
  const [mainTab, setMainTab] = useState<'mentor' | 'creator'>('mentor');
  const [langTab, setLangTab] = useState<'English' | 'Japanese' | 'Chinese' | 'Free'>('English');
  const [mediaTab, setMediaTab] = useState<'video' | 'audio'>('video');

  const fetchProfile = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`http://localhost:8081/api/user/profile`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        const pData = data.data || data;
        setProfile(pData);
        setCurrentUser(pData);
        return pData;
      }
    } catch (err) {
      console.error("Error fetching profile", err);
    }
    return null;
  };

  const fetchAvatar = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`http://localhost:8081/api/user/profile/avatar`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setAvatar(data.data?.url || data.url);
      }
    } catch (err) {
      console.error("Error fetching avatar", err);
    }
  };

  const fetchRoomsData = async (userId: string) => {
    try {
      const token = localStorage.getItem('token');

      // Fetch all available rooms
      const res = await fetch('http://localhost:8081/api/learner/rooms', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        const allRooms = data.data || data || [];
        setOpenRooms(allRooms.filter((r: any) => r.roomStatus === 'OPENED'));
      }

      // Fetch history rooms
      if (userId) {
        const histRes = await fetch(`http://localhost:8081/api/learner/rooms/history/${userId}`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (histRes.ok) {
          const histData = await histRes.json();
          setHistoryRooms(histData.data || histData || []);
        }
      }
    } catch (err) {
      console.error("Error fetching rooms", err);
    }
  };

  const fetchCreatorContents = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/creator/contents', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        // Filter only PUBLISHED contents for the learner
        const published = (data || []).filter((c: any) => c.contentStatus === 'PUBLISHED');
        setPaidContents(published);
      }
    } catch (err) {
      console.error("Error fetching creator contents", err);
    }
  };

  const fetchPurchasedContents = async (currUserId: string) => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`http://localhost:8081/api/creator/contents/learner/${currUserId}/purchased`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setPurchasedContents(data || []);
        const ids = new Set<string>((data || []).map((c: any) => c.contentId));
        setPurchasedContentIds(ids);
      }
    } catch (err) {
      console.error("Error fetching purchased contents", err);
    }
  };

  useEffect(() => {
    const initData = async () => {
      const pData = await fetchProfile();
      fetchAvatar();
      fetchCreatorContents();

      const currentUserId = pData?.userId || pData?.id || currentUser?.id;
      if (currentUserId) {
        fetchRoomsData(currentUserId);
        fetchPurchasedContents(currentUserId);
      }
    };

    initData();
  }, []); useEffect(() => {
    let intervalId: any;

    const initData = async () => {
      const pData = await fetchProfile();
      fetchAvatar();
      fetchCreatorContents();

      const currentUserId = pData?.userId || pData?.id || currentUser?.id;
      if (currentUserId) {
        // 1. Gọi lần đầu tiên khi vừa vào trang
        fetchRoomsData(currentUserId);
        fetchPurchasedContents(currentUserId);

        // 2. Cứ mỗi 5 giây (5000ms) tự động gọi lại hàm lấy phòng một lần
        intervalId = setInterval(() => {
          console.log("Đang âm thầm cập nhật danh sách phòng mới...");
          fetchRoomsData(currentUserId);
        }, 5000);
      }
    };

    initData();

    // 3. Xóa bộ hẹn giờ khi người học chuyển sang trang khác để tránh tốn tài nguyên
    return () => {
      if (intervalId) clearInterval(intervalId);
    };
  }, []);

  const handlePurchaseContent = async (content: any) => {
    const isFree = content.priceAmount === 0;
    const confirmMessage = isFree
      ? `Bạn muốn chọn nội dung "${content.title}" này?`
      : `Bạn muốn thanh toán nội dung "${content.title}" này với giá ${content.priceAmount} Xu phải không?`;

    if (!window.confirm(confirmMessage)) {
      return;
    }

    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/payment/purchase/content', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ contentId: content.contentId })
      });

      const data = await res.json();
      if (res.ok && data.isSuccess) {
        alert(isFree ? "Đã chọn nội dung thành công!" : "Thanh toán thành công!");
        const currentUserId = profile?.userId || profile?.id || currentUser?.id;
        if (currentUserId) {
          fetchPurchasedContents(currentUserId);
          fetchProfile();
        }
      } else {
        alert(data.message || "Giao dịch thất bại");
      }
    } catch (err) {
      alert("Lỗi kết nối khi thanh toán");
    }
  };

  const handleJoinRoom = async (room: any) => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`http://localhost:8081/api/learner/rooms/${room.roomId}/join`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ userId: currentUser?.id || profile?.userId || '' })
      });
      if (res.ok) {
        navigate(`/live-room/${room.roomId}`, {
          state: {
            roomTitle: room.roomTitle || `Phòng học ${room.roomId}`,
            languageId: room.languageId,
            levelNumber: room.levelNumber
          }
        });
      } else {
        alert("Không thể tham gia phòng");
      }
    } catch (err) {
      alert("Lỗi kết nối");
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('currentRole');
    navigate('/login');
  };

  // Filter open rooms by current active language tab
  const filteredRooms = openRooms.filter((room: any) => {
    if (langTab === 'Free') {
      return !room.languageId || !room.languageName || room.languageName === 'Language';
    } else {
      return room.languageName === langTab;
    }
  });

  // Filter creator contents by type
  const filteredContents = paidContents.filter((content: any) => {
    const type = content.contentType?.toUpperCase() || '';
    if (mediaTab === 'video') {
      return type.includes('VIDEO');
    } else {
      return type.includes('PODCAST');
    }
  });

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
          <h1 style={{ margin: 0, fontSize: '1.5rem', fontWeight: 700, letterSpacing: '-0.025em' }}>Lucy Learner</h1>
          {/* Main Tabs */}
          <nav style={{ display: 'flex', gap: '10px', marginLeft: '20px' }}>
            <button
              onClick={() => setMainTab('mentor')}
              style={{
                background: mainTab === 'mentor' ? 'rgba(255, 255, 255, 0.2)' : 'transparent',
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
              Mentor (Phòng Học Trực Tuyến)
            </button>
            <button
              onClick={() => setMainTab('creator')}
              style={{
                background: mainTab === 'creator' ? 'rgba(255, 255, 255, 0.2)' : 'transparent',
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
              Content Creator (Nội Dung Trực Quan)
            </button>
          </nav>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <div
            style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer', padding: '4px 8px', borderRadius: '8px', transition: 'background 0.2s' }}
            onClick={() => navigate('/learner-profile')}
            onMouseEnter={(e) => e.currentTarget.style.background = 'rgba(255,255,255,0.1)'}
            onMouseLeave={(e) => e.currentTarget.style.background = 'transparent'}
          >
            {avatar ? (
              <img src={avatar} alt="avatar" style={{ width: '40px', height: '40px', borderRadius: '50%', border: '2px solid white', objectFit: 'cover' }} />
            ) : (
              <div style={{ width: '40px', height: '40px', borderRadius: '50%', background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>
                {profile?.fullName?.[0] || currentUser?.fullName?.[0] || 'U'}
              </div>
            )}
            <span style={{ fontWeight: '500' }}>{profile?.fullName || currentUser?.fullName || 'Học viên'}</span>
          </div>
          <button onClick={handleLogout} style={{ padding: '8px 16px', background: 'rgba(255,255,255,0.2)', color: 'white', border: '1px solid rgba(255,255,255,0.4)', borderRadius: '8px', cursor: 'pointer', backdropFilter: 'blur(4px)', transition: 'all 0.2s', fontWeight: 600 }}>
            Đăng xuất
          </button>
        </div>
      </header>

      {/* Main Area */}
      <main style={{ padding: '40px', maxWidth: '1200px', margin: '0 auto' }}>

        {mainTab === 'mentor' ? (
          /* MENTOR VIEW */
          <section>
            {/* Sub-tabs for Language */}
            <div style={{ display: 'flex', gap: '10px', marginBottom: '24px', borderBottom: '1px solid #E2E8F0', paddingBottom: '12px' }}>
              <button
                onClick={() => setLangTab('English')}
                style={{
                  padding: '8px 16px',
                  background: langTab === 'English' ? 'var(--primary)' : 'white',
                  color: langTab === 'English' ? 'white' : 'var(--text-secondary)',
                  border: '1px solid #E2E8F0',
                  borderRadius: '20px',
                  cursor: 'pointer',
                  fontWeight: 600,
                  fontSize: '0.85rem',
                  transition: 'all 0.2s'
                }}
              >
                🇬🇧 Tiếng Anh (English)
              </button>
              <button
                onClick={() => setLangTab('Japanese')}
                style={{
                  padding: '8px 16px',
                  background: langTab === 'Japanese' ? 'var(--primary)' : 'white',
                  color: langTab === 'Japanese' ? 'white' : 'var(--text-secondary)',
                  border: '1px solid #E2E8F0',
                  borderRadius: '20px',
                  cursor: 'pointer',
                  fontWeight: 600,
                  fontSize: '0.85rem',
                  transition: 'all 0.2s'
                }}
              >
                🇯🇵 Tiếng Nhật (Japanese)
              </button>
              <button
                onClick={() => setLangTab('Chinese')}
                style={{
                  padding: '8px 16px',
                  background: langTab === 'Chinese' ? 'var(--primary)' : 'white',
                  color: langTab === 'Chinese' ? 'white' : 'var(--text-secondary)',
                  border: '1px solid #E2E8F0',
                  borderRadius: '20px',
                  cursor: 'pointer',
                  fontWeight: 600,
                  fontSize: '0.85rem',
                  transition: 'all 0.2s'
                }}
              >
                🇨🇳 Tiếng Trung (Chinese)
              </button>
              <button
                onClick={() => setLangTab('Free')}
                style={{
                  padding: '8px 16px',
                  background: langTab === 'Free' ? 'var(--primary)' : 'white',
                  color: langTab === 'Free' ? 'white' : 'var(--text-secondary)',
                  border: '1px solid #E2E8F0',
                  borderRadius: '20px',
                  cursor: 'pointer',
                  fontWeight: 600,
                  fontSize: '0.85rem',
                  transition: 'all 0.2s'
                }}
              >
                🌐 Tự do (Free Topic)
              </button>
            </div>

            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
              <h2 style={{ color: 'var(--text-primary)', margin: 0, fontSize: '1.5rem' }}>Phòng học đang mở</h2>
              <span style={{ padding: '6px 12px', background: 'rgba(100, 195, 165, 0.2)', color: 'var(--primary-dark)', borderRadius: '20px', fontSize: '0.875rem', fontWeight: 600 }}>
                {filteredRooms.length} phòng khả dụng
              </span>
            </div>

            {filteredRooms.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '60px', background: 'var(--card-color)', borderRadius: '16px', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)' }}>
                <p style={{ color: 'var(--text-secondary)', fontSize: '1.1rem' }}>Hiện tại không có phòng học nào đang mở.</p>
              </div>
            ) : (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '24px' }}>
                {filteredRooms.map((room, idx) => (
                  <div key={idx} style={{
                    padding: '24px',
                    borderRadius: '16px',
                    background: 'var(--card-color)',
                    boxShadow: '0 4px 6px -1px rgba(0,0,0,0.05), 0 2px 4px -1px rgba(0,0,0,0.03)',
                    transition: 'transform 0.2s, box-shadow 0.2s',
                    cursor: 'pointer'
                  }}
                    onMouseEnter={(e) => e.currentTarget.style.transform = 'translateY(-4px)'}
                    onMouseLeave={(e) => e.currentTarget.style.transform = 'translateY(0)'}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '16px' }}>
                      {/* Với tự do không hiện level number và title */}
                      {langTab === 'Free' || !room.languageId ? (
                        <span style={{ padding: '4px 10px', background: '#F1F5F9', color: '#475569', borderRadius: '12px', fontSize: '0.75rem', fontWeight: 700 }}>
                          ✨ Phòng Tự do
                        </span>
                      ) : (
                        <span style={{ padding: '4px 10px', background: 'rgba(100, 195, 165, 0.15)', color: 'var(--primary-dark)', borderRadius: '12px', fontSize: '0.75rem', fontWeight: 700 }}>
                          {room.languageName || 'Ngoại ngữ'} • Level {room.levelNumber || 1}
                        </span>
                      )}
                    </div>

                    <h3 style={{ margin: '0 0 8px 0', color: 'var(--text-primary)', fontSize: '1.25rem', lineHeight: '1.4' }}>
                      {room.roomTitle || 'Phòng học ' + room.roomId}
                    </h3>
                    <p style={{ margin: '0 0 24px 0', color: 'var(--text-secondary)', fontSize: '0.9rem', display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <span style={{ padding: '4px', background: 'var(--bg-gradient-mid)', borderRadius: '50%', display: 'inline-block' }}>👨‍🏫</span>
                      Giảng viên: <strong style={{ color: 'var(--text-primary)' }}>{room.hostUserName || 'Đang cập nhật'}</strong>
                    </p>

                    <button onClick={() => handleJoinRoom(room)} style={{
                      padding: '12px 20px',
                      background: 'var(--primary)',
                      color: 'white',
                      border: 'none',
                      borderRadius: '10px',
                      cursor: 'pointer',
                      width: '100%',
                      fontWeight: 'bold',
                      fontSize: '1rem',
                      boxShadow: '0 4px 6px -1px rgba(100, 195, 165, 0.4)'
                    }}>
                      Tham gia ngay
                    </button>
                  </div>
                ))}
              </div>
            )}

            {/* History Rooms */}
            <section style={{ marginTop: '48px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
                <h2 style={{ color: 'var(--text-primary)', margin: 0, fontSize: '1.5rem' }}>Phòng từng tham gia</h2>
                <span style={{ padding: '6px 12px', background: 'rgba(148, 163, 184, 0.2)', color: '#475569', borderRadius: '20px', fontSize: '0.875rem', fontWeight: 600 }}>
                  {historyRooms.length} phòng
                </span>
              </div>

              {historyRooms.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '60px', background: 'var(--card-color)', borderRadius: '16px', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)' }}>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '1.1rem' }}>Bạn chưa tham gia phòng học nào.</p>
                </div>
              ) : (
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '24px' }}>
                  {historyRooms.map((room, idx) => (
                    <div key={idx} style={{
                      padding: '24px',
                      borderRadius: '16px',
                      background: 'var(--card-color)',
                      boxShadow: '0 4px 6px -1px rgba(0,0,0,0.05)',
                      border: '1px solid #E2E8F0',
                      opacity: 0.8
                    }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '16px' }}>
                        <span style={{ padding: '4px 10px', background: '#F1F5F9', color: '#64748B', borderRadius: '12px', fontSize: '0.75rem', fontWeight: 700 }}>
                          {room.languageName || 'Không tìm thấy ngôn ngữ'} • Level {room.levelNumber || 'Không tìm thấy level'}
                        </span>
                        <span style={{ fontSize: '0.75rem', color: '#94A3B8', fontWeight: 600 }}>
                          {room.roomStatus === 'ENDED' ? 'Đã kết thúc' : 'Đã tham gia'}
                        </span>
                      </div>

                      <h3 style={{ margin: '0 0 8px 0', color: 'var(--text-primary)', fontSize: '1.1rem', lineHeight: '1.4' }}>
                        {room.roomTitle || 'Phòng học ' + room.roomId}
                      </h3>
                      <p style={{ margin: '0 0 16px 0', color: 'var(--text-secondary)', fontSize: '0.85rem' }}>
                        Giảng viên: <strong>{room.hostUserName || 'Đang cập nhật'}</strong>
                      </p>

                      {room.roomStatus === 'OPENED' ? (
                        <button onClick={() => handleJoinRoom(room)} style={{
                          padding: '8px 16px', background: '#F8FAFC', color: 'var(--primary)', border: '1px solid var(--primary)', borderRadius: '8px', cursor: 'pointer', width: '100%', fontWeight: 'bold'
                        }}>Vào lại phòng</button>
                      ) : (
                        <button disabled style={{
                          padding: '8px 16px', background: '#F1F5F9', color: '#94A3B8', border: 'none', borderRadius: '8px', width: '100%', fontWeight: 'bold', cursor: 'not-allowed'
                        }}>Phòng đã đóng</button>
                      )}
                    </div>
                  ))}
                </div>
              )}
            </section>
          </section>
        ) : (
          /* CONTENT CREATOR VIEW */
          <section>
            {/* Sub-tabs for Media Type */}
            <div style={{ display: 'flex', gap: '10px', marginBottom: '24px', borderBottom: '1px solid #E2E8F0', paddingBottom: '12px' }}>
              <button
                onClick={() => setMediaTab('video')}
                style={{
                  padding: '8px 16px',
                  background: mediaTab === 'video' ? 'var(--primary)' : 'white',
                  color: mediaTab === 'video' ? 'white' : 'var(--text-secondary)',
                  border: '1px solid #E2E8F0',
                  borderRadius: '20px',
                  cursor: 'pointer',
                  fontWeight: 600,
                  fontSize: '0.85rem',
                  transition: 'all 0.2s',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px'
                }}
              >
                <Video size={16} /> Video
              </button>
              <button
                onClick={() => setMediaTab('audio')}
                style={{
                  padding: '8px 16px',
                  background: mediaTab === 'audio' ? 'var(--primary)' : 'white',
                  color: mediaTab === 'audio' ? 'white' : 'var(--text-secondary)',
                  border: '1px solid #E2E8F0',
                  borderRadius: '20px',
                  cursor: 'pointer',
                  fontWeight: 600,
                  fontSize: '0.85rem',
                  transition: 'all 0.2s',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px'
                }}
              >
                <Music size={16} /> Podcast
              </button>
            </div>

            {/* Section for Purchased Contents */}
            {purchasedContents.filter((c: any) => mediaTab === 'video' ? c.contentType === 'VIDEO' : c.contentType !== 'VIDEO').length > 0 && (
              <div style={{ marginBottom: '40px', padding: '24px', background: 'rgba(100, 195, 165, 0.05)', borderRadius: '16px', border: '1px dashed var(--primary)' }}>
                <h2 style={{ color: 'var(--text-primary)', margin: '0 0 20px 0', fontSize: '1.4rem', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  📚 Những nội dung bạn đã mua / chọn
                </h2>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '24px' }}>
                  {purchasedContents
                    .filter((c: any) => mediaTab === 'video' ? c.contentType === 'VIDEO' : c.contentType !== 'VIDEO')
                    .map((content, idx) => (
                      <Card key={`purchased-${idx}`} style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '12px', justifyContent: 'space-between', background: 'white' }}>
                        <div>
                          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                            <span style={{ padding: '4px 10px', background: '#F3F4F6', color: '#374151', borderRadius: '12px', fontSize: '0.75rem', fontWeight: 700 }}>
                              {content.contentType}
                            </span>
                            <span style={{ padding: '4px 10px', background: '#D1FAE5', color: '#065F46', borderRadius: '12px', fontSize: '0.75rem', fontWeight: 700 }}>
                              Đã sở hữu
                            </span>
                          </div>

                          <h3 style={{ margin: '0 0 8px 0', color: 'var(--text-primary)', fontSize: '1.15rem', lineHeight: '1.4' }}>
                            {content.title}
                          </h3>
                          <p style={{ margin: 0, color: 'var(--text-secondary)', fontSize: '0.875rem', whiteSpace: 'pre-line' }}>
                            {content.descriptionText || 'Không có mô tả.'}
                          </p>
                        </div>

                        {content.mediaUrl && (
                          <div style={{ marginTop: '12px', background: '#F9FAFB', padding: '12px', borderRadius: '8px', border: '1px solid #E5E7EB' }}>
                            {content.mediaUrl.endsWith('.mp3') || content.mediaUrl.endsWith('.wav') || content.mediaUrl.toLowerCase().includes('audio') || content.contentType?.startsWith('PODCAST') ? (
                              <audio controls src={`http://localhost:8081${content.mediaUrl}`} style={{ width: '100%' }} />
                            ) : (
                              <video controls src={`http://localhost:8081${content.mediaUrl}`} style={{ width: '100%', maxHeight: '180px', borderRadius: '6px' }} />
                            )}
                          </div>
                        )}
                      </Card>
                    ))}
                </div>
              </div>
            )}

            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
              <h2 style={{ color: 'var(--text-primary)', margin: 0, fontSize: '1.5rem' }}>
                Nội dung {mediaTab === 'video' ? 'Video' : 'Âm thanh'} đang có
              </h2>
              <span style={{ padding: '6px 12px', background: 'rgba(100, 195, 165, 0.2)', color: 'var(--primary-dark)', borderRadius: '20px', fontSize: '0.875rem', fontWeight: 600 }}>
                {filteredContents.length} tài nguyên khả dụng
              </span>
            </div>

            {filteredContents.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '60px', background: 'var(--card-color)', borderRadius: '16px', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)' }}>
                <p style={{ color: 'var(--text-secondary)', fontSize: '1.1rem' }}>Hiện chưa có nội dung nào được đăng tải công khai.</p>
              </div>
            ) : (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '24px' }}>
                {filteredContents.map((content, idx) => {
                  const isPurchased = purchasedContentIds.has(content.contentId);
                  return (
                    <Card key={idx} style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '12px', justifyContent: 'space-between', border: isPurchased ? '1px solid var(--primary)' : '1px solid #E2E8F0' }}>
                      <div>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                          <span style={{ padding: '4px 10px', background: '#F3F4F6', color: '#374151', borderRadius: '12px', fontSize: '0.75rem', fontWeight: 700 }}>
                            {content.contentType}
                          </span>
                          {isPurchased ? (
                            <span style={{ padding: '4px 10px', background: '#D1FAE5', color: '#065F46', borderRadius: '12px', fontSize: '0.75rem', fontWeight: 700 }}>
                              Đã sở hữu
                            </span>
                          ) : (
                            <span style={{ padding: '4px 10px', background: '#FEF3C7', color: '#D97706', borderRadius: '12px', fontSize: '0.75rem', fontWeight: 700 }}>
                              {content.priceAmount === 0 ? 'Miễn phí' : `${content.priceAmount} Xu`}
                            </span>
                          )}
                        </div>

                        <h3 style={{ margin: '0 0 8px 0', color: 'var(--text-primary)', fontSize: '1.2rem', lineHeight: '1.4' }}>
                          {content.title}
                        </h3>
                        <p style={{ margin: 0, color: 'var(--text-secondary)', fontSize: '0.9rem', whiteSpace: 'pre-line' }}>
                          {content.descriptionText || 'Không có mô tả.'}
                        </p>
                      </div>

                      {content.mediaUrl && (
                        <div style={{ marginTop: '16px' }}>
                          {isPurchased ? (
                            <div style={{ background: '#F9FAFB', padding: '12px', borderRadius: '8px', border: '1px solid #E5E7EB' }}>
                              <p style={{ margin: '0 0 8px 0', fontSize: '0.8rem', color: '#6B7280', display: 'flex', alignItems: 'center', gap: '4px' }}>
                                <Play size={12} /> Phát nội dung:
                              </p>
                              {content.mediaUrl.endsWith('.mp3') || content.mediaUrl.endsWith('.wav') || content.mediaUrl.toLowerCase().includes('audio') || content.contentType?.startsWith('PODCAST') ? (
                                <audio controls src={`http://localhost:8081${content.mediaUrl}`} style={{ width: '100%' }} />
                              ) : (
                                <video controls src={`http://localhost:8081${content.mediaUrl}`} style={{ width: '100%', maxHeight: '180px', borderRadius: '6px' }} />
                              )}
                            </div>
                          ) : (
                            <div style={{ background: '#F9FAFB', padding: '20px', borderRadius: '8px', border: '1px solid #E5E7EB', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '10px' }}>
                              <p style={{ margin: 0, fontSize: '0.9rem', color: '#6B7280', fontWeight: 500 }}>Nội dung bị khóa</p>
                              <button
                                onClick={() => handlePurchaseContent(content)}
                                style={{
                                  padding: '8px 16px',
                                  background: 'var(--primary)',
                                  color: 'white',
                                  border: 'none',
                                  borderRadius: '8px',
                                  cursor: 'pointer',
                                  fontWeight: 'bold',
                                  fontSize: '0.9rem',
                                  boxShadow: '0 2px 4px rgba(100, 195, 165, 0.3)',
                                  transition: 'all 0.2s'
                                }}
                              >
                                {content.priceAmount === 0 ? 'Chọn nội dung này' : `Mua nội dung (${content.priceAmount} Xu)`}
                              </button>
                            </div>
                          )}
                        </div>
                      )}
                    </Card>
                  );
                })}
              </div>
            )}
          </section>
        )}

      </main>
    </div>
  );
};
