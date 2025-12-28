import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:cars_ahajjo/services/notification_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;

  static const String _socketUrl = 'http://localhost:5003';

  // Callbacks for events
  final Map<String, List<Function>> _listeners = {};

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  // Initialize socket connection
  void initialize() {
    socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(5)
          .build(),
    );

    socket.onConnect((_) {
      print('Socket connected: ${socket.id}');
      _emit('socket_connected', {});
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
      _emit('socket_disconnected', {});
    });

    socket.on('error', (error) {
      print('Socket error: $error');
      _emit('socket_error', {'error': error});
    });

    socket.on('connect_error', (error) {
      print('Socket connection error: $error');
      _emit('socket_error', {'error': error});
    });

    socket.on('reconnect_attempt', (_) {
      print('Attempting to reconnect...');
      _emit('socket_reconnecting', {});
    });

    socket.on('reconnect', (_) {
      print('Socket reconnected: ${socket.id}');
      _emit('socket_reconnected', {});
    });

    // Listen to all socket events
    setupListeners();
  }

  // Connect to server
  void connect() {
    if (!socket.connected) {
      socket.connect();
    }
  }

  // Disconnect from server
  void disconnect() {
    if (socket.connected) {
      socket.disconnect();
    }
  }

  // Setup all socket event listeners
  void setupListeners() {
    // Location Updates
    socket.on('driver_location_changed', (data) {
      print('Driver location changed: $data');
      _emit('driver_location_changed', data);
    });

    socket.on('active_drivers', (data) {
      print('Active drivers: $data');
      _emit('active_drivers', data);
    });

    socket.on('driver_offline', (data) {
      print('Driver offline: $data');
      _emit('driver_offline', data);
    });

    // Chat & Messages
    socket.on('message_received', (data) {
      print('Message received: $data');
      _emit('message_received', data);
      // Show local notification
      NotificationService().showNotification(
        title: 'New Message',
        body: data['message'] ?? 'You have a new message',
        payload: 'message',
      );
    });

    socket.on('user_typing', (data) {
      print('User typing: $data');
      _emit('user_typing', data);
    });

    // Driver Status
    socket.on('driver_status_updated', (data) {
      print('Driver status updated: $data');
      _emit('driver_status_updated', data);
      NotificationService().showNotification(
        title: 'Driver Status',
        body: 'Driver ${data['driverId']} is now ${data['status']}',
        payload: 'status',
      );
    });

    // Ride Requests
    socket.on('incoming_ride_request', (data) {
      print('Incoming ride request: $data');
      _emit('incoming_ride_request', data);
      NotificationService().showNotification(
        title: 'Ride Request',
        body: 'New ride request from ${data['riderId']}',
        payload: 'ride_request',
      );
    });

    socket.on('ride_response_received', (data) {
      print('Ride response received: $data');
      _emit('ride_response_received', data);
    });

    // Admin Announcements
    socket.on('announcement', (data) {
      print('Announcement: $data');
      _emit('announcement', data);
      NotificationService().showNotification(
        title: data['title'] ?? 'Announcement',
        body: data['message'] ?? '',
        payload: 'announcement',
      );
    });
  }

  // ==================== Location Events ====================

  /// Send driver's real-time location
  void sendDriverLocation(String driverId, double latitude, double longitude) {
    socket.emit('driver_location_update', {
      'driverId': driverId,
      'latitude': latitude,
      'longitude': longitude,
    });
    print('Sent driver location: $driverId, $latitude, $longitude');
  }

  /// Request list of active drivers
  void requestActiveDrivers() {
    socket.emit('get_active_drivers');
  }

  /// Update driver status (online, offline, busy)
  void updateDriverStatus(String driverId, String status) {
    socket.emit('driver_status_change', {
      'driverId': driverId,
      'status': status,
    });
    print('Driver status updated: $driverId -> $status');
  }

  // ==================== Chat Events ====================

  /// Send a new message in real-time
  void sendChatMessage(
    String senderId,
    String receiverId,
    String message,
    String conversationId,
  ) {
    socket.emit('new_message', {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'conversationId': conversationId,
    });
    print('Chat message sent: $senderId -> $receiverId');
  }

  /// Join a conversation room for real-time updates
  void joinConversation(String conversationId) {
    socket.emit('join_conversation', conversationId);
    print('Joined conversation: $conversationId');
  }

  /// Leave a conversation room
  void leaveConversation(String conversationId) {
    socket.emit('leave_conversation', conversationId);
    print('Left conversation: $conversationId');
  }

  /// Notify others that user is typing
  void notifyTyping(String conversationId, String userId) {
    socket.emit('user_typing', {
      'conversationId': conversationId,
      'userId': userId,
    });
  }

  /// Notify others that user stopped typing
  void notifyStopTyping(String conversationId, String userId) {
    socket.emit('user_stop_typing', {
      'conversationId': conversationId,
      'userId': userId,
    });
  }

  // ==================== Ride Events ====================

  /// Send a ride request to a specific driver
  void requestRide(
    String riderId,
    String driverId,
    String pickupLocation,
    String destination,
  ) {
    socket.emit('ride_request', {
      'riderId': riderId,
      'driverId': driverId,
      'pickupLocation': pickupLocation,
      'destination': destination,
    });
    print('Ride request sent: $riderId -> $driverId');
  }

  /// Respond to a ride request (accept/reject)
  void respondToRideRequest(String riderId, String driverId, bool accepted) {
    socket.emit('ride_response', {
      'riderId': riderId,
      'driverId': driverId,
      'accepted': accepted,
    });
    print('Ride response: $driverId -> $accepted');
  }

  // ==================== Event Listener Management ====================

  /// Register a callback for a specific event
  void on(String eventName, Function callback) {
    if (!_listeners.containsKey(eventName)) {
      _listeners[eventName] = [];
    }
    _listeners[eventName]!.add(callback);
  }

  /// Unregister a callback for a specific event
  void off(String eventName, Function callback) {
    if (_listeners.containsKey(eventName)) {
      _listeners[eventName]!.remove(callback);
    }
  }

  /// Emit event to all registered listeners
  void _emit(String eventName, dynamic data) {
    if (_listeners.containsKey(eventName)) {
      for (var callback in _listeners[eventName]!) {
        callback(data);
      }
    }
  }

  // Check if socket is connected
  bool get isConnected => socket.connected;

  // Get socket ID
  String? get socketId => socket.id;
}
