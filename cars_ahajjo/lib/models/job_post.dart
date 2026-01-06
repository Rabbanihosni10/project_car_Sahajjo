class JobPost {
  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String title;
  final String description;
  final String carModel;
  final String location;
  final double salary;
  final String salaryType; // monthly, daily, weekly
  final String jobType; // part-time, full-time, contract
  final int experience; // years required
  final String licenseType; // A, B, C, D, etc.
  final List<String> workingHours;
  final List<String> requirements;
  final List<String> perks;
  final String status; // open, closed, filled
  final List<Applicant> applicants;
  final String? selectedDriver;
  final String? contractUrl;
  final DateTime postedAt;
  final DateTime expiryDate;

  JobPost({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.title,
    required this.description,
    required this.carModel,
    required this.location,
    required this.salary,
    required this.salaryType,
    required this.jobType,
    required this.experience,
    required this.licenseType,
    required this.workingHours,
    required this.requirements,
    required this.perks,
    required this.status,
    required this.applicants,
    this.selectedDriver,
    this.contractUrl,
    required this.postedAt,
    required this.expiryDate,
  });

  bool get isOpen => status == 'open';
  bool get isFilled => status == 'filled';
  bool get isClosed => status == 'closed';
  bool get isPending => status == 'pending';
  bool get hasExpired => DateTime.now().isAfter(expiryDate);

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: (json['_id'] ?? '').toString(),
      ownerId:
          (json['ownerId'] is Map
                  ? (json['ownerId']['_id'] ?? '')
                  : (json['ownerId'] ?? ''))
              .toString(),
      ownerName: json['ownerId'] is Map
          ? (json['ownerId']['name'] ?? 'Unknown')
          : 'Unknown',
      ownerEmail: json['ownerId'] is Map
          ? (json['ownerId']['email'] ?? '')
          : '',
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      carModel: (json['carModel'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      salary:
          (json['salary'] is String
                  ? double.tryParse(json['salary'] as String) ?? 0.0
                  : (json['salary'] ?? 0))
              .toDouble(),
      salaryType: (json['salaryType'] ?? 'monthly').toString(),
      jobType: (json['jobType'] ?? 'part-time').toString(),
      experience: json['experience'] is String
          ? int.tryParse(json['experience'] as String) ?? 0
          : (json['experience'] ?? 0) as int,
      licenseType: (json['licenseType'] ?? 'B').toString(),
      workingHours:
          (json['workingHours'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      requirements:
          (json['requirements'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      perks: (json['perks'] as List?)?.map((e) => e.toString()).toList() ?? [],
      status: (json['status'] ?? 'open').toString(),
      applicants:
          (json['applicants'] as List?)
              ?.map((a) => Applicant.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      selectedDriver: json['selectedDriver']?.toString(),
      contractUrl: json['contractUrl']?.toString(),
      postedAt: DateTime.parse(
        (json['postedAt'] ?? DateTime.now().toIso8601String()).toString(),
      ),
      expiryDate: DateTime.parse(
        (json['expiryDate'] ??
                DateTime.now().add(const Duration(days: 30)).toIso8601String())
            .toString(),
      ),
    );
  }
}

class Applicant {
  final String driverId;
  final String driverName;
  final String driverEmail;
  final String driverPhone;
  final String status; // pending, interviewed, accepted, rejected
  final DateTime appliedAt;
  final String? notes;

  Applicant({
    required this.driverId,
    required this.driverName,
    required this.driverEmail,
    required this.driverPhone,
    required this.status,
    required this.appliedAt,
    this.notes,
  });

  bool get isPending => status == 'pending';
  bool get isInterviewed => status == 'interviewed';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      driverId:
          (json['driverId'] is Map
                  ? (json['driverId']['_id'] ?? '')
                  : (json['driverId'] ?? ''))
              .toString(),
      driverName: json['driverId'] is Map
          ? (json['driverId']['name'] ?? 'Unknown').toString()
          : 'Unknown',
      driverEmail: json['driverId'] is Map
          ? (json['driverId']['email'] ?? '').toString()
          : '',
      driverPhone: json['driverId'] is Map
          ? (json['driverId']['phone'] ?? '').toString()
          : '',
      status: (json['status'] ?? 'pending').toString(),
      appliedAt: DateTime.parse(
        (json['appliedAt'] ?? DateTime.now().toIso8601String()).toString(),
      ),
      notes: json['notes']?.toString(),
    );
  }
}
