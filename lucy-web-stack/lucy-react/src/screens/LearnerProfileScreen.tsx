import React, { useEffect, useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { AppContext } from '../App';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { Input } from '../components/Input';
import { ChevronLeft, Wallet, ArrowDownCircle, ArrowUpCircle } from 'lucide-react';

export const LearnerProfileScreen: React.FC = () => {
  const navigate = useNavigate();
  const { currentUser, setCurrentUser } = React.useContext(AppContext);
  const [profile, setProfile] = useState<any>(null);
  const [avatar, setAvatar] = useState<string>('');
  const [wallet, setWallet] = useState<any>(null);
  const [isUpdating, setIsUpdating] = useState(false);
  const [depositAmount, setDepositAmount] = useState<string>('');
  const [withdrawAmount, setWithdrawAmount] = useState<string>('');
  const [withdrawBankName, setWithdrawBankName] = useState<string>('');
  const [withdrawAccountNo, setWithdrawAccountNo] = useState<string>('');
  const [withdrawAccountName, setWithdrawAccountName] = useState<string>('');
  const [showMomoDetails, setShowMomoDetails] = useState(false);
  const [momoSetting, setMomoSetting] = useState<any>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const fetchProfileData = async () => {
    try {
      const token = sessionStorage.getItem('token');
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
      const token = sessionStorage.getItem('token');
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
      const token = sessionStorage.getItem('token');
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

  const handleShowMomo = async () => {
    if (!depositAmount || isNaN(Number(depositAmount)) || Number(depositAmount) <= 0) {
      alert("Vui lòng nhập số tiền nạp hợp lệ.");
      return;
    }

    try {
      const token = sessionStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/payment/settings/momo', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (res.ok) {
        const data = await res.json();
        if (data) {
          setMomoSetting(data);
          setShowMomoDetails(true);
        } else {
          alert("Hệ thống chưa thiết lập thông tin thanh toán Momo.");
        }
      } else {
        alert("Lỗi khi lấy thông tin thanh toán.");
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
      const token = sessionStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/payment/deposit', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ amount: Number(depositAmount) })
      });
      if (res.ok) {
        alert("Yêu cầu nạp tiền thành công! Vui lòng chờ admin phê duyệt đơn nạp.");
        setDepositAmount('');
        setShowMomoDetails(false);
        setMomoSetting(null);
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
    if (!withdrawBankName.trim()) {
      alert("Vui lòng nhập tên ngân hàng.");
      return;
    }
    if (!withdrawAccountNo.trim()) {
      alert("Vui lòng nhập số tài khoản.");
      return;
    }
    if (!withdrawAccountName.trim()) {
      alert("Vui lòng nhập tên tài khoản thụ hưởng.");
      return;
    }

    try {
      const token = sessionStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/payment/withdraw', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          amount: Number(withdrawAmount),
          bankName: withdrawBankName,
          bankAccountNumber: withdrawAccountNo,
          bankAccountName: withdrawAccountName
        })
      });
      if (res.ok) {
        const data = await res.json();
        if (data && data.isSuccess === false) {
          alert(data.message || "Lỗi khi rút tiền.");
        } else {
          alert("Yêu cầu rút tiền thành công! Vui lòng chờ admin phê duyệt.");
          setWithdrawAmount('');
          setWithdrawBankName('');
          setWithdrawAccountNo('');
          setWithdrawAccountName('');
          fetchProfileData();
        }
      } else {
        alert("Lỗi khi rút tiền.");
      }
    } catch (err) {
      console.error(err);
      alert("Lỗi kết nối.");
    }
  };

  // Hàm tự động replace thẻ {USER_ID} / {ORDER_CODE} bằng ID thật của người dùng
  const getTransferContent = () => {
    const template = momoSetting?.transferContentTemplate || 'NAPXU {USER_ID}';
    // Lấy ID chuẩn của người dùng hiện tại
    const currentUserId = profile?.userId || profile?.id || currentUser?.userId || currentUser?.id || 'USER';

    // Nếu template có chứa thẻ biến {USER_ID} hoặc {ORDER_CODE}
    if (template.includes('{USER_ID}') || template.includes('{ORDER_CODE}')) {
      return template
        .replace(/\{USER_ID\}/g, currentUserId)
        .replace(/\{ORDER_CODE\}/g, currentUserId);
    }

    // Nếu trong template không có thẻ biến, nối ID vào cuối chuỗi
    return `${template} ${currentUserId}`.trim();
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
        <button onClick={() => navigate('/learner')} style={{
          background: 'transparent', border: 'none', color: 'white', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '8px', fontSize: '1rem', fontWeight: 600
        }}>
          <ChevronLeft size={24} /> Quay lại
        </button>
        <h1 style={{ margin: '0 auto', fontSize: '1.5rem', fontWeight: 700 }}>Hồ sơ của tôi</h1>
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
                  value={profile?.displayName ?? profile?.fullName ?? ''}
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
                    disabled={showMomoDetails}
                  />
                  {!showMomoDetails ? (
                    <Button type="button" onClick={handleShowMomo} style={{ background: '#10B981', minWidth: '100px' }}>Nạp</Button>
                  ) : (
                    <Button type="button" onClick={() => { setShowMomoDetails(false); setMomoSetting(null); }} style={{ background: '#64748B', minWidth: '100px' }}>Hủy</Button>
                  )}
                </div>

                {showMomoDetails && momoSetting && (
                  <div style={{ marginTop: '20px', padding: '16px', borderRadius: '8px', border: '1px dashed #10B981', backgroundColor: '#F0FDF4', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                    <h4 style={{ margin: '0 0 12px 0', color: '#15803D', fontSize: '1rem', fontWeight: 600 }}>Quét mã Momo để nạp tiền</h4>
                    {momoSetting.qrImageUrl ? (
                      <img
                        src={`http://localhost:8081${momoSetting.qrImageUrl}`}
                        alt="Momo QR Code"
                        style={{ width: '200px', height: '200px', objectFit: 'contain', borderRadius: '8px', boxShadow: '0 4px 12px rgba(0,0,0,0.1)', marginBottom: '16px' }}
                      />
                    ) : (
                      <div style={{ width: '200px', height: '200px', display: 'flex', alignItems: 'center', justifyContent: 'center', backgroundColor: '#E2E8F0', borderRadius: '8px', marginBottom: '16px', color: '#64748B' }}>
                        Không có ảnh QR
                      </div>
                    )}

                    <div style={{ width: '100%', fontSize: '0.9rem', color: '#1E293B', marginBottom: '16px', lineHeight: '1.6' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid #E2E8F0', padding: '6px 0' }}>
                        <span style={{ color: '#64748B' }}>Chủ tài khoản:</span>
                        <strong style={{ color: '#1E293B' }}>{momoSetting.receiverName}</strong>
                      </div>
                      <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid #E2E8F0', padding: '6px 0' }}>
                        <span style={{ color: '#64748B' }}>Số điện thoại:</span>
                        <strong style={{ color: '#1E293B' }}>{momoSetting.receiverPhone}</strong>
                      </div>
                      <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid #E2E8F0', padding: '6px 0' }}>
                        <span style={{ color: '#64748B' }}>Số tiền:</span>
                        <strong style={{ color: '#15803D' }}>{Number(depositAmount).toLocaleString('vi-VN')} đ</strong>
                      </div>
                      <div style={{ display: 'flex', flexDirection: 'column', padding: '6px 0' }}>
                        <span style={{ color: '#64748B', marginBottom: '4px' }}>Nội dung chuyển khoản:</span>
                        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', background: '#F8FAFC', padding: '8px', borderRadius: '6px', border: '1px solid #E2E8F0' }}>
                          <code style={{ fontSize: '0.95rem', color: '#0F172A', fontWeight: 'bold' }}>
                            {getTransferContent()}
                          </code>
                          <button
                            type="button"
                            onClick={() => {
                              navigator.clipboard.writeText(getTransferContent());
                              alert("Đã sao chép nội dung chuyển khoản!");
                            }}
                            style={{ background: 'var(--primary)', border: 'none', color: 'white', padding: '4px 8px', borderRadius: '4px', fontSize: '0.8rem', cursor: 'pointer' }}
                          >
                            Sao chép
                          </button>
                        </div>
                      </div>
                    </div>

                    <Button type="button" onClick={handleDeposit} style={{ background: '#10B981', width: '100%', padding: '12px' }}>
                      Tôi đã nộp tiền
                    </Button>
                  </div>
                )}
              </div>

              <div style={{ border: '1px solid #E2E8F0', padding: '20px', borderRadius: '12px' }}>
                <h3 style={{ marginTop: 0, fontSize: '1.1rem', color: 'var(--text-primary)', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
                  <ArrowUpCircle color="#EF4444" size={20} /> Rút xu
                </h3>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  <div>
                    <label style={{ display: 'block', fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '4px', fontWeight: 500 }}>Số xu cần rút</label>
                    <Input
                      type="number"
                      placeholder="Nhập số xu"
                      value={withdrawAmount}
                      onChange={(e) => setWithdrawAmount(e.target.value)}
                      style={{ width: '100%' }}
                    />
                  </div>
                  <div>
                    <label style={{ display: 'block', fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '4px', fontWeight: 500 }}>Tên ngân hàng</label>
                    <Input
                      type="text"
                      placeholder="Ví dụ: Vietcombank, MB Bank..."
                      value={withdrawBankName}
                      onChange={(e) => setWithdrawBankName(e.target.value)}
                      style={{ width: '100%' }}
                    />
                  </div>
                  <div>
                    <label style={{ display: 'block', fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '4px', fontWeight: 500 }}>Số tài khoản</label>
                    <Input
                      type="text"
                      placeholder="Nhập số tài khoản ngân hàng"
                      value={withdrawAccountNo}
                      onChange={(e) => setWithdrawAccountNo(e.target.value)}
                      style={{ width: '100%' }}
                    />
                  </div>
                  <div>
                    <label style={{ display: 'block', fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '4px', fontWeight: 500 }}>Tên tài khoản thụ hưởng</label>
                    <Input
                      type="text"
                      placeholder="Nhập tên chủ tài khoản"
                      value={withdrawAccountName}
                      onChange={(e) => setWithdrawAccountName(e.target.value)}
                      style={{ width: '100%' }}
                    />
                  </div>
                  <Button type="button" onClick={handleWithdraw} style={{ background: '#EF4444', width: '100%', marginTop: '8px' }}>Rút tiền</Button>
                </div>
              </div>
            </div>
          </Card>
        </section>

      </main>
    </div>
  );
};
