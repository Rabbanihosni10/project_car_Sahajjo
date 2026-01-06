// Comprehensive backend connectivity test
const http = require('http');

const testEndpoint = (url, name) => {
  return new Promise((resolve) => {
    const req = http.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          const count = Array.isArray(json.data) ? json.data.length : 'N/A';
          console.log(`✅ ${name.padEnd(25)} | Status: ${res.statusCode} | Count: ${count}`);
          resolve({ success: true, name, count });
        } catch (e) {
          console.log(`⚠️  ${name.padEnd(25)} | Status: ${res.statusCode} | Response: ${data.substring(0, 50)}`);
          resolve({ success: false, name });
        }
      });
    });
    req.on('error', (err) => {
      console.log(`❌ ${name.padEnd(25)} | Error: ${err.message}`);
      resolve({ success: false, name, error: err.message });
    });
    req.setTimeout(3000, () => {
      req.destroy();
      console.log(`⏱️  ${name.padEnd(25)} | Timeout`);
      resolve({ success: false, name, error: 'Timeout' });
    });
  });
};

(async () => {
  console.log('\n=== TESTING ALL BACKEND APIS ===\n');
  console.log('Endpoint'.padEnd(27) + '| Status & Data Count\n' + '─'.repeat(60));
  
  const tests = [
    // Core features
    { url: 'http://localhost:5003/api/forum/posts', name: 'Forum Posts' },
    { url: 'http://localhost:5003/api/jobs', name: 'Job Posts' },
    { url: 'http://localhost:5003/api/marketplace/products', name: 'Marketplace Products' },
    
    // Requires auth - will show structure
    { url: 'http://localhost:5003/api/people/discover', name: 'People Discovery' },
    { url: 'http://localhost:5003/api/messages', name: 'Messages' },
    { url: 'http://localhost:5003/api/notifications', name: 'Notifications' },
    { url: 'http://localhost:5003/api/drivers', name: 'Drivers' },
    { url: 'http://localhost:5003/api/garages', name: 'Garages' },
    { url: 'http://localhost:5003/api/rides', name: 'Rides' },
    { url: 'http://localhost:5003/api/rentals', name: 'Rentals' },
  ];

  const results = [];
  for (const test of tests) {
    const result = await testEndpoint(test.url, test.name);
    results.push(result);
  }

  console.log('\n' + '─'.repeat(60));
  const successful = results.filter(r => r.success).length;
  const failed = results.filter(r => !r.success).length;
  
  console.log(`\n📊 Summary: ${successful} working | ${failed} require auth/setup`);
  
  // Check database collections
  console.log('\n=== CHECKING DATABASE ===\n');
  const mongoose = require('mongoose');
  require('dotenv').config();
  
  try {
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/cars_ahajjo');
    const db = mongoose.connection.db;
    const collections = await db.listCollections().toArray();
    
    console.log('Collections in database:');
    for (const col of collections) {
      const count = await db.collection(col.name).countDocuments();
      const status = count > 0 ? '✅' : '⚠️';
      console.log(`${status} ${col.name.padEnd(20)} | ${count} documents`);
    }
    
    await mongoose.disconnect();
  } catch (e) {
    console.log('❌ Database connection failed:', e.message);
  }

  console.log('\n✅ All tests completed!\n');
  process.exit(0);
})();
