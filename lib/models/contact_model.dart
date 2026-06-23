// ============================================
// Aarohan SOS Alert
// File        : models/contact_model.dart
// Description : Emergency Contact Data Model
// ============================================

import 'dart:convert';

class ContactModel {
  // ----------------------------
  // Fields
  // ----------------------------

  final String id;
  final String name;
  final String phone;
  final String relationship;
  final int priority;

  // ----------------------------
  // Constructor
  // ----------------------------

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    required this.priority,
  });

  // ----------------------------
  // Copy With
  // ----------------------------

  ContactModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? relationship,
    int? priority,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
      priority: priority ?? this.priority,
    );
  }

  // ----------------------------
  // To Map
  // ----------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'priority': priority,
    };
  }

  // ----------------------------
  // From Map
  // ----------------------------

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relationship: map['relationship'] ?? '',
      priority: map['priority'] ?? 0,
    );
  }

  // ----------------------------
  // To JSON
  // ----------------------------

  String toJson() => json.encode(toMap());

  // ----------------------------
  // From JSON
  // ----------------------------

  factory ContactModel.fromJson(String source) =>
      ContactModel.fromMap(json.decode(source));

  // ----------------------------
  // To String
  // ----------------------------

  @override
  String toString() {
    return 'ContactModel('
        'id: $id, '
        'name: $name, '
        'phone: $phone, '
        'relationship: $relationship, '
        'priority: $priority)';
  }

  // ----------------------------
  // Equality
  // ----------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}