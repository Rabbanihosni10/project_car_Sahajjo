const mongoose = require('mongoose');

const documentSchema = new mongoose.Schema({
  ownerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  documentType: {
    type: String,
    enum: ['driver_license', 'nid', 'vehicle_registration', 'vehicle_insurance', 'tax_certificate', 'pollution_certificate', 'fitness_certificate'],
    required: true,
  },
  documentNumber: String,
  issuingAuthority: String,
  issueDate: Date,
  expiryDate: Date,
  fileUrl: {
    type: String,
    required: true,
  },
  fileName: String,
  fileSize: Number,
  mimeType: String,
  status: {
    type: String,
    enum: ['pending', 'verified', 'rejected', 'expired'],
    default: 'pending',
  },
  verificationNotes: String,
  verifiedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  verifiedAt: Date,
  reminder: {
    sent: {
      type: Boolean,
      default: false,
    },
    sentDate: Date,
  },
  metadata: {
    // Additional fields for different document types
    type: Map,
    of: String,
  },
  uploadedAt: {
    type: Date,
    default: Date.now,
  },
});

// Index to find expiring documents
documentSchema.index({ expiryDate: 1 });
documentSchema.index({ ownerId: 1, documentType: 1 });

module.exports = mongoose.model('Document', documentSchema);
