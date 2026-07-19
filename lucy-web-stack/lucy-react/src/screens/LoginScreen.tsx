import React from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Card } from '../components/Card';
import { Input } from '../components/Input';
import { Button } from '../components/Button';
import { Lock, User } from 'lucide-react';
import { AppContext } from '../App';

export const LoginScreen: React.FC = () => {
  const navigate = useNavigate();
  const { setCurrentRole, setCurrentUser } = React.useContext(AppContext);
  const [email, setEmail] = React.useState('');
  const [password, setPassword] = React.useState('');

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const res = await fetch('http://localhost:8081/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      });
      if (res.ok) {
        const result = await res.json();
        const payload = result.data || result;

        let targetRole = 'learner';
        let path = '/learner';
        // handle roles correctly based on number or string
        const roleVal = payload.role || (payload.roles && payload.roles[0]);
        if (roleVal === 'R001' || roleVal === 1 || roleVal === 'admin') { targetRole = 'admin'; path = '/admin'; }
        else if (roleVal === 'R002' || roleVal === 2) { targetRole = 'learner'; path = '/learner'; }
        else if (roleVal === 'R003' || roleVal === 3) { targetRole = 'mentor'; path = '/mentor'; }
        else if (roleVal === 'R004' || roleVal === 4) { targetRole = 'creator'; path = '/creator'; }

        setCurrentRole(targetRole);
        localStorage.setItem('currentRole', targetRole);
        localStorage.setItem('token', payload.token || result.token || '');
        setCurrentUser({ id: payload.userId || 'U002', fullName: email.split('@')[0], email, role: payload.role || (payload.roles && payload.roles[0]) || 'R002' });

        navigate(path);
      } else {
        const errorResult = await res.json();
        alert(errorResult.message || "Sai email hoặc mật khẩu");
      }
    } catch (err) {
      alert("Lỗi kết nối Server");
    }
  };

  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '100vh', padding: '20px' }}>
      <Card style={{ maxWidth: '400px', width: '100%', padding: '40px 24px' }}>
        <div style={{ textAlign: 'center', marginBottom: '32px' }}>
          <h1 style={{ color: 'var(--primary)', fontSize: '2rem', marginBottom: '8px' }}>LUCY</h1>
          <p style={{ color: 'var(--text-secondary)' }}>Sign in to continue</p>
        </div>

        <form onSubmit={handleLogin}>
          <div style={{ position: 'relative' }}>
            <Input
              type="text"
              placeholder="Username or Email"
              style={{ paddingLeft: '40px' }}
              value={email}
              onChange={(e: any) => setEmail(e.target.value)}
            />
            <User
              size={20}
              color="var(--text-secondary)"
              style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)' }}
            />
          </div>

          <div style={{ position: 'relative', marginTop: '16px' }}>
            <Input
              type="password"
              placeholder="Password"
              style={{ paddingLeft: '40px' }}
              value={password}
              onChange={(e: any) => setPassword(e.target.value)}
            />
            <Lock
              size={20}
              color="var(--text-secondary)"
              style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)' }}
            />
          </div>

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', margin: '16px 0 24px' }}>
            <label style={{ display: 'flex', alignItems: 'center', color: 'var(--text-secondary)', fontSize: '14px', cursor: 'pointer' }}>
              <input type="checkbox" style={{ marginRight: '8px' }} />
              Remember me
            </label>
            <Link to="/forgot-password" style={{ color: 'var(--primary)', fontSize: '14px', fontWeight: 500, textDecoration: 'none' }}>Forgot password?</Link>
          </div>

          <Button type="submit" style={{ width: '100%' }}>Login</Button>
        </form>

        <div style={{ textAlign: 'center', marginTop: '24px', fontSize: '14px', color: 'var(--text-secondary)' }}>
          Chưa có tài khoản?{' '}
          <Link to="/register" style={{ color: 'var(--primary)', fontWeight: 600, textDecoration: 'none' }}>Đăng ký ngay</Link>
        </div>
      </Card>
    </div>
  );
};
