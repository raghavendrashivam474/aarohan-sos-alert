// ============================================
// Aarohan SOS Alert
// File        : services/permission/permission_service.dart
// Description : Centralized Permission Management
// Sprint      : 3 - Real Emergency Communication Layer
// ============================================

import 'dart:developer' as developer;
import 'package:permission_handler/permission_handler.dart';

// ----------------------------
// Permission Types
// ----------------------------

enum AppPermission {
  location,
  sms,
  phone,
  contacts,
}

extension AppPermissionExt on AppPermission {
  String get label {
    switch (this) {
      case AppPermission.location:
        return 'Location';
      case AppPermission.sms:
        return 'SMS';
      case AppPermission.phone:
        return 'Phone';
      case AppPermission.contacts:
        return 'Contacts';
    }
  }

  Permission get handlerPermission {
    switch (this) {
      case AppPermission.location:
        return Permission.locationWhenInUse;
      case AppPermission.sms:
        return Permission.sms;
      case AppPermission.phone:
        return Permission.phone;
      case AppPermission.contacts:
        return Permission.contacts;
    }
  }
}

// ----------------------------
// Permission Result
// ----------------------------

class PermissionResult {
  final AppPermission permission;
  final bool granted;
  final bool permanentlyDenied;
  final String? errorMessage;

  PermissionResult({
    required this.permission,
    required this.granted,
    this.permanentlyDenied = false,
    this.errorMessage,
  });

  String get summary {
    if (granted) return '${permission.label} permission granted';
    if (permanentlyDenied) {
      return '${permission.label} permission permanently denied. '
          'Please enable it from app settings.';
    }
    return errorMessage ?? '${permission.label} permission denied';
  }
}

// ----------------------------
// Permission Service
// ----------------------------

/// Centralized permission management for the entire application.
///
/// Handles:
/// - Checking permission status
/// - Requesting permissions
/// - Detecting permanent denial
/// - Opening app settings
///
/// Follows single responsibility principle:
/// - Does NOT perform communication
/// - Does NOT show UI dialogs
/// - Only manages permission state
class PermissionService {
  // ----------------------------
  // Singleton Setup
  // ----------------------------

  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // ----------------------------
  // Check Permission
  // ----------------------------

  /// Checks current status of a permission without requesting it.
  Future<PermissionStatus> checkStatus(AppPermission permission) async {
    try {
      return await permission.handlerPermission.status;
    } catch (e) {
      _log('Error checking ${permission.label}: $e');
      return PermissionStatus.denied;
    }
  }

  /// Returns true if permission is currently granted.
  Future<bool> isGranted(AppPermission permission) async {
    final status = await checkStatus(permission);
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  // ----------------------------
  // Request Permission
  // ----------------------------

  /// Requests a single permission and returns structured result.
  Future<PermissionResult> request(AppPermission permission) async {
    try {
      _log('Requesting ${permission.label} permission');

      // Check current status first
      final currentStatus = await permission.handlerPermission.status;

      // Already granted
      if (currentStatus == PermissionStatus.granted ||
          currentStatus == PermissionStatus.limited) {
        _log('${permission.label} already granted');
        return PermissionResult(
          permission: permission,
          granted: true,
        );
      }

      // Permanently denied - cannot request again
      if (currentStatus == PermissionStatus.permanentlyDenied) {
        _log('${permission.label} permanently denied');
        return PermissionResult(
          permission: permission,
          granted: false,
          permanentlyDenied: true,
        );
      }

      // Request permission
      final newStatus = await permission.handlerPermission.request();

      final granted = newStatus == PermissionStatus.granted ||
          newStatus == PermissionStatus.limited;

      final permanentlyDenied =
          newStatus == PermissionStatus.permanentlyDenied;

      _log('${permission.label} result: ${newStatus.name}');

      return PermissionResult(
        permission: permission,
        granted: granted,
        permanentlyDenied: permanentlyDenied,
      );
    } catch (e) {
      _log('Error requesting ${permission.label}: $e');
      return PermissionResult(
        permission: permission,
        granted: false,
        errorMessage: 'Failed to request permission: ${e.toString()}',
      );
    }
  }

  // ----------------------------
  // Request Multiple Permissions
  // ----------------------------

  /// Requests multiple permissions and returns results for each.
  Future<Map<AppPermission, PermissionResult>> requestMultiple(
    List<AppPermission> permissions,
  ) async {
    final results = <AppPermission, PermissionResult>{};

    for (final permission in permissions) {
      results[permission] = await request(permission);
    }

    return results;
  }

  // ----------------------------
  // Convenience Methods
  // ----------------------------

  /// Requests location permission.
  Future<PermissionResult> requestLocation() =>
      request(AppPermission.location);

  /// Requests SMS permission.
  Future<PermissionResult> requestSms() => request(AppPermission.sms);

  /// Requests phone/call permission.
  Future<PermissionResult> requestPhone() => request(AppPermission.phone);

  /// Requests contacts permission.
  Future<PermissionResult> requestContacts() =>
      request(AppPermission.contacts);

  // ----------------------------
  // Settings Navigation
  // ----------------------------

  /// Opens the app settings screen where user can manually grant permissions.
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      _log('Error opening app settings: $e');
      return false;
    }
  }

  // ----------------------------
  // Bulk Status Check
  // ----------------------------

  /// Returns granted status for all app permissions.
  Future<Map<AppPermission, bool>> checkAllPermissions() async {
    final results = <AppPermission, bool>{};

    for (final permission in AppPermission.values) {
      results[permission] = await isGranted(permission);
    }

    return results;
  }

  // ----------------------------
  // Internal Logging
  // ----------------------------

  void _log(String message) {
    developer.log(message, name: 'PermissionService');
  }
}