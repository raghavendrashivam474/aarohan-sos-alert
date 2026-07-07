# Aarohan SOS Alert 🚨
![Platform](https://img.shields.io/badge/Platform-Android-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart](https://img.shields.io/badge/Dart-3.x-blue)
![Version](https://img.shields.io/badge/Version-v3.0.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

A lightweight, offline-first emergency assistance application built with Flutter for Android.

Aarohan SOS Alert enables users to quickly access emergency information, manage trusted contacts, retrieve their live location, and dispatch emergency alerts through a clean and extensible emergency workflow.

---

# Overview

Aarohan SOS Alert began as a student MVP focused on emergency preparedness and has evolved into a modular emergency notification system.

The application emphasizes:

* Simple and reliable emergency workflows
* Offline-first functionality
* Clean software architecture
* Extensible communication pipeline
* Maintainable and modular codebase

The project serves both as a practical emergency assistance application and as a demonstration of structured software engineering practices.

---

# Features

## User Profile

* Personal profile registration
* Medical information storage
* Blood group information
* Emergency information management

---

## Emergency Contacts

* Add, edit and delete contacts
* Priority-based contact management
* Local persistence
* Contact overview dashboard

---

## SOS Workflow

* One-tap SOS activation
* Current GPS location retrieval
* Google Maps location generation
* Emergency message generation
* Structured emergency alert creation

---

## Emergency Dispatch Engine

A modular dispatch architecture responsible for emergency communication.

Current dispatch methods:

* ✅ Simulation Dispatcher
* ✅ Native Android Share Dispatcher

Future-ready dispatch methods:

* SMS Dispatcher
* Call Dispatcher
* WhatsApp Dispatcher
* Email Dispatcher
* Multi-channel Dispatcher

---

## Dispatch Pipeline

```text
SOS Button
      ↓
SOS Controller
      ↓
Emergency Alert
      ↓
Dispatch Engine
      ↓
Dispatch Strategy
      ↓
Dispatcher(s)
      ↓
Dispatch Result
      ↓
Success Screen
```

---

## Offline First

* SharedPreferences storage
* Local contact management
* Local user profile
* GPS-based functionality
* No backend dependency for core features

---

---


## Real Emergency Communication

* Strategy-based dispatch execution
* Multi-channel emergency alerts
* Sequential dispatch
* Parallel dispatch
* Fallback dispatch
* Native SMS integration
* Native Phone Dialer integration
* Android Share Sheet integration
* Dispatch result reporting

---


# Architecture

The project follows a layered architecture.

```text
UI Layer
│
├── Screens
├── Widgets
│
▼
Application Layer
│
├── SOS Controller
│
▼
Domain Layer

├── User Service
├── Contact Service
├── Location Service
├── Message Service
├── Dispatch Engine
├── Dispatch Strategies
└── Permission Service
▼
Infrastructure Layer
│
├── SharedPreferences
├── Geolocator
├── Android Share Sheet
└── Platform APIs
```

The architecture follows the Single Responsibility Principle, ensuring each component performs one well-defined responsibility.

---

# Tech Stack

| Component   | Technology         |
| ----------- | ------------------ |
| Framework   | Flutter            |
| Language    | Dart               |
| Storage     | SharedPreferences  |
| Location    | Geolocator         |
| Permissions | Permission Handler |
| Sharing     | share_plus         |
| Platform    | Android            |
| SMS | sms: URI |
| Phone | tel: URI |
| Sharing | share_plus |
| URL Launching | url_launcher |

---

# Project Structure

```text
lib/
├── controllers/
│   └── sos_controller.dart
│
├── models/
│   ├── dispatch/
│   ├── contact_model.dart
│   └── user_model.dart
│
├── screens/
│
├── services/
│   ├── dispatch/
│   ├── location_service.dart
│   ├── message_service.dart
│   └── storage_service.dart
│
├── widgets/
│
├── utils/
│
└── main.dart
```

---

# Documentation

Comprehensive documentation is available inside the `/docs` directory.

Documentation includes:

* Project Origin
* Pre-Planning
* Product Vision
* Architecture Decisions
* Sprint Reports
* Technical Reports
* MVP Documentation
* Future Roadmap
* Lessons Learned
* Release Notes
* Developer Handover Guide

---

# Current Status

| Item | Status |
|------|--------|
| Version | v3.0.0 |
| Sprint | Sprint 3 Complete |
| Build Status | Release APK Generated |
| Platform | Android |
| Architecture | Real Emergency Communication Layer |
| Release State | Functional Prototype (Device Verified) |

---

# Communication Methods

| Method | Status |
|---------|--------|
| Simulation Dispatcher | ✅ Implemented |
| Share Dispatcher | ✅ Implemented |
| SMS Dispatcher | ✅ Implemented |
| Call Dispatcher | ✅ Implemented |
| Sequential Strategy | ✅ Implemented |
| Parallel Strategy | ✅ Implemented |
| Fallback Strategy | ✅ Implemented |
| WhatsApp Direct | 🚧 Planned |
| Email Dispatcher | 🚧 Planned |
---

# Roadmap

### Sprint 1

* Core MVP
* User registration
* Emergency contacts
* GPS integration
* SOS workflow

### Sprint 2

* Emergency Dispatch Engine
* SOS Controller
* Emergency Alert model
* Dispatch Result model
* Share Dispatcher
* Modular dispatcher architecture

### Sprint 3

* Real Emergency Communication Layer
* SMS Dispatcher
* Call Dispatcher
* Share Dispatcher
* Strategy Engine
* Sequential Strategy
* Parallel Strategy
* Fallback Strategy
* Permission Management

### Future Roadmap

* Emergency Session Manager
* Alert History
* Retry Engine
* Live Tracking
* WhatsApp Direct Dispatcher
* Email Dispatcher
* Emergency Timeline
* Cloud Synchronization
* SafeRoute Evolution

---

# Known Limitations

Current version intentionally excludes:

* Automatic background SMS delivery
* Automatic direct phone calling without platform permissions
* Live location tracking
* Alert History
* Emergency Timeline
* Authentication
* Cloud backend
* Firebase integration
* Police or ambulance integration
* AI-assisted emergency detection

---

# Contributors

## Amitesh Rajput

**Project Owner & Lead Developer**

Responsibilities:

- Original project idea
- Product vision
- UI/UX planning
- Feature planning
- Flutter development
- Testing
- Product ownership

---

## Raghavendra Singh

**Technical Mentor & Software Architect**

Responsibilities:

- Software architecture
- Engineering mentorship
- System design
- Documentation strategy
- Sprint planning
- Architecture reviews
- Release management
# Philosophy

Aarohan is built around a simple engineering principle:

> Build a complete, maintainable, and reliable solution before expanding functionality.

The project prioritizes:

* Simplicity
* Reliability
* Modularity
* Extensibility
* Clean architecture
* Practical execution

---

# License

Licensed under the MIT License.

Copyright (c) 2026 Amitesh Rajput

See the LICENSE file for complete license information.
