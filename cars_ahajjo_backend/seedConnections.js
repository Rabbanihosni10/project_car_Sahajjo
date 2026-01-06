const mongoose = require('mongoose');
const dotenv = require('dotenv');
const connectMongo = require('./config/db');
const User = require('./models/user');
const Connection = require('./models/connection');
const UserProfile = require('./models/userProfile');

dotenv.config();
connectMongo();

const seedConnections = async () => {
  try {
    console.log('Starting to seed connections...');

    // Get all users
    const users = await User.find().select('_id name email');
    console.log(`Found ${users.length} users`);

    if (users.length < 2) {
      console.log('Not enough users to create connections');
      process.exit(0);
    }

    // Clear existing connections
    await Connection.deleteMany({});
    await UserProfile.deleteMany({});
    console.log('Cleared existing connections and profiles');

    // Create user profiles for all users
    const profiles = [];
    users.forEach(user => {
      profiles.push({
        userId: user._id,
        bio: `I am ${user.name}. I love cars and connecting with people.`,
        avatar: `https://ui-avatars.com/api/?name=${user.name}&background=random`,
        location: ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'][
          Math.floor(Math.random() * 5)
        ],
        profession: ['Driver', 'Car Owner', 'Mechanic', 'Dealer'][
          Math.floor(Math.random() * 4)
        ],
        website: `https://${user.name.toLowerCase().replace(/\s/g, '')}.com`,
        interests: ['Cars', 'Driving', 'Networking', 'Community', 'Technology'].slice(
          0,
          Math.floor(Math.random() * 4) + 2
        ),
        followerCount: 0,
        followingCount: 0,
        friendCount: 0,
        isProfilePublic: true,
        allowDirectMessages: true,
        allowConnectionRequests: true,
      });
    });

    const createdProfiles = await UserProfile.insertMany(profiles);
    console.log(`Created ${createdProfiles.length} user profiles`);

    // Create connections between users
    const connections = [];
    const connectionTypes = ['friend', 'colleague', 'community'];
    const statuses = ['accepted', 'accepted', 'accepted', 'pending', 'pending'];

    // Create 5-8 connections per user
    users.forEach((user, index) => {
      const connectionCount = Math.floor(Math.random() * 4) + 5; // 5-8 connections

      for (let i = 0; i < connectionCount; i++) {
        let randomUserIndex = Math.floor(Math.random() * users.length);

        // Make sure we don't connect a user with themselves
        while (randomUserIndex === index) {
          randomUserIndex = Math.floor(Math.random() * users.length);
        }

        const connection = {
          initiatorId: user._id,
          recipientId: users[randomUserIndex]._id,
          status: statuses[Math.floor(Math.random() * statuses.length)],
          connectionType: connectionTypes[Math.floor(Math.random() * connectionTypes.length)],
          isFollowing: Math.random() > 0.5,
          requestedAt: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000), // Random date in last 30 days
          acceptedAt:
            Math.random() > 0.3
              ? new Date(Date.now() - Math.random() * 20 * 24 * 60 * 60 * 1000)
              : null,
        };

        // Check if reverse connection doesn't exist
        const reverseExists = connections.some(
          c =>
            c.initiatorId.toString() === randomUserIndex.toString() &&
            c.recipientId.toString() === user._id.toString()
        );

        if (!reverseExists) {
          connections.push(connection);
        }
      }
    });

    // Insert unique connections
    const uniqueConnections = [];
    const seen = new Set();

    connections.forEach(conn => {
      const key = [
        conn.initiatorId.toString(),
        conn.recipientId.toString(),
      ]
        .sort()
        .join('-');

      if (!seen.has(key)) {
        seen.add(key);
        uniqueConnections.push(conn);
      }
    });

    const insertedConnections = await Connection.insertMany(uniqueConnections);
    console.log(`Created ${insertedConnections.length} connections`);

    // Update follower/friend counts in profiles
    for (const profile of createdProfiles) {
      const userConnections = await Connection.find({
        $or: [
          { initiatorId: profile.userId, status: 'accepted' },
          { recipientId: profile.userId, status: 'accepted' },
        ],
      });

      const followers = userConnections.filter(
        conn => conn.recipientId.toString() === profile.userId.toString() && conn.isFollowing
      ).length;

      const following = userConnections.filter(
        conn => conn.initiatorId.toString() === profile.userId.toString() && conn.isFollowing
      ).length;

      const friends = userConnections.filter(
        conn =>
          conn.status === 'accepted' &&
          (conn.connectionType === 'friend' || conn.connectionType === 'colleague')
      ).length;

      profile.followerCount = followers;
      profile.followingCount = following;
      profile.friendCount = friends;

      await profile.save();
    }

    console.log('✅ Seeding completed successfully!');
    console.log(`Total profiles: ${createdProfiles.length}`);
    console.log(`Total connections: ${insertedConnections.length}`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding connections:', error);
    process.exit(1);
  }
};

// Run the seed
seedConnections();
