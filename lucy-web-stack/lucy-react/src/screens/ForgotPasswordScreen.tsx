import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Card } from '../components/Card';
import { Input } from '../components/Input';
import { Button } from '../components/Button';
import { Mail, Key, Lock, ArrowLeft } from 'lucide-react';

export const ForgotPasswordScreen: React.FC = () => {
  const navigate = useNavigate();
  const [step, setStep] = useState(1); // 1: Nhập Email, 2: Nhập Key, 3: Mật khẩu mới
  const [email, setEmail] = useState('');
  const [key, setKey] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Bước 1: Yêu cầu gửi mã xác nhận về Email
  const handleRequestKey = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim()) return;
    setIsSubmitting(true);
    try {
      const res = await fetch('http://localhost:8081/api/auth/forgot-password/request', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email })
      });
      if (res.ok) {
        alert("Mã xác nhận (Key) đã được xử lý! Vui lòng kiểm tra Email.");
        setStep(2);
      } else {
        const err = await res.json();
        alert(err.message || "Email không tồn tại trên hệ thống");
      }
    } catch (err) {
      alert("Lỗi kết nối Server");
    } finally {
      setIsSubmitting(false);
    }
  };

  // Bước 2: Kiểm tra mã Key vừa nhận được
  const handleVerifyKey = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!key.trim()) return;
    setIsSubmitting(true);
    try {
      const res = await fetch('http://localhost:8081/api/auth/forgot-password/verify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, key })
      });
      if (res.ok) {
        alert("Mã xác nhận chính xác! Hãy thiết lập mật khẩu mới.");
        setStep(3);
      } else {
        const err = await res.json();
        alert(err.message || "Mã xác nhận không đúng");
      }
    } catch (err) {
      alert("Lỗi kết nối Server");
    } finally {
      setIsSubmitting(false);
    }
  };

  // Bước 3: Gửi mật khẩu mới lên để lưu trữ
  const handleResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    if (newPassword !== confirmPassword) {
      alert("Mật khẩu xác nhận không khớp!");
      return;
    }
    setIsSubmitting(true);
    try {
      const res = await fetch('http://localhost:8081/api/auth/forgot-password/reset', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, key, newPassword })
      });
      if (res.ok) {
        alert("Cập nhật mật khẩu thành công! Vui lòng đăng nhập lại.");
        navigate('/login');
      } else {
        const err = await res.json();
        alert(err.message || "Không thể đổi mật khẩu");
      }
    } catch (err) {
      alert("Lỗi kết nối Server");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '100vh', padding: '20px' }}>
      <Card style={{ maxWidth: '400px', width: '100%', padding: '40px 24px' }}>
        <div style={{ textAlign: 'center', marginBottom: '32px' }}>
          <h1 style={{ color: 'var(--primary)', fontSize: '2rem', marginBottom: '8px' }}>LUCY</h1>
          <p style={{ color: 'var(--text-secondary)' }}>
            {step === 1 && "Phục hồi mật khẩu"}
            {step === 2 && "Xác minh danh tính"}
            {step === 3 && "Đặt mật khẩu mới"}
          </p>
        </div>

        {/* BƯỚC 1: NHẬP EMAIL */}
        {step === 1 && (
          <form onSubmit={handleRequestKey}>
            <div style={{ position: 'relative' }}>
              <Input
                type="email"
                placeholder="Nhập địa chỉ Email"
                style={{ paddingLeft: '40px' }}
                value={email}
                onChange={(e: any) => setEmail(e.target.value)}
                required
              />
              <Mail
                size={20}
                color="var(--text-secondary)"
                style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)' }}
              />
            </div>
            <Button type="submit" disabled={isSubmitting} style={{ width: '100%', marginTop: '24px' }}>
              Gửi mã xác nhận
            </Button>
          </form>
        )}

        {/* BƯỚC 2: NHẬP KEY XÁC MINH */}
        {step === 2 && (
          <form onSubmit={handleVerifyKey}>
            <div style={{ position: 'relative' }}>
              <Input
                type="text"
                placeholder="Nhập mã xác nhận (Key)"
                style={{ paddingLeft: '40px' }}
                value={key}
                onChange={(e: any) => setKey(e.target.value)}
                required
              />
              <Key
                size={20}
                color="var(--text-secondary)"
                style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)' }}
              />
            </div>
            <Button type="submit" disabled={isSubmitting} style={{ width: '100%', marginTop: '24px' }}>
              Xác nhận mã số
            </Button>
          </form>
        )}

        {/* BƯỚC 3: THIẾT LẬP MẬT KHẨU MỚI */}
        {step === 3 && (
          <form onSubmit={handleResetPassword}>
            <div style={{ position: 'relative' }}>
              <Input
                type="password"
                placeholder="Mật khẩu mới"
                style={{ paddingLeft: '40px' }}
                value={newPassword}
                onChange={(e: any) => setNewPassword(e.target.value)}
                required
              />
              <Lock
                size={20}
                color="var(--text-secondary)"
                style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)' }}
              />
            </div>

            <div style={{ position: 'relative', marginTop: '16px' }}>
              <Input
                type="password"
                placeholder="Xác nhận mật khẩu mới"
                style={{ paddingLeft: '40px' }}
                value={confirmPassword}
                onChange={(e: any) => setConfirmPassword(e.target.value)}
                required
              />
              <Lock
                size={20}
                color="var(--text-secondary)"
                style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)' }}
              />
            </div>
            <Button type="submit" disabled={isSubmitting} style={{ width: '100%', marginTop: '24px' }}>
              Thay đổi mật khẩu
            </Button>
          </form>
        )}

        <div style={{ textAlign: 'center', marginTop: '24px', fontSize: '14px' }}>
          <Link to="/login" style={{ color: 'var(--primary)', fontWeight: 600, textDecoration: 'none', display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
            <ArrowLeft size={16} /> Quay lại đăng nhập
          </Link>
        </div>
      </Card>
    </div>
  );
};
