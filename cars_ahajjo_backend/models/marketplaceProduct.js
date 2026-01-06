const mongoose = require('mongoose');

const marketplaceProductSchema = new mongoose.Schema({
  sellerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  name: {
    type: String,
    required: true,
  },
  description: String,
  category: {
    type: String,
    enum: ['car_parts', 'accessories', 'maintenance', 'cleaning', 'electronics', 'safety'],
    default: 'accessories',
  },
  subcategory: String,
  price: {
    type: Number,
    required: true,
  },
  originalPrice: Number, // For discounts
  discount: Number, // Percentage
  images: [String],
  stock: {
    type: Number,
    default: 0,
  },
  sku: String,
  specifications: {
    type: Map,
    of: String, // e.g., { 'color': 'black', 'size': 'large' }
  },
  warranty: {
    duration: Number, // months
    type: String, // manufacturer, seller
  },
  shipping: {
    available: {
      type: Boolean,
      default: true,
    },
    cost: Number,
    estimatedDays: Number,
    freeShippingOver: Number, // BDT
  },
  ratings: {
    average: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    count: {
      type: Number,
      default: 0,
    },
    reviews: [
      {
        buyerId: mongoose.Schema.Types.ObjectId,
        rating: Number,
        comment: String,
        createdAt: Date,
      },
    ],
  },
  status: {
    type: String,
    enum: ['active', 'inactive', 'discontinued'],
    default: 'active',
  },
  views: {
    type: Number,
    default: 0,
  },
  sales: {
    type: Number,
    default: 0,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('MarketplaceProduct', marketplaceProductSchema);
