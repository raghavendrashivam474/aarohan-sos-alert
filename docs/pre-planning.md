# pre-planning.md

## Aarohan SOS Alert

Version: Final Revision

Status: Historical Planning Record

---

# Background

The Aarohan SOS Alert project originated from an idea proposed by Amitesh Rajput.

The initial concept was to create a mobile application capable of helping users during emergency situations through a single SOS action.

The original vision included:

* Emergency alert generation
* Calling trusted contacts
* Sending emergency messages
* Sharing user location

The project was discussed, refined, and structured through multiple planning sessions before implementation began.

This document preserves the reasoning, decisions, and scope discussions that shaped the project before development.

---

# Project Owner

Amitesh Rajput

Role:

* Idea Owner
* Product Owner
* Primary Feature Decision Maker

---

# Planning Contributions

During the planning phase, the following activities were completed:

## Problem Definition

The emergency response problem was identified and refined.

Target users identified:

* General public
* Elderly individuals
* Students
* Solo travellers
* Individuals requiring rapid emergency assistance

The primary goal became:

> Enable users to quickly notify trusted contacts and share their location during emergencies.

---

# Feature Discovery

Initial features proposed:

* SOS Alert System
* Emergency Calling
* Emergency Messaging
* Live Location Sharing
* Emergency Contact Management

Additional concepts discussed:

* Voice Activation
* Smart SOS
* Alarm Trigger
* Police Contacting
* Ambulance Contacting
* Continuous Tracking

These ideas helped shape the long-term vision but were intentionally deferred.

---

# Product Scope Refinement

One of the most important planning activities was reducing scope to create a realistic MVP.

Final MVP Features:

* User Information Collection
* Emergency Contact Storage
* SOS Dashboard
* GPS Location Retrieval
* Emergency Message Generation
* Contact Management
* Local Data Persistence

Excluded from MVP:

* Authentication
* Backend Services
* Cloud Database
* Continuous Tracking
* AI Features
* Voice Commands
* SMS Automation
* Automatic Calling

This decision significantly reduced implementation complexity and increased the likelihood of successful completion.

---

# User Flow Definition

Final user flow established during planning:

Introduction Screen
↓
User Details Screen
↓
Emergency Contact Setup
↓
SOS Dashboard
↓
Emergency Workflow
↓
Alert Confirmation Screen

This workflow remained largely unchanged throughout implementation.

---

# Wireframe Development

Initial hand-drawn wireframes were produced to visualize application structure.

Defined screens included:

* Introduction Screen
* User Details Screen
* SOS Dashboard
* Contact Management Screen
* Alert Confirmation Screen

These wireframes served as the foundation for implementation.

---

# Detailed Screen Planning

The following screens were finalized before development:

## Screen 1

Introduction

Purpose:
Application introduction and onboarding.

---

## Screen 2

User Details + Emergency Contacts

Purpose:
Collect user information and trusted contact details.

---

## Screen 3

SOS Dashboard

Purpose:
Provide a single-action emergency trigger.

---

## Screen 4

Emergency Contact Management

Purpose:
Add, edit, and manage emergency contacts.

---

## Screen 5

Success / Alert Confirmation

Purpose:
Display SOS execution result and generated emergency information.

---

# Branding Decisions

Application Name:

Aarohan SOS Alert

Tagline:

Help. Anytime. Anywhere.

Logo Direction:

* Shield Symbol
* SOS Identity
* Emergency Communication Theme
* Safety-Oriented Visual Language

A final logo was selected and later integrated into the completed application.

---

# Technology Direction

Before development, the following technical approach was selected:

Frontend:

* Flutter

Local Storage:

* SharedPreferences

Location Services:

* Geolocator

Permissions:

* Permission Handler

Architecture Approach:

* Offline First
* Local Data Storage
* No Backend Dependency
* Simple MVP Architecture

This technology direction remained unchanged during development.

---

# Planning Risks Identified

During planning, several risks were identified:

* Scope expansion
* Feature overload
* SMS integration complexity
* Call integration complexity
* Android permission management
* GPS reliability

To mitigate these risks, the project was intentionally simplified.

---

# Development Readiness Checklist

Completed During Planning:

[x] Problem Statement

[x] Feature Definition

[x] User Flow

[x] Wireframes

[x] Screen Specifications

[x] Branding Direction

[x] Logo Concept

[x] MVP Scope Definition

[x] Technology Direction

Ready For:

[x] Development

[x] Testing

[x] Submission

---

# Planning Outcome

The planning phase successfully produced:

* Clear project goals
* Defined user flow
* Screen specifications
* Branding direction
* MVP scope boundaries
* Technical direction

These decisions significantly reduced confusion during implementation and helped maintain focus throughout development.

---

# Post-Planning Reflection

The planning process proved valuable because it prevented uncontrolled scope growth and established a realistic MVP.

Several ambitious ideas were intentionally deferred, allowing the project to reach a completed and build-validated state.

The final application remained closely aligned with the original planning vision while successfully delivering a functional SOS assistance prototype.

---

# Key Observation

Aarohan evolved from a simple emergency assistance idea into a structured software project through iterative planning, requirement clarification, wireframing, branding discussions, scope control, and technical decision-making.

This document preserves the context and rationale behind the project's earliest decisions and serves as the historical starting point of the Aarohan SOS Alert journey.
