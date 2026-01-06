// Check connections and user roles in database
const mongoose = require('mongoose');
require('dotenv').config();

const User = require('./models/user');
const Connection = require('./models/connection');

async function checkConnections() {
  try {
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/carsahajjo');
    console.log('✅ Connected to MongoDB\n');

    // Get all users
    const users = await User.find({}).select('name email role').lean();
    console.log('📋 All Users:');
    console.log('═'.repeat(60));
    users.forEach(user => {
      console.log(`  ${user.name.padEnd(20)} | ${user.role.padEnd(10)} | ${user._id}`);
    });
    
    console.log('\n📊 Role Summary:');
    const roleCounts = users.reduce((acc, user) => {
      acc[user.role] = (acc[user.role] || 0) + 1;
      return acc;
    }, {});
    Object.entries(roleCounts).forEach(([role, count]) => {
      console.log(`  ${role}: ${count}`);
    });

    // Get all connections
    const connections = await Connection.find({})
      .populate('initiatorId', 'name role')
      .populate('recipientId', 'name role')
      .lean();
    
    console.log('\n🔗 All Connections:');
    console.log('═'.repeat(60));
    
    if (connections.length === 0) {
      console.log('  ⚠️  NO CONNECTIONS FOUND!');
      console.log('\n💡 Solution: Create connections between drivers and owners');
      console.log('   Run: node cars_ahajjo_backend/seedConnections.js');
    } else {
      connections.forEach(conn => {
        const initiator = conn.initiatorId?.name || 'Unknown';
        const initiatorRole = conn.initiatorId?.role || '?';
        const recipient = conn.recipientId?.name || 'Unknown';
        const recipientRole = conn.recipientId?.role || '?';
        const statusIcon = conn.status === 'accepted' ? '✅' : 
                          conn.status === 'pending' ? '⏳' :
                          conn.status === 'rejected' ? '❌' : '🚫';
        
        console.log(`  ${statusIcon} ${initiator} (${initiatorRole}) ↔ ${recipient} (${recipientRole}) [${conn.status}]`);
      });
      
      console.log('\n📊 Connection Status Summary:');
      const statusCounts = connections.reduce((acc, conn) => {
        acc[conn.status] = (acc[conn.status] || 0) + 1;
        return acc;
      }, {});
      Object.entries(statusCounts).forEach(([status, count]) => {
        console.log(`  ${status}: ${count}`);
      });
    }

    // Check for driver-owner pairs
    const drivers = users.filter(u => u.role === 'driver');
    const owners = users.filter(u => u.role === 'owner');
    
    console.log('\n👥 Available for Connection:');
    console.log(`  Drivers: ${drivers.length}`);
    console.log(`  Owners: ${owners.length}`);
    
    if (drivers.length === 0 || owners.length === 0) {
      console.log('\n⚠️  WARNING: Need both drivers and owners for messaging!');
      console.log('   Current users may not have the correct roles.');
    }

    // Find accepted driver-owner connections
    const acceptedConnections = connections.filter(c => 
      c.status === 'accepted' && 
      c.initiatorId && c.recipientId &&
      ((c.initiatorId.role === 'driver' && c.recipientId.role === 'owner') ||
       (c.initiatorId.role === 'owner' && c.recipientId.role === 'driver'))
    );
    
    console.log('\n✅ Accepted Driver-Owner Connections (Can Message):');
    if (acceptedConnections.length === 0) {
      console.log('  ⚠️  NO ACCEPTED DRIVER-OWNER CONNECTIONS!');
      console.log('\n📝 To Fix:');
      console.log('  1. Ensure users have correct roles (driver/owner)');
      console.log('  2. Create connection requests between them');
      console.log('  3. Accept the connection requests');
    } else {
      acceptedConnections.forEach(conn => {
        console.log(`  ✅ ${conn.initiatorId.name} ↔ ${conn.recipientId.name}`);
      });
    }

    mongoose.connection.close();
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

checkConnections();
