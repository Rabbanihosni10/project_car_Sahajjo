import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cars_ahajjo/services/garage_service.dart';

class GoogleGarageMapScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const GoogleGarageMapScreen({super.key, this.userData});

  @override
  State<GoogleGarageMapScreen> createState() => _GoogleGarageMapScreenState();
}

class _GoogleGarageMapScreenState extends State<GoogleGarageMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  List<dynamic> garages = [];
  bool _isLoading = true;
  LatLng _initialPosition = const LatLng(23.8103, 90.4125); // Dhaka default

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
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
          await _fetchNearbyGarages();
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
      await _fetchNearbyGarages();
    } catch (e) {
      print('Error initializing location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error getting your location')),
        );
      }
      await _fetchNearbyGarages();
    }
  }

  Future<void> _fetchNearbyGarages() async {
    try {
      final nearby = await GarageService.getNearbyGarages(
        latitude: _initialPosition.latitude,
        longitude: _initialPosition.longitude,
        radiusInKm: 10,
      );

      setState(() {
        garages = nearby;
        _isLoading = false;
      });

      _addGarageMarkers();
    } catch (e) {
      print('Error fetching garages: $e');
      setState(() => _isLoading = false);
    }
  }

  void _addCurrentLocationMarker() {
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _initialPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
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
            markerId: MarkerId('garage_$i'),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            infoWindow: InfoWindow(
              title: garage['name'] ?? 'Garage',
              snippet: garage['address'] ?? 'Tap for details',
              onTap: () => _showGarageDetails(garage),
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  void _showGarageDetails(dynamic garage) {
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
                const Icon(Icons.location_on, color: Colors.orange, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    garage['name'] ?? 'Garage',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (garage['address'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.place, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(garage['address'])),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (garage['phone'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.phone, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(garage['phone']),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (garage['services'] != null) ...[
              const Row(
                children: [
                  Icon(Icons.build, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Services:'),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (garage['services'] as List)
                    .map(
                      (service) => Chip(
                        label: Text(service.toString()),
                        backgroundColor: Colors.blue[50],
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (garage['rating'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.star, size: 20, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text('${garage['rating']} / 5.0'),
                ],
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Call ${garage['phone'] ?? 'garage'}'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.phone),
                label: const Text('Call Garage'),
              ),
            ),
          ],
        ),
      ),
    );
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
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 14,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                if (garages.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
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
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(8),
                        itemCount: garages.length,
                        itemBuilder: (context, index) {
                          final garage = garages[index];
                          return _buildGarageCard(garage);
                        },
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildGarageCard(dynamic garage) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => _showGarageDetails(garage),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                garage['name'] ?? 'Garage',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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
              const Spacer(),
              if (garage['rating'] != null)
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${garage['rating']}',
                      style: const TextStyle(fontSize: 12),
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
