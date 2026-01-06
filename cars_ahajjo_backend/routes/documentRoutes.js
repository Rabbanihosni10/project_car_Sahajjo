const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const documentController = require('../controllers/documentController');

const router = express.Router();

// Upload document
router.post('/', authenticateToken, documentController.uploadDocument);

// Get user documents
router.get('/', authenticateToken, documentController.getUserDocuments);

// Get document details
router.get('/:documentId', authenticateToken, documentController.getDocumentDetails);

// Delete document
router.delete('/:documentId', authenticateToken, documentController.deleteDocument);

// Admin: Verify document
router.patch('/:documentId/verify', authenticateToken, documentController.verifyDocument);

// Admin: Get expiring documents
router.get('/admin/expiring', authenticateToken, documentController.getExpiringDocuments);

// Admin: Send expiry reminders
router.post('/admin/send-reminders', authenticateToken, documentController.sendExpiryReminders);

module.exports = router;
