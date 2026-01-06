const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    transactionType: {
      type: String,
      enum: ['ride_payment', 'driver_earning', 'refund', 'wallet_topup', 'withdrawal'],
      required: true,
    },
    amount: {
      type: Number,
      required: true,
    },
    currency: {
      type: String,
      default: 'BDT',
    },
    description: {
      type: String,
    },
    paymentMethod: {
      type: String,
      enum: ['stripe', 'sslcommerz', 'razorpay', 'bkash', 'nagad', 'wallet', 'cash', 'bank_transfer'],
      required: true,
    },
    // Payment gateway references
    paymentGatewayId: String, // Stripe/Razorpay ID
    status: {
      type: String,
      enum: ['pending', 'completed', 'failed', 'refunded'],
      default: 'pending',
    },
    relatedUserId: mongoose.Schema.Types.ObjectId, // For ride payments: driver ID
    relatedModel: String, // 'Ride', 'Trip', etc.
    relatedModelId: mongoose.Schema.Types.ObjectId,

    // Wallet
    walletBalance: Number, // User's wallet balance after transaction
    
    // Error handling
    errorMessage: String,
    retryCount: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Transaction', transactionSchema);
