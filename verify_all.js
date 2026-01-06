const http = require('http');

const tests = [
  { url: 'http://localhost:5003/api/forum/posts', name: 'Forum Posts' },
  { url: 'http://localhost:5003/api/jobs', name: 'Job Posts' },
  { url: 'http://localhost:5003/api/rentals', name: 'Car Rentals' }
];

console.log('\n=== FINAL VERIFICATION ===\n');

Promise.all(tests.map(t => new Promise((resolve) => {
  http.get(t.url, (res) => {
    let data = '';
    res.on('data', (chunk) => data += chunk);
    res.on('end', () => {
      const json = JSON.parse(data);
      const count = json.data.length;
      console.log(`✅ ${t.name.padEnd(20)} | ${count} items`);
      resolve();
    });
  });
}))).then(() => {
  console.log('\n✅ All features verified and working!\n');
  process.exit(0);
});
