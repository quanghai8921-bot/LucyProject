import React from 'react';

export const Input: React.FC<React.InputHTMLAttributes<HTMLInputElement>> = ({ style, ...props }) => (
  <input 
    style={{ 
      width: '100%', 
      padding: '12px 16px', 
      borderRadius: '8px', 
      border: '1px solid #E5E7EB',
      outline: 'none',
      fontSize: '1rem',
      boxSizing: 'border-box',
      ...style 
    }} 
    {...props} 
  />
);
