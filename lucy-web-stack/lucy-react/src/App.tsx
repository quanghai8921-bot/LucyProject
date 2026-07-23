import { createContext, useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { LoginScreen } from './screens/LoginScreen';
import { RegisterScreen } from './screens/RegisterScreen';
import { LearnerHome } from './screens/LearnerHome';
import { MentorHome } from './screens/MentorHome';
import { AdminUsersScreen } from './screens/AdminUsersScreen';
import { LiveRoomScreen } from './screens/LiveRoomScreen';
import { LearnerProfileScreen } from './screens/LearnerProfileScreen';
import { MentorProfileScreen } from './screens/MentorProfileScreen';
import { CreatorHome } from './screens/CreatorHome';
import { ForgotPasswordScreen } from './screens/ForgotPasswordScreen';

export const AppContext = createContext<any>(null);

function App() {
  const [currentUser, setCurrentUser] = useState<any>(null);
  const [currentRole, setCurrentRole] = useState<string>('');

  useEffect(() => {
    // Optional: Load user from sessionStorage if token exists
  }, []);

  return (
    <AppContext.Provider value={{ currentUser, setCurrentUser, currentRole, setCurrentRole }}>
      <Router>
        <Routes>
          <Route path="/login" element={<LoginScreen />} />
          <Route path="/register" element={<RegisterScreen />} />
          <Route path="/learner" element={<LearnerHome />} />
          <Route path="/mentor" element={<MentorHome />} />
          <Route path="/admin" element={<AdminUsersScreen />} />
          <Route path="/live-room/:roomId" element={<LiveRoomScreen />} />
          <Route path="/learner-profile" element={<LearnerProfileScreen />} />
          <Route path="/mentor-profile" element={<MentorProfileScreen />} />
          <Route path="/creator" element={<CreatorHome />} />
          <Route path="*" element={<Navigate to="/login" />} />
          {/* Các tuyến đường cũ của bạn */}
          <Route path="/login" element={<LoginScreen />} />
          <Route path="/register" element={<RegisterScreen />} />

          {/* 🌟 THÊM DÒNG NÀY ĐỂ KÍCH HOẠT CHUYỂN TRANG */}
          <Route path="/forgot-password" element={<ForgotPasswordScreen />} />

          <Route path="/learner" element={<LearnerHome />} />
          <Route path="/mentor" element={<MentorHome />} />
        </Routes>
      </Router>
    </AppContext.Provider>
  );
}

export default App;
