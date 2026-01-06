const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const marketplaceController = require('../controllers/marketplaceController');

const router = express.Router();

// ===== PRODUCT ROUTES =====
router.post('/products', authenticateToken, marketplaceController.createProduct);
router.get('/products', marketplaceController.getProducts);
router.get('/products/:productId', marketplaceController.getProductDetails);

// ===== CART ROUTES =====
router.get('/cart', authenticateToken, marketplaceController.getCart);
router.post('/cart/add', authenticateToken, marketplaceController.addToCart);
router.delete('/cart/remove/:productId', authenticateToken, marketplaceController.removeFromCart);
router.patch('/cart/:productId/quantity', authenticateToken, marketplaceController.updateCartQuantity);

// ===== ORDER ROUTES =====
router.post('/checkout', authenticateToken, marketplaceController.checkout);
router.get('/orders', authenticateToken, marketplaceController.getOrders);
router.get('/orders/:orderId', authenticateToken, marketplaceController.getOrderDetails);
router.patch('/orders/:orderId/status', authenticateToken, marketplaceController.updateOrderStatus);

module.exports = router;
