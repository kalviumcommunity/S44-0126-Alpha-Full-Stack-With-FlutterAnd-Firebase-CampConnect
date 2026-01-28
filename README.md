# S44-0126-Alpha-Full-Stack-With-FlutterAnd-Firebase-CampConnect

## Problem Statement

College clubs and student communities manage events, announcements, and attendance using scattered platforms like WhatsApp, Google Forms, and Instagram. This leads to missed updates, confusion about registrations, and inefficient event coordination.

## Solution Overview

CampConnect is a mobile-first Flutter application that centralizes club events, announcements, and attendance management into one intuitive platform. Using Firebase for real-time data sync and authentication, students can easily discover events, register, and stay updated, while club admins can manage events efficiently.

---

## Day 1 – Introduction to Flutter & Dart (2.8)

This milestone focuses on setting up the Flutter development environment and building the foundation for the CampConnect mobile application.

### What Was Implemented

- Flutter SDK installation and environment verification using `flutter doctor`
- Creation of a new Flutter project
- Modular folder structure inside the `lib/` directory:
  - `screens/` for UI screens
  - `widgets/` for reusable components
  - `models/` and `services/` for future scalability
- Implemented a basic **Welcome Screen** using `StatefulWidget`
- Added a simple UI interaction using `setState` to demonstrate Flutter’s reactive UI model

### Learnings

- Understood Flutter’s widget-based architecture
- Learned the difference between Stateless and Stateful widgets
- Gained familiarity with Dart syntax and UI composition
- Established a scalable project structure for future development

---

## Day 2 – Responsive & Adaptive UI Design (2.9)

This milestone focuses on designing a responsive and adaptive user interface for the CampConnect mobile application that works seamlessly across different screen sizes and orientations.

### What Was Implemented

- Created a new responsive home screen using Flutter
- Implemented dynamic layout adjustments using `MediaQuery` to detect screen size
- Used conditional logic to differentiate layouts for phones and tablets
- Applied adaptive widgets such as `Expanded`, `AspectRatio`, and `GridView`
- Ensured UI consistency across portrait and landscape orientations
- Designed a scalable and reusable event card layout

### Learnings

- Learned how to build responsive layouts using `MediaQuery` and `LayoutBuilder`
- Understood how to adapt UI designs for phones and tablets
- Gained experience using flexible and adaptive Flutter widgets
- Learned the importance of responsive design for real-world mobile applications
- Improved understanding of structuring reusable and scalable UI components

---

## Day 3 – Firebase Integration: Authentication & Firestore (2.10)

This milestone focuses on integrating Firebase services into the CampConnect mobile application, specifically user authentication and Firestore database for event management.

### What Was Implemented

- Integrated Firebase into the Flutter project using FlutterFire
- Initialized Firebase using Firebase.initializeApp()
- Implemented email/password authentication with Firebase Auth
- Created signup and login screens with navigation flow
- Connected Cloud Firestore for storing and retrieving user data
- Displayed Firestore data in real time using StreamBuilder

### Learnings

- Learned how to configure Firebase with Flutter
- Understood Firebase Authentication workflows
- Gained experience using Cloud Firestore with real-time updates
- Learned how Firebase simplifies backend and data synchronization
