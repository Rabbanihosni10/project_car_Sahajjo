import React, { useState } from 'react';
import './Login.css'; // Your existing styles

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // Normal sign-in handler
  const handleSignIn = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });
      const data = await res.json();
      if (data.token) {
        localStorage.setItem('token', data.token);
        // Navigate to dashboard or home page
        window.location.href = '/dashboard';
      } else {
        setError(data.message || 'Login failed');
      }
    } catch (e) {
      setError('Network error: ' + e.message);
    }
    setLoading(false);
  };

  // Admin panel login handler
  const handleAdminLogin = async () => {
    setLoading(true);
    setError('');
    try {
      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: 'rabbanihosni10@gmail.com',
          password: '123',
        }),
      });
      const data = await res.json();
      if (data.token) {
        localStorage.setItem('token', data.token);
        // Navigate to admin panel
        window.location.href = '/admin-ui/panel';
      } else {
        setError(data.message || 'Admin login failed');
      }
    } catch (e) {
      setError('Network error: ' + e.message);
    }
    setLoading(false);
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <h1>Sign in</h1>
        
        {error && <div className="error-message">{error}</div>}

        <form onSubmit={handleSignIn}>
          <div className="form-group">
            <label>Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Enter your email"
              required
            />
          </div>

          <div className="form-group">
            <label>Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Enter your password"
              required
            />
          </div>

          <button type="submit" disabled={loading} className="btn btn-primary">
            {loading ? 'Signing in...' : 'Sign in'}
          </button>
        </form>

        <div className="divider"></div>

        <button
          onClick={handleAdminLogin}
          disabled={loading}
          className="btn btn-secondary"
        >
          {loading ? 'Loading...' : 'Create a new account'}
        </button>

        {/* ADMIN PANEL BUTTON - Placed after Create a new account */}
        <div className="admin-section">
          <button
            onClick={handleAdminLogin}
            disabled={loading}
            className="btn btn-admin"
          >
            {loading ? 'Loading...' : 'Admin Panel'}
          </button>
          <p className="admin-hint">
            Email: <code>rabbanihosni10@gmail.com</code> | Password: <code>123</code>
          </p>
        </div>
      </div>
    </div>
  );
}
