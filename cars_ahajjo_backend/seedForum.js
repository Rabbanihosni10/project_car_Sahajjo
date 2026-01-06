// Seed forum posts with sample data
const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const ForumPost = require('./models/forumPost');
const User = require('./models/user');

const seedForumPosts = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/car_sahajjo');

    console.log('Connected to MongoDB');

    // Clear existing posts
    await ForumPost.deleteMany({});
    console.log('Cleared existing forum posts');

    // Get a sample user (driver) to use as author
    let sampleUser = await User.findOne({ role: 'driver' });

    if (!sampleUser) {
      console.log('No driver found, creating a sample driver for forum posts...');
      sampleUser = new User({
        name: 'Ahmed Driver',
        email: 'ahmed@example.com',
        phone: '01700000001',
        password: 'hashed_password_here',
        role: 'driver',
        licenseNumber: 'DL123456',
        vehicleType: 'Sedan',
        yearsOfExperience: 5,
      });
      await sampleUser.save();
      console.log('Sample driver created');
    }

    // Sample forum posts
    const samplePosts = [
      {
        authorId: sampleUser._id,
        title: 'Best maintenance tips for fuel efficiency',
        content: 'I have been driving for 5 years and here are some tips that helped me improve my fuel efficiency. Regular tire pressure checks, proper wheel alignment, and using quality fuel have made a significant difference in my mileage.',
        category: 'tips',
        tags: ['fuel-efficiency', 'maintenance', 'tips'],
        likeCount: 12,
      },
      {
        authorId: sampleUser._id,
        title: 'Safe driving during monsoon season',
        content: 'The monsoon season requires extra caution. Ensure your tires have good tread, keep a safe distance from other vehicles, and avoid flooded roads. Your safety is more important than being on time.',
        category: 'tips',
        tags: ['safety', 'monsoon', 'weather'],
        likeCount: 8,
      },
      {
        authorId: sampleUser._id,
        title: 'Recommended routes to avoid traffic in Dhaka',
        content: 'I usually take the Gulshan to Banani route via Ring Road during peak hours. It saves me about 15 minutes compared to the main roads. What routes do you all prefer?',
        category: 'general',
        tags: ['dhaka', 'traffic', 'routes'],
        likeCount: 15,
      },
      {
        authorId: sampleUser._id,
        title: 'Experience with car rentals - What to check',
        content: 'When renting a car, always check the fuel level, tire condition, and existing damages before taking the vehicle. Take photos and get them documented. This saved me from disputes later.',
        category: 'marketplace',
        tags: ['rentals', 'documentation', 'checklist'],
        likeCount: 10,
      },
      {
        authorId: sampleUser._id,
        title: 'Finding reliable repair shops near your area',
        content: 'Finding a trustworthy mechanic is crucial. Ask friends for recommendations and check online reviews. I have been going to Ali\'s garage in Mirpur for 2 years now and they never disappointed me.',
        category: 'tips',
        tags: ['repair', 'mechanics', 'recommendations'],
        likeCount: 14,
      },
      {
        authorId: sampleUser._id,
        title: 'New driving rules and regulations 2024',
        content: 'The traffic police have introduced new fines for traffic violations. Make sure you are aware of the updated speed limits and parking regulations to avoid penalties.',
        category: 'announcements',
        tags: ['rules', 'regulations', 'legal'],
        likeCount: 9,
      },
    ];

    // Create posts
    const createdPosts = await ForumPost.insertMany(samplePosts);
    console.log(`Created ${createdPosts.length} sample forum posts`);

    console.log('Forum seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding forum posts:', error);
    process.exit(1);
  }
};

seedForumPosts();
