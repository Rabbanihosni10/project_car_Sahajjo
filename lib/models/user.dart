enum UserRole { visitor, driver, carOwner, admin }

class User {
  final String email;
  final String password;
  final String fullName;
  final String phone;
  final UserRole role;

  User({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.role,
  });
}

class VisitorUser extends User {
  VisitorUser({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) : super(
         email: email,
         password: password,
         fullName: fullName,
         phone: phone,
         role: UserRole.visitor,
       );
}

class DriverUser extends User {
  final String licenseNumber;
  final String licenseExpiry;
  final String vehicleType;
  final String yearsOfExperience;

  DriverUser({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.vehicleType,
    required this.yearsOfExperience,
  }) : super(
         email: email,
         password: password,
         fullName: fullName,
         phone: phone,
         role: UserRole.driver,
       );
}

class CarOwnerUser extends User {
  final String companyName;
  final String businessRegistration;
  final String numberOfCars;
  final String businessType;

  CarOwnerUser({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required this.companyName,
    required this.businessRegistration,
    required this.numberOfCars,
    required this.businessType,
  }) : super(
         email: email,
         password: password,
         fullName: fullName,
         phone: phone,
         role: UserRole.carOwner,
       );
}

class AdminUser extends User {
  final String adminId;
  final String permissions;
  final DateTime createdAt;
  final bool isActive;

  AdminUser({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required this.adminId,
    required this.permissions,
    required this.createdAt,
    this.isActive = true,
  }) : super(
         email: email,
         password: password,
         fullName: fullName,
         phone: phone,
         role: UserRole.admin,
       );
}
