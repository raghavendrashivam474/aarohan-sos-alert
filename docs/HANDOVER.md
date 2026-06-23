# HANDOVER.md

## Aarohan SOS Alert

Version: v1.0 Final

Status: Project Handover Document

Prepared For: Future Developers

Last Updated: June 2026

---

# Purpose

This document is intended for any developer who takes over the Aarohan SOS Alert project after the original development phase.

After reading this document, a new developer should understand:

* What the project is
* Why it exists
* Current architecture
* Current limitations
* How to run it
* How to extend it
* What should not be changed

without requiring access to the original team.

---

# Project Overview

## Project Name

Aarohan SOS Alert

## Platform

Android

## Framework

Flutter

## Version

v1.0 Final

## Current Status

Build Validated

APK Generated

Submission Ready

---

# What Is Aarohan?

Aarohan SOS Alert is an emergency assistance application.

The application allows users to:

* Register personal information
* Store emergency contacts
* Trigger an SOS workflow
* Retrieve current GPS location
* Generate Google Maps location links
* Prepare emergency messages

The application currently operates entirely offline.

No backend exists.

No cloud synchronization exists.

---

# Project Goal

Primary Goal:

Provide a simple emergency assistance workflow that can be triggered quickly during an emergency.

The MVP focuses on:

* Simplicity
* Reliability
* Offline functionality

---

# Project Philosophy

Aarohan intentionally follows:

* Offline-first architecture
* Minimal dependencies
* Low complexity
* High maintainability

Many advanced features were intentionally excluded.

This was done to ensure project completion.

---

# Technology Stack

## Frontend

Flutter

## Language

Dart

## Local Storage

SharedPreferences

## Location Services

Geolocator

## Permission Management

Permission Handler

## URL Handling

URL Launcher

## Backend

None

## Database

None

## Authentication

None

---

# Project Structure

```text
lib/
├── main.dart
├── screens/
├── models/
├── services/
├── widgets/
└── utils/
```

---

# Folder Responsibilities

## screens/

Contains application pages.

Current screens:

* intro_screen.dart
* user_details_screen.dart
* dashboard_screen.dart
* contact_management_screen.dart
* success_screen.dart

Rule:

Screens should contain UI logic only.

Avoid placing business logic here.

---

## models/

Contains application data models.

Current models:

* UserModel
* ContactModel

Rule:

All new entities should be added here.

---

## services/

Contains business and platform logic.

Current services:

* StorageService
* LocationService

Rule:

Device access and data operations belong here.

---

## widgets/

Contains reusable UI components.

Current widgets:

* SOSButton
* ContactCard

Rule:

Reusable UI should not be duplicated across screens.

---

## utils/

Contains constants and helper methods.

Current contents:

* Theme configuration
* Color definitions
* Text styles
* Helper methods

---

# Current User Flow

```text
App Launch
 ↓
Intro Screen
 ↓
User Registration
 ↓
Emergency Contacts
 ↓
Dashboard
 ↓
SOS
 ↓
Location Fetch
 ↓
Message Generation
 ↓
Success Screen
```

This workflow should remain stable unless major redesign is planned.

---

# How Data Is Stored

All data is stored locally.

Implementation:

SharedPreferences

Stored Data:

* User profile
* Medical information
* Emergency contacts
* Setup completion flag

No external server communication exists.

---

# Current SOS Workflow

When user presses SOS:

1. Confirmation dialog shown

2. Location permission requested

3. GPS coordinates retrieved

4. Google Maps URL generated

5. Emergency message prepared

6. Success screen displayed

Important:

The application DOES NOT currently:

* Send SMS
* Place calls
* Contact emergency services

The workflow is currently a prepared-message workflow.

---

# Assets

## Logo

Location:

```text
assets/images/logo.jpeg
```

Used In:

* Introduction Screen
* Dashboard Header
* Launcher Icon

---

# Build Instructions

## Clean Build

```bash
flutter clean
flutter pub get
flutter build apk --release
```

Generated APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

# Required Environment

Flutter Stable

Android SDK Installed

Android Licenses Accepted

Verify:

```bash
flutter doctor
```

before development.

---

# Common Issues

## Location Permission Failure

Symptoms:

* GPS not retrieved

Check:

* Permission status
* Device location settings

---

## Build Failure

Run:

```bash
flutter clean
flutter pub get
```

Then rebuild.

---

## Launcher Icon Not Updating

Possible Cause:

Device cache.

Solution:

* Uninstall application
* Reinstall APK

---

# Known Limitations

Current limitations include:

* No SMS dispatch
* No automatic calling
* No live tracking
* No cloud sync
* No authentication
* No data backup
* No emergency service integration

These are expected limitations of v1.0.

---

# Future Roadmap

Potential v2.0 features:

## Communication

* SMS Sending
* Automatic Calling

## Tracking

* Live Location Updates
* Background Tracking

## Cloud

* Firebase
* Authentication
* Cloud Backup

## Safety

* Emergency Service Integration
* Smart Escalation Logic

These features should be implemented gradually.

Do not attempt all at once.

---

# Important Design Decisions

## Why No Backend?

The MVP was intentionally simplified.

Adding backend infrastructure would significantly increase complexity.

---

## Why SharedPreferences?

Simple.

Reliable.

Appropriate for MVP.

---

## Why Offline First?

Emergency tools should remain useful even with limited connectivity.

---

# Development Rules

If continuing this project:

DO:

✓ Keep architecture simple

✓ Maintain modular structure

✓ Reuse widgets

✓ Preserve documentation

✓ Test on real devices

---

DO NOT:

✗ Add unnecessary dependencies

✗ Introduce complex architecture prematurely

✗ Skip documentation updates

✗ Break existing user flow without reason

---

# Recommended Reading Order

Before making changes:

1. README.md

2. pre-planning.md

3. project-origin.md

4. project-history.md

5. architecture.md

6. lessons-learned.md

7. technical-report.md

8. This document

---

# Final Note

Aarohan SOS Alert was built as a focused MVP demonstrating emergency assistance workflows.

The project intentionally prioritizes completion, clarity, and maintainability over feature quantity.

Future developers are encouraged to evolve the application carefully while preserving the simplicity that enabled the initial release.

---

End of Handover Document
