import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { AppContext } from '../App';
import { Card } from '../components/Card';

type TabType = 
  | 'USERS' 
  | 'MENTOR_APPS' 
  | 'CREATOR_APPS' 
  | 'WALLET' 
  | 'WITHDRAW_REQS' 
  | 'TOPUP_REQS' 
  | 'PAYMENT_CONFIG';

export const AdminUsersScreen: React.FC = () => {
  const navigate = useNavigate();
  const { currentUser } = React.useContext(AppContext);
  const [activeTab, setActiveTab] = useState<TabType>('USERS');
  const [filterStatus, setFilterStatus] = useState<'PENDING' | 'PROCESSED' | 'REJECTED'>('PENDING');

  // Real Data
  const [topupOrders, setTopupOrders] = useState<any[]>([]);
  const [withdrawRequests, setWithdrawRequests] = useState<any[]>([]);
  const [adminWallet, setAdminWallet] = useState<any>(null);
  const [systemUsers, setSystemUsers] = useState<any[]>([]);
  const [mentorApps, setMentorApps] = useState<any[]>([]);
  const [creatorApps, setCreatorApps] = useState<any[]>([]);

  // Form states for config
  const [momoConfig, setMomoConfig] = useState<any>({});

  useEffect(() => {
    if (activeTab === 'USERS') fetchSystemUsers();
    if (activeTab === 'MENTOR_APPS') fetchMentorApps();
    if (activeTab === 'CREATOR_APPS') fetchCreatorApps();
    if (activeTab === 'TOPUP_REQS') fetchTopups();
    if (activeTab === 'WITHDRAW_REQS') fetchWithdraws();
    if (activeTab === 'WALLET') fetchAdminWallet();
    if (activeTab === 'PAYMENT_CONFIG') fetchMomoConfig();
  }, [activeTab]);

  const fetchSystemUsers = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/admin/users', { 
        headers: { 'Authorization': `Bearer ${token}` } 
      });
      if (res.ok) {
        const data = await res.json();
        setSystemUsers(data.data || []);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const fetchMentorApps = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/admin/mentor-applications', { 
        headers: { 'Authorization': `Bearer ${token}` } 
      });
      if (res.ok) {
        const data = await res.json();
        setMentorApps(data.data || []);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const fetchCreatorApps = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/admin/creator-applications', { 
        headers: { 'Authorization': `Bearer ${token}` } 
      });
      if (res.ok) {
        const data = await res.json();
        setCreatorApps(data.data || []);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const fetchTopups = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/payment/admin/topup-orders', { 
        headers: { 
          'Authorization': `Bearer ${token}`,
          'X-User-Id': currentUser?.id || 'Uadmin' 
        } 
      });
      if (res.ok) {
        const data = await res.json();
        setTopupOrders(data.data || data || []);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const fetchWithdraws = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/payment/admin/withdraw-requests', { 
        headers: { 
          'Authorization': `Bearer ${token}`,
          'X-User-Id': currentUser?.id || 'Uadmin' 
        } 
      });
      if (res.ok) {
        const data = await res.json();
        setWithdrawRequests(data.data || data || []);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const fetchAdminWallet = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/payment/wallet', { 
        headers: { 
          'Authorization': `Bearer ${token}`,
          'X-User-Id': currentUser?.id || 'Uadmin' 
        } 
      });
      if (res.ok) {
        const data = await res.json();
        setAdminWallet(data.data || data);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const fetchMomoConfig = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/payment/admin/settings/momo', {
        headers: { 
          'Authorization': `Bearer ${token}`,
          'X-User-Id': currentUser?.id || 'Uadmin'
        }
      });
      if (res.ok) {
        const data = await res.json();
        setMomoConfig(data || {});
      }
    } catch (err) {
      console.error(err);
    }
  };

  const saveMomoConfig = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/payment/admin/settings/momo', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'X-User-Id': currentUser?.id || 'Uadmin'
        },
        body: JSON.stringify({
          receiverUserId: currentUser?.id || 'Uadmin',
          receiverPhone: momoConfig.receiverPhone || '',
          receiverName: momoConfig.receiverName || '',
          transferContentTemplate: momoConfig.transferContentTemplate || 'NAPXU {USER_ID}',
          qrImageUrl: momoConfig.qrImageUrl || ''
        })
      });
      if (res.ok) {
        alert("Lưu cấu hình thành công");
      } else {
        alert("Lỗi lưu cấu hình");
      }
    } catch (err) {
      alert("Lỗi kết nối");
    }
  };

  const handleUploadQr = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const formData = new FormData();
    formData.append('file', file);
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:8081/api/payment/admin/settings/momo/qr', {
        method: 'POST',
        headers: { 
          'Authorization': `Bearer ${token}`,
          'X-User-Id': currentUser?.id || 'Uadmin'
        },
        body: formData
      });
      if (res.ok) {
        const data = await res.json();
        setMomoConfig({ ...momoConfig, qrImageUrl: data.url });
        alert("Tải mã QR thành công, nhớ ấn Lưu cấu hình để ghi nhận.");
      } else {
        alert("Lỗi tải mã QR");
      }
    } catch (err) {
      alert("Lỗi kết nối");
    }
  };

  const approveTopup = async (id: string) => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`http://localhost:8081/api/payment/admin/topup-orders/${id}/approve`, {
        method: 'POST',
        headers: { 
          'Authorization': `Bearer ${token}`,
          'X-User-Id': currentUser?.id || 'Uadmin' 
        }
      });
      if (res.ok) {
        alert("Duyệt nạp tiền thành công");
        fetchTopups();
        fetchAdminWallet();
      } else {
        alert("Có lỗi khi duyệt nạp tiền");
      }
    } catch (err) {
      alert("Lỗi kết nối");
    }
  };

  const rejectTopup = async (id: string) => {
    const reason = prompt("Nhập lý do từ chối (bắt buộc):");
    if (!reason) return;
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`http://localhost:8081/api/payment/admin/topup-orders/${id}/reject`, {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'X-User-Id': currentUser?.id || 'Uadmin' 
        },
        body: JSON.stringify({ reason })
      });
      if (res.ok) {
        alert("Đã từ chối đơn nạp tiền");
        fetchTopups();
      } else {
        alert("Có lỗi khi từ chối");
      }
    } catch (err) {
      alert("Lỗi kết nối");
    }
  };

  const approveWithdraw = async (id: string) => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`http://localhost:8081/api/payment/admin/withdraw/approve/${id}`, {
        method: 'POST',
        headers: { 
          'Authorization': `Bearer ${token}`,
          'X-User-Id': currentUser?.id || 'Uadmin' 
        }
      });
      if (res.ok) {
        alert("Duyệt rút tiền thành công");
        fetchWithdraws();
      } else {
        alert("Có lỗi khi duyệt rút tiền");
      }
    } catch (err) {
      alert("Lỗi kết nối");
    }
  };

  const rejectWithdraw = async (id: string) => {
    const reason = prompt("Nhập lý do từ chối (bắt buộc):");
    if (!reason) return;
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`http://localhost:8081/api/payment/admin/withdraw/reject/${id}`, {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'X-User-Id': currentUser?.id || 'Uadmin' 
        },
        body: JSON.stringify({ rejectReason: reason })
      });
      if (res.ok) {
        alert("Đã từ chối rút tiền");
        fetchWithdraws();
      } else {
        alert("Có lỗi khi từ chối rút tiền");
      }
    } catch (err) {
      alert("Lỗi kết nối");
    }
  };

  const processMentorApp = async (id: string, action: 'approve' | 'reject') => {
    let payload = {};
    if (action === 'reject') {
      const reason = prompt("Nhập lý do từ chối (bắt buộc):");
      if (!reason) return;
      payload = { reason };
    }
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`http://localhost:8081/api/admin/mentor-applications/${id}/${action}`, {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        alert(action === 'approve' ? "Đã duyệt đơn" : "Đã từ chối đơn");
        fetchMentorApps();
      } else {
        alert("Lỗi khi xử lý đơn");
      }
    } catch (err) {
      alert("Lỗi kết nối");
    }
  };

  const processCreatorApp = async (id: string, action: 'approve' | 'reject') => {
    let payload = {};
    if (action === 'reject') {
      const reason = prompt("Nhập lý do từ chối (bắt buộc):");
      if (!reason) return;
      payload = { reason };
    }
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`http://localhost:8081/api/admin/creator-applications/${id}/${action}`, {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        alert(action === 'approve' ? "Đã duyệt đơn" : "Đã từ chối đơn");
        fetchCreatorApps();
      } else {
        alert("Lỗi khi xử lý đơn");
      }
    } catch (err) {
      alert("Lỗi kết nối");
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    navigate('/login');
  };

  const tabs = [
    { id: 'USERS', label: 'Người dùng hệ thống', icon: '👥' },
    { id: 'MENTOR_APPS', label: 'Đơn đăng ký Mentor', icon: '🎓' },
    { id: 'CREATOR_APPS', label: 'Đơn đăng ký Creator', icon: '🎨' },
    { id: 'WALLET', label: 'Ví xu của Admin', icon: '💰' },
    { id: 'WITHDRAW_REQS', label: 'Đơn yêu cầu rút tiền', icon: '💸' },
    { id: 'TOPUP_REQS', label: 'Đơn yêu cầu nạp tiền', icon: '📥' },
    { id: 'PAYMENT_CONFIG', label: 'Cấu hình thanh toán', icon: '⚙️' },
  ];

  const getFilteredMentorApps = () => {
    if (filterStatus === 'PENDING') return mentorApps.filter(app => app.status === 'PENDING');
    if (filterStatus === 'PROCESSED') return mentorApps.filter(app => app.status === 'APPROVED');
    return mentorApps.filter(app => app.status === 'REJECTED');
  };

  const getFilteredCreatorApps = () => {
    if (filterStatus === 'PENDING') return creatorApps.filter(app => app.status === 'PENDING');
    if (filterStatus === 'PROCESSED') return creatorApps.filter(app => app.status === 'APPROVED');
    return creatorApps.filter(app => app.status === 'REJECTED');
  };

  const getFilteredWithdraws = () => {
    if (filterStatus === 'PENDING') return withdrawRequests.filter(req => req.requestStatus === 'PENDING');
    if (filterStatus === 'PROCESSED') return withdrawRequests.filter(req => req.requestStatus === 'APPROVED' || req.requestStatus === 'PAID');
    return withdrawRequests.filter(req => req.requestStatus === 'REJECTED' || req.requestStatus === 'FAILED');
  };

  const getFilteredTopups = () => {
    if (filterStatus === 'PENDING') return topupOrders.filter(req => req.orderStatus === 'PENDING');
    if (filterStatus === 'PROCESSED') return topupOrders.filter(req => req.orderStatus === 'APPROVED' || req.orderStatus === 'PAID');
    return topupOrders.filter(req => req.orderStatus === 'REJECTED' || req.orderStatus === 'FAILED');
  };

  return (
    <div style={{ display: 'flex', minHeight: '100vh', fontFamily: "'Inter', sans-serif" }}>
      {/* Sidebar */}
      <div style={{ width: '280px', backgroundColor: 'var(--card-color)', padding: '24px 0', display: 'flex', flexDirection: 'column', borderRight: '1px solid var(--input-border)', boxShadow: '4px 0 10px rgba(0,0,0,0.02)', zIndex: 10 }}>
        <div style={{ padding: '0 24px', marginBottom: '40px' }}>
          <h2 style={{ margin: 0, fontSize: '24px', fontWeight: '800', background: 'linear-gradient(to right, var(--primary), var(--primary-dark))', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
            Lucy Admin
          </h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '13px', margin: '4px 0 0 0' }}>Welcome back, {currentUser?.fullName || 'Admin'}</p>
        </div>

        <nav style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '8px', padding: '0 12px' }}>
          {tabs.map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as TabType)}
              style={{
                display: 'flex', alignItems: 'center', gap: '12px', padding: '12px 16px', borderRadius: '12px',
                border: 'none', background: activeTab === tab.id ? 'rgba(100, 195, 165, 0.15)' : 'transparent',
                color: activeTab === tab.id ? 'var(--primary)' : 'var(--text-secondary)',
                cursor: 'pointer', textAlign: 'left', fontSize: '14px', fontWeight: '600',
                transition: 'all 0.2s ease', outline: 'none'
              }}
              onMouseEnter={(e) => { if (activeTab !== tab.id) e.currentTarget.style.background = 'rgba(0,0,0,0.03)' }}
              onMouseLeave={(e) => { if (activeTab !== tab.id) e.currentTarget.style.background = 'transparent' }}
            >
              <span style={{ fontSize: '18px' }}>{tab.icon}</span>
              {tab.label}
            </button>
          ))}
        </nav>

        <div style={{ padding: '24px' }}>
          <button onClick={handleLogout} style={{ width: '100%', padding: '12px', background: 'rgba(239, 68, 68, 0.1)', color: '#f87171', border: '1px solid rgba(239, 68, 68, 0.2)', borderRadius: '12px', cursor: 'pointer', fontWeight: 'bold', transition: 'all 0.2s' }}
            onMouseEnter={(e) => e.currentTarget.style.background = 'rgba(239, 68, 68, 0.2)'}
            onMouseLeave={(e) => e.currentTarget.style.background = 'rgba(239, 68, 68, 0.1)'}
          >
            Đăng xuất
          </button>
        </div>
      </div>

      {/* Main Content */}
      <div style={{ flex: 1, padding: '40px', overflowY: 'auto' }}>
        
        {activeTab === 'USERS' && (
          <div style={fadeInStyle}>
            <h1 style={headerStyle}>Người dùng hệ thống</h1>
            <p style={subHeaderStyle}>Danh sách tất cả người dùng trong hệ thống (Dữ liệu thật từ DB)</p>
            {systemUsers.length === 0 ? (
              <div style={emptyStateStyle}>Không có người dùng nào.</div>
            ) : (
              <div style={gridStyle}>
                {systemUsers.map((user, idx) => (
                  <div key={idx} style={cardStyle}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '16px' }}>
                      <div style={{ width: '50px', height: '50px', borderRadius: '50%', background: '#334155', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#f8fafc', fontWeight: 'bold' }}>
                        {user.fullName ? user.fullName.charAt(0).toUpperCase() : 'U'}
                      </div>
                      <div style={{ overflow: 'hidden' }}>
                        <h3 style={{ margin: 0, color: '#f8fafc', whiteSpace: 'nowrap', textOverflow: 'ellipsis', overflow: 'hidden' }}>{user.fullName || 'Người dùng'}</h3>
                        <p style={{ margin: 0, color: '#94a3b8', fontSize: '14px', whiteSpace: 'nowrap', textOverflow: 'ellipsis', overflow: 'hidden' }}>{user.email || user.phoneNumber || 'N/A'}</p>
                      </div>
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <span style={{ display: 'inline-block', padding: '4px 12px', background: 'rgba(59, 130, 246, 0.2)', color: '#60a5fa', borderRadius: '20px', fontSize: '12px', fontWeight: 'bold' }}>USER</span>
                      <span style={{ fontSize: '12px', color: user.isStatus === 1 ? '#10b981' : '#f43f5e' }}>{user.isStatus === 1 ? 'Hoạt động' : 'Khóa'}</span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* Tab 2: Đơn đăng ký Mentor */}
        {activeTab === 'MENTOR_APPS' && (
          <div style={fadeInStyle}>
            <h1 style={headerStyle}>Đơn đăng ký Mentor</h1>
            <p style={subHeaderStyle}>Xét duyệt các đơn xin trở thành Mentor (Dữ liệu thật từ DB)</p>
            
            <div style={{ display: 'flex', gap: '8px', marginBottom: '24px' }}>
              <button onClick={() => setFilterStatus('PENDING')} style={{ padding: '8px 16px', background: filterStatus === 'PENDING' ? 'var(--primary)' : 'transparent', color: filterStatus === 'PENDING' ? '#fff' : 'var(--text-secondary)', border: `1px solid ${filterStatus === 'PENDING' ? 'var(--primary)' : 'var(--input-border)'}`, borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>Đơn chờ xác nhận</button>
              <button onClick={() => setFilterStatus('PROCESSED')} style={{ padding: '8px 16px', background: filterStatus === 'PROCESSED' ? '#10b981' : 'transparent', color: filterStatus === 'PROCESSED' ? '#fff' : 'var(--text-secondary)', border: `1px solid ${filterStatus === 'PROCESSED' ? '#10b981' : 'var(--input-border)'}`, borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>Đơn đã duyệt</button>
              <button onClick={() => setFilterStatus('REJECTED')} style={{ padding: '8px 16px', background: filterStatus === 'REJECTED' ? '#f43f5e' : 'transparent', color: filterStatus === 'REJECTED' ? '#fff' : 'var(--text-secondary)', border: `1px solid ${filterStatus === 'REJECTED' ? '#f43f5e' : 'var(--input-border)'}`, borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>Đơn đã từ chối</button>
            </div>

            {getFilteredMentorApps().length === 0 ? (
              <div style={emptyStateStyle}>Không có đơn nào.</div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                {getFilteredMentorApps().map((app, idx) => (
                  <div key={idx} style={{ ...cardStyle, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                      <h3 style={{ margin: '0 0 8px 0', color: 'var(--text-primary)' }}>{app.fullName || app.userId}</h3>
                      <p style={{ margin: '0 0 4px 0', color: 'var(--text-secondary)', fontSize: '14px' }}>Mã đơn: {app.applicationId}</p>
                      <p style={{ margin: '0 0 4px 0', color: 'var(--text-secondary)', fontSize: '14px' }}>Ngôn ngữ: {app.languageId || 'N/A'}</p>
                      {app.certificateUrl && (
                        <p style={{ margin: '0 0 4px 0', color: 'var(--primary)', fontSize: '14px' }}><a href={app.certificateUrl} target="_blank" rel="noreferrer" style={{color: 'var(--primary)'}}>Xem chứng chỉ</a></p>
                      )}
                      <p style={{ margin: '0 0 4px 0', color: 'var(--text-secondary)', fontSize: '14px' }}>Ngày gửi: {app.submittedAt ? new Date(app.submittedAt).toLocaleString() : 'N/A'}</p>
                      <p style={{ margin: 0, fontSize: '14px' }}>Trạng thái: <span style={{ color: app.status === 'PENDING' ? '#fbbf24' : (app.status === 'APPROVED' ? '#10b981' : '#f43f5e'), fontWeight: 'bold' }}>{app.status}</span></p>
                      {app.status === 'REJECTED' && app.rejectReason && (
                        <p style={{ margin: '4px 0 0 0', color: '#f43f5e', fontSize: '14px' }}>Lý do từ chối: {app.rejectReason}</p>
                      )}
                    </div>
                    {app.status === 'PENDING' && (
                      <div style={{ display: 'flex', gap: '12px' }}>
                        <button onClick={() => processMentorApp(app.applicationId, 'approve')} style={approveBtnStyle}>Duyệt</button>
                        <button onClick={() => processMentorApp(app.applicationId, 'reject')} style={rejectBtnStyle}>Từ chối</button>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* Tab 3: Đơn đăng ký Creator */}
        {activeTab === 'CREATOR_APPS' && (
          <div style={fadeInStyle}>
            <h1 style={headerStyle}>Đơn đăng ký Creator</h1>
            <p style={subHeaderStyle}>Xét duyệt các đơn xin xuất bản khóa học (Dữ liệu thật từ DB)</p>

            <div style={{ display: 'flex', gap: '8px', marginBottom: '24px' }}>
              <button onClick={() => setFilterStatus('PENDING')} style={{ padding: '8px 16px', background: filterStatus === 'PENDING' ? 'var(--primary)' : 'transparent', color: filterStatus === 'PENDING' ? '#fff' : 'var(--text-secondary)', border: `1px solid ${filterStatus === 'PENDING' ? 'var(--primary)' : 'var(--input-border)'}`, borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>Đơn chờ xác nhận</button>
              <button onClick={() => setFilterStatus('PROCESSED')} style={{ padding: '8px 16px', background: filterStatus === 'PROCESSED' ? '#10b981' : 'transparent', color: filterStatus === 'PROCESSED' ? '#fff' : 'var(--text-secondary)', border: `1px solid ${filterStatus === 'PROCESSED' ? '#10b981' : 'var(--input-border)'}`, borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>Đơn đã duyệt</button>
              <button onClick={() => setFilterStatus('REJECTED')} style={{ padding: '8px 16px', background: filterStatus === 'REJECTED' ? '#f43f5e' : 'transparent', color: filterStatus === 'REJECTED' ? '#fff' : 'var(--text-secondary)', border: `1px solid ${filterStatus === 'REJECTED' ? '#f43f5e' : 'var(--input-border)'}`, borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>Đơn đã từ chối</button>
            </div>

            {getFilteredCreatorApps().length === 0 ? (
              <div style={emptyStateStyle}>Không có đơn nào.</div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                {getFilteredCreatorApps().map((app, idx) => (
                  <div key={idx} style={{ ...cardStyle, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                      <h3 style={{ margin: '0 0 8px 0', color: 'var(--text-primary)' }}>{app.fullName || app.userId}</h3>
                      <p style={{ margin: '0 0 4px 0', color: 'var(--text-secondary)', fontSize: '14px' }}>Mã đơn: {app.applicationId}</p>
                      {app.certificateUrl && (
                        <p style={{ margin: '0 0 4px 0', color: 'var(--primary)', fontSize: '14px' }}><a href={app.certificateUrl} target="_blank" rel="noreferrer" style={{color: 'var(--primary)'}}>Xem chứng chỉ / Kênh Youtube</a></p>
                      )}
                      <p style={{ margin: '0 0 4px 0', color: 'var(--text-secondary)', fontSize: '14px' }}>Ngày gửi: {app.submittedAt ? new Date(app.submittedAt).toLocaleString() : 'N/A'}</p>
                      <p style={{ margin: 0, fontSize: '14px' }}>Trạng thái: <span style={{ color: app.status === 'PENDING' ? '#fbbf24' : (app.status === 'APPROVED' ? '#10b981' : '#f43f5e'), fontWeight: 'bold' }}>{app.status}</span></p>
                      {app.status === 'REJECTED' && app.rejectReason && (
                        <p style={{ margin: '4px 0 0 0', color: '#f43f5e', fontSize: '14px' }}>Lý do từ chối: {app.rejectReason}</p>
                      )}
                    </div>
                    {app.status === 'PENDING' && (
                      <div style={{ display: 'flex', gap: '12px' }}>
                        <button onClick={() => processCreatorApp(app.applicationId, 'approve')} style={approveBtnStyle}>Duyệt</button>
                        <button onClick={() => processCreatorApp(app.applicationId, 'reject')} style={rejectBtnStyle}>Từ chối</button>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {activeTab === 'WALLET' && (
          <div style={fadeInStyle}>
            <h1 style={headerStyle}>Ví xu của Admin</h1>
            <p style={subHeaderStyle}>Số dư xu hiện tại của hệ thống</p>
            <div style={{ ...cardStyle, maxWidth: '400px', background: 'linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%)', border: 'none', position: 'relative', overflow: 'hidden' }}>
              <div style={{ position: 'absolute', top: -50, right: -50, width: 150, height: 150, background: 'rgba(255, 255, 255, 0.2)', borderRadius: '50%', filter: 'blur(30px)' }} />
              <h3 style={{ color: 'rgba(255,255,255,0.9)', margin: '0 0 16px 0', fontWeight: 'normal' }}>Tổng số dư (XU)</h3>
              <div style={{ fontSize: '48px', fontWeight: '800', color: '#fff', display: 'flex', alignItems: 'center', gap: '12px' }}>
                <span style={{ color: '#fbbf24' }}>●</span>
                {adminWallet?.balance !== undefined ? adminWallet.balance.toLocaleString() : '0'}
              </div>
              <p style={{ margin: '16px 0 0 0', color: 'rgba(255,255,255,0.7)', fontSize: '14px' }}>Cập nhật lúc: {new Date().toLocaleTimeString()}</p>
            </div>
          </div>
        )}

        {/* Tab 5: Đơn Rút Tiền */}
        {activeTab === 'WITHDRAW_REQS' && (
          <div style={fadeInStyle}>
            <h1 style={headerStyle}>Đơn rút tiền</h1>
            <p style={subHeaderStyle}>Duyệt yêu cầu rút tiền của Mentor/Creator (Dữ liệu thật từ DB)</p>

            <div style={{ display: 'flex', gap: '8px', marginBottom: '24px' }}>
              <button onClick={() => setFilterStatus('PENDING')} style={{ padding: '8px 16px', background: filterStatus === 'PENDING' ? 'var(--primary)' : 'transparent', color: filterStatus === 'PENDING' ? '#fff' : 'var(--text-secondary)', border: `1px solid ${filterStatus === 'PENDING' ? 'var(--primary)' : 'var(--input-border)'}`, borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>Đơn chờ xác nhận</button>
              <button onClick={() => setFilterStatus('PROCESSED')} style={{ padding: '8px 16px', background: filterStatus === 'PROCESSED' ? '#10b981' : 'transparent', color: filterStatus === 'PROCESSED' ? '#fff' : 'var(--text-secondary)', border: `1px solid ${filterStatus === 'PROCESSED' ? '#10b981' : 'var(--input-border)'}`, borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>Đơn đã duyệt/chuyển</button>
              <button onClick={() => setFilterStatus('REJECTED')} style={{ padding: '8px 16px', background: filterStatus === 'REJECTED' ? '#f43f5e' : 'transparent', color: filterStatus === 'REJECTED' ? '#fff' : 'var(--text-secondary)', border: `1px solid ${filterStatus === 'REJECTED' ? '#f43f5e' : 'var(--input-border)'}`, borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>Đơn đã từ chối</button>
            </div>

            {getFilteredWithdraws().length === 0 ? (
              <div style={emptyStateStyle}>Không có yêu cầu rút tiền nào.</div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                {getFilteredWithdraws().map((req, idx) => (
                  <div key={idx} style={{ ...cardStyle, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                      <h3 style={{ margin: '0 0 8px 0', color: 'var(--text-primary)' }}>Mã yêu cầu: {req.withdrawRequestId}</h3>
                      <p style={{ margin: '0 0 4px 0', color: '#10b981', fontSize: '18px', fontWeight: 'bold' }}>{Number(req.amount).toLocaleString()} Xu</p>
                      <p style={{ margin: '0 0 4px 0', color: 'var(--text-secondary)', fontSize: '14px' }}>Ngân hàng: {req.bankName}</p>
                      <p style={{ margin: '0 0 4px 0', color: 'var(--text-secondary)', fontSize: '14px' }}>STK: {req.bankAccountNumber} - {req.bankAccountName}</p>
                      <p style={{ margin: 0, fontSize: '14px' }}>Trạng thái: <span style={{ color: req.requestStatus === 'PENDING' ? '#fbbf24' : (req.requestStatus === 'APPROVED' ? '#10b981' : '#f43f5e'), fontWeight: 'bold' }}>{req.requestStatus}</span></p>
                      {req.requestStatus === 'REJECTED' && req.rejectReason && (
                        <p style={{ margin: '4px 0 0 0', color: '#f43f5e', fontSize: '14px' }}>Lý do từ chối: {req.rejectReason}</p>
                      )}
                    </div>
                    {req.requestStatus === 'PENDING' && (
                      <div style={{ display: 'flex', gap: '12px' }}>
                        <button onClick={() => approveWithdraw(req.withdrawRequestId)} style={approveBtnStyle}>Đã chuyển khoản</button>
                        <button onClick={() => rejectWithdraw(req.withdrawRequestId)} style={rejectBtnStyle}>Từ chối</button>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* Tab 6: Đơn Nạp Tiền */}
        {activeTab === 'TOPUP_REQS' && (
          <div style={fadeInStyle}>
            <h1 style={headerStyle}>Đơn nạp tiền</h1>
            <p style={subHeaderStyle}>Xác nhận nạp tiền vào ví người dùng (Dữ liệu thật từ DB)</p>

            <div style={{ display: 'flex', gap: '8px', marginBottom: '24px' }}>
              <button onClick={() => setFilterStatus('PENDING')} style={{ padding: '8px 16px', background: filterStatus === 'PENDING' ? 'var(--primary)' : 'transparent', color: filterStatus === 'PENDING' ? '#fff' : 'var(--text-secondary)', border: `1px solid ${filterStatus === 'PENDING' ? 'var(--primary)' : 'var(--input-border)'}`, borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>Đơn chờ xác nhận</button>
              <button onClick={() => setFilterStatus('PROCESSED')} style={{ padding: '8px 16px', background: filterStatus === 'PROCESSED' ? '#10b981' : 'transparent', color: filterStatus === 'PROCESSED' ? '#fff' : 'var(--text-secondary)', border: `1px solid ${filterStatus === 'PROCESSED' ? '#10b981' : 'var(--input-border)'}`, borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>Đơn đã nhận tiền</button>
              <button onClick={() => setFilterStatus('REJECTED')} style={{ padding: '8px 16px', background: filterStatus === 'REJECTED' ? '#f43f5e' : 'transparent', color: filterStatus === 'REJECTED' ? '#fff' : 'var(--text-secondary)', border: `1px solid ${filterStatus === 'REJECTED' ? '#f43f5e' : 'var(--input-border)'}`, borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>Đơn đã từ chối</button>
            </div>

            {getFilteredTopups().length === 0 ? (
              <div style={emptyStateStyle}>Không có đơn nào.</div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                {getFilteredTopups().map((order, idx) => (
                  <div key={idx} style={{ ...cardStyle, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                      <h3 style={{ margin: '0 0 8px 0', color: 'var(--text-primary)' }}>Mã nạp: {order.topUpOrderId}</h3>
                      <p style={{ margin: '0 0 4px 0', color: '#10b981', fontSize: '18px', fontWeight: 'bold' }}>+{Number(order.amount).toLocaleString()} Xu</p>
                      <p style={{ margin: '0 0 4px 0', color: 'var(--text-secondary)', fontSize: '14px' }}>Phương thức: {order.paymentProvider || 'Chuyển khoản'}</p>
                      <p style={{ margin: '0 0 4px 0', color: 'var(--text-secondary)', fontSize: '14px' }}>Mã GD ngoài: {order.externalTransactionCode || 'N/A'}</p>
                      <p style={{ margin: 0, fontSize: '14px' }}>Trạng thái: <span style={{ color: order.orderStatus === 'PENDING' ? '#fbbf24' : (order.orderStatus === 'PAID' ? '#10b981' : '#f43f5e'), fontWeight: 'bold' }}>{order.orderStatus}</span></p>
                    </div>
                    {order.orderStatus === 'PENDING' && (
                      <div style={{ display: 'flex', gap: '12px' }}>
                        <button onClick={() => approveTopup(order.topUpOrderId)} style={approveBtnStyle}>Xác nhận đã nhận tiền</button>
                        <button onClick={() => rejectTopup(order.topUpOrderId)} style={rejectBtnStyle}>Từ chối</button>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {activeTab === 'PAYMENT_CONFIG' && (
          <div style={fadeInStyle}>
            <h1 style={headerStyle}>Cấu hình thanh toán</h1>
            <p style={subHeaderStyle}>Thiết lập tài khoản ngân hàng / ví điện tử nhận tiền nạp từ học viên</p>
            
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '32px' }}>
              <div style={cardStyle}>
                <h3 style={{ color: 'var(--text-primary)', marginTop: 0, marginBottom: '24px' }}>Thông tin tài khoản (MoMo/Bank)</h3>
                
                <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                  <div>
                    <label style={{ display: 'block', color: 'var(--text-secondary)', fontSize: '14px', marginBottom: '8px' }}>Số điện thoại / STK</label>
                    <input type="text" placeholder="Ví dụ: 0912345678" style={inputStyle} value={momoConfig.receiverPhone || ''} onChange={(e) => setMomoConfig({...momoConfig, receiverPhone: e.target.value})} />
                  </div>
                  <div>
                    <label style={{ display: 'block', color: 'var(--text-secondary)', fontSize: '14px', marginBottom: '8px' }}>Tên chủ tài khoản</label>
                    <input type="text" placeholder="Ví dụ: NGUYEN VAN A" style={inputStyle} value={momoConfig.receiverName || ''} onChange={(e) => setMomoConfig({...momoConfig, receiverName: e.target.value})} />
                  </div>
                  <div>
                    <label style={{ display: 'block', color: 'var(--text-secondary)', fontSize: '14px', marginBottom: '8px' }}>Cú pháp nạp (Ví dụ: NAPXU {`{USER_ID}`})</label>
                    <input type="text" placeholder="Ví dụ: NAPXU {USER_ID}" style={inputStyle} value={momoConfig.transferContentTemplate || ''} onChange={(e) => setMomoConfig({...momoConfig, transferContentTemplate: e.target.value})} />
                  </div>
                  
                  <button onClick={saveMomoConfig} style={{ ...approveBtnStyle, alignSelf: 'flex-start', marginTop: '16px' }}>Lưu cấu hình</button>
                </div>
              </div>

              <div style={{ ...cardStyle, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
                <h3 style={{ color: 'var(--text-primary)', marginTop: 0, marginBottom: '24px' }}>Mã QR Nhận Tiền</h3>
                <div style={{ width: '250px', height: '250px', background: 'var(--input-background)', borderRadius: '16px', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '24px', border: '2px dashed var(--input-border)', overflow: 'hidden' }}>
                  {momoConfig.qrImageUrl ? (
                    <img src={`http://localhost:8081${momoConfig.qrImageUrl}`} alt="QR Code" style={{ width: '100%', height: '100%', objectFit: 'contain' }} />
                  ) : (
                    <span style={{ color: 'var(--text-secondary)' }}>[Chưa có QR]</span>
                  )}
                </div>
                <label style={{ padding: '12px 24px', background: 'rgba(100, 195, 165, 0.1)', color: 'var(--primary)', border: '1px solid rgba(100, 195, 165, 0.2)', borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>
                  Tải ảnh QR lên
                  <input type="file" style={{ display: 'none' }} accept="image/*" onChange={handleUploadQr} />
                </label>
              </div>
            </div>
          </div>
        )}

      </div>
    </div>
  );
};

// Common Styles
const fadeInStyle: React.CSSProperties = { animation: 'fadeIn 0.3s ease-in-out' };
const headerStyle: React.CSSProperties = { margin: '0 0 8px 0', color: 'var(--text-primary)', fontSize: '32px', fontWeight: '800' };
const subHeaderStyle: React.CSSProperties = { margin: '0 0 32px 0', color: 'var(--text-secondary)', fontSize: '16px' };
const gridStyle: React.CSSProperties = { display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '24px' };
const cardStyle: React.CSSProperties = { background: 'var(--card-color)', border: '1px solid var(--input-border)', borderRadius: '16px', padding: '24px', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)' };
const inputStyle: React.CSSProperties = { width: '100%', padding: '12px 16px', background: 'var(--input-background)', border: '1px solid var(--input-border)', borderRadius: '8px', color: 'var(--text-primary)', outline: 'none', boxSizing: 'border-box' };
const approveBtnStyle: React.CSSProperties = { padding: '10px 20px', background: 'linear-gradient(to right, #10b981, #059669)', color: 'white', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold', boxShadow: '0 4px 6px -1px rgba(16, 185, 129, 0.3)' };
const rejectBtnStyle: React.CSSProperties = { padding: '10px 20px', background: 'rgba(239, 68, 68, 0.1)', color: '#f87171', border: '1px solid rgba(239, 68, 68, 0.2)', borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' };
const emptyStateStyle: React.CSSProperties = { padding: '40px', background: 'var(--card-color)', borderRadius: '16px', border: '1px dashed var(--input-border)', color: 'var(--text-secondary)', textAlign: 'center' };
