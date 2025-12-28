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
  bool get hasExpired => DateTime.now().isAfter(expiryDate);

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['_id'] ?? '',
      ownerId: json['ownerId']?['_id'] ?? json['ownerId'] ?? '',
      ownerName: json['ownerId']?['name'] ?? 'Unknown',
      ownerEmail: json['ownerId']?['email'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      carModel: json['carModel'] ?? '',
      location: json['location'] ?? '',
      salary: (json['salary'] ?? 0).toDouble(),
      salaryType: json['salaryType'] ?? 'monthly',
      jobType: json['jobType'] ?? 'part-time',
      experience: json['experience'] ?? 0,
      licenseType: json['licenseType'] ?? 'B',
      workingHours: List<String>.from(json['workingHours'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      perks: List<String>.from(json['perks'] ?? []),
      status: json['status'] ?? 'open',
      applicants:
          (json['applicants'] as List?)
              ?.map((a) => Applicant.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      selectedDriver: json['selectedDriver'],
      contractUrl: json['contractUrl'],
      postedAt: DateTime.parse(
        json['postedAt'] ?? DateTime.now().toIso8601String(),
      ),
      expiryDate: DateTime.parse(
        json['expiryDate'] ??
            DateTime.now().add(Duration(days: 30)).toIso8601String(),
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
      driverId: json['driverId']?['_id'] ?? json['driverId'] ?? '',
      driverName: json['driverId']?['name'] ?? 'Unknown',
      driverEmail: json['driverId']?['email'] ?? '',
      driverPhone: json['driverId']?['phone'] ?? '',
      status: json['status'] ?? 'pending',
      appliedAt: DateTime.parse(
        json['appliedAt'] ?? DateTime.now().toIso8601String(),
      ),
      notes: json['notes'],
    );
  }
}
