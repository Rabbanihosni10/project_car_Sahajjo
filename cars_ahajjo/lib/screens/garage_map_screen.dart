import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cars_ahajjo/services/garage_service.dart';

class GarageMapScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const GarageMapScreen({super.key, this.userData});

  @override
  State<GarageMapScreen> createState() => _GarageMapScreenState();
}

class _GarageMapScreenState extends State<GarageMapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  final List<Marker> _markers = [];
  List<dynamic> garages = [];
  bool _isLoading = true;
  LatLng? _initialPosition;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
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
        // Use default location (Dhaka) if service not enabled
        setState(() {
          _initialPosition = const LatLng(23.8103, 90.4125); // Dhaka
        });
        await _fetchNearbyGarages();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission required')),
            );
          }
          // Use default location
          setState(() {
            _initialPosition = const LatLng(23.8103, 90.4125); // Dhaka
          });
          await _fetchNearbyGarages();
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _initialPosition = LatLng(position.latitude, position.longitude);
      });

      // Add current location marker
      _addCurrentLocationMarker();

      // Fetch nearby garages
      await _fetchNearbyGarages();
    } catch (e) {
      print('Error initializing location: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Using default location')));
      }
      // Use default location on error
      setState(() {
        _initialPosition = const LatLng(23.8103, 90.4125); // Dhaka
      });
      await _fetchNearbyGarages();
    }
  }

  Future<void> _fetchNearbyGarages() async {
    // Use current position or default Dhaka location
    final lat =
        _currentPosition?.latitude ?? _initialPosition?.latitude ?? 23.8103;
    final lng =
        _currentPosition?.longitude ?? _initialPosition?.longitude ?? 90.4125;

    try {
      final nearby = await GarageService.getNearbyGarages(
        latitude: lat,
        longitude: lng,
        radiusInKm: 10,
      );

      setState(() {
        garages = nearby;
        _isLoading = false;
      });

      print('Loaded ${garages.length} garages');
      _addGarageMarkers();
    } catch (e) {
      print('Error fetching garages: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error loading garages')));
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

  void _addGarageMarkers() {
    for (int i = 0; i < garages.length; i++) {
      final garage = garages[i];
      final location = garage['location'];
      if (location != null && location['coordinates'] != null) {
        final coordinates = location['coordinates'];
        final position = LatLng(coordinates[1], coordinates[0]);

        _markers.add(
          Marker(
            point: position,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              color: Colors.orange,
              size: 32,
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Garages'),
        elevation: 0,
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchNearbyGarages();
            },
            tooltip: 'Refresh garages',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _initialPosition == null
                      ? const Center(child: CircularProgressIndicator())
                      : FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _initialPosition!,
                            initialZoom: 14,
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
                if (garages.isNotEmpty)
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${garages.length} Garages Nearby',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Swipe to view →',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: garages.length,
                            itemBuilder: (context, index) {
                              final garage = garages[index];
                              return _buildGarageCard(garage);
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No garages found nearby. Pull to refresh.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildGarageCard(dynamic garage) {
    final rating = garage['rating']?.toString() ?? '4.5';
    final services = garage['services'] as List?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange[700], size: 20),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    garage['name'] ?? 'Garage',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[700], size: 16),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              garage['address'] ?? 'Address',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (services != null && services.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                services.take(2).join(', '),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Spacer(),
            Row(
              children: [
                if (garage['phone'] != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Call: ${garage['phone']}'),
                            action: SnackBarAction(
                              label: 'OK',
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone, size: 14),
                      label: const Text('Call', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
