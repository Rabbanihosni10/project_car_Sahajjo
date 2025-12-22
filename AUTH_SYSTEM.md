# Car Sahajjo - Authentication System

## Overview

This is a comprehensive authentication system for the Car Sahajjo app with support for three different user roles: **Visitor**, **Driver**, and **Car Owner**. Each role has a customized sign-up form with role-specific fields.

## Project Structure

```
lib/
├── main.dart                    # Main entry point
├── models/
│   └── user.dart               # User models for all roles
├── screens/
│   ├── sign_in_screen.dart      # Sign-in page
│   ├── sign_up_screen.dart      # Role selection page
│   ├── signup_visitor.dart      # Visitor sign-up form
│   ├── signup_driver.dart       # Driver sign-up form
│   ├── signup_car_owner.dart    # Car owner sign-up form
│   └── home_screen.dart         # Home page after login
```

## Features

### 1. Sign-In Screen

- Clean and user-friendly interface
- Email and password fields
- Show/hide password toggle
- Forgot password link (placeholder)
- Link to create new account
- Loading state during authentication

### 2. Role Selection Screen

- Three role cards with icons and descriptions
- Radio button selection
- Clear indication of selected role
- Role-specific information displayed

### 3. Role-Specific Sign-Up Forms

#### Visitor Sign-Up

- Full Name
- Email Address
- Phone Number
- Password & Confirm Password
- Terms & Conditions checkbox

#### Driver Sign-Up

- Full Name
- Email Address
- Phone Number
- **License Number** (specific to drivers)
- **License Expiry Date** (date picker)
- **Vehicle Type** (dropdown: Sedan, SUV, Hatchback, Pickup Truck, Minivan, Van)
- **Years of Driving Experience**
- Password & Confirm Password
- Terms & Conditions checkbox

#### Car Owner Sign-Up

- Contact Person Name
- Email Address
- Phone Number
- **Company Name**
- **Business Type** (dropdown: Taxi Service, Ride Sharing, Car Rental, Corporate Fleet, Tourist Service, Other)
- **Business Registration Number**
- **Number of Cars in Fleet**
- Password & Confirm Password
- Terms & Conditions checkbox

## User Models

### Base User Model

```dart
User {
  String email;
  String password;
  String fullName;
  String phone;
  UserRole role; // visitor, driver, carOwner
}
```

### VisitorUser

Inherits from `User` with basic fields only.

### DriverUser

Extends `User` with:

- `licenseNumber`: Driver's license number
- `licenseExpiry`: License expiration date
- `vehicleType`: Type of vehicle driven
- `yearsOfExperience`: Years of driving experience

### CarOwnerUser

Extends `User` with:

- `companyName`: Name of the company
- `businessRegistration`: Business registration number
- `numberOfCars`: Fleet size
- `businessType`: Type of business

## Navigation Flow

```
Sign In Screen
    ↓
    └─→ Create Account Link → Role Selection Screen
                               ├─→ Visitor Sign-Up → Home Screen
                               ├─→ Driver Sign-Up → Home Screen
                               └─→ Car Owner Sign-Up → Home Screen
    ↓
Home Screen
```

## UI Design Features

- **Color Scheme**: Blue (#2196F3) as primary color
- **Rounded Corners**: 10px border radius for inputs and buttons
- **Icons**: Intuitive icons for all fields
- **Validation**: Form validation with user-friendly error messages
- **Loading States**: Loading indicators during API calls
- **Responsive**: SingleChildScrollView for overflow handling

## Validation Rules

1. **All fields are required**
2. **Email format validation** (basic)
3. **Password matching** required
4. **Terms & Conditions** must be accepted
5. **Phone number format** validation
6. **License expiry date** must be in the future (for drivers)

## Error Handling

- Displays SnackBar messages for validation errors
- Shows loading indicators during async operations
- Prevents duplicate submissions with loading state

## Next Steps (For Backend Integration)

1. Replace mock async delays with actual API calls
2. Implement real authentication with backend
3. Store user tokens securely
4. Add real form validation
5. Implement password reset functionality
6. Add user profile management
7. Implement role-based access control

## Running the App

```bash
flutter pub get
flutter run
```

The app will start at the Sign-In screen. You can navigate through:

1. Create Account → Select Role → Fill Form → Home Screen
2. Or sign in (demo accepts any email/password)

---

**Last Updated**: December 2024
