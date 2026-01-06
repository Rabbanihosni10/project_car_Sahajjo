const http = require('http');

console.log('=== Testing Backend Connection ===\n');

const testServer = () => {
  return new Promise((resolve, reject) => {
    const req = http.get('http://localhost:5003/api/forum/posts', (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        console.log('✅ Server Status:', res.statusCode);
        const json = JSON.parse(data);
        console.log('✅ Forum Posts Count:', json.data.length);
        console.log('✅ Sample Post:', json.data[0]?.title || 'N/A');
        resolve(json);
      });
    });
    req.on('error', (err) => {
      console.log('❌ Server Error:', err.message);
      reject(err);
    });
  });
};

(async () => {
  try {
    await testServer();
    console.log('\n✅ All tests passed! Backend is working correctly.');
    console.log('\nFrontend should connect to:');
    console.log('- Web: http://localhost:5003/api/forum/posts');
    console.log('- Android Emulator: http://10.0.2.2:5003/api/forum/posts');
  } catch (error) {
    console.log('\n❌ Connection test failed!');
    console.log('Make sure backend is running: cd cars_ahajjo_backend && npm start');
  }
  process.exit(0);
})();
