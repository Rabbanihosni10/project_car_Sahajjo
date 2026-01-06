import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cars_ahajjo/services/location_service.dart';
import 'package:cars_ahajjo/services/auth_services.dart';

class DriverLiveLocationScreen extends StatefulWidget {
  const DriverLiveLocationScreen({super.key});

  @override
  State<DriverLiveLocationScreen> createState() =>
      _DriverLiveLocationScreenState();
}

class _DriverLiveLocationScreenState extends State<DriverLiveLocationScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isSharing = false;
  StreamSubscription<Position>? _positionSub;

  final List<Marker> _markers = [];
  LatLng? _initialPosition;
  String? _driverId;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _initializeSocket();
  }

  /// Initialize Socket.io for real-time location broadcasting
  void _initializeSocket() async {
    _driverId = await AuthService.getUserId();
    LocationService.initializeSocket();

    // Listen for other drivers' location updates
    LocationService.onDriverLocationChanged((data) {
      print('Driver location changed: $data');
      final driverId = data['driverId'];
      final latitude = data['latitude'];
      final longitude = data['longitude'];

      if (driverId != _driverId) {
        setState(() {
          _markers.add(
            Marker(
              point: LatLng(latitude, longitude),
              width: 40,
              height: 40,
              child: const Icon(
                Icons.local_taxi,
                color: Colors.orange,
                size: 32,
              ),
            ),
          );
        });
      }
    });
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable location services'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission is required'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _initialPosition = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            point: _initialPosition!,
            width: 40,
            height: 40,
            child: const Icon(Icons.my_location, color: Colors.blue, size: 28),
          ),
        );
      });
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error getting your location'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startSharingLocation() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Location not available')));
      return;
    }

    setState(() => _isSharing = true);

    final success = await LocationService.updateLocation(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    if (success) {
      if (_driverId != null) {
        LocationService.setDriverStatus(_driverId!, 'online');
      }

      // Start streaming continuous updates
      _positionSub?.cancel();
      _positionSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen((pos) async {
            _currentPosition = pos;
            _initialPosition = LatLng(pos.latitude, pos.longitude);
            _markers
              ..clear()
              ..add(
                Marker(
                  point: _initialPosition!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
              );
            _mapController.move(_initialPosition!, 15);
            await LocationService.updateLocation(pos.latitude, pos.longitude);
            if (mounted) setState(() {});
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Live location sharing started'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to share location'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSharing = false);
    }
  }

  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _initialPosition = LatLng(position.latitude, position.longitude);
        _markers.clear();
        _markers.add(
          Marker(
            point: _initialPosition!,
            width: 40,
            height: 40,
            child: const Icon(Icons.my_location, color: Colors.blue, size: 28),
          ),
        );
      });

      _mapController.move(_initialPosition!, 15);

      // Auto-share location every 5 seconds
      if (_isSharing) {
        await LocationService.updateLocation(
          position.latitude,
          position.longitude,
        );
      }
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Live Location'),
        elevation: 0,
        backgroundColor: Colors.blue[600],
      ),
      body: Column(
        children: [
          Expanded(
            child: _initialPosition == null
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _initialPosition!,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.cars.ahajjo',
                      ),
                      MarkerLayer(markers: _markers),
                    ],
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isSharing ? Icons.location_on : Icons.location_off,
                            color: _isSharing ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isSharing
                                ? 'Location Sharing: Active'
                                : 'Location Sharing: Inactive',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _isSharing ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      if (_currentPosition != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isSharing ? null : _startSharingLocation,
                  icon: Icon(
                    _isSharing ? Icons.check_circle : Icons.share_location,
                  ),
                  label: Text(
                    _isSharing ? 'Sharing Location' : 'Start Sharing',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _updateLocation,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    if (_driverId != null) {
      LocationService.setDriverStatus(_driverId!, 'offline');
    }
    LocationService.disconnectSocket();
    super.dispose();
  }
}
