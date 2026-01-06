const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const { authenticateToken } = require('../middleware/auth');

// SSLCommerz callbacks (do NOT require auth)
router.post('/ssl/success', paymentController.sslSuccess);
router.post('/ssl/fail', paymentController.sslFail);
router.post('/ssl/cancel', paymentController.sslCancel);

// Authenticated routes below
router.use(authenticateToken);

// Create payment intent
router.post('/create-intent', paymentController.createPaymentIntent);

// Create SSLCommerz session
router.post('/ssl/session', paymentController.createSslCommerzSession);

// Confirm payment
router.post('/confirm', paymentController.confirmPayment);

// Get transaction history
router.get('/history', paymentController.getTransactionHistory);

// Get specific transaction
router.get('/:transactionId', paymentController.getTransaction);

// Get wallet balance
router.get('/wallet/balance', paymentController.getWalletBalance);

// Withdraw from wallet
router.post('/wallet/withdraw', paymentController.withdrawFromWallet);

// Process refund
router.post('/refund', paymentController.processRefund);

module.exports = router;
