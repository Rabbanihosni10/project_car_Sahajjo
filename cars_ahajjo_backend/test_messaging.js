// Test messaging between accepted driver-owner pairs
const axios = require('axios');

const BASE_URL = 'http://localhost:5003/api';

// Test users from database - accepted driver-owner connections
const testPairs = [
  { driver: '6951053a4d07a59a4d2d0980', driverName: 'kw', owner: '695112acd1783dd05f37916f', ownerName: 'rw' },
  { driver: '695358a410b5d93a035b8980', driverName: 'Hosni', owner: '69536be110b5d93a035b899e', ownerName: 'Tarequl' },
  { driver: '69535eed10b5d93a035b898a', driverName: 'Noha', owner: '695112acd1783dd05f37916f', ownerName: 'rw' },
  { driver: '695366a310b5d93a035b898f', driverName: 'tr', owner: '6950eebfc80ad513c0fc72cb', ownerName: 'jw' },
];

async function testMessaging() {
  console.log('🧪 Testing Messaging Between Driver-Owner Pairs\n');
  console.log('Note: You need to login first to get auth tokens!\n');
  
  // You need to replace these with actual JWT tokens from login
  console.log('📝 Steps to test:');
  console.log('1. Login as a driver (e.g., kw)');
  console.log('2. Copy the JWT token from response');
  console.log('3. Use Postman or curl to send message:\n');
  
  testPairs.forEach((pair, index) => {
    console.log(`Test ${index + 1}: ${pair.driverName} (driver) → ${pair.ownerName} (owner)`);
    console.log(`POST ${BASE_URL}/messages/send`);
    console.log(`Headers: { "Authorization": "Bearer YOUR_TOKEN" }`);
    console.log(`Body: {
  "receiverId": "${pair.owner}",
  "message": "Hello from ${pair.driverName}!"
}`);
    console.log('');
  });
  
  console.log('\n🔑 To get auth token:');
  console.log(`POST ${BASE_URL}/auth/login`);
  console.log(`Body: {
  "email": "driver@email.com",
  "password": "password"
}`);
  
  console.log('\n\n📋 Accepted Driver-Owner Pairs (From Database):');
  console.log('═'.repeat(60));
  testPairs.forEach(pair => {
    console.log(`  ✅ ${pair.driverName.padEnd(15)} (${pair.driver.slice(-8)})`);
    console.log(`     ↔ ${pair.ownerName.padEnd(15)} (${pair.owner.slice(-8)})`);
    console.log('');
  });
}

testMessaging();
