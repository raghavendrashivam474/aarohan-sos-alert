# architecture.md

## Aarohan SOS Alert

Version: v1.0 Final

Status: Released

---

# Purpose

This document explains the technical architecture of Aarohan SOS Alert.

It is intended to help future developers understand:

* Application structure
* Responsibilities of each module
* Data flow
* Design decisions
* Future extension points

---

# Architectural Philosophy

Aarohan was intentionally designed as a lightweight MVP.

Key principles:

* Offline First
* Simple Architecture
* Minimal Dependencies
* No Backend Requirement
* Easy Maintenance

The goal was to create a functional emergency assistance prototype while minimizing implementation complexity.

---

# High-Level Architecture

```text
User
 ↓
Screens
 ↓
Services
 ↓
Local Storage / Device APIs
```

Application layers:

```text
UI Layer
 ↓
Business Logic Layer
 ↓
Persistence Layer
 ↓
Device Services
```

---

# Project Structure

```text
lib/
├── screens/
├── models/
├── services/
├── widgets/
├── utils/
└── main.dart
```

---

# Screen Layer

Responsible for:

* User interaction
* Navigation
* Data collection
* SOS workflow initiation

Screens:

## Intro Screen

Responsibilities:

* Branding
* Application introduction
* Setup routing

---

## User Details Screen

Responsibilities:

* User registration
* Medical information collection
* Initial emergency contact setup

---

## Dashboard Screen

Responsibilities:

* Main application hub
* SOS trigger
* Contact visibility
* Workflow initiation

---

## Contact Management Screen

Responsibilities:

* CRUD operations for contacts
* Priority management

---

## Success Screen

Responsibilities:

* Display SOS result
* Show generated location link
* Show emergency message

---

# Model Layer

Purpose:

Represent application data.

---

## UserModel

Contains:

* Name
* Phone
* Age
* Blood Group
* Address
* Medical Information
* Emergency Contacts

Acts as the primary application entity.

---

## ContactModel

Contains:

* Name
* Phone Number
* Relationship
* Priority

Represents a trusted emergency contact.

---

# Service Layer

Purpose:

Centralize application logic.

---

## StorageService

Responsibilities:

* Save user information
* Load user information
* Save contacts
* Load contacts
* Setup state management

Implementation:

SharedPreferences

Reason:

* Lightweight
* Offline support
* No backend required

---

## LocationService

Responsibilities:

* Permission handling
* GPS access
* Coordinate retrieval
* Maps link generation

Implementation:

Geolocator

Reason:

Reliable location access with minimal complexity.

---

# Widget Layer

Purpose:

Reusable UI components.

---

## SOSButton

Responsibilities:

* Visual SOS trigger
* Loading state handling
* Animation support

---

## ContactCard

Responsibilities:

* Contact presentation
* Edit/Delete actions
* Consistent contact display

---

# Data Flow

User Registration:

```text
User Input
 ↓
UserDetailsScreen
 ↓
StorageService
 ↓
SharedPreferences
```

---

Contact Management:

```text
Contact Form
 ↓
ContactModel
 ↓
StorageService
 ↓
SharedPreferences
```

---

SOS Workflow:

```text
User Presses SOS
 ↓
Dashboard
 ↓
LocationService
 ↓
GPS Coordinates
 ↓
Google Maps Link
 ↓
Message Generation
 ↓
Success Screen
```

---

# Navigation Flow

```text
Intro Screen
      ↓
User Details
      ↓
Dashboard
      ↓
Success Screen
```

Additional navigation:

```text
Dashboard
      ↓
Contact Management
      ↓
Dashboard
```

---

# Design Decisions

## Why Flutter?

* Single codebase
* Fast development
* Android support
* Strong UI capabilities

---

## Why SharedPreferences?

* Simple persistence
* No server requirement
* Ideal for MVP

---

## Why No Backend?

The MVP focused on:

* Demonstrating workflow
* Reducing complexity
* Increasing completion probability

---

## Why No Authentication?

Application stores only local data.

Authentication was unnecessary for MVP goals.

---

# Future Extension Points

Potential future enhancements:

* SMS Integration
* Automatic Calling
* Live Tracking
* Cloud Backup
* Authentication
* Firebase Backend
* Emergency Services Integration

The architecture intentionally leaves room for these additions.

---

# Summary

Aarohan SOS Alert follows a simple layered architecture focused on maintainability, offline usability, and MVP delivery.

The structure prioritizes clarity and rapid development while providing a foundation for future enhancements if the project evolves beyond its initial academic scope.
