const express = require('express');
const router = express.Router();

// Simple Home Page with Login + Admin Panel buttons
router.get('/', (req, res) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.send(`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Car Sahajjo - Home</title>
  <style>
    :root { --primary:#111827; --border:#e5e7eb; --text:#374151; --muted:#6b7280; --bg:#f7f7f8; --accent:#f59e0b; }
    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif; background: var(--bg); margin:0; padding:40px; }
    .card { max-width: 720px; margin: 0 auto; background: #fff; border:1px solid var(--border); border-radius: 12px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
    .card-header { padding: 20px 24px; border-bottom:1px solid var(--border); }
    .card-body { padding: 20px 24px; }
    h1 { font-size: 22px; margin:0 0 6px; }
    p { margin:0; color: var(--muted); font-size: 14px; }
    .row { display:flex; gap:12px; flex-wrap:wrap; margin-top:16px; }
    button, a.button { display:inline-flex; align-items:center; justify-content:center; height: 40px; padding:0 16px; border-radius:8px; border:1px solid var(--border); background:#fff; cursor:pointer; font-weight:600; text-decoration:none; color:var(--text); }
    .primary { background: var(--primary); color:#fff; border-color: var(--primary); }
    .admin { background: linear-gradient(135deg, var(--accent), #f97316); color:#fff; border:none; }
    .hint { font-size: 12px; color: var(--muted); margin-top: 6px; }
    .sep { height:1px; background:var(--border); margin:16px 0; }
  </style>
</head>
<body>
  <div class="card">
    <div class="card-header">
      <h1>Car Sahajjo</h1>
      <p>Quick access to Login and Admin Panel.</p>
    </div>
    <div class="card-body">
      <div class="row">
        <a class="button primary" href="/admin-ui/login">Login</a>
        <!-- Admin Panel button placed beside Login button -->
        <button id="adminBtn" class="admin">Admin Panel</button>
      </div>
      <div class="hint">Admin: rabbanihosni10@gmail.com / 123</div>
      <div class="sep"></div>
      <p>API quick links:</p>
      <div class="row">
        <a class="button" href="/api/admin/health" target="_blank">Platform Health</a>
        <a class="button" href="/api/garages" target="_blank">Garages</a>
        <a class="button" href="/api/forum/posts" target="_blank">Forum Posts</a>
      </div>
      <script>
        document.getElementById('adminBtn').addEventListener('click', async () => {
          try {
            const res = await fetch('/api/auth/login', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ email: 'rabbanihosni10@gmail.com', password: '123' })
            });
            const data = await res.json();
            if (data && data.token) {
              localStorage.setItem('token', data.token);
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

module.exports = router;
