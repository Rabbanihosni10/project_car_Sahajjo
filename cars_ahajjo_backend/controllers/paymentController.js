const mongoose = require('mongoose');
const Transaction = require('../models/transaction');
const User = require('../models/user');

// Stripe (optional) lazy init
let stripe = null;
try {
  const Stripe = require('stripe');
  const key = process.env.STRIPE_SECRET_KEY;
  if (key) {
    stripe = new Stripe(key);
  }
} catch (err) {}

// Create a payment intent (Stripe)
exports.createPaymentIntent = async (req, res) => {
  try {
    const { amount, currency = 'USD', description, paymentMethod } = req.body;
    const userId = req.user.id;

    if (!amount || amount <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid amount' });
    }

    let paymentIntentId = null;
    const stripeRequested = paymentMethod === 'stripe';
    const stripeUnavailable = stripeRequested && !stripe;
    const useStripe = stripeRequested && stripe;

    if (useStripe) {
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(amount * 100),
        currency: currency.toLowerCase(),
        metadata: { userId: userId.toString(), description },
      });
      paymentIntentId = paymentIntent.id;
    }

    const transaction = new Transaction({
      userId,
      amount,
      currency,
      description,
      paymentMethod: stripeUnavailable ? 'cash_offline' : paymentMethod,
      paymentGatewayId: paymentIntentId,
      transactionType: 'ride_payment',
      status: useStripe ? 'pending' : 'completed',
    });
    await transaction.save();

    const clientSecret = useStripe && paymentIntentId
      ? (await stripe.paymentIntents.retrieve(paymentIntentId)).client_secret
      : null;

    res.status(201).json({
      success: true,
      message: stripeUnavailable ? 'Stripe not configured, saved as cash payment' : 'Payment intent created',
      data: { transactionId: transaction._id, paymentIntentId, clientSecret },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error creating payment intent', error: error.message });
  }
};

// Confirm payment (Stripe)
exports.confirmPayment = async (req, res) => {
  try {
    const { transactionId, paymentIntentId } = req.body;
    const userId = req.user.id;

    const transaction = await Transaction.findById(transactionId);
    if (!transaction || transaction.userId.toString() !== userId.toString()) {
      return res.status(404).json({ success: false, message: 'Transaction not found' });
    }

    if (transaction.status === 'completed') {
      return res.status(200).json({ success: true, message: 'Payment already completed', data: transaction });
    }

    if (transaction.paymentMethod === 'stripe') {
      if (!stripe) {
        transaction.status = 'completed';
        await transaction.save();
        return res.status(200).json({ success: true, message: 'Stripe not configured; marking as completed (cash flow)', data: transaction });
      }
      const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
      if (paymentIntent.status === 'succeeded') {
        transaction.status = 'completed';
        await transaction.save();
        return res.status(200).json({ success: true, message: 'Payment confirmed successfully', data: transaction });
      } else {
        transaction.status = 'failed';
        transaction.errorMessage = paymentIntent.last_payment_error?.message;
        await transaction.save();
        return res.status(400).json({ success: false, message: 'Payment not completed', data: transaction });
      }
    }

    // Non-stripe (cash or other) auto-completes
    transaction.status = 'completed';
    await transaction.save();
    return res.status(200).json({ success: true, message: 'Payment recorded as completed', data: transaction });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error confirming payment', error: error.message });
  }
};

// Get transaction history
exports.getTransactionHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit = 10, skip = 0 } = req.query;
    const transactions = await Transaction.find({ userId }).sort({ createdAt: -1 }).limit(parseInt(limit)).skip(parseInt(skip));
    const total = await Transaction.countDocuments({ userId });
    res.status(200).json({ success: true, data: transactions, pagination: { total, limit: parseInt(limit), skip: parseInt(skip) } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching transactions', error: error.message });
  }
};

// Get transaction by ID
exports.getTransaction = async (req, res) => {
  try {
    const { transactionId } = req.params;
    const userId = req.user.id;
    const transaction = await Transaction.findById(transactionId);
    if (!transaction || transaction.userId.toString() !== userId.toString()) {
      return res.status(404).json({ success: false, message: 'Transaction not found' });
    }
    res.status(200).json({ success: true, data: transaction });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching transaction', error: error.message });
  }
};

// Wallet balance (drivers)
exports.getWalletBalance = async (req, res) => {
  try {
    const userId = req.user.id;
    const earnings = await Transaction.aggregate([
      { $match: { userId: mongoose.Types.ObjectId(userId), transactionType: 'driver_earning', status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]);
    const totalEarnings = earnings.length > 0 ? earnings[0].total : 0;
    res.status(200).json({ success: true, data: { walletBalance: totalEarnings } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching wallet balance', error: error.message });
  }
};

// Refund (Stripe)
exports.processRefund = async (req, res) => {
  try {
    const { transactionId } = req.body;
    const userId = req.user.id;
    const transaction = await Transaction.findById(transactionId);
    if (!transaction || transaction.userId.toString() !== userId.toString()) {
      return res.status(404).json({ success: false, message: 'Transaction not found' });
    }
    if (transaction.status !== 'completed') {
      return res.status(400).json({ success: false, message: 'Can only refund completed transactions' });
    }
    if (transaction.paymentMethod === 'stripe' && transaction.paymentGatewayId) {
      if (!stripe) {
        return res.status(400).json({ success: false, message: 'Stripe is not configured on the server' });
      }
      await stripe.refunds.create({ payment_intent: transaction.paymentGatewayId });
      transaction.status = 'refunded';
      await transaction.save();
      return res.status(200).json({ success: true, message: 'Refund processed successfully', data: transaction });
    }
    res.status(400).json({ success: false, message: 'Unsupported refund method' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error processing refund', error: error.message });
  }
};

// SSLCommerz: Create payment session
exports.createSslCommerzSession = async (req, res) => {
  try {
    const {
      amount,
      currency = 'BDT',
      description = 'Ride payment',
      successUrl,
      failUrl,
      cancelUrl,
    } = req.body;
    const userId = req.user.id;

    if (!amount || amount <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid amount' });
    }

    const storeId = process.env.SSL_STORE_ID;
    const storePass = process.env.SSL_STORE_PASSWORD;
    if (!storeId || !storePass) {
      return res.status(500).json({ success: false, message: 'SSLCommerz credentials missing' });
    }

    const base = process.env.APP_BASE_URL || `http://localhost:${process.env.PORT || 5003}`;
    const tranId = `SSL_${Date.now()}_${Math.floor(Math.random() * 100000)}`;

    const user = await User.findById(userId).lean();
    const payload = new URLSearchParams({
      store_id: storeId,
      store_passwd: storePass,
      total_amount: amount.toString(),
      currency,
      tran_id: tranId,
      success_url: successUrl || `${base}/api/payments/ssl/success`,
      fail_url: failUrl || `${base}/api/payments/ssl/fail`,
      cancel_url: cancelUrl || `${base}/api/payments/ssl/cancel`,
      cus_name: user?.name || 'Customer',
      cus_email: user?.email || 'customer@example.com',
      cus_add1: 'Address',
      cus_city: 'City',
      cus_country: 'Bangladesh',
      shipping_method: 'NO',
      product_category: 'Ride',
      product_name: description,
    });

    const apiUrl = process.env.SSL_SANDBOX === 'true'
      ? 'https://sandbox.sslcommerz.com/gwprocess/v3/api.php'
      : 'https://securepay.sslcommerz.com/gwprocess/v3/api.php';

    const resp = await fetch(apiUrl, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: payload });
    const data = await resp.json();
    if (data.status !== 'SUCCESS' || !data.GatewayPageURL) {
      return res.status(400).json({ success: false, message: 'Failed to create SSLCommerz session', data });
    }

    const transaction = new Transaction({
      userId,
      amount,
      currency,
      description,
      paymentMethod: 'sslcommerz',
      paymentGatewayId: tranId,
      transactionType: 'ride_payment',
      status: 'pending',
    });
    await transaction.save();

    res.status(201).json({ success: true, message: 'SSLCommerz session created', data: { transactionId: transaction._id, tranId, gatewayUrl: data.GatewayPageURL } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error creating SSLCommerz session', error: error.message });
  }
};

// SSLCommerz: Success callback
exports.sslSuccess = async (req, res) => {
  try {
    const { val_id, tran_id } = req.body;
    if (!val_id || !tran_id) {
      return res.status(400).json({ success: false, message: 'Missing val_id or tran_id' });
    }
    const storeId = process.env.SSL_STORE_ID;
    const storePass = process.env.SSL_STORE_PASSWORD;
    const validateUrl = (process.env.SSL_SANDBOX === 'true'
      ? 'https://sandbox.sslcommerz.com/validator/api/validationserverAPI.php'
      : 'https://securepay.sslcommerz.com/validator/api/validationserverAPI.php') + `?val_id=${encodeURIComponent(val_id)}&store_id=${encodeURIComponent(storeId)}&store_passwd=${encodeURIComponent(storePass)}&v=1&format=json`;

    const resp = await fetch(validateUrl);
    const data = await resp.json();
    const transaction = await Transaction.findOne({ paymentGatewayId: tran_id });
    if (!transaction) {
      return res.status(404).json({ success: false, message: 'Transaction not found' });
    }
    if (data.status === 'VALID' || data.status === 'VALIDATED') {
      transaction.status = 'completed';
      await transaction.save();
      return res.status(200).json({ success: true, message: 'Payment validated', data: transaction });
    }
    transaction.status = 'failed';
    transaction.errorMessage = data.status;
    await transaction.save();
    res.status(400).json({ success: false, message: 'Payment not valid', data });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error validating payment', error: error.message });
  }
};

// SSLCommerz: Fail callback
exports.sslFail = async (req, res) => {
  try {
    const { tran_id } = req.body;
    const transaction = await Transaction.findOne({ paymentGatewayId: tran_id });
    if (transaction) {
      transaction.status = 'failed';
      await transaction.save();
    }
    res.status(200).json({ success: false, message: 'Payment failed' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error handling fail', error: error.message });
  }
};

// SSLCommerz: Cancel callback
exports.sslCancel = async (req, res) => {
  try {
    const { tran_id } = req.body;
    const transaction = await Transaction.findOne({ paymentGatewayId: tran_id });
    if (transaction) {
      transaction.status = 'failed';
      transaction.errorMessage = 'cancelled';
      await transaction.save();
    }
    res.status(200).json({ success: false, message: 'Payment cancelled' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error handling cancel', error: error.message });
  }
};

// Withdraw from wallet
exports.withdrawFromWallet = async (req, res) => {
  try {
    const { amount, bankAccount, accountHolderName } = req.body;
    const userId = req.user.id;

    if (!amount || amount <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid withdrawal amount' });
    }

    // Calculate current wallet balance
    const earnings = await Transaction.aggregate([
      { $match: { userId: mongoose.Types.ObjectId(userId), transactionType: 'driver_earning', status: 'completed' } },
      { $group: { _id: null, totalEarnings: { $sum: '$amount' } } },
    ]);
    
    const withdrawals = await Transaction.aggregate([
      { $match: { userId: mongoose.Types.ObjectId(userId), transactionType: 'withdrawal', status: 'completed' } },
      { $group: { _id: null, totalWithdrawals: { $sum: '$amount' } } },
    ]);

    const totalEarnings = earnings.length > 0 ? earnings[0].totalEarnings : 0;
    const totalWithdrawals = withdrawals.length > 0 ? withdrawals[0].totalWithdrawals : 0;
    const currentBalance = totalEarnings - totalWithdrawals;

    // Validate sufficient balance
    if (currentBalance < amount) {
      return res.status(400).json({ 
        success: false, 
        message: 'Insufficient balance',
        data: { currentBalance, requestedAmount: amount }
      });
    }

    // Create withdrawal transaction
    const transaction = new Transaction({
      userId,
      amount,
      currency: 'BDT',
      description: `Withdrawal to ${bankAccount || 'Bank Account'}`,
      paymentMethod: 'bank_transfer',
      transactionType: 'withdrawal',
      status: 'completed', // In production, this would be 'pending' until bank processes
      walletBalance: currentBalance - amount,
    });

    await transaction.save();

    res.status(200).json({ 
      success: true, 
      message: 'Withdrawal request processed successfully',
      data: { 
        transaction,
        newBalance: currentBalance - amount 
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error processing withdrawal', error: error.message });
  }
};
