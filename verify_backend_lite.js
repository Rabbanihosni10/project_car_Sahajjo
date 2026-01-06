const http = require('http');

const endpoints = [
    { path: '/', name: 'Root' },
    { path: '/api/jobs', name: 'Jobs API' },
    { path: '/api/marketplace/products', name: 'Marketplace API' },
    { path: '/api/forum/posts', name: 'Forum API' }
];

console.log('Starting Connectivity Check...');

let completed = 0;

endpoints.forEach(ep => {
    const options = {
        hostname: 'localhost',
        port: 5003,
        path: ep.path,
        method: 'GET',
        timeout: 3000
    };

    const req = http.request(options, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
            console.log(`[PASS] ${ep.name}: Status ${res.statusCode}`);
            completed++;
            if (completed === endpoints.length) process.exit(0);
        });
    });

    req.on('error', (e) => {
        console.log(`[FAIL] ${ep.name}: ${e.message}`);
        completed++;
        if (completed === endpoints.length) process.exit(1);
    });

    req.on('timeout', () => {
        req.destroy();
        console.log(`[TIMEOUT] ${ep.name}`);
        completed++;
        if (completed === endpoints.length) process.exit(1);
    });

    req.end();
});
