class Garage {
  final String? id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final List<String> services;
  final double? rating;
  final String? ownerId;
  final DateTime? createdAt;

  Garage({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.services,
    this.rating,
    this.ownerId,
    this.createdAt,
  });

  factory Garage.fromJson(Map<String, dynamic> json) {
    return Garage(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      latitude: _parseLatLng(json, 'latitude'),
      longitude: _parseLatLng(json, 'longitude'),
      services: json['services'] != null
          ? List<String>.from(json['services'])
          : [],
      rating: json['rating']?.toDouble(),
      ownerId: json['ownerId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  static double _parseLatLng(Map<String, dynamic> json, String key) {
    if (json[key] != null) {
      return json[key].toDouble();
    }
    // Handle MongoDB location format
    if (json['location'] != null && json['location']['coordinates'] != null) {
      final coords = json['location']['coordinates'];
      return key == 'latitude' ? coords[1].toDouble() : coords[0].toDouble();
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'location': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'services': services,
      if (rating != null) 'rating': rating,
      if (ownerId != null) 'ownerId': ownerId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
