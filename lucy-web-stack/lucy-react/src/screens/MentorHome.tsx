import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { AppContext } from '../App';
import { Card } from '../components/Card';
import { Input } from '../components/Input';
import { Button } from '../components/Button';
import { PlusCircle, Video, CheckCircle, Clock } from 'lucide-react';

export const MentorHome: React.FC = () => {
  const navigate = useNavigate();
  const { currentUser } = React.useContext(AppContext);
  const [openRooms, setOpenRooms] = useState<any[]>([]);
  const [endedRooms, setEndedRooms] = useState<any[]>([]);
  const [roomName, setRoomName] = useState('');
  const [lang, setLang] = useState('English');
  const [level, setLevel] = useState('1');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [profile, setProfile] = useState<any>(null);
  const [avatar, setAvatar] = useState<string>('');

  useEffect(() => {
    const initData = async () => {
      try {
        const token = localStorage.getItem('token');
        if (!token) {
          navigate('/login');
          return;
        }

        // Fetch real profile from backend to survive page reloads
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
        }

        // Fetch avatar
        const avaRes = await fetch('http://localhost:8081/api/user/profile/avatar', {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (avaRes.ok) {
          const avaData = await avaRes.json();
          setAvatar(avaData.data?.url || avaData.url || avaData);
        }
      } catch (err) {
        console.error("Init mentor data error", err);
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
      console.error("Error fetching mentor rooms", err);
    }
  };

  const createRoom = async (e: React.FormEvent) => {
    e.preventDefault();
    if (isSubmitting) return;
    setIsSubmitting(true);
    try {
      const token = localStorage.getItem('token');
      const actualUserId = profile?.userId || profile?.id || currentUser?.id;
      const actualRole = profile?.role || profile?.roles?.[0] || currentUser?.role || 'R003';

      // Fetch LMS content based on selected language and level
      const contentReq = await fetch(`http://localhost:8081/api/v1/content/level-details?languageName=${lang}&levelNumber=${level}`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });

      if (!contentReq.ok) {
        alert("Cấp độ (Level) " + level + " không tồn tại. Vui lòng kiểm tra lại.");
        setIsSubmitting(false);
        return;
      } else {
        const contentData = await contentReq.json();
        console.log("Loaded LMS Content:", contentData);
      }

      const payload = {
        roomTitle: roomName || 'Phòng học của ' + (profile?.fullName || currentUser?.fullName || 'Giảng viên'),
        hostUserId: actualUserId,
        hostRole: actualRole,
        languageId: lang,
        levelId: null, // Let backend resolve it by levelNumber
        levelNumber: parseInt(level),
        scheduledStartAt: new Date().toISOString().slice(0, 19), // Format: yyyy-MM-dd'T'HH:mm:ss
        maxParticipants: 50,
        roomStatus: 'OPENED',
        accessType: 'FREE',
        roomType: 'MENTOR_CLASS'
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
        if (actualUserId && token) {
          fetchRooms(actualUserId, token);
        }

        alert("Khởi tạo phòng thành công! Bạn có thể bấm nút 'Vào lại phòng' bên cạnh để bắt đầu.");
      } else {
        const errorText = await createReq.text();
        console.error("Lỗi từ server:", errorText);
        alert("Không thể tạo phòng: " + (errorText || "Lỗi không xác định"));
      }
    } catch (err: any) {
      console.error(err);
      alert("Lỗi kết nối Server: " + err.message);
    } finally {
      setIsSubmitting(false);
    }
  };

  const endRoom = async (room: any) => {
    if (!window.confirm("Bạn có chắc chắn muốn kết thúc phòng này? Hành động này không thể hoàn tác.")) return;
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`http://localhost:8081/api/mentor/rooms/${room.roomId}/end`, {
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

  const handleLogout = () => {
    localStorage.removeItem('token');
    navigate('/login');
  };

  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg-gradient-start)', fontFamily: 'Inter, sans-serif' }}>
      <header style={{
        background: 'var(--primary)',
        padding: '20px 40px',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        color: 'white',
        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
      }}>
        <h1 style={{ margin: 0, fontSize: '1.5rem', fontWeight: 700, letterSpacing: '-0.025em' }}>Lucy Mentor</h1>
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
                {profile?.fullName?.[0] || currentUser?.fullName?.[0] || 'G'}
              </div>
            )}
            <span style={{ fontWeight: '500' }}>Giảng viên: {profile?.fullName || currentUser?.fullName || ''}</span>
          </div>
          <button onClick={handleLogout} style={{ padding: '8px 16px', background: 'rgba(255,255,255,0.2)', color: 'white', border: '1px solid rgba(255,255,255,0.4)', borderRadius: '8px', cursor: 'pointer', backdropFilter: 'blur(4px)', transition: 'all 0.2s', fontWeight: 600 }}>
            Đăng xuất
          </button>
        </div>
      </header>

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
              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontWeight: 500, fontSize: '0.9rem' }}>Ngôn ngữ</label>
                <select value={lang} onChange={(e: any) => setLang(e.target.value)} style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid #E5E7EB', outline: 'none', background: 'white' }}>
                  <option value="English">Tiếng Anh</option>
                  <option value="Japanese">Tiếng Nhật</option>
                  <option value="Chinese">Tiếng Trung</option>
                </select>
              </div>
              <div style={{ marginBottom: '24px' }}>
                <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontWeight: 500, fontSize: '0.9rem' }}>Cấp độ (Level)</label>
                <input
                  type="number"
                  min="1"
                  value={level}
                  onChange={(e: any) => setLevel(e.target.value)}
                  placeholder="Nhập cấp độ (VD: 1, 2, 3...)"
                  style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid #E5E7EB', outline: 'none', background: 'white', boxSizing: 'border-box' }}
                  required
                />
              </div>
              <Button type="submit" disabled={isSubmitting} style={{ width: '100%', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', opacity: isSubmitting ? 0.7 : 1 }}>
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
                          {room.languageName || 'Không tìm thấy ngôn ngữ'} • {room.levelNumber || 'Không tìm thấy level'}
                        </span>
                        <span style={{ padding: '4px 10px', background: '#DBEAFE', color: '#1E40AF', borderRadius: '12px', fontSize: '0.75rem', fontWeight: 700 }}>
                          Trạng thái: {room.roomStatus === 'ONGOING' ? 'Đang diễn ra' : room.roomStatus}
                        </span>
                      </div>
                    </div>
                    {room.roomStatus === 'OPENED' ? (
                      <div style={{ display: 'flex', gap: '8px' }}>
                        <button onClick={() => navigate(`/live-room/${room.roomId}`, {
                          state: {
                            roomTitle: room.roomTitle,
                            languageId: room.languageName || room.languageId,
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
                      <p style={{ margin: 0, color: '#64748B', fontSize: '0.8rem' }}>{room.languageName || 'Không tìm thấy ngôn ngữ'} • {room.levelNumber || 'Không tìm thấy level'}</p>
                    </div>
                    <span style={{ fontSize: '0.8rem', color: '#94A3B8', fontWeight: 600 }}>Đã đóng</span>
                  </div>
                ))}
              </div>
            )}
          </div>

        </section>
      </main>
    </div>
  );
};
