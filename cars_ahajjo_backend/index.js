const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const http = require("http");
const socketIO = require("socket.io");
const connectMongo = require("./config/db");
const { seedAdmin } = require("./utils/seedAdmin");

dotenv.config(); //.env configure
connectMongo();  // mongodb connected
// Ensure admin user exists with requested credentials
seedAdmin();
const app = express();  // express app

// Create HTTP server for Socket.io
const server = http.createServer(app);
const io = socketIO(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
    credentials: true
  },
  // Improve socket connection stability
  transports: ['websocket', 'polling'],
  allowEIO3: true,
  pingInterval: 10000,     // Send ping every 10 seconds
  pingTimeout: 30000,      // Wait 30 seconds for pong before disconnecting
  upgradeTimeout: 30000,   // Time to wait for upgrade
  maxHttpBufferSize: 1e8,  // 100 MB max buffer
  connectTimeout: 45000,   // Connection timeout
  allowUpgrades: true,
  perMessageDeflate: false // Disable compression to reduce CPU load
});

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// Make io accessible to routes (must be before route handlers)
app.use((req, res, next) => {
  req.io = io;
  next();
});

app.use("/api/auth", require("./routes/authRoutes"));
app.use("/api/location", require("./routes/locationRoutes"));
app.use("/api/garages", require("./routes/garageRoutes"));
app.use("/api/messages", require("./routes/messageRoutes"));
app.use("/api/drivers", require("./routes/driverRoutes"));
app.use("/api/payments", require("./routes/paymentRoutes"));
app.use("/api/search", require("./routes/searchRoutes"));
app.use("/api/ratings", require("./routes/ratingRoutes"));
app.use("/api/rides", require("./routes/rideRoutes"));
app.use("/api/jobs", require("./routes/jobRoutes"));
app.use("/api/fares", require("./routes/fareRoutes"));
app.use("/api/rentals", require("./routes/rentalRoutes"));
app.use("/api/marketplace", require("./routes/marketplaceRoutes"));
app.use("/api/forum", require("./routes/forumRoutes"));
app.use("/api/notifications", require("./routes/notificationRoutes"));
app.use("/api/documents", require("./routes/documentRoutes"));
app.use("/api/admin", require("./routes/adminRoutes"));
app.use("/api/chat", require("./routes/chatRoutes"));
app.use("/api/people", require("./routes/peopleRoutes"));
// Minimal admin UI demo routes (serve HTML with Admin Panel button)
app.use("/admin-ui", require("./routes/adminUiRoutes"));
// Map APIs and interactive map UI
app.use("/api/map", require("./routes/mapRoutes"));
app.use("/map", require("./routes/mapUiRoutes"));
// Home UI with Login and Admin Panel buttons
app.use("/", require("./routes/homeUiRoutes"));

// Socket.io Event Handling
const driverLocations = {}; // Store active driver locations { driverId: { lat, lng, timestamp } }
const userSockets = {}; // Track user sockets { userId: socketId }

io.on("connection", (socket) => {
  console.log("✅ New user connected:", socket.id);

  // User identification
  socket.on("user_identify", (data) => {
    const { userId, role } = data;
    if (userId) {
      socket.userId = userId;
      socket.userRole = role;
      userSockets[userId] = socket.id;
      console.log(`User identified: ${userId} (${role}) - Socket: ${socket.id}`);
    }
  });

  // Handle connection errors
  socket.on("error", (error) => {
    console.error(`❌ Socket error for ${socket.id}:`, error);
  });

  // Heartbeat to keep connection alive
  socket.on("ping", () => {
    socket.emit("pong");
  });

  // Location Updates - Driver sends real-time location
  socket.on("driver_location_update", (data) => {
    const { driverId, latitude, longitude } = data;
    
    console.log(`📍 Location update from driver ${driverId}: lat=${latitude}, lng=${longitude}`);
    
    // Store driver location
    driverLocations[driverId] = {
      socketId: socket.id,
      latitude,
      longitude,
      timestamp: new Date()
    };

    // Broadcast location to all connected users
    socket.broadcast.emit("driver_location_changed", {
      driverId,
      latitude,
      longitude,
      timestamp: new Date()
    });

    console.log(`Driver ${driverId} location updated:`, latitude, longitude);
  });

  // Chat Messages - Send real-time chat notifications
  socket.on("new_message", (data) => {
    const { senderId, receiverId, message, conversationId } = data;

    // Emit to the specific receiver
    io.emit("message_received", {
      senderId,
      receiverId,
      message,
      conversationId,
      timestamp: new Date()
    });

    console.log(`Message from ${senderId} to ${receiverId}`);
  });

  // Join Chat Room - Users join conversation rooms
  socket.on("join_conversation", (conversationId) => {
    socket.join(`conversation_${conversationId}`);
    console.log(`User joined conversation: ${conversationId}`);
  });

  // Leave Chat Room
  socket.on("leave_conversation", (conversationId) => {
    socket.leave(`conversation_${conversationId}`);
    console.log(`User left conversation: ${conversationId}`);
  });

  // Typing Indicator
  socket.on("user_typing", (data) => {
    const { conversationId, userId } = data;
    io.to(`conversation_${conversationId}`).emit("user_typing", {
      userId,
      isTyping: true
    });
  });

  socket.on("user_stop_typing", (data) => {
    const { conversationId, userId } = data;
    io.to(`conversation_${conversationId}`).emit("user_typing", {
      userId,
      isTyping: false
    });
  });

  // Driver Status - Online/Offline/Busy
  socket.on("driver_status_change", (data) => {
    const { driverId, status } = data; // status: online, offline, busy
    
    socket.broadcast.emit("driver_status_updated", {
      driverId,
      status,
      timestamp: new Date()
    });

    console.log(`Driver ${driverId} status: ${status}`);
  });

  // Ride Request Notification
  socket.on("ride_request", (data) => {
    const { riderId, driverId, pickupLocation, destination } = data;
    
    io.to(`driver_${driverId}`).emit("incoming_ride_request", {
      riderId,
      pickupLocation,
      destination,
      timestamp: new Date()
    });

    console.log(`Ride request from ${riderId} to ${driverId}`);
  });

  // Ride Acceptance/Rejection
  socket.on("ride_response", (data) => {
    const { riderId, driverId, accepted } = data;
    
    io.to(`rider_${riderId}`).emit("ride_response_received", {
      driverId,
      accepted,
      timestamp: new Date()
    });

    console.log(`Ride response from ${driverId}: ${accepted ? "Accepted" : "Rejected"}`);
  });

  // Get Active Drivers
  socket.on("get_active_drivers", () => {
    socket.emit("active_drivers", driverLocations);
  });

  // Disconnect Handler - SINGLE handler at the end
  socket.on("disconnect", (reason) => {
    console.log(`❌ User ${socket.id} disconnected. Reason: ${reason}`);
    
    // Clean up user socket mapping
    if (socket.userId) {
      delete userSockets[socket.userId];
      console.log(`Cleaned up socket mapping for user: ${socket.userId}`);
    }
    
    // Clean up driver location data
    for (const driverId in driverLocations) {
      if (driverLocations[driverId].socketId === socket.id) {
        delete driverLocations[driverId];
        io.emit("driver_offline", { driverId });
        console.log(`Cleaned up location for driver: ${driverId}`);
      }
    }
  });
});

const PORT = process.env.PORT || 5003;
server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

