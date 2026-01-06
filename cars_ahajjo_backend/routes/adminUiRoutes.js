const express = require('express');
const { requireAdmin } = require('../middleware/auth');
const router = express.Router();

// Demo login page with Admin Panel button after default actions
router.get('/login', (req, res) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.send(`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Login</title>
  <style>
    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif; background:#f7f7f8; margin:0; padding:40px; }
    .card { max-width: 420px; margin: 0 auto; background: #fff; border:1px solid #e5e7eb; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
    .card-header { padding: 20px 24px; border-bottom:1px solid #e5e7eb; }
    .card-body { padding: 20px 24px; }
    h1 { font-size: 18px; margin:0 0 6px; }
    p { margin:0; color:#6b7280; font-size: 13px; }
    .actions { display:flex; flex-direction: column; gap:10px; margin-top: 16px; }
    button { height: 40px; border-radius:8px; border:1px solid #d1d5db; background:#fff; cursor:pointer; font-weight:600; }
    button.primary { background:#111827; color:#fff; border-color:#111827; }
    .sep { margin: 12px 0; height:1px; background:#e5e7eb; }
    .hint { font-size: 12px; color:#6b7280; margin-top: 8px; }
  </style>
</head>
<body>
  <div class="card">
    <div class="card-header">
      <h1>Sign in</h1>
      <p>Demo page for admin access button placement.</p>
    </div>
    <div class="card-body">
      <div class="actions">
        <button class="primary" onclick="alert('Implement your normal sign-in flow here')">Sign in</button>
        <button onclick="alert('Implement your account creation flow here')">Create a new account</button>
      </div>
      <div class="sep"></div>
      <div class="actions">
        <!-- Admin Panel button placed AFTER the create account button -->
        <button id="adminButton" class="primary">Admin Panel</button>
        <div class="hint">Uses admin email 'rabbanihosni10@gmail.com' and password '123'.</div>
      </div>
      <script>
        document.getElementById('adminButton').addEventListener('click', async () => {
          try {
            const res = await fetch('/api/auth/login', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ email: 'rabbanihosni10@gmail.com', password: '123' })
            });
            const data = await res.json();
            if (data && data.token) {
              localStorage.setItem('token', data.token);
              // Navigate to admin panel (protected)
              window.location.href = '/admin-ui/panel';
            } else {
              alert(data.message || 'Admin login failed');
            }
          } catch (e) {
            alert('Network error: ' + e.message);
          }
        });
      </script>
    </div>
  </div>
</body>
</html>
  `);
});

// Simple protected admin panel page
router.get('/panel', requireAdmin, (req, res) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.send(`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Admin Panel</title>
  <style>
    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif; background:#f7f7f8; margin:0; padding:40px; }
    .card { max-width: 640px; margin: 0 auto; background: #fff; border:1px solid #e5e7eb; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); padding: 24px; }
    h1 { font-size: 22px; margin:0 0 8px; }
    p { margin:0 0 12px; color:#374151; }
    pre { background:#f3f4f6; border:1px solid #e5e7eb; padding:12px; border-radius:8px; overflow:auto; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Welcome, Admin</h1>
    <p>Your token is stored in localStorage and validated server-side.</p>
    <p>Dashboard stats:</p>
    <pre id="stats">Loading...</pre>
    <div style="margin-top:12px; display:flex; gap:8px;">
      <a href="/api/admin/dashboard/stats" target="_blank">Raw Stats API</a>
      <a href="/api/admin/transactions" target="_blank">Transactions</a>
      <a href="/api/admin/ratings" target="_blank">Ratings</a>
      <a href="/api/admin/logs" target="_blank">Logs</a>
    </div>
  </div>
  <script>
    (async function(){
      try {
        const token = localStorage.getItem('token');
        const res = await fetch('/api/admin/dashboard/stats', {
          headers: { Authorization: 'Bearer ' + token }
        });
        const data = await res.json();
        document.getElementById('stats').textContent = JSON.stringify(data, null, 2);
      } catch (e) {
        document.getElementById('stats').textContent = 'Failed to load stats: ' + e.message;
      }
    })();
  </script>
</body>
</html>
  `);
});

module.exports = router;
