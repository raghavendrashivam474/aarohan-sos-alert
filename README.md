# Aarohan SOS Alert 🚨

![Platform](https://img.shields.io/badge/Platform-Android-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart](https://img.shields.io/badge/Dart-3.x-blue)
![Version](https://img.shields.io/badge/Version-v4.0.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

A lightweight, offline-first emergency assistance application built with Flutter for Android.

Aarohan SOS Alert helps users manage trusted emergency contacts, retrieve their current location, generate structured emergency alerts, communicate through multiple dispatch channels, and initiate contact with India's ERSS 112 emergency pathway.

---

# Overview

Aarohan SOS Alert began as a focused student MVP for emergency preparedness and has evolved into a modular emergency communication system.

The application emphasizes:

* Simple and reliable emergency workflows
* Offline-first functionality
* Reduced interaction friction during emergencies
* Multi-channel emergency communication
* Clean and extensible software architecture
* Truthful user communication
* Safe official emergency escalation
* Maintainable and modular engineering practices

The project serves both as a practical emergency assistance prototype and as a demonstration of structured software engineering, architecture evolution, and safety-conscious product development.

---

# Features

## User Profile

* Personal profile registration
* Medical information storage
* Blood group information
* Emergency information management
* Local profile persistence

---

## Emergency Contacts

* Add emergency contacts
* Edit existing contacts
* Delete contacts
* Priority-based contact management
* Local contact persistence
* Contact overview interface

---

## SOS Workflow

* One-tap SOS activation
* Current GPS location retrieval
* Google Maps location link generation
* Emergency message generation
* Structured emergency alert creation
* Multi-channel emergency dispatch
* Detailed dispatch result reporting

---

## Emergency Dispatch Engine

A modular dispatch architecture responsible for trusted-contact emergency communication.

Implemented dispatchers:

* ✅ Simulation Dispatcher
* ✅ Share Dispatcher
* ✅ SMS Dispatcher
* ✅ Call Dispatcher

Implemented dispatch strategies:

* ✅ Sequential Strategy
* ✅ Parallel Strategy
* ✅ Fallback Strategy

Future-ready dispatch channels:

* WhatsApp Dispatcher
* Email Dispatcher
* Additional communication providers

---

## Real Emergency Communication

Aarohan supports strategy-based emergency communication across multiple channels.

Capabilities include:

* Multi-channel dispatch execution
* Sequential emergency dispatch
* Parallel emergency dispatch
* Fallback-based dispatch
* SMS pathway integration
* Phone dialer integration
* Android Share Sheet integration
* Per-dispatcher result reporting
* Aggregate dispatch status reporting
* Structured communication failures

---

## Dialer Reliability Layer

Sprint 4 introduced a dedicated `DialerGateway` abstraction to isolate Android calling behaviour.

The calling layer supports a multi-tier launch strategy:

```text
Call Request
      ↓
DialerGateway
      ↓
Preferred Dialer Resolution
      ↓
System Dialer Intent
      ↓
Generic tel: URI Fallback
      ↓
DialerLaunchResult
The gateway is designed to:

Isolate Android-specific calling logic
Respect device dialer configuration
Reduce unnecessary calling friction where supported
Handle missing or incompatible dialers safely
Return structured launch results
Avoid exposing platform exceptions directly to the UI

A native Android dialer resolution channel is planned for further stabilization and default-dialer optimization.

Emergency Type Classification

Aarohan supports structured emergency categories:

Immediate Threat to Life
Medical Emergency
Fire Emergency
Police / Safety Emergency
General Emergency

Emergency types provide contextual information for official escalation workflows.

They do not automatically determine or claim which emergency agency has been notified.

ERSS 112 Emergency Escalation

Sprint 4 introduced a dedicated official emergency escalation pathway for India's Emergency Response Support System.

Aarohan can initiate the supported citizen calling pathway to:
112
The escalation workflow is intentionally separate from trusted-contact dispatch.
Emergency Workflow
        │
        ├── Trusted Contact Dispatch
        │        ↓
        │   Dispatch Engine
        │
        └── Official Escalation
                 ↓
        Emergency Agency Gateway
                 ↓
             ERSS Gateway
                 ↓
          112 Contact Pathway

The application:

Requires explicit user confirmation
Allows emergency type selection
Opens the 112 contact pathway
Preserves emergency context where available
Provides fallback emergency number information
Uses truthful result wording

Aarohan does not claim that police, ambulance, fire services, or other authorities have been automatically notified.

The user must complete the emergency call to communicate with ERSS operators.

Truthful Emergency Communication

Safety-critical wording is treated as an architectural concern.

The application uses structured wording rules to avoid misleading emergency claims.

Examples of valid wording:
112 India contact pathway opened.

Complete the call to speak to the operator.

The application intentionally avoids unverified claims such as:
Police notified.

Ambulance dispatched.

Authorities are on the way.
unless such outcomes can genuinely be verified by a supported future integration.

Offline First

Core functionality remains offline-first.

SharedPreferences-based local storage
Local user profile
Local emergency contact management
GPS-based location retrieval
Local emergency message preparation
No cloud backend dependency for core workflows
No authentication dependency

Network connectivity may still be required by external applications or services used after Aarohan launches a communication pathway.

Emergency Workflow:
SOS Button
      ↓
SOS Controller
      ↓
Location Service
      ↓
Message Service
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
      │
      ├── Review Dispatch Results
      │
      └── Escalate to 112
                 ↓
        Emergency Type Selection
                 ↓
         Explicit Confirmation
                 ↓
    Emergency Escalation Controller
                 ↓
      Emergency Agency Gateway
                 ↓
            ERSS Gateway
                 ↓
          Dialer Gateway
                 ↓
       112 Contact Pathway

Architecture

Aarohan follows a layered and responsibility-oriented architecture.
UI Layer
│
├── Screens
└── Widgets
│
▼
Application Layer
│
├── SOS Controller
└── Emergency Escalation Controller
│
▼
Domain / Service Layer
│
├── Location Service
├── Message Service
├── Permission Service
├── Dispatch Engine
├── Dispatch Strategies
├── Dispatchers
├── Dialer Gateway
├── Emergency Agency Gateway
└── ERSS Gateway
│
▼
Infrastructure Layer
│
├── SharedPreferences
├── Geolocator
├── Android Share Sheet
├── Android Dialer Intents
├── URL Launcher
└── Platform APIs

The architecture emphasizes:

Single Responsibility Principle
Separation of concerns
Open/Closed extensibility
Structured result models
Gateway-based platform isolation
Strategy-based dispatch execution

Trusted-contact dispatch and official agency escalation remain architecturally separate.

Tech Stack
| Component            | Technology                       |
| -------------------- | -------------------------------- |
| Framework            | Flutter                          |
| Language             | Dart                             |
| Platform             | Android                          |
| Storage              | SharedPreferences                |
| Location             | Geolocator                       |
| Permissions          | permission_handler               |
| Sharing              | share_plus                       |
| URL Launching        | url_launcher                     |
| SMS Pathway          | `sms:` URI                       |
| Phone Pathway        | `tel:` URI / Android dialer      |
| Emergency Escalation | ERSS 112 citizen calling pathway |

Project Structure
lib/
├── controllers/
│   ├── sos_controller.dart
│   └── emergency_escalation_controller.dart
│
├── models/
│   ├── dispatch/
│   ├── emergency/
│   ├── contact_model.dart
│   └── user_model.dart
│
├── screens/
│   ├── emergency_escalation_screen.dart
│   └── ...
│
├── services/
│   ├── dispatch/
│   ├── dialer/
│   ├── emergency_agency/
│   ├── location_service.dart
│   ├── message_service.dart
│   ├── permission_service.dart
│   └── storage_service.dart
│
├── widgets/
│
├── utils/
│
└── main.dart

Documentation

Comprehensive project documentation is maintained inside the /docs directory.

Documentation includes:

Project Origin
Pre-Planning
Product Vision
Architecture Decisions
Sprint Reports
Technical Reports
MVP Documentation
Project History
Future Roadmap
Lessons Learned
Release Notes
Developer Handover Guide

The documentation records both implemented capabilities and the reasoning behind major architecture decisions.

Current Status
| Item                         | Status                                     |
| ---------------------------- | ------------------------------------------ |
| Version                      | v4.0.0                                     |
| Sprint                       | Sprint 4 Implemented                       |
| Build Status                 | Release APK Generated                      |
| APK Size                     | Approximately 49 MB                        |
| Platform                     | Android                                    |
| Architecture                 | Dispatch Reliability & Official Escalation |
| Release State                | Functional Prototype                       |
| Device Validation            | Brief Validation Complete                  |
| Full Multi-Dialer Validation | Pending                                    |

Communication & Escalation Capabilities

| Capability                       | Status        |
| -------------------------------- | ------------- |
| Simulation Dispatcher            | ✅ Implemented |
| Share Dispatcher                 | ✅ Implemented |
| SMS Dispatcher                   | ✅ Implemented |
| Call Dispatcher                  | ✅ Implemented |
| Sequential Strategy              | ✅ Implemented |
| Parallel Strategy                | ✅ Implemented |
| Fallback Strategy                | ✅ Implemented |
| Dialer Gateway                   | ✅ Implemented |
| Emergency Type Classification    | ✅ Implemented |
| Emergency Agency Gateway         | ✅ Implemented |
| ERSS 112 Gateway                 | ✅ Implemented |
| Explicit Escalation Confirmation | ✅ Implemented |
| Truthful Escalation Wording      | ✅ Implemented |
| Native Default Dialer Resolution | 🚧 Planned    |
| WhatsApp Direct Dispatcher       | 🚧 Planned    |
| Email Dispatcher                 | 🚧 Planned    |

Roadmap
Sprint 1 — Core MVP
User registration
Emergency contacts
GPS integration
Emergency message generation
Initial SOS workflow
Local persistence
Sprint 2 — Emergency Dispatch Engine
SOS Controller
Emergency Alert model
Dispatch Result model
Dispatcher abstraction
Share Dispatcher
Modular Dispatch Engine
Sprint 3 — Real Emergency Communication Layer
SMS Dispatcher
Call Dispatcher
Share Dispatcher
Strategy Engine
Sequential Strategy
Parallel Strategy
Fallback Strategy
Permission management
Multi-channel dispatch reporting
Sprint 4 — Emergency Dispatch Reliability & Official Escalation
DialerGateway abstraction
CallDispatcher refactor
Structured DialerLaunchResult
Emergency type model
EmergencyAgencyGateway
ERSS 112 Gateway
Emergency Escalation Controller
Emergency Escalation Screen
Explicit escalation confirmation
Truthful UI wording safeguards
112 contact pathway integration
Stabilization
Native Android DialerGateway MethodChannel implementation
Default dialer resolution
Truecaller multi-dialer testing
Full physical-device validation
Failure-path testing
Architecture documentation refresh
Future Roadmap
Active SOS safety controls
Safe / resolved emergency updates
Accidental SOS cancellation
Live location tracking
Emergency Session Manager
Alert History
Retry Engine
Emergency Timeline
WhatsApp Dispatcher
Email Dispatcher
Cloud synchronization
SafeRoute evolution

Known Limitations

The current version has the following known limitations:

Native default dialer resolution is not yet implemented
Dialer chooser behaviour may depend on Android device configuration
The user must explicitly complete phone calls
Aarohan does not automatically notify ERSS authorities
Real 112 calls are intentionally not performed during testing
Automatic background SMS delivery is not implemented
Continuous live location tracking is not implemented
Alert History is not implemented
Emergency Timeline is not implemented
Authentication is not implemented
Cloud synchronization is not implemented
AI-assisted emergency detection is not implemented

These limitations are intentionally documented to avoid overstating application capabilities.

Safety and Responsible Use

Aarohan SOS Alert is an emergency assistance prototype.

The application must not be treated as a replacement for official emergency services.

For official emergency assistance in India, users should contact the appropriate emergency service through the supported official pathway.

The ERSS 112 escalation capability in Aarohan assists the user in initiating the calling pathway.

It does not guarantee:

Successful call completion
Emergency service acknowledgement
Responder dispatch
Response time
Emergency resolution

Use emergency services only for genuine emergencies.

Contributors
Amitesh Rajput

Project Owner & Lead Developer

Responsibilities:

Original project idea
Product vision
UI/UX planning
Feature planning
Flutter development
Device testing
Product ownership

Raghavendra Singh

Technical Mentor & Software Architect

Responsibilities:

Software architecture
Engineering mentorship
System design
Architecture reviews
Documentation strategy
Sprint planning
Technical review
Release management

Philosophy

Aarohan is built around a simple engineering principle:

Build a complete, maintainable, reliable, and truthful solution before expanding functionality.

The project prioritizes:

Simplicity
Reliability
Modularity
Extensibility
Clean architecture
Safety-conscious design
Truthful communication
Practical execution

License

Licensed under the MIT License.

Copyright (c) 2026 Amitesh Rajput

See the LICENSE file for complete license information.