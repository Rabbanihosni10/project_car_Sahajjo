require('dotenv').config();
const mongoose = require('mongoose');
const MarketplaceProduct = require('./models/marketplaceProduct');
const User = require('./models/user');

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/carsahajjo');
    console.log('MongoDB connected for seeding marketplace products');
  } catch (err) {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  }
};

const seedProducts = async () => {
  try {
    // Find a seller (any user)
    const seller = await User.findOne({ role: 'owner' });
    if (!seller) {
      console.log('No seller found. Please create a user first.');
      return;
    }

    console.log(`Using seller: ${seller.name} (${seller._id})`);

    // Clear existing products
    await MarketplaceProduct.deleteMany({});
    console.log('Cleared existing marketplace products');

    const products = [
      // Car Parts
      {
        sellerId: seller._id,
        name: 'Premium Brake Pads Set',
        description: 'High-performance ceramic brake pads for smooth and safe braking',
        category: 'car_parts',
        subcategory: 'brakes',
        price: 2500,
        originalPrice: 3000,
        discount: 17,
        stock: 50,
        images: ['https://via.placeholder.com/300x300?text=Brake+Pads'],
        specifications: {
          'Material': 'Ceramic',
          'Compatibility': 'Universal',
          'Brand': 'AutoPro'
        },
        warranty: { duration: 12, type: 'manufacturer' },
        shipping: { available: true, cost: 100, estimatedDays: 3 },
        ratings: { average: 4.5, count: 23 },
        status: 'active'
      },
      {
        sellerId: seller._id,
        name: 'LED Headlight Bulbs',
        description: 'Ultra bright LED headlight bulbs with 6000K white light',
        category: 'car_parts',
        subcategory: 'lights',
        price: 1800,
        originalPrice: 2200,
        discount: 18,
        stock: 100,
        images: ['https://via.placeholder.com/300x300?text=LED+Headlights'],
        specifications: {
          'Lumens': '6000',
          'Color': '6000K White',
          'Type': 'LED'
        },
        warranty: { duration: 24, type: 'manufacturer' },
        shipping: { available: true, cost: 80, estimatedDays: 2 },
        ratings: { average: 4.7, count: 45 },
        status: 'active'
      },
      {
        sellerId: seller._id,
        name: 'Air Filter - High Performance',
        description: 'Premium air filter for better engine performance and fuel efficiency',
        category: 'car_parts',
        subcategory: 'engine',
        price: 800,
        originalPrice: 1000,
        discount: 20,
        stock: 75,
        images: ['https://via.placeholder.com/300x300?text=Air+Filter'],
        specifications: {
          'Type': 'High-flow',
          'Material': 'Cotton',
          'Compatibility': 'Most sedans'
        },
        warranty: { duration: 6, type: 'seller' },
        shipping: { available: true, cost: 60, estimatedDays: 2 },
        ratings: { average: 4.3, count: 18 },
        status: 'active'
      },

      // Accessories
      {
        sellerId: seller._id,
        name: 'Car Phone Holder - Dashboard Mount',
        description: 'Universal phone holder with strong grip and 360° rotation',
        category: 'accessories',
        subcategory: 'interior',
        price: 450,
        originalPrice: 600,
        discount: 25,
        stock: 200,
        images: ['https://via.placeholder.com/300x300?text=Phone+Holder'],
        specifications: {
          'Mount Type': 'Dashboard',
          'Compatibility': 'All smartphones',
          'Color': 'Black'
        },
        warranty: { duration: 6, type: 'seller' },
        shipping: { available: true, cost: 50, estimatedDays: 1 },
        ratings: { average: 4.6, count: 67 },
        status: 'active'
      },
      {
        sellerId: seller._id,
        name: 'Premium Car Seat Covers',
        description: 'Leather-look seat covers for all car types. Easy to install.',
        category: 'accessories',
        subcategory: 'interior',
        price: 3500,
        originalPrice: 4500,
        discount: 22,
        stock: 30,
        images: ['https://via.placeholder.com/300x300?text=Seat+Covers'],
        specifications: {
          'Material': 'PU Leather',
          'Color': 'Black',
          'Set': '5 Seats'
        },
        warranty: { duration: 12, type: 'seller' },
        shipping: { available: true, cost: 150, estimatedDays: 3 },
        ratings: { average: 4.4, count: 34 },
        status: 'active'
      },
      {
        sellerId: seller._id,
        name: 'Car Floor Mats - Waterproof',
        description: '4-piece waterproof floor mat set for all weather protection',
        category: 'accessories',
        subcategory: 'interior',
        price: 1200,
        originalPrice: 1500,
        discount: 20,
        stock: 80,
        images: ['https://via.placeholder.com/300x300?text=Floor+Mats'],
        specifications: {
          'Material': 'TPE Rubber',
          'Color': 'Black',
          'Pieces': '4'
        },
        warranty: { duration: 12, type: 'seller' },
        shipping: { available: true, cost: 80, estimatedDays: 2 },
        ratings: { average: 4.5, count: 29 },
        status: 'active'
      },

      // Maintenance
      {
        sellerId: seller._id,
        name: 'Engine Oil - 5W-30 Synthetic',
        description: 'Premium synthetic engine oil for better protection and performance',
        category: 'maintenance',
        subcategory: 'fluids',
        price: 2200,
        originalPrice: 2500,
        discount: 12,
        stock: 60,
        images: ['https://via.placeholder.com/300x300?text=Engine+Oil'],
        specifications: {
          'Grade': '5W-30',
          'Type': 'Fully Synthetic',
          'Volume': '4 Liters'
        },
        warranty: { duration: 0, type: 'none' },
        shipping: { available: true, cost: 120, estimatedDays: 2 },
        ratings: { average: 4.8, count: 52 },
        status: 'active'
      },
      {
        sellerId: seller._id,
        name: 'Car Wash Shampoo - 1L',
        description: 'pH-balanced car wash shampoo with wax for shine',
        category: 'cleaning',
        subcategory: 'exterior',
        price: 350,
        originalPrice: 450,
        discount: 22,
        stock: 150,
        images: ['https://via.placeholder.com/300x300?text=Car+Shampoo'],
        specifications: {
          'Volume': '1 Liter',
          'Type': 'Shampoo + Wax',
          'pH': 'Balanced'
        },
        warranty: { duration: 0, type: 'none' },
        shipping: { available: true, cost: 60, estimatedDays: 2 },
        ratings: { average: 4.2, count: 41 },
        status: 'active'
      },

      // Electronics
      {
        sellerId: seller._id,
        name: 'Dash Camera - 1080P Full HD',
        description: 'Front and rear dash camera with night vision and parking mode',
        category: 'electronics',
        subcategory: 'cameras',
        price: 5500,
        originalPrice: 7000,
        discount: 21,
        stock: 25,
        images: ['https://via.placeholder.com/300x300?text=Dash+Camera'],
        specifications: {
          'Resolution': '1080P',
          'Screen': '3 inch',
          'Storage': 'Up to 128GB'
        },
        warranty: { duration: 24, type: 'manufacturer' },
        shipping: { available: true, cost: 150, estimatedDays: 3 },
        ratings: { average: 4.6, count: 38 },
        status: 'active'
      },
      {
        sellerId: seller._id,
        name: 'Bluetooth Car Adapter',
        description: 'Wireless Bluetooth adapter for hands-free calling and music',
        category: 'electronics',
        subcategory: 'audio',
        price: 650,
        originalPrice: 850,
        discount: 24,
        stock: 120,
        images: ['https://via.placeholder.com/300x300?text=Bluetooth+Adapter'],
        specifications: {
          'Bluetooth': '5.0',
          'Ports': 'USB + AUX',
          'Mic': 'Built-in'
        },
        warranty: { duration: 12, type: 'manufacturer' },
        shipping: { available: true, cost: 50, estimatedDays: 2 },
        ratings: { average: 4.4, count: 56 },
        status: 'active'
      },

      // Safety
      {
        sellerId: seller._id,
        name: 'First Aid Kit for Cars',
        description: 'Complete 50-piece first aid kit for emergency situations',
        category: 'safety',
        subcategory: 'emergency',
        price: 850,
        originalPrice: 1000,
        discount: 15,
        stock: 90,
        images: ['https://via.placeholder.com/300x300?text=First+Aid+Kit'],
        specifications: {
          'Pieces': '50',
          'Case': 'Compact',
          'Type': 'Medical'
        },
        warranty: { duration: 0, type: 'none' },
        shipping: { available: true, cost: 70, estimatedDays: 2 },
        ratings: { average: 4.7, count: 33 },
        status: 'active'
      },
      {
        sellerId: seller._id,
        name: 'Car Fire Extinguisher',
        description: 'Compact 1kg ABC fire extinguisher for vehicle safety',
        category: 'safety',
        subcategory: 'emergency',
        price: 1200,
        originalPrice: 1500,
        discount: 20,
        stock: 40,
        images: ['https://via.placeholder.com/300x300?text=Fire+Extinguisher'],
        specifications: {
          'Weight': '1kg',
          'Type': 'ABC Powder',
          'Mount': 'Bracket Included'
        },
        warranty: { duration: 12, type: 'manufacturer' },
        shipping: { available: true, cost: 100, estimatedDays: 3 },
        ratings: { average: 4.5, count: 21 },
        status: 'active'
      }
    ];

    await MarketplaceProduct.insertMany(products);
    console.log(`✅ Successfully seeded ${products.length} marketplace products`);
  } catch (error) {
    console.error('Error seeding products:', error);
  } finally {
    mongoose.connection.close();
  }
};

connectDB().then(seedProducts);
