# Aarohan SOS Alert 🚨

A lightweight emergency assistance Android application built with Flutter.

Aarohan SOS Alert helps users quickly access emergency information, manage trusted contacts, retrieve their current location, and generate SOS assistance messages during emergency situations.

---

## Overview

Aarohan SOS Alert was created as a focused MVP (Minimum Viable Product) to explore emergency assistance workflows while maintaining simplicity, reliability, and offline usability.

The application allows users to:

* Store personal emergency information
* Manage emergency contacts
* Retrieve current GPS location
* Generate Google Maps location links
* Prepare SOS assistance messages
* Access a simple emergency dashboard

---

## Features

### User Registration

* Personal profile setup
* Medical information storage
* Emergency information management

### Emergency Contacts

* Add contacts
* Edit contacts
* Delete contacts
* Contact prioritization

### SOS Workflow

* One-tap SOS trigger
* GPS location retrieval
* Google Maps link generation
* Emergency message preparation

### Offline First

* Local storage using SharedPreferences
* No internet dependency for core functionality
* No backend required

---

## Tech Stack

| Component   | Technology         |
| ----------- | ------------------ |
| Framework   | Flutter            |
| Language    | Dart               |
| Storage     | SharedPreferences  |
| Location    | Geolocator         |
| Permissions | Permission Handler |
| Platform    | Android            |

---

## Project Structure

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

## Documentation

Project documentation is available in the `/docs` directory.

Includes:

* Project Origin
* Pre-Planning
* Project History
* Architecture
* MVP Finalization
* Technical Report
* Lessons Learned
* Release Notes
* Developer Handover Guide

---

## Current Status

Version: v1.0

Status: MVP Complete

Build Status: Release APK Generated

Platform: Android

---

## Known Limitations

Current MVP does not include:

* SMS auto-sending
* Automatic calling
* Live tracking
* Cloud synchronization
* Authentication
* Emergency service integration

These are considered future enhancements.

---

## Contributors

### Amitesh Rajput

* Original idea and product vision
* Feature planning
* Wireframes
* Branding direction
* Product ownership

### Raghavendra Singh

* Technical guidance
* Architecture support
* Development mentorship
* Documentation
* Release preparation

---

## Philosophy

Aarohan was intentionally built with a simple principle:

> Complete a focused solution before expanding the feature set.

The project prioritizes clarity, maintainability, and practical execution over excessive complexity.

---

## License

This project is currently intended for educational and learning purposes.
