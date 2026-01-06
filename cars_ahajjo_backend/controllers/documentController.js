const Document = require('../models/document');
const Notification = require('../models/notification');

// Upload document
exports.uploadDocument = async (req, res) => {
  try {
    const { documentType, documentNumber, issueDate, expiryDate, issuingAuthority } = req.body;
    const userId = req.user.id;

    // In production, handle file upload via multer/cloud storage
    const fileUrl = req.body.fileUrl || 'https://example.com/documents/' + Date.now();

    const document = new Document({
      ownerId: userId,
      documentType,
      documentNumber,
      issueDate,
      expiryDate,
      issuingAuthority,
      fileUrl,
    });

    await document.save();

    // Send admin notification for verification
    await Notification.create({
      recipientId: null, // Admin
      title: 'New Document Submitted',
      body: `${documentType} uploaded by user ${userId}`,
      type: 'admin',
      relatedId: document._id,
      status: 'pending',
    });

    res.status(201).json({
      success: true,
      message: 'Document uploaded',
      data: document,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error uploading document',
      error: error.message,
    });
  }
};

// Get user documents
exports.getUserDocuments = async (req, res) => {
  try {
    const userId = req.user.id;
    const { status, type } = req.query;

    const query = { ownerId: userId };
    if (status) query.status = status;
    if (type) query.documentType = type;

    const documents = await Document.find(query).sort({ uploadedAt: -1 });

    res.status(200).json({
      success: true,
      data: documents,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching documents',
      error: error.message,
    });
  }
};

// Get document details
exports.getDocumentDetails = async (req, res) => {
  try {
    const { documentId } = req.params;

    const document = await Document.findById(documentId)
      .populate('ownerId', 'name email')
      .populate('verifiedBy', 'name');

    if (!document) {
      return res.status(404).json({ success: false, message: 'Document not found' });
    }

    res.status(200).json({
      success: true,
      data: document,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching document',
      error: error.message,
    });
  }
};

// Admin: Verify document
exports.verifyDocument = async (req, res) => {
  try {
    const { documentId } = req.params;
    const { status, verificationNotes } = req.body;
    const adminId = req.user.id;

    const document = await Document.findByIdAndUpdate(
      documentId,
      {
        status,
        verificationNotes,
        verifiedBy: adminId,
        verifiedAt: new Date(),
      },
      { new: true }
    );

    if (!document) {
      return res.status(404).json({ success: false, message: 'Document not found' });
    }

    // Send notification to user
    await Notification.create({
      recipientId: document.ownerId,
      title: `Document ${status}`,
      body: `Your ${document.documentType} has been ${status}. ${verificationNotes || ''}`,
      type: 'admin',
      relatedId: documentId,
      status: 'pending',
    });

    res.status(200).json({
      success: true,
      message: 'Document verified',
      data: document,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error verifying document',
      error: error.message,
    });
  }
};

// Get expiring documents (admin)
exports.getExpiringDocuments = async (req, res) => {
  try {
    const { days = 30 } = req.query;

    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + parseInt(days));

    const documents = await Document.find({
      expiryDate: { $lte: expiryDate, $gte: new Date() },
      status: { $in: ['verified', 'expired'] },
    })
      .populate('ownerId', 'name email phone')
      .sort({ expiryDate: 1 });

    res.status(200).json({
      success: true,
      data: documents,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching expiring documents',
      error: error.message,
    });
  }
};

// Send expiry reminders
exports.sendExpiryReminders = async (req, res) => {
  try {
    const { days = 7 } = req.query;

    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + parseInt(days));

    const documents = await Document.find({
      expiryDate: { $lte: expiryDate, $gte: new Date() },
      'reminder.sent': false,
    }).populate('ownerId', 'name email phone');

    for (const doc of documents) {
      // Send notification
      await Notification.create({
        recipientId: doc.ownerId._id,
        title: 'Document Expiring Soon',
        body: `Your ${doc.documentType} expires on ${doc.expiryDate.toLocaleDateString()}. Please renew it.`,
        type: 'admin',
        relatedId: doc._id,
        status: 'pending',
      });

      // Mark reminder as sent
      doc.reminder.sent = true;
      doc.reminder.sentDate = new Date();
      await doc.save();
    }

    res.status(200).json({
      success: true,
      message: `Reminders sent to ${documents.length} users`,
      data: documents,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error sending reminders',
      error: error.message,
    });
  }
};

// Delete document
exports.deleteDocument = async (req, res) => {
  try {
    const { documentId } = req.params;
    const userId = req.user.id;

    const document = await Document.findById(documentId);
    if (!document || document.ownerId.toString() !== userId) {
      return res.status(403).json({ success: false, message: 'Unauthorized' });
    }

    await Document.findByIdAndDelete(documentId);

    res.status(200).json({
      success: true,
      message: 'Document deleted',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting document',
      error: error.message,
    });
  }
};
