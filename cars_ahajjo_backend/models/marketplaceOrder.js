const mongoose = require('mongoose');

const marketplaceOrderSchema = new mongoose.Schema({
  orderNo: {
    type: String,
    unique: true,
    default: () => `ORDER-${Date.now()}`,
  },
  buyerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  items: [
    {
      productId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'MarketplaceProduct',
      },
      sellerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
      quantity: Number,
      price: Number,
      subtotal: Number,
    },
  ],
  shippingAddress: {
    name: String,
    phone: String,
    email: String,
    address: String,
    city: String,
    postalCode: String,
  },
  pricing: {
    subtotal: Number,
    shipping: Number,
    tax: Number,
    couponDiscount: Number,
    total: Number,
  },
  payment: {
    method: {
      type: String,
      enum: ['cash_on_delivery', 'card', 'ssl_commerz', 'stripe'],
      default: 'cash_on_delivery',
    },
    status: {
      type: String,
      enum: ['pending', 'completed', 'failed', 'refunded'],
      default: 'pending',
    },
    transactionId: String,
    paidDate: Date,
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'returned'],
    default: 'pending',
  },
  tracking: {
    number: String,
    provider: String, // e.g., 'Pathao', 'Redx'
    updates: [
      {
        status: String,
        timestamp: Date,
        location: String,
      },
    ],
  },
  delivery: {
    estimatedDate: Date,
    actualDate: Date,
    signature: String,
    notes: String,
  },
  returns: {
    requestedAt: Date,
    reason: String,
    status: String, // pending, approved, refunding, completed
    refundAmount: Number,
  },
  feedback: {
    rating: Number,
    review: String,
    images: [String],
    createdAt: Date,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('MarketplaceOrder', marketplaceOrderSchema);
