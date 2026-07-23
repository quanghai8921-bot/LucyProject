import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Card } from '../components/Card';
import { Input } from '../components/Input';
import { Button } from '../components/Button';
import { User, Lock, Mail} from 'lucide-react';
import { AppContext } from '../App';

export const RegisterScreen: React.FC = () => {
  const navigate = useNavigate();
  const { setCurrentRole, setCurrentUser } = React.useContext(AppContext);
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState('R002'); // R002 = Learner, R003 = Mentor

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const res = await fetch('http://localhost:8081/api/auth/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ fullName, email, password, role })
      });
      if (res.ok) {
        const result = await res.json();
        const payload = result.data || result;
        
        if (!payload.token) {
          alert("Đăng ký thành công! Đơn đăng ký của bạn đang chờ Admin phê duyệt. Bạn sẽ có thể đăng nhập sau khi được duyệt.");
          navigate('/login');
          return;
        }

        sessionStorage.setItem('token', payload.token);
        setCurrentUser({ id: payload.userId, fullName: payload.fullName, email: payload.email, role: payload.roles[0] });
        
        let targetRole = 'learner';
        let path = '/learner';
        const roleVal = payload.roles[0];
        if (roleVal === 'R001' || roleVal === 1 || roleVal === 'R002' || roleVal === 2) { targetRole = 'learner'; path = '/learner'; }
        else if (roleVal === 'R003' || roleVal === 3) { targetRole = 'mentor'; path = '/mentor'; }

        setCurrentRole(targetRole);
        navigate(path);
      } else {
        const errorResult = await res.json();
        alert("Đăng ký thất bại: " + (errorResult.message || ''));
      }
    } catch (err) {
      alert("Lỗi kết nối Server");
    }
  };

  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '100vh', padding: '20px' }}>
      <Card style={{ maxWidth: '400px', width: '100%', padding: '40px 24px' }}>
        <div style={{ textAlign: 'center', marginBottom: '32px' }}>
          <h1 style={{ color: 'var(--primary)', fontSize: '2rem', marginBottom: '8px' }}>Đăng Ký</h1>
          <p style={{ color: 'var(--text-secondary)' }}>Tạo tài khoản mới</p>
        </div>

        <form onSubmit={handleRegister}>
          <div style={{ position: 'relative', marginBottom: '16px' }}>
            <Input 
              type="text" 
              placeholder="Họ và Tên" 
              style={{ paddingLeft: '40px' }} 
              value={fullName}
              onChange={(e: any) => setFullName(e.target.value)}
              required
            />
            <User size={20} color="var(--text-secondary)" style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)' }} />
          </div>

          <div style={{ position: 'relative', marginBottom: '16px' }}>
            <Input 
              type="email" 
              placeholder="Email" 
              style={{ paddingLeft: '40px' }} 
              value={email}
              onChange={(e: any) => setEmail(e.target.value)}
              required
            />
            <Mail size={20} color="var(--text-secondary)" style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)' }} />
          </div>

          <div style={{ position: 'relative', marginBottom: '16px' }}>
            <Input 
              type="password" 
              placeholder="Mật khẩu" 
              style={{ paddingLeft: '40px' }} 
              value={password}
              onChange={(e: any) => setPassword(e.target.value)}
              required
            />
            <Lock size={20} color="var(--text-secondary)" style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)' }} />
          </div>

          <div style={{ marginBottom: '24px' }}>
            <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)' }}>Vai trò:</label>
            <select 
              value={role} 
              onChange={(e: any) => setRole(e.target.value)}
              style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid #ccc' }}
            >
              <option value="R002">Học viên (Learner)</option>
              <option value="R003">Giảng viên (Mentor)</option>
              <option value="R004">Người tạo nội dung (Content Creator)</option>
            </select>
          </div>

          <Button type="submit" style={{ width: '100%' }}>Đăng ký</Button>
        </form>

        <div style={{ textAlign: 'center', marginTop: '24px', fontSize: '14px', color: 'var(--text-secondary)' }}>
          Đã có tài khoản?{' '}
          <Link to="/login" style={{ color: 'var(--primary)', fontWeight: 600, textDecoration: 'none' }}>Đăng nhập</Link>
        </div>
      </Card>
    </div>
  );
};
