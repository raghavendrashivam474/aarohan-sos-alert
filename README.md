# Aarohan SOS Alert 🚨

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
Dispatcher
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
│
├── User Service
├── Contact Service
├── Location Service
├── Message Service
├── Dispatch Engine
│
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

| Item          | Status                    |
| ------------- | ------------------------- |
| Version       | v2.0                      |
| Sprint        | Sprint 2 Complete         |
| Build Status  | Release APK Generated     |
| Platform      | Android                   |
| Architecture  | Emergency Dispatch Engine |
| Release State | Functional Prototype      |

---

# Current Dispatch Methods

| Method              | Status        |
| ------------------- | ------------- |
| Simulation          | ✅ Implemented |
| Android Share Sheet | ✅ Implemented |
| SMS                 | 🚧 Planned    |
| Phone Call          | 🚧 Planned    |
| WhatsApp Direct     | 🚧 Planned    |
| Email               | 🚧 Planned    |

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

### Future Sprints

* SMS Dispatcher
* Call Dispatcher
* Alert History
* Retry Mechanism
* Live Tracking
* Emergency Timeline
* Multi-channel Dispatch
* Cloud Synchronization

---

# Known Limitations

Current version intentionally excludes:

* Automatic SMS delivery
* Automatic phone calling
* Continuous live tracking
* Authentication
* Cloud backend
* Firebase integration
* Police or ambulance integration
* AI-assisted emergency detection

These remain future enhancements.

---

# Contributors

## Amitesh Rajput

**Project Owner**

Contributions:

* Original idea
* Product vision
* Feature planning
* User flow
* Wireframes
* Branding direction
* Product ownership

---

## Raghavendra Singh

**Technical Mentor & Architecture Support**

Contributions:

* Software architecture
* Engineering guidance
* System design
* Documentation
* Development mentorship
* Sprint planning
* Release preparation

---

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

This project is intended for educational, learning, and demonstration purposes.

Future licensing may be updated as the project evolves.
