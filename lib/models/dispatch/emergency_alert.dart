// ============================================
// Aarohan SOS Alert
// File        : models/dispatch/emergency_alert.dart
// Description : Emergency Alert Data Model (Sprint 4 - With Emergency Type)
// ============================================

import '../user_model.dart';
import '../contact_model.dart';
import '../emergency/emergency_type.dart';

// ----------------------------
// Emergency Alert Model
// ----------------------------

class EmergencyAlert {
  // ----------------------------
  // Core Fields
  // ----------------------------

  final String alertId;
  final UserModel user;
  final List<ContactModel> contacts;
  final double latitude;
  final double longitude;
  final String mapLink;
  final String message;
  final DateTime timestamp;
  final EmergencyType emergencyType;
  final Map<String, dynamic> metadata;

  // ----------------------------
  // Constructor
  // ----------------------------

  EmergencyAlert({
    String? alertId,
    required this.user,
    required this.contacts,
    required this.latitude,
    required this.longitude,
    required this.mapLink,
    required this.message,
    DateTime? timestamp,
    this.emergencyType = EmergencyType.general,
    this.metadata = const {},
  })  : alertId = alertId ??
            'ALT_${DateTime.now().millisecondsSinceEpoch}',
        timestamp = timestamp ?? DateTime.now();

  // ----------------------------
  // Convenience Getters
  // ----------------------------

  bool get hasContacts => contacts.isNotEmpty;

  int get contactCount => contacts.length;

  bool get hasValidLocation => latitude != 0.0 && longitude != 0.0;

  String get userName => user.name;

  String get userPhone => user.phone;

  ContactModel? get primaryContact =>
      contacts.isNotEmpty ? contacts.first : null;

  List<String> get contactPhones =>
      contacts.map((c) => c.phone).toList();

  List<String> get contactNames =>
      contacts.map((c) => c.name).toList();

  String get formattedCoordinates =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  String get formattedTimestamp {
    return '${timestamp.day.toString().padLeft(2, '0')}/'
        '${timestamp.month.toString().padLeft(2, '0')}/'
        '${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // ----------------------------
  // Emergency Type Helpers
  // ----------------------------

  /// Returns true if the alert has a specific (non-general) emergency type.
  bool get hasSpecificType => emergencyType != EmergencyType.general;

  /// Returns the emergency type emoji.
  String get emergencyEmoji => emergencyType.emoji;

  /// Returns the emergency type label.
  String get emergencyLabel => emergencyType.label;

  // ----------------------------
  // Validation
  // ----------------------------

  bool get isValid {
    return user.name.isNotEmpty &&
        contacts.isNotEmpty &&
        message.isNotEmpty &&
        mapLink.isNotEmpty;
  }

  String? get validationError {
    if (user.name.isEmpty) return 'User information is missing';
    if (contacts.isEmpty) return 'No emergency contacts configured';
    if (message.isEmpty) return 'Emergency message not prepared';
    if (mapLink.isEmpty) return 'Location link not generated';
    return null;
  }

  // ----------------------------
  // Copy With
  // ----------------------------

  EmergencyAlert copyWith({
    String? alertId,
    UserModel? user,
    List<ContactModel>? contacts,
    double? latitude,
    double? longitude,
    String? mapLink,
    String? message,
    DateTime? timestamp,
    EmergencyType? emergencyType,
    Map<String, dynamic>? metadata,
  }) {
    return EmergencyAlert(
      alertId: alertId ?? this.alertId,
      user: user ?? this.user,
      contacts: contacts ?? this.contacts,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mapLink: mapLink ?? this.mapLink,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      emergencyType: emergencyType ?? this.emergencyType,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Creates a copy of this alert with a specific emergency type.
  /// Useful for escalation flows where type is determined after initial dispatch.
  EmergencyAlert withEmergencyType(EmergencyType type) {
    return copyWith(emergencyType: type);
  }

  // ----------------------------
  // Serialization
  // ----------------------------

  Map<String, dynamic> toMap() {
    return {
      'alertId': alertId,
      'user': user.toMap(),
      'contacts': contacts.map((c) => c.toMap()).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'mapLink': mapLink,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'emergencyType': emergencyType.name,
      'metadata': metadata,
    };
  }

  factory EmergencyAlert.fromMap(Map<String, dynamic> map) {
    return EmergencyAlert(
      alertId: map['alertId'] as String?,
      user: UserModel.fromMap(map['user'] as Map<String, dynamic>),
      contacts: (map['contacts'] as List)
          .map((c) => ContactModel.fromMap(c as Map<String, dynamic>))
          .toList(),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      mapLink: map['mapLink'] as String,
      message: map['message'] as String,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : null,
      emergencyType: EmergencyTypeExt.fromCode(map['emergencyType'] as String?),
      metadata: (map['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }

  @override
  String toString() {
    return 'EmergencyAlert('
        'alertId: $alertId, '
        'user: ${user.name}, '
        'type: ${emergencyType.label}, '
        'contacts: ${contacts.length}, '
        'coordinates: $formattedCoordinates, '
        'timestamp: $formattedTimestamp)';
  }
}