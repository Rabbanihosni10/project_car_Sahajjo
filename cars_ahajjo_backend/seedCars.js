const mongoose = require('mongoose');
const dotenv = require('dotenv');

dotenv.config();

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/cars_ahajjo')
  .then(() => console.log('✅ MongoDB Connected'))
  .catch(err => console.error('❌ MongoDB Error:', err));

const CarRental = require('./models/carRental');
const User = require('./models/user');

// Sample car data with images
const carsData = [
  // Economy Cars
  {
    carName: 'Toyota Axio',
    carModel: '2020 G Grade',
    registrationNumber: 'DHAKA-GA-11-2345',
    image: 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=400',
    category: 'economy',
    location: 'Dhanmondi, Dhaka',
    pricePerDay: 2500,
    pricePerMonth: 60000,
    capacity: 5,
    features: ['AC', 'Power Steering', 'Airbags', 'Music System', 'Central Lock'],
    deposit: { required: true, amount: 10000, refundableWithin: 7 },
  },
  {
    carName: 'Honda Fit',
    carModel: '2019 Hybrid',
    registrationNumber: 'DHAKA-TA-15-4567',
    image: 'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=400',
    category: 'economy',
    location: 'Mirpur, Dhaka',
    pricePerDay: 2200,
    pricePerMonth: 55000,
    capacity: 5,
    features: ['AC', 'Hybrid', 'Fuel Efficient', 'Music System'],
    deposit: { required: true, amount: 8000, refundableWithin: 5 },
  },
  {
    carName: 'Suzuki Swift',
    carModel: '2021 VXI',
    registrationNumber: 'DHAKA-KA-18-7890',
    image: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=400',
    category: 'economy',
    location: 'Uttara, Dhaka',
    pricePerDay: 2300,
    pricePerMonth: 57000,
    capacity: 5,
    features: ['AC', 'ABS', 'Power Windows', 'Keyless Entry'],
    deposit: { required: true, amount: 9000, refundableWithin: 7 },
  },
  {
    carName: 'Toyota Vitz',
    carModel: '2018 F Package',
    registrationNumber: 'DHAKA-BA-12-3456',
    image: 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400',
    category: 'economy',
    location: 'Gulshan, Dhaka',
    pricePerDay: 2000,
    pricePerMonth: 50000,
    capacity: 5,
    features: ['AC', 'Power Steering', 'CD Player', 'ABS'],
    deposit: { required: true, amount: 7000, refundableWithin: 5 },
  },

  // Sedan Cars
  {
    carName: 'Toyota Corolla',
    carModel: '2021 Altis Grande',
    registrationNumber: 'DHAKA-HA-20-1234',
    image: 'https://images.unsplash.com/photo-1623869675781-80aa31012a5a?w=400',
    category: 'sedan',
    location: 'Banani, Dhaka',
    pricePerDay: 3500,
    pricePerMonth: 85000,
    capacity: 5,
    features: ['AC', 'Leather Seats', 'Sunroof', 'ABS', 'Airbags', 'Cruise Control'],
    deposit: { required: true, amount: 15000, refundableWithin: 7 },
  },
  {
    carName: 'Honda Civic',
    carModel: '2020 Oriel',
    registrationNumber: 'DHAKA-MA-19-5678',
    image: 'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=400',
    category: 'sedan',
    location: 'Bashundhara, Dhaka',
    pricePerDay: 4000,
    pricePerMonth: 95000,
    capacity: 5,
    features: ['AC', 'Leather Seats', 'Push Start', 'Navigation', 'Premium Audio'],
    deposit: { required: true, amount: 18000, refundableWithin: 10 },
  },
  {
    carName: 'Toyota Premio',
    carModel: '2019 F Package',
    registrationNumber: 'DHAKA-JA-17-9012',
    image: 'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=400',
    category: 'sedan',
    location: 'Mohammadpur, Dhaka',
    pricePerDay: 3200,
    pricePerMonth: 78000,
    capacity: 5,
    features: ['AC', 'Power Seats', 'ABS', 'Airbags', 'Reverse Camera'],
    deposit: { required: true, amount: 12000, refundableWithin: 7 },
  },
  {
    carName: 'Nissan Sunny',
    carModel: '2020 XV',
    registrationNumber: 'DHAKA-NA-21-3456',
    image: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400',
    category: 'sedan',
    location: 'Tejgaon, Dhaka',
    pricePerDay: 2800,
    pricePerMonth: 68000,
    capacity: 5,
    features: ['AC', 'Power Windows', 'ABS', 'USB Port', 'Bluetooth'],
    deposit: { required: true, amount: 10000, refundableWithin: 5 },
  },

  // SUV Cars
  {
    carName: 'Toyota Fielder',
    carModel: '2019 Hybrid',
    registrationNumber: 'DHAKA-EA-18-7890',
    image: 'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=400',
    category: 'suv',
    location: 'Baridhara, Dhaka',
    pricePerDay: 4500,
    pricePerMonth: 110000,
    capacity: 7,
    features: ['AC', 'Hybrid', 'Spacious', 'Reverse Camera', 'ABS', 'Airbags'],
    deposit: { required: true, amount: 20000, refundableWithin: 10 },
  },
  {
    carName: 'Honda CR-V',
    carModel: '2020 EX',
    registrationNumber: 'DHAKA-FA-20-2345',
    image: 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=400',
    category: 'suv',
    location: 'Gulshan, Dhaka',
    pricePerDay: 5500,
    pricePerMonth: 135000,
    capacity: 7,
    features: ['AC', 'Leather Seats', 'Sunroof', 'AWD', 'Navigation', '360 Camera'],
    deposit: { required: true, amount: 25000, refundableWithin: 15 },
  },
  {
    carName: 'Toyota Harrier',
    carModel: '2019 Premium',
    registrationNumber: 'DHAKA-LA-19-6789',
    image: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=400',
    category: 'suv',
    location: 'Motijheel, Dhaka',
    pricePerDay: 6000,
    pricePerMonth: 145000,
    capacity: 5,
    features: ['AC', 'Luxury Interior', 'Premium Sound', 'Panoramic Roof', 'AWD'],
    deposit: { required: true, amount: 30000, refundableWithin: 15 },
  },
  {
    carName: 'Mitsubishi Pajero',
    carModel: '2018 Sport',
    registrationNumber: 'DHAKA-PA-16-1234',
    image: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400',
    category: 'suv',
    location: 'Banani, Dhaka',
    pricePerDay: 5000,
    pricePerMonth: 120000,
    capacity: 7,
    features: ['AC', '4WD', 'Off-road Capable', 'Roof Rack', 'Hill Assist'],
    deposit: { required: true, amount: 22000, refundableWithin: 10 },
  },

  // Luxury Cars
  {
    carName: 'Toyota Camry',
    carModel: '2021 V6',
    registrationNumber: 'DHAKA-CA-21-9012',
    image: 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=400',
    category: 'luxury',
    location: 'Gulshan-2, Dhaka',
    pricePerDay: 7000,
    pricePerMonth: 170000,
    capacity: 5,
    features: ['AC', 'Leather Seats', 'Premium Audio', 'Adaptive Cruise', 'Lane Assist'],
    deposit: { required: true, amount: 35000, refundableWithin: 20 },
  },
  {
    carName: 'BMW 5 Series',
    carModel: '2020 520i',
    registrationNumber: 'DHAKA-BM-20-3456',
    image: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400',
    category: 'luxury',
    location: 'Banani, Dhaka',
    pricePerDay: 12000,
    pricePerMonth: 300000,
    capacity: 5,
    features: ['AC', 'Luxury Interior', 'Massage Seats', 'Head-up Display', 'Premium Sound'],
    deposit: { required: true, amount: 60000, refundableWithin: 30 },
  },
  {
    carName: 'Mercedes E-Class',
    carModel: '2021 E200',
    registrationNumber: 'DHAKA-ME-21-7890',
    image: 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=400',
    category: 'luxury',
    location: 'Gulshan-1, Dhaka',
    pricePerDay: 15000,
    pricePerMonth: 380000,
    capacity: 5,
    features: ['AC', 'Luxury Leather', 'Ambient Lighting', 'MBUX System', 'Burmester Audio'],
    deposit: { required: true, amount: 75000, refundableWithin: 30 },
  },
  {
    carName: 'Audi A6',
    carModel: '2020 Premium',
    registrationNumber: 'DHAKA-AU-20-1234',
    image: 'https://images.unsplash.com/photo-1610768764270-790fbec18178?w=400',
    category: 'luxury',
    location: 'Baridhara DOHS, Dhaka',
    pricePerDay: 13000,
    pricePerMonth: 320000,
    capacity: 5,
    features: ['AC', 'Quattro AWD', 'Virtual Cockpit', 'Matrix LED', 'Bang & Olufsen'],
    deposit: { required: true, amount: 65000, refundableWithin: 30 },
  },

  // Vans
  {
    carName: 'Toyota Hiace',
    carModel: '2019 GL',
    registrationNumber: 'DHAKA-HA-19-5678',
    image: 'https://images.unsplash.com/photo-1527786356703-4b100091cd2c?w=400',
    category: 'van',
    location: 'Mohakhali, Dhaka',
    pricePerDay: 4000,
    pricePerMonth: 95000,
    capacity: 12,
    features: ['AC', 'Spacious', 'Comfortable Seats', 'Luggage Space', 'GPS'],
    deposit: { required: true, amount: 18000, refundableWithin: 10 },
  },
  {
    carName: 'Nissan Urvan',
    carModel: '2020 Standard',
    registrationNumber: 'DHAKA-UR-20-9012',
    image: 'https://images.unsplash.com/photo-1464219789935-c2d9d9aba644?w=400',
    category: 'van',
    location: 'Uttara Sector 10, Dhaka',
    pricePerDay: 3800,
    pricePerMonth: 90000,
    capacity: 15,
    features: ['AC', 'Commercial Grade', 'Power Steering', 'ABS'],
    deposit: { required: true, amount: 16000, refundableWithin: 7 },
  },
  {
    carName: 'Toyota Noah',
    carModel: '2018 Si',
    registrationNumber: 'DHAKA-NO-18-3456',
    image: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400',
    category: 'van',
    location: 'Mirpur-10, Dhaka',
    pricePerDay: 3500,
    pricePerMonth: 85000,
    capacity: 8,
    features: ['AC', 'Family Van', 'Entertainment System', 'Sliding Doors'],
    deposit: { required: true, amount: 15000, refundableWithin: 7 },
  },
];

async function seedCars() {
  try {
    // Find or create a default owner
    let owner = await User.findOne({ role: 'owner' });
    
    if (!owner) {
      console.log('⚠️  No owner found, creating default owner...');
      const bcrypt = require('bcryptjs');
      owner = await User.create({
        name: 'Default Owner',
        email: 'owner@carsahajjo.com',
        phone: '01700000000',
        password: await bcrypt.hash('password123', 10),
        role: 'owner',
        isVerified: true,
      });
      console.log('✅ Default owner created');
    }

    console.log(`\n📦 Seeding ${carsData.length} cars...`);

    // Clear existing rentals
    await CarRental.deleteMany({});
    console.log('🗑️  Cleared existing car rentals');

    // Add ownerId to each car
    const carsWithOwner = carsData.map(car => ({
      ...car,
      ownerId: owner._id,
      availability: {
        startDate: new Date(),
        endDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year
        blockedDates: [],
      },
    }));

    // Insert cars
    const insertedCars = await CarRental.insertMany(carsWithOwner);
    
    console.log(`\n✅ Successfully seeded ${insertedCars.length} cars!`);
    console.log('\n📊 Summary:');
    console.log(`   - Economy: ${insertedCars.filter(c => c.category === 'economy').length}`);
    console.log(`   - Sedan: ${insertedCars.filter(c => c.category === 'sedan').length}`);
    console.log(`   - SUV: ${insertedCars.filter(c => c.category === 'suv').length}`);
    console.log(`   - Luxury: ${insertedCars.filter(c => c.category === 'luxury').length}`);
    console.log(`   - Van: ${insertedCars.filter(c => c.category === 'van').length}`);

    console.log('\n🎉 Database seeded successfully!');
    console.log('💡 You can now view these cars in the Car Info section');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

// Run seeder
seedCars();
