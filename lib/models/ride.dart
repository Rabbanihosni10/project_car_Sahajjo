class Ride {
  final String id;
  final String riderId;
  final String? driverId;
  final Map<String, dynamic> pickupLocation;
  final Map<String, dynamic> dropLocation;
  final double distance;
  final int duration;
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double? surgeFare;
  final double tax;
  final double totalFare;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final Map<String, dynamic>? riderRating;
  final Map<String, dynamic>? driverRating;
  final String? notes;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  Ride({
    required this.id,
    required this.riderId,
    this.driverId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.distance,
    required this.duration,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    this.surgeFare,
    required this.tax,
    required this.totalFare,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.riderRating,
    this.driverRating,
    this.notes,
    required this.requestedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['_id'] as String,
      riderId: json['riderId'] as String,
      driverId: json['driverId'] as String?,
      pickupLocation: json['pickupLocation'] as Map<String, dynamic>,
      dropLocation: json['dropLocation'] as Map<String, dynamic>,
      distance: (json['distance'] as num).toDouble(),
      duration: json['duration'] as int,
      baseFare: (json['baseFare'] as num).toDouble(),
      distanceFare: (json['distanceFare'] as num).toDouble(),
      timeFare: (json['timeFare'] as num).toDouble(),
      surgeFare: json['surgeFare'] != null
          ? (json['surgeFare'] as num).toDouble()
          : null,
      tax: (json['tax'] as num).toDouble(),
      totalFare: (json['totalFare'] as num).toDouble(),
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: json['paymentStatus'] as String,
      riderRating: json['riderRating'] as Map<String, dynamic>?,
      driverRating: json['driverRating'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
    );
  }

  bool get isActive =>
      ['requested', 'accepted', 'in_progress'].contains(status);
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}
