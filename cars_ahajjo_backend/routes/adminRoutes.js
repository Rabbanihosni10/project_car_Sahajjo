const express = require("express");
const adminController = require("../controllers/adminController");
const { requireAdmin } = require("../middleware/auth");
const router = express.Router();

// Dashboard & Analytics
router.get("/dashboard/stats", requireAdmin, adminController.getDashboardStats);
router.get("/revenue/stats", requireAdmin, adminController.getRevenueStats);
router.get("/health", adminController.getHealthCheck);

// User Management
router.get("/users", requireAdmin, adminController.getAllUsers);
router.get("/users/:userId", requireAdmin, adminController.getUserDetails);
router.put("/users/:userId/ban", requireAdmin, adminController.toggleUserBan);
router.put("/users/:userId/deactivate", requireAdmin, adminController.deactivateUser);

// Transaction Management
router.get("/transactions", requireAdmin, adminController.getTransactions);

// Rating & Review Moderation
router.get("/ratings", requireAdmin, adminController.getRatings);
router.put("/ratings/:ratingId/flag", requireAdmin, adminController.toggleRatingFlag);

// System Logs
router.get("/logs", requireAdmin, adminController.getSystemLogs);

// Announcements
router.post("/announcements", requireAdmin, adminController.sendAnnouncement);

module.exports = router;
