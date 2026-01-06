import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cars_ahajjo/services/garage_service.dart';

class OwnerGarageMapScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const OwnerGarageMapScreen({super.key, this.userData});

  @override
  State<OwnerGarageMapScreen> createState() => _OwnerGarageMapScreenState();
}

class _OwnerGarageMapScreenState extends State<OwnerGarageMapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  final List<Marker> _markers = [];
  List<dynamic> ownerGarages = [];
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission required')),
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
      });

      // Add current location marker
      _addCurrentLocationMarker();

      // Fetch owner garages
      await _fetchOwnerGarages();
    } catch (e) {
      print('Error initializing location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error getting your location')),
      );
    }
  }

  Future<void> _fetchOwnerGarages() async {
    if (_currentPosition == null) return;

    try {
      // Fetch all garages and filter by owner ID (or fetch owner-specific endpoint)
      final allGarages = await GarageService.getNearbyGarages(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusInKm: 50, // Wider radius to fetch all owner garages
      );

      setState(() {
        ownerGarages = allGarages;
        _isLoading = false;
      });

      _addGarageMarkers();
    } catch (e) {
      print('Error fetching garages: $e');
      setState(() => _isLoading = false);
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
    for (int i = 0; i < ownerGarages.length; i++) {
      final garage = ownerGarages[i];
      final location = garage['location'];
      if (location != null && location['coordinates'] != null) {
        final coordinates = location['coordinates'];
        final position = LatLng(coordinates[1], coordinates[0]);

        _markers.add(
          Marker(
            point: position,
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.red, size: 32),
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
        title: const Text('My Garages'),
        elevation: 0,
        backgroundColor: Colors.blue[600],
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
                            initialZoom: 12,
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
                if (ownerGarages.isNotEmpty)
                  Container(
                    height: 120,
                    color: Colors.white,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      itemCount: ownerGarages.length,
                      itemBuilder: (context, index) {
                        final garage = ownerGarages[index];
                        return _buildGarageCard(garage);
                      },
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No garages found',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildGarageCard(dynamic garage) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              garage['name'] ?? 'Garage',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              garage['address'] ?? 'Address',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (garage['phone'] != null)
              Text(
                garage['phone'],
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${garage['name']} - Edit feature coming soon',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: Colors.red[600],
              ),
              child: const Text(
                'Details',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
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
