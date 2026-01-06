// Seed job posts with sample data
const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const JobPost = require('./models/jobPost');
const User = require('./models/user');

const seedJobPosts = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/car_sahajjo');

    console.log('Connected to MongoDB');

    // Clear existing jobs
    await JobPost.deleteMany({});
    console.log('Cleared existing job posts');

    // Get a sample user (owner) to use as author
    let sampleOwner = await User.findOne({ role: 'owner' });

    if (!sampleOwner) {
      console.log('No owner found, creating a sample owner for job posts...');
      sampleOwner = new User({
        name: 'John Owner',
        email: 'owner@example.com',
        phone: '01800000001',
        password: 'hashed_password_here',
        role: 'owner',
        companyName: 'Prime Rides',
        numberOfCars: 10,
      });
      await sampleOwner.save();
      console.log('Sample owner created');
    }

    // Sample job posts
    const sampleJobs = [
      {
        ownerId: sampleOwner._id,
        title: 'Experienced Driver Needed for Dhaka City Routes',
        description: 'Looking for an experienced driver for daily commute routes in Dhaka. Must have 3+ years experience and valid license. Good salary and benefits.',
        carModel: 'Toyota Prius 2023',
        location: {
          address: 'Dhaka',
          latitude: 23.8103,
          longitude: 90.4125,
        },
        salary: 35000,
        salaryType: 'monthly',
        jobType: 'full_time',
        experience: '3+ years',
        licenseType: 'Professional',
        workingHours: '6:00 AM - 6:00 PM',
        requirements: ['Valid driving license', '3+ years experience', 'Good driving record'],
        perks: ['Fixed salary', 'Fuel allowance', 'Health insurance'],
        status: 'open',
      },
      {
        ownerId: sampleOwner._id,
        title: 'Part-time Driver for Weekend Trips',
        description: 'Need a reliable driver for weekend trips. Flexible hours. Good pay.',
        carModel: 'Honda Accord 2022',
        location: {
          address: 'Mirpur, Dhaka',
          latitude: 23.8223,
          longitude: 90.3654,
        },
        salary: 15000,
        salaryType: 'monthly',
        jobType: 'part_time',
        experience: '2+ years',
        licenseType: 'Professional',
        workingHours: '9:00 AM - 9:00 PM (Weekends)',
        requirements: ['Valid license', '2+ years experience'],
        perks: ['Flexible hours', 'Bonus incentives'],
        status: 'open',
      },
      {
        ownerId: sampleOwner._id,
        title: 'Airport Shuttle Driver Required',
        description: 'We need experienced drivers for airport shuttle service. Must be punctual and professional.',
        carModel: 'Hyundai i10 2021',
        location: {
          address: 'Gulshan, Dhaka',
          latitude: 23.7808,
          longitude: 90.4167,
        },
        salary: 40000,
        salaryType: 'monthly',
        jobType: 'full_time',
        experience: '4+ years',
        licenseType: 'Professional',
        workingHours: '5:00 AM - 11:00 PM',
        requirements: ['Valid license', '4+ years experience', 'English speaking', 'Professional appearance'],
        perks: ['Competitive salary', 'Uniform provided', 'Training'],
        status: 'open',
      },
      {
        ownerId: sampleOwner._id,
        title: 'Delivery Driver for E-commerce Logistics',
        description: 'Looking for reliable drivers for daily delivery runs. Must be familiar with Dhaka routes.',
        carModel: 'Suzuki Van 2020',
        location: {
          address: 'Motijheel, Dhaka',
          latitude: 23.7330,
          longitude: 90.4172,
        },
        salary: 30000,
        salaryType: 'monthly',
        jobType: 'full_time',
        experience: '2+ years',
        licenseType: 'Professional',
        workingHours: '8:00 AM - 6:00 PM',
        requirements: ['Valid license', '2+ years experience', 'Familiarity with Dhaka'],
        perks: ['Fixed salary', 'Bonus for deliveries', 'Vehicle maintenance covered'],
        status: 'open',
      },
      {
        ownerId: sampleOwner._id,
        title: 'Corporate Driver for Executive Travel',
        description: 'Seeking professional driver for executive client transport. Must maintain high standards.',
        carModel: 'BMW 7 Series 2022',
        location: {
          address: 'Banani, Dhaka',
          latitude: 23.7937,
          longitude: 90.4066,
        },
        salary: 50000,
        salaryType: 'monthly',
        jobType: 'full_time',
        experience: '5+ years',
        licenseType: 'Professional',
        workingHours: '7:00 AM - 7:00 PM',
        requirements: ['Valid license', '5+ years experience', 'Professional demeanor', 'Discretion required'],
        perks: ['Premium salary', 'Fuel card', 'Training', 'Health benefits'],
        status: 'open',
      },
      {
        ownerId: sampleOwner._id,
        title: 'Rideshare Driver with Flexible Hours',
        description: 'Join our platform as a driver. Work your own hours and earn good money.',
        carModel: 'Honda City 2021',
        location: {
          address: 'Dhanmondi, Dhaka',
          latitude: 23.7461,
          longitude: 90.3742,
        },
        salary: 25000,
        salaryType: 'monthly',
        jobType: 'contract',
        experience: '1+ years',
        licenseType: 'Professional',
        workingHours: 'Flexible - 6:00 AM - 12:00 AM',
        requirements: ['Valid license', '1+ years experience', 'Smartphone'],
        perks: ['Flexible hours', 'High earning potential', 'App support'],
        status: 'open',
      },
    ];

    // Create posts
    const createdJobs = await JobPost.insertMany(sampleJobs);
    console.log(`Created ${createdJobs.length} sample job posts`);

    console.log('Job seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding job posts:', error);
    process.exit(1);
  }
};

seedJobPosts();
