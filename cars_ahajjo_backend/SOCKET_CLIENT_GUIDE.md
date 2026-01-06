# Socket.io Client Connection Guide

## ✅ Issues Fixed

### Backend Fixes Applied:

1. ✅ Removed duplicate disconnect handlers
2. ✅ Added proper transport configuration (websocket + polling fallback)
3. ✅ Optimized ping/pong intervals (10s/30s instead of 25s/60s)
4. ✅ Added user identification system
5. ✅ Added heartbeat mechanism
6. ✅ Improved error logging
7. ✅ Added connection state tracking

## 📱 Flutter/Dart Client Implementation

### 1. Add socket_io_client Dependency

```yaml
# pubspec.yaml
dependencies:
  socket_io_client: ^2.0.3+1
```

### 2. Socket Service Implementation

```dart
// lib/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connect(String userId, String role) {
    if (_socket != null && _isConnected) {
      print('Socket already connected');
      return;
    }

    _socket = IO.io(
      'http://your-backend-url:5003',
      IO.OptionBuilder()
        .setTransports(['websocket', 'polling']) // Use websocket first, fallback to polling
        .enableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(1000)
        .setReconnectionDelayMax(5000)
        .setTimeout(20000)
        .setExtraHeaders({'foo': 'bar'}) // Optional headers
        .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Socket connected: ${_socket!.id}');
      _isConnected = true;

      // Identify user to server
      _socket!.emit('user_identify', {
        'userId': userId,
        'role': role,
      });

      // Start heartbeat
      _startHeartbeat();
    });

    _socket!.onConnectError((data) {
      print('❌ Connection Error: $data');
      _isConnected = false;
    });

    _socket!.onConnectTimeout((data) {
      print('⏱️ Connection Timeout: $data');
      _isConnected = false;
    });

    _socket!.onError((error) {
      print('❌ Socket Error: $error');
    });

    _socket!.onDisconnect((reason) {
      print('❌ Disconnected: $reason');
      _isConnected = false;
      _stopHeartbeat();
    });

    _socket!.onReconnect((attempt) {
      print('🔄 Reconnected after $attempt attempts');
    });

    _socket!.onReconnectAttempt((attempt) {
      print('🔄 Reconnection attempt $attempt');
    });

    _socket!.onReconnectFailed((_) {
      print('❌ Reconnection failed after all attempts');
    });

    // Custom event handlers
    _setupEventHandlers();

    _socket!.connect();
  }

  Timer? _heartbeatTimer;

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      if (_isConnected && _socket != null) {
        _socket!.emit('ping');
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
  }

  void _setupEventHandlers() {
    _socket!.on('pong', (_) {
      // Server responded to ping
    });

    _socket!.on('message_received', (data) {
      print('📩 Message received: $data');
      // Handle incoming messages
    });

    _socket!.on('driver_location_changed', (data) {
      print('📍 Driver location updated: $data');
      // Handle driver location updates
    });

    _socket!.on('driver_offline', (data) {
      print('👋 Driver went offline: $data');
      // Handle driver going offline
    });

    // Add more event handlers as needed
  }

  void sendMessage(String receiverId, String message) {
    if (_socket != null && _isConnected) {
      _socket!.emit('new_message', {
        'senderId': 'currentUserId',
        'receiverId': receiverId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void updateDriverLocation(String driverId, double lat, double lng) {
    if (_socket != null && _isConnected) {
      _socket!.emit('driver_location_update', {
        'driverId': driverId,
        'latitude': lat,
        'longitude': lng,
      });
    }
  }

  void disconnect() {
    _stopHeartbeat();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    print('Socket disconnected manually');
  }
}
```

### 3. Usage in Your App

```dart
// When user logs in
void onLogin(String userId, String role) {
  SocketService().connect(userId, role);
}

// When sending messages
void sendMessage(String receiverId, String message) {
  SocketService().sendMessage(receiverId, message);
}

// When app is paused (optional - keep connection alive)
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    // Don't disconnect, keep connection alive
  } else if (state == AppLifecycleState.resumed) {
    // Reconnect if disconnected
    if (!SocketService().isConnected) {
      SocketService().connect(userId, role);
    }
  }
}

// When user logs out
void onLogout() {
  SocketService().disconnect();
}
```

## 🔧 Common Issues & Solutions

### Issue 1: Socket keeps disconnecting

**Solution**:

- Ensure backend is running
- Check if firewall is blocking WebSocket connections
- Use polling transport as fallback

### Issue 2: Can't connect on mobile devices

**Solution**:

- Use your computer's local IP instead of localhost
- Example: `http://192.168.1.100:5003` instead of `http://localhost:5003`

### Issue 3: Connection works on WiFi but not mobile data

**Solution**:

- Deploy backend to a public server (Heroku, AWS, etc.)
- Ensure server has proper SSL certificate for WSS (secure websocket)

### Issue 4: Disconnects after 30 seconds

**Solution**:

- Heartbeat is now implemented
- Client sends ping every 15 seconds
- Server waits 30 seconds for pong

## 📊 Testing Socket Connection

### Test in Browser Console:

```javascript
const socket = io("http://localhost:5003", {
  transports: ["websocket", "polling"],
});

socket.on("connect", () => {
  console.log("Connected:", socket.id);

  // Identify user
  socket.emit("user_identify", {
    userId: "test-user-123",
    role: "driver",
  });

  // Test ping
  setInterval(() => {
    socket.emit("ping");
  }, 15000);
});

socket.on("pong", () => {
  console.log("Pong received");
});

socket.on("disconnect", (reason) => {
  console.log("Disconnected:", reason);
});
```

## 🎯 Best Practices

1. **Always identify users** after connection:

   ```dart
   socket.emit('user_identify', { userId: userId, role: role });
   ```

2. **Implement heartbeat** to keep connection alive:

   ```dart
   Timer.periodic(Duration(seconds: 15), (_) => socket.emit('ping'));
   ```

3. **Handle reconnection** gracefully:

   ```dart
   socket.onReconnect((_) {
     // Re-identify user
     // Re-subscribe to rooms
     // Refresh data
   });
   ```

4. **Clean up** on logout:

   ```dart
   socket.disconnect();
   socket.dispose();
   ```

5. **Use connection state** before emitting:
   ```dart
   if (socket.connected) {
     socket.emit('event', data);
   }
   ```

## 🔍 Debugging

Enable Socket.io client logging:

```dart
_socket = IO.io(url,
  IO.OptionBuilder()
    .enableForceNew()
    .enableForceNewConnection()
    .setTransports(['websocket'])
    .build()
);

// Add debug logging
_socket!.onAny((event, data) {
  print('Socket Event: $event, Data: $data');
});
```

## 📝 Server Logs

The server now logs:

- ✅ New connections with socket ID
- 👤 User identification
- ❌ Disconnections with reason
- 🔄 Location updates
- 📩 Messages
- ⚠️ Errors

Check backend console for these logs to debug connection issues.
