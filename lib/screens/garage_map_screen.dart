import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cars_ahajjo/services/location_service.dart';

class GarageMapScreen extends StatefulWidget {
  const GarageMapScreen({super.key});

  @override
  State<GarageMapScreen> createState() => _GarageMapScreenState();
}

class _GarageMapScreenState extends State<GarageMapScreen> {
  late GoogleMapController mapController;
  Position? _currentPosition;
  final Set<Marker> markers = {};
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

      // Fetch nearby garages
      await _fetchNearbyGarages();
    } catch (e) {
      print('Error initializing location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error getting your location')),
      );
    }
  }

  Future<void> _fetchNearbyGarages() async {
    if (_currentPosition == null) return;

    try {
      final nearby = await LocationService.getNearbyGarages(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        maxDistance: 10000, // 10km
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
    if (_initialPosition == null) return;
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _initialPosition!,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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

        markers.add(
          Marker(
            markerId: MarkerId('garage_$i'),
            position: position,
            infoWindow: InfoWindow(
              title: garage['name'] ?? 'Garage',
              snippet: garage['address'] ?? '',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_initialPosition != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(_initialPosition!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Garages'),
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
                      : GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _initialPosition!,
                            zoom: 14,
                          ),
                          markers: markers,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: true,
                        ),
                ),
                if (garages.isNotEmpty)
                  Container(
                    height: 120,
                    color: Colors.white,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      itemCount: garages.length,
                      itemBuilder: (context, index) {
                        final garage = garages[index];
                        return _buildGarageCard(garage);
                      },
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No garages found nearby',
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
                      '${garage['name']} - Call feature coming soon',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: Colors.blue[600],
              ),
              child: const Text(
                'Contact',
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
    mapController.dispose();
    super.dispose();
  }
}
