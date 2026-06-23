// ============================================
// Aarohan SOS Alert
// File        : models/user_model.dart
// Description : User Data Model
// ============================================

import 'dart:convert';
import 'contact_model.dart';

class UserModel {
  // ----------------------------
  // Fields
  // ----------------------------

  final String name;
  final String phone;
  final String age;
  final String bloodGroup;
  final String address;
  final String medicalConditions;
  final String allergies;
  final List<ContactModel> emergencyContacts;

  // ----------------------------
  // Constructor
  // ----------------------------

  UserModel({
    required this.name,
    required this.phone,
    this.age = '',
    this.bloodGroup = '',
    this.address = '',
    this.medicalConditions = '',
    this.allergies = '',
    this.emergencyContacts = const [],
  });

  // ----------------------------
  // Copy With
  // ----------------------------

  UserModel copyWith({
    String? name,
    String? phone,
    String? age,
    String? bloodGroup,
    String? address,
    String? medicalConditions,
    String? allergies,
    List<ContactModel>? emergencyContacts,
  }) {
    return UserModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }

  // ----------------------------
  // To Map
  // ----------------------------

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'age': age,
      'bloodGroup': bloodGroup,
      'address': address,
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'emergencyContacts': emergencyContacts
          .map((contact) => contact.toMap())
          .toList(),
    };
  }

  // ----------------------------
  // From Map
  // ----------------------------

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      age: map['age'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      address: map['address'] ?? '',
      medicalConditions: map['medicalConditions'] ?? '',
      allergies: map['allergies'] ?? '',
      emergencyContacts: map['emergencyContacts'] != null
          ? List<ContactModel>.from(
              (map['emergencyContacts'] as List).map(
                (contact) => ContactModel.fromMap(contact),
              ),
            )
          : [],
    );
  }

  // ----------------------------
  // To JSON
  // ----------------------------

  String toJson() => json.encode(toMap());

  // ----------------------------
  // From JSON
  // ----------------------------

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  // ----------------------------
  // To String
  // ----------------------------

  @override
  String toString() {
    return 'UserModel('
        'name: $name, '
        'phone: $phone, '
        'age: $age, '
        'bloodGroup: $bloodGroup, '
        'address: $address, '
        'medicalConditions: $medicalConditions, '
        'allergies: $allergies, '
        'emergencyContacts: $emergencyContacts)';
  }

  // ----------------------------
  // Equality
  // ----------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.phone == phone;
  }

  @override
  int get hashCode => phone.hashCode;
}