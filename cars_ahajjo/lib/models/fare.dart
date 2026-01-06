class Fare {
  final String id;
  final String rideId;
  final String riderName;
  final String driverName;
  final double distance;
  final int durationMinutes;
  final double fare;
  final double tax;
  final double total;
  final double surgeMultiplier;
  final String paymentMethod;
  final String currency;
  final String status;
  final DateTime recordedAt;

  Fare({
    required this.id,
    required this.rideId,
    required this.riderName,
    required this.driverName,
    required this.distance,
    required this.durationMinutes,
    required this.fare,
    required this.tax,
    required this.total,
    required this.surgeMultiplier,
    required this.paymentMethod,
    required this.currency,
    required this.status,
    required this.recordedAt,
  });

  factory Fare.fromJson(Map<String, dynamic> json) {
    return Fare(
      id: json['_id'] ?? '',
      rideId: json['rideId'] ?? '',
      riderName: json['riderId']?['name'] ?? 'Unknown',
      driverName: json['driverId']?['name'] ?? 'Unknown',
      distance: (json['distance'] ?? 0).toDouble(),
      durationMinutes: json['durationMinutes'] ?? 0,
      fare: (json['fare'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      surgeMultiplier: (json['surgeMultiplier'] ?? 1.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'cash',
      currency: json['currency'] ?? 'BDT',
      status: json['status'] ?? 'completed',
      recordedAt: DateTime.parse(
        json['recordedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class FareEstimate {
  final double baseFare;
  final double tax;
  final double total;
  final double surgeMultiplier;
  final Map<String, double> breakdown;

  FareEstimate({
    required this.baseFare,
    required this.tax,
    required this.total,
    required this.surgeMultiplier,
    required this.breakdown,
  });

  factory FareEstimate.fromJson(Map<String, dynamic> json) {
    final fareData = json['fareEstimate'] ?? {};
    return FareEstimate(
      baseFare: (fareData['baseFare'] ?? 0).toDouble(),
      tax: (fareData['tax'] ?? 0).toDouble(),
      total: (fareData['total'] ?? 0).toDouble(),
      surgeMultiplier: (json['surgeFactor'] ?? 1.0).toDouble(),
      breakdown: {
        'baseFare': ((fareData['breakdown']?['baseFare']) ?? 0).toDouble(),
        'distanceCharge': ((fareData['breakdown']?['distanceCharge']) ?? 0)
            .toDouble(),
        'timeCharge': ((fareData['breakdown']?['timeCharge']) ?? 0).toDouble(),
      },
    );
  }
}

class FareStatistics {
  final double totalEarnings;
  final int totalRides;
  final double averageFare;
  final String period;

  FareStatistics({
    required this.totalEarnings,
    required this.totalRides,
    required this.averageFare,
    required this.period,
  });

  factory FareStatistics.fromJson(Map<String, dynamic> json) {
    return FareStatistics(
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      totalRides: json['totalRides'] ?? 0,
      averageFare: (json['averageFare'] ?? 0).toDouble(),
      period: json['period'] ?? '',
    );
  }
}
