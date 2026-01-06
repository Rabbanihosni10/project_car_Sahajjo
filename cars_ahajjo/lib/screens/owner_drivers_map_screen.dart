import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cars_ahajjo/services/driver_location_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class OwnerDriversMapScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const OwnerDriversMapScreen({super.key, this.userData});

  @override
  State<OwnerDriversMapScreen> createState() => _OwnerDriversMapScreenState();
}

class _OwnerDriversMapScreenState extends State<OwnerDriversMapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  List<Map<String, dynamic>> _drivers = [];
  bool _isLoading = true;
  LatLng? _initialPosition;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchDriverLocations();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services')),
          );
        }
        // Use default location (Dhaka)
        setState(() {
          _initialPosition = const LatLng(23.8103, 90.4125);
        });
        await _fetchDriverLocations();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _initialPosition = const LatLng(23.8103, 90.4125);
          });
          await _fetchDriverLocations();
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });

      _addCurrentLocationMarker();
      await _fetchDriverLocations();
    } catch (e) {
      print('Error initializing location: $e');
      setState(() {
        _initialPosition = const LatLng(23.8103, 90.4125);
      });
      await _fetchDriverLocations();
    }
  }

  Future<void> _fetchDriverLocations() async {
    try {
      final ownerId =
          widget.userData?['id'] ?? widget.userData?['_id'] ?? 'mock_owner';
      final drivers = await DriverLocationService.getOwnerDriversLocations(
        ownerId,
      );

      if (mounted) {
        setState(() {
          _drivers = drivers;
          _isLoading = false;
        });

        _updateDriverMarkers();
      }
    } catch (e) {
      print('Error fetching driver locations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addCurrentLocationMarker() {
    if (_initialPosition == null) return;
    _markers.add(
      Marker(
        point: _initialPosition!,
        width: 40,
        height: 40,
        child: const Icon(Icons.my_location, color: Colors.blue, size: 28),
      ),
    );
  }

  void _updateDriverMarkers() {
    // Clear old driver markers (keep current location)
    _markers.removeWhere((marker) => marker.point != _initialPosition);

    for (final driver in _drivers) {
      final location = driver['location'];
      if (location != null &&
          location['latitude'] != null &&
          location['longitude'] != null) {
        final position = LatLng(location['latitude'], location['longitude']);
        final isActive = driver['status'] == 'active';

        _markers.add(
          Marker(
            point: position,
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () => _showDriverInfo(driver),
              child: Stack(
                children: [
                  Icon(
                    Icons.local_taxi,
                    color: isActive ? Colors.green : Colors.grey,
                    size: 36,
                  ),
                  if (isActive)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  void _showDriverInfo(Map<String, dynamic> driver) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: driver['status'] == 'active'
                      ? Colors.green[100]
                      : Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    color: driver['status'] == 'active'
                        ? Colors.green[700]
                        : Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver['driverName'] ?? 'Driver',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        driver['phone'] ?? 'No phone',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    driver['status'] == 'active' ? 'ACTIVE' : 'OFFLINE',
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  backgroundColor: driver['status'] == 'active'
                      ? Colors.green
                      : Colors.grey,
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.directions_car,
              'Car',
              driver['carModel'] ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.pin, 'Plate', driver['carPlate'] ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              'Last Update',
              _formatLastUpdated(driver['lastUpdated']),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _centerOnDriver(driver);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.my_location, size: 18),
                    label: const Text('Center on Map'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement call functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Call feature coming soon'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  void _centerOnDriver(Map<String, dynamic> driver) {
    final location = driver['location'];
    if (location != null) {
      _mapController.move(
        LatLng(location['latitude'], location['longitude']),
        15,
      );
    }
  }

  String _formatLastUpdated(String? timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hr ago';
      } else {
        return DateFormat('MMM dd, hh:mm a').format(dateTime);
      }
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Drivers'),
        elevation: 0,
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDriverLocations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Status banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.blue[50],
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_drivers.length} driver(s) • Auto-refresh every 30s',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                      Text(
                        '${_drivers.where((d) => d['status'] == 'active').length} active',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _initialPosition == null
                      ? const Center(child: CircularProgressIndicator())
                      : FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _initialPosition!,
                            initialZoom: 13,
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
                // Driver list at bottom
                if (_drivers.isNotEmpty)
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      itemCount: _drivers.length,
                      itemBuilder: (context, index) {
                        final driver = _drivers[index];
                        return _buildDriverCard(driver);
                      },
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'No drivers found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    final isActive = driver['status'] == 'active';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => _showDriverInfo(driver),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_taxi,
                    color: isActive ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      driver['driverName'] ?? 'Driver',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                driver['carModel'] ?? 'Unknown',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isActive ? 'Active' : 'Offline',
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? Colors.green[700] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
