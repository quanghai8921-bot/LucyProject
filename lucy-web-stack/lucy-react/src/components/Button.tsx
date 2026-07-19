import React from 'react';

export const Button: React.FC<React.ButtonHTMLAttributes<HTMLButtonElement>> = ({ children, style, ...props }) => (
  <button 
    style={{ 
      padding: '12px 24px', 
      background: 'var(--primary, #3B82F6)', 
      color: '#fff', 
      border: 'none', 
      borderRadius: '8px',
      fontSize: '1rem',
      fontWeight: '600',
      cursor: 'pointer',
      transition: 'background 0.2s',
      ...style 
    }} 
    {...props}
  >
    {children}
  </button>
);
