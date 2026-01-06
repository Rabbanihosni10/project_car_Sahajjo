const MarketplaceProduct = require('../models/marketplaceProduct');
const Cart = require('../models/cart');
const MarketplaceOrder = require('../models/marketplaceOrder');

// ===== PRODUCT MANAGEMENT =====
exports.createProduct = async (req, res) => {
  try {
    const {
      name,
      description,
      category,
      subcategory,
      price,
      originalPrice,
      discount,
      stock,
      specifications,
      warranty,
      shipping,
    } = req.body;

    const product = new MarketplaceProduct({
      sellerId: req.user.id,
      name,
      description,
      category,
      subcategory,
      price,
      originalPrice,
      discount,
      stock,
      specifications,
      warranty,
      shipping,
    });

    await product.save();

    res.status(201).json({
      success: true,
      message: 'Product created',
      data: product,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error creating product',
      error: error.message,
    });
  }
};

exports.getProducts = async (req, res) => {
  try {
    const { category, search, sortBy = 'newest' } = req.query;

    const query = { status: 'active' };
    if (category) query.category = category;
    if (search) {
      query.$or = [
        { name: new RegExp(search, 'i') },
        { description: new RegExp(search, 'i') },
      ];
    }

    let products = await MarketplaceProduct.find(query)
      .populate('sellerId', 'name rating')
      .limit(50);

    // Add default images if not present
    products = products.map(product => {
      const productObj = product.toObject();
      if (!productObj.images || productObj.images.length === 0) {
        productObj.images = [`https://via.placeholder.com/150x150?text=${encodeURIComponent(productObj.name || 'Product')}`];
      }
      return productObj;
    });

    if (sortBy === 'price-low') products.sort((a, b) => a.price - b.price);
    if (sortBy === 'price-high') products.sort((a, b) => b.price - a.price);
    if (sortBy === 'rating') products.sort((a, b) => b.ratings.average - a.ratings.average);

    res.status(200).json({ success: true, data: products });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching products',
      error: error.message,
    });
  }
};

exports.getProductDetails = async (req, res) => {
  try {
    const { productId } = req.params;

    const product = await MarketplaceProduct.findByIdAndUpdate(
      productId,
      { $inc: { views: 1 } },
      { new: true }
    ).populate('sellerId', 'name email rating');

    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    // Add default images if not present
    const productObj = product.toObject();
    if (!productObj.images || productObj.images.length === 0) {
      productObj.images = [`https://via.placeholder.com/300x300?text=${encodeURIComponent(productObj.name || 'Product')}`];
    }

    res.status(200).json({ success: true, data: productObj });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching product',
      error: error.message,
    });
  }
};

// ===== CART MANAGEMENT =====
exports.getCart = async (req, res) => {
  try {
    const userId = req.user.id;

    let cart = await Cart.findOne({ userId }).populate('items.productId');
    if (!cart) {
      cart = new Cart({ userId, items: [] });
      await cart.save();
    }

    res.status(200).json({ success: true, data: cart });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching cart',
      error: error.message,
    });
  }
};

exports.addToCart = async (req, res) => {
  try {
    const { productId, quantity = 1 } = req.body;
    const userId = req.user.id;

    const product = await MarketplaceProduct.findById(productId);
    if (!product || product.stock < quantity) {
      return res.status(400).json({ success: false, message: 'Product not available' });
    }

    let cart = await Cart.findOne({ userId });
    if (!cart) {
      cart = new Cart({ userId, items: [] });
    }

    const existingItem = cart.items.find((i) => i.productId.toString() === productId);
    if (existingItem) {
      existingItem.quantity += quantity;
    } else {
      cart.items.push({
        productId,
        quantity,
        price: product.price,
      });
    }

    // Recalculate totals
    const subtotal = cart.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    cart.subtotal = Math.round(subtotal * 100) / 100;
    cart.tax = Math.round(subtotal * 0.05 * 100) / 100; // 5% tax
    cart.total = Math.round((cart.subtotal + cart.shippingCost + cart.tax - cart.couponDiscount) * 100) / 100;

    await cart.save();

    res.status(200).json({
      success: true,
      message: 'Item added to cart',
      data: cart,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error adding to cart',
      error: error.message,
    });
  }
};

exports.removeFromCart = async (req, res) => {
  try {
    const { productId } = req.params;
    const userId = req.user.id;

    const cart = await Cart.findOne({ userId });
    if (!cart) {
      return res.status(404).json({ success: false, message: 'Cart not found' });
    }

    cart.items = cart.items.filter((i) => i.productId.toString() !== productId);

    // Recalculate totals
    const subtotal = cart.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    cart.subtotal = Math.round(subtotal * 100) / 100;
    cart.total = Math.round((cart.subtotal + cart.shippingCost + cart.tax - cart.couponDiscount) * 100) / 100;

    await cart.save();

    res.status(200).json({
      success: true,
      message: 'Item removed from cart',
      data: cart,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error removing from cart',
      error: error.message,
    });
  }
};

exports.updateCartQuantity = async (req, res) => {
  try {
    const { productId } = req.params;
    const { quantity } = req.body;
    const userId = req.user.id;

    const cart = await Cart.findOne({ userId });
    if (!cart) {
      return res.status(404).json({ success: false, message: 'Cart not found' });
    }

    const item = cart.items.find((i) => i.productId.toString() === productId);
    if (!item) {
      return res.status(404).json({ success: false, message: 'Item not in cart' });
    }

    item.quantity = quantity;

    // Recalculate totals
    const subtotal = cart.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    cart.subtotal = Math.round(subtotal * 100) / 100;
    cart.tax = Math.round(subtotal * 0.05 * 100) / 100;
    cart.total = Math.round((cart.subtotal + cart.shippingCost + cart.tax - cart.couponDiscount) * 100) / 100;

    await cart.save();

    res.status(200).json({
      success: true,
      message: 'Cart updated',
      data: cart,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error updating cart',
      error: error.message,
    });
  }
};

// ===== ORDER MANAGEMENT =====
exports.checkout = async (req, res) => {
  try {
    const { shippingAddress, paymentMethod } = req.body;
    const userId = req.user.id;

    const cart = await Cart.findOne({ userId }).populate('items.productId');
    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ success: false, message: 'Cart is empty' });
    }

    const orderItems = await Promise.all(
      cart.items.map(async (item) => {
        const product = await MarketplaceProduct.findById(item.productId);
        return {
          productId: item.productId,
          sellerId: product.sellerId,
          quantity: item.quantity,
          price: item.price,
          subtotal: item.price * item.quantity,
        };
      })
    );

    const order = new MarketplaceOrder({
      buyerId: userId,
      items: orderItems,
      shippingAddress,
      pricing: {
        subtotal: cart.subtotal,
        shipping: cart.shippingCost,
        tax: cart.tax,
        couponDiscount: cart.couponDiscount,
        total: cart.total,
      },
      payment: {
        method: paymentMethod || 'cash_on_delivery',
        status: paymentMethod === 'cash_on_delivery' ? 'pending' : 'completed',
      },
    });

    await order.save();

    // Clear cart
    cart.items = [];
    cart.subtotal = 0;
    cart.tax = 0;
    cart.total = 0;
    await cart.save();

    req.io.emit('new_order', {
      orderId: order._id,
      message: `New order ${order.orderNo}`,
    });

    res.status(201).json({
      success: true,
      message: 'Order created',
      data: order,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error creating order',
      error: error.message,
    });
  }
};

exports.getOrders = async (req, res) => {
  try {
    const buyerId = req.user.id;

    const orders = await MarketplaceOrder.find({ buyerId })
      .populate('items.productId', 'name price')
      .populate('items.sellerId', 'name email')
      .sort({ createdAt: -1 });

    res.status(200).json({ success: true, data: orders });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching orders',
      error: error.message,
    });
  }
};

exports.getOrderDetails = async (req, res) => {
  try {
    const { orderId } = req.params;

    const order = await MarketplaceOrder.findById(orderId)
      .populate('buyerId', 'name email phone')
      .populate('items.productId')
      .populate('items.sellerId', 'name email');

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    res.status(200).json({ success: true, data: order });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching order',
      error: error.message,
    });
  }
};

exports.updateOrderStatus = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status } = req.body;

    const order = await MarketplaceOrder.findByIdAndUpdate(
      orderId,
      { status },
      { new: true }
    );

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    req.io.emit('order_status_updated', {
      orderId,
      status,
      message: `Order ${order.orderNo} status: ${status}`,
    });

    res.status(200).json({
      success: true,
      message: 'Order status updated',
      data: order,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error updating order',
      error: error.message,
    });
  }
};
