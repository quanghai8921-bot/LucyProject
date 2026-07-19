import React, { useEffect, useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { AppContext } from '../App';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { Input } from '../components/Input';
import { ChevronLeft, Wallet, ArrowDownCircle, ArrowUpCircle } from 'lucide-react';

export const MentorProfileScreen: React.FC = () => {
  const navigate = useNavigate();
  const { currentUser, setCurrentUser } = React.useContext(AppContext);
  const [profile, setProfile] = useState<any>(null);
  const [avatar, setAvatar] = useState<string>('');
  const [wallet, setWallet] = useState<any>(null);
  const [isUpdating, setIsUpdating] = useState(false);
  const [depositAmount, setDepositAmount] = useState<string>('');
  const [withdrawAmount, setWithdrawAmount] = useState<string>('');
  const fileInputRef = useRef<HTMLInputElement>(null);

  const fetchProfileData = async () => {
    try {
      const token = localStorage.getItem('token');
      // Fetch profile
      const profRes = await fetch('http://localhost:8081/api/user/profile', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      let pData = null;
      if (profRes.ok) {
        const data = await profRes.json();
        pData = data.data || data;
        setProfile(pData);
        setCurrentUser(pData);
      }

      // Fetch avatar
      const avaRes = await fetch('http://localhost:8081/api/user/profile/avatar', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (avaRes.ok) {
        const data = await avaRes.json();
        setAvatar(data.data?.url || data.url || data);
      }

      // Fetch wallet
      const userIdToUse = pData?.userId || pData?.id || currentUser?.userId || currentUser?.id;
      if (userIdToUse) {
        const walletRes = await fetch('http://localhost:8081/api/payment/wallet', {
          headers: { 
            'Authorization': `Bearer ${token}`,
            'X-User-Id': userIdToUse
          }
        });
        if (walletRes.ok) {
          const data = await walletRes.json();
          setWallet(data.data || data);
        }
      } else {
        console.warn("No user ID available to fetch wallet");
      }
    } catch (err) {
      console.error("Error fetching profile data", err);
    }
  };

  useEffect(() => {
    fetchProfileData();
  }, []);

  const handleUpdateProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsUpdating(true);
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/user/profile', {
        method: 'PUT',
        headers: { 
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ displayName: profile?.displayName || profile?.fullName })
      });
      if (res.ok) {
        alert("Cập nhật thông tin thành công!");
        fetchProfileData();
      } else {
        alert("Lỗi khi cập nhật thông tin.");
      }
    } catch (err) {
      console.error(err);
      alert("Lỗi kết nối.");
    } finally {
      setIsUpdating(false);
    }
  };

  const handleAvatarChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    try {
      const token = localStorage.getItem('token');
      const formData = new FormData();
      formData.append('file', file);
      
      const res = await fetch('http://localhost:8081/api/user/profile/avatar', {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${token}` },
        body: formData
      });
      
      if (res.ok) {
        alert("Cập nhật ảnh đại diện thành công!");
        fetchProfileData();
      } else {
        alert("Lỗi khi cập nhật ảnh.");
      }
    } catch (err) {
      console.error(err);
      alert("Lỗi kết nối.");
    }
  };

  const handleDeposit = async () => {
    if (!depositAmount || isNaN(Number(depositAmount)) || Number(depositAmount) <= 0) {
      alert("Vui lòng nhập số tiền nạp hợp lệ.");
      return;
    }
    
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/payment/deposit', {
        method: 'POST',
        headers: { 
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ amount: Number(depositAmount) })
      });
      if (res.ok) {
        alert("Yêu cầu nạp tiền thành công!");
        setDepositAmount('');
        fetchProfileData();
      } else {
        alert("Lỗi khi nạp tiền.");
      }
    } catch (err) {
      console.error(err);
      alert("Lỗi kết nối.");
    }
  };

  const handleWithdraw = async () => {
    if (!withdrawAmount || isNaN(Number(withdrawAmount)) || Number(withdrawAmount) <= 0) {
      alert("Vui lòng nhập số tiền rút hợp lệ.");
      return;
    }
    
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/payment/withdraw', {
        method: 'POST',
        headers: { 
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ amount: Number(withdrawAmount) })
      });
      if (res.ok) {
        alert("Yêu cầu rút tiền thành công!");
        setWithdrawAmount('');
        fetchProfileData();
      } else {
        alert("Lỗi khi rút tiền.");
      }
    } catch (err) {
      console.error(err);
      alert("Lỗi kết nối.");
    }
  };

  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg-gradient-start)', fontFamily: 'Inter, sans-serif' }}>
      <header style={{ 
        background: 'var(--primary)', 
        padding: '20px 40px', 
        display: 'flex', 
        alignItems: 'center', 
        color: 'white',
        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)' 
      }}>
        <button onClick={() => navigate('/mentor')} style={{ 
          background: 'transparent', border: 'none', color: 'white', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '8px', fontSize: '1rem', fontWeight: 600 
        }}>
          <ChevronLeft size={24} /> Quay lại
        </button>
        <h1 style={{ margin: '0 auto', fontSize: '1.5rem', fontWeight: 700 }}>Hồ sơ Giảng viên</h1>
      </header>

      <main style={{ padding: '40px', maxWidth: '1000px', margin: '0 auto', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '40px' }}>
        
        {/* Profile Details */}
        <section>
          <Card style={{ padding: '32px' }}>
            <h2 style={{ marginTop: 0, marginBottom: '24px', color: 'var(--text-primary)', fontSize: '1.5rem' }}>Thông tin cá nhân</h2>
            
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginBottom: '32px' }}>
              <div 
                style={{ width: '120px', height: '120px', borderRadius: '50%', background: '#F1F5F9', marginBottom: '16px', display: 'flex', alignItems: 'center', justifyContent: 'center', overflow: 'hidden', cursor: 'pointer', border: '4px solid white', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
                onClick={() => fileInputRef.current?.click()}
              >
                {avatar ? (
                  <img src={avatar} alt="avatar" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                ) : (
                  <span style={{ fontSize: '3rem', color: '#94A3B8', fontWeight: 'bold' }}>{profile?.fullName?.[0] || currentUser?.fullName?.[0] || 'U'}</span>
                )}
              </div>
              <input type="file" ref={fileInputRef} style={{ display: 'none' }} accept="image/*" onChange={handleAvatarChange} />
              <button 
                onClick={() => fileInputRef.current?.click()}
                style={{ background: 'transparent', border: '1px solid var(--primary)', color: 'var(--primary)', padding: '6px 16px', borderRadius: '20px', fontSize: '0.875rem', fontWeight: 600, cursor: 'pointer' }}
              >
                Đổi ảnh đại diện
              </button>
            </div>

            <form onSubmit={handleUpdateProfile}>
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontWeight: 500 }}>Tên hiển thị</label>
                <Input 
                  value={profile?.displayName || profile?.fullName || ''} 
                  onChange={(e) => setProfile({ ...profile, displayName: e.target.value })} 
                  placeholder="Nhập tên hiển thị" 
                  required 
                  style={{ width: '100%' }}
                />
              </div>
              <Button type="submit" style={{ width: '100%' }} disabled={isUpdating}>
                {isUpdating ? 'Đang cập nhật...' : 'Cập nhật thông tin'}
              </Button>
            </form>
          </Card>
        </section>

        {/* Wallet Details */}
        <section>
          <Card style={{ padding: '32px', height: '100%' }}>
            <h2 style={{ marginTop: 0, marginBottom: '24px', color: 'var(--text-primary)', fontSize: '1.5rem', display: 'flex', alignItems: 'center', gap: '10px' }}>
              <Wallet color="var(--primary)" /> Ví Xu (Coins)
            </h2>
            
            <div style={{ background: 'linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%)', padding: '32px', borderRadius: '16px', color: 'white', marginBottom: '32px', display: 'flex', flexDirection: 'column', alignItems: 'center', boxShadow: '0 10px 25px -5px rgba(100, 195, 165, 0.4)' }}>
              <span style={{ fontSize: '1rem', fontWeight: 500, opacity: 0.9, marginBottom: '8px' }}>Số dư hiện tại</span>
              <span style={{ fontSize: '3rem', fontWeight: 800, display: 'flex', alignItems: 'center', gap: '8px' }}>
                {wallet?.balance || 0} <span style={{ fontSize: '1.5rem', fontWeight: 600, opacity: 0.9 }}>xu</span>
              </span>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '20px' }}>
              <div style={{ border: '1px solid #E2E8F0', padding: '20px', borderRadius: '12px' }}>
                <h3 style={{ marginTop: 0, fontSize: '1.1rem', color: 'var(--text-primary)', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <ArrowDownCircle color="#10B981" size={20} /> Nạp xu
                </h3>
                <div style={{ display: 'flex', gap: '12px', marginTop: '16px' }}>
                  <Input 
                    type="number" 
                    placeholder="Số xu cần nạp" 
                    value={depositAmount} 
                    onChange={(e) => setDepositAmount(e.target.value)} 
                    style={{ flex: 1 }}
                  />
                  <Button type="button" onClick={handleDeposit} style={{ background: '#10B981', minWidth: '100px' }}>Nạp</Button>
                </div>
              </div>

              <div style={{ border: '1px solid #E2E8F0', padding: '20px', borderRadius: '12px' }}>
                <h3 style={{ marginTop: 0, fontSize: '1.1rem', color: 'var(--text-primary)', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <ArrowUpCircle color="#EF4444" size={20} /> Rút xu
                </h3>
                <div style={{ display: 'flex', gap: '12px', marginTop: '16px' }}>
                  <Input 
                    type="number" 
                    placeholder="Số xu cần rút" 
                    value={withdrawAmount} 
                    onChange={(e) => setWithdrawAmount(e.target.value)} 
                    style={{ flex: 1 }}
                  />
                  <Button type="button" onClick={handleWithdraw} style={{ background: '#EF4444', minWidth: '100px' }}>Rút</Button>
                </div>
              </div>
            </div>
          </Card>
        </section>

      </main>
    </div>
  );
};
