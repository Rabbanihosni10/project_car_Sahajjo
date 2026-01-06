
const io = require('socket.io-client');

console.log('🧪 Testing Socket.io Connection...\n');

const socket = io('http://localhost:5003', {
  transports: ['websocket', 'polling'],
  reconnectionAttempts: 3,
  reconnectionDelay: 1000,
});

let pingInterval;
let startTime = Date.now();

socket.on('connect', () => {
  console.log('✅ Connected successfully!');
  console.log(`   Socket ID: ${socket.id}`);
  console.log(`   Transport: ${socket.io.engine.transport.name}`);
  
  socket.emit('user_identify', {
    userId: 'test-user-123',
    role: 'driver'
  });
  

  console.log('\n📡 Starting heartbeat (ping every 5 seconds)...\n');
  let pingCount = 0;
  pingInterval = setInterval(() => {
    pingCount++;
    const elapsed = Math.floor((Date.now() - startTime) / 1000);
    console.log(`[${elapsed}s] Ping #${pingCount}`);
    socket.emit('ping');
  }, 5000);
  

  setTimeout(() => {
    console.log('\n✅ Test completed successfully! Connection stable for 60 seconds.');
    clearInterval(pingInterval);
    socket.disconnect();
    process.exit(0);
  }, 60000);
});

socket.on('pong', () => {
  const elapsed = Math.floor((Date.now() - startTime) / 1000);
  console.log(`   └─ [${elapsed}s] ✓ Pong received`);
});

socket.on('connect_error', (error) => {
  console.error('❌ Connection Error:', error.message);
  clearInterval(pingInterval);
  process.exit(1);
});

socket.on('connect_timeout', () => {
  console.error('⏱️  Connection Timeout');
  clearInterval(pingInterval);
  process.exit(1);
});

socket.on('disconnect', (reason) => {
  const elapsed = Math.floor((Date.now() - startTime) / 1000);
  console.log(`\n❌ Disconnected after ${elapsed} seconds. Reason: ${reason}`);
  clearInterval(pingInterval);
  
  if (reason === 'io server disconnect') {
    console.log('   Server disconnected the socket. This should not happen with the fix.');
  } else if (reason === 'transport close') {
    console.log('   Transport closed. Check network connection.');
  } else if (reason === 'ping timeout') {
    console.log('   Ping timeout. Server did not respond in time.');
  }
  
  process.exit(1);
});

socket.on('reconnect_attempt', (attempt) => {
  console.log(`🔄 Reconnection attempt #${attempt}`);
});

socket.on('reconnect', (attempt) => {
  console.log(`✅ Reconnected after ${attempt} attempts`);
  startTime = Date.now();
});

socket.on('reconnect_failed', () => {
  console.error('❌ Reconnection failed after all attempts');
  clearInterval(pingInterval);
  process.exit(1);
});

console.log('Connecting to http://localhost:5003...\n');
