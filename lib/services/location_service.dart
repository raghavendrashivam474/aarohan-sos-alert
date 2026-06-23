// ============================================
// Aarohan SOS Alert
// File        : services/location_service.dart
// Description : GPS Location Service
// ============================================

import 'package:geolocator/geolocator.dart';
import '../utils/constants.dart';

class LocationResult {
  // ----------------------------
  // Fields
  // ----------------------------

  final bool success;
  final double? latitude;
  final double? longitude;
  final String? mapLink;
  final String? errorMessage;

  // ----------------------------
  // Constructor
  // ----------------------------

  LocationResult({
    required this.success,
    this.latitude,
    this.longitude,
    this.mapLink,
    this.errorMessage,
  });
}

class LocationService {
  // ----------------------------
  // Singleton Setup
  // ----------------------------

  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // ----------------------------
  // Check Permission
  // ----------------------------

  Future<bool> checkPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // ----------------------------
  // Request Permission
  // ----------------------------

  Future<bool> requestPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      // If denied request permission
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // If permanently denied return false
      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      // Permission granted
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // ----------------------------
  // Get Current Location
  // ----------------------------

  Future<LocationResult> getCurrentLocation() async {
    try {
      // Step 1 - Check if location service is on
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          success: false,
          errorMessage:
              'Location services are disabled. Please enable GPS.',
        );
      }

      // Step 2 - Check and request permission
      bool hasPermission = await requestPermission();
      if (!hasPermission) {
        return LocationResult(
          success: false,
          errorMessage:
              'Location permission denied. Please allow location access.',
        );
      }

      // Step 3 - Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Step 4 - Build map link
      String mapLink = buildMapLink(
        position.latitude,
        position.longitude,
      );

      return LocationResult(
        success: true,
        latitude: position.latitude,
        longitude: position.longitude,
        mapLink: mapLink,
      );
    } on LocationServiceDisabledException {
      return LocationResult(
        success: false,
        errorMessage: 'GPS is turned off. Please enable location services.',
      );
    } on PermissionDeniedException {
      return LocationResult(
        success: false,
        errorMessage: 'Location permission was denied.',
      );
    } catch (e) {
      return LocationResult(
        success: false,
        errorMessage: 'Failed to get location. Please try again.',
      );
    }
  }

  // ----------------------------
  // Open Location Settings
  // ----------------------------

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // ----------------------------
  // Open App Settings
  // ----------------------------

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}