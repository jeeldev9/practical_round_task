# 📱 Smart Task Manager

[![Flutter Version](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue.svg?style=flat-square&logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20(Feature--First)-orange.svg?style=flat-square)](https://clean-architecture.org)
[![State Management](https://img.shields.io/badge/State--Management-GetX-green.svg?style=flat-square)](https://pub.dev/packages/get)
[![Database](https://img.shields.io/badge/Database-SQLite%20%26%20Firestore-red.svg?style=flat-square)](https://pub.dev/packages/sqflite)

A robust, enterprise-grade **Smart Task Manager** application built with Flutter using a **Feature-First Clean Architecture**. The application is designed to be highly performant, modular, and **offline-first**, delivering seamless synchronization between a local SQLite database and remote Cloud Firestore.

---

## ✨ Core Capabilities

### 1. 🏗️ Feature-First Clean Architecture
The codebase is structured according to domain-driven design principles, keeping components decoupled, maintainable, and highly testable:
*   **Domain Layer:** Pure Dart code containing business entities, repository contracts, and isolated use cases. Completely independent of any framework or UI library.
*   **Data Layer:** Implementation of repositories, models (JSON serialization/deserialization), and data sources (SQLite, Firebase, network clients).
*   **Presentation Layer:** State controllers powered by GetX, responsive UI screens, and reusable widgets.

### 2. ⚡ Offline-First Synchronization
A highly reliable offline sync engine ensures the app remains fully functional without internet access:
*   **SQLite Local Cache:** All task operations are written instantly to SQLite (`sqflite`), providing instant responsiveness.
*   **Action Queue:** Offline modifications (`CREATE`, `UPDATE`, `DELETE`) are serialized into JSON and queued in a local `pending_actions` table.
*   **Reactive Sync Trigger:** A dedicated `ConnectivityService` monitors network status. Upon reconnecting, the `SyncService` is triggered to process and replay the pending action queue in chronological order, updating Cloud Firestore and reconciling local SQLite IDs.

### 3. 🔐 Secure & Modular Authentication
*   **Firebase Authentication:** Features secure Email & Password registration, login, and forgot password/recovery flows.
*   **Secure Storage:** Tokens and preferences are stored securely using `flutter_secure_storage` and `shared_preferences`.
*   **Local Profile Cache:** User profiles are cached inside a dedicated `users_cache` SQLite table to ensure instant profile loading.

### 4. 📊 Interactive Dashboard & Metrics
*   **Dynamic Metrics:** An advanced analytics dashboard aggregates real-time task metrics (e.g., total pending tasks, completed tasks, and high-priority pending tasks).
*   **Milestone tracking:** Visual progress banners dynamically measure achievements and keep users engaged.

### 5. 🔍 Advanced Search & In-Memory Filters
*   **Instant Search:** Multi-field string matching (titles and descriptions) calculated responsively in-memory via GetX observables.
*   **Multi-Criteria Filtering:** Quick-toggle filters to refine tasks dynamically by Priority Level (Low, Medium, High) and Task Status (Active, Completed).

### 6. 🔔 Smart Notification System
*   **Push Notifications:** Fully integrated with Firebase Cloud Messaging (FCM) to handle background, foreground, and terminated state notification entry points.
*   **Local Scheduled Alerts:** Automatically schedules precise reminders for task due dates (set to fire at 9:00 AM on the day of the due date) using `flutter_local_notifications`.
*   **Notifications History:** A local notifications screen keeps a historical ledger of all received alerts, allowing easy tracking.

### 7. 🎨 Premium Modern UI & Theme Management
*   **Harmonious Color Palette:** Designed with beautiful Light, Dark, and System theme configurations.
*   **Zero Flash/Jump Startup:** Theme preferences are fetched from local storage before the initial build frame so there is no layout flashing.
*   **Rich Micro-interactions:** Smooth animations using Lottie, progressive shimmer loading effects, and clean Google Fonts typography (Outfit / Inter).

---

## 📂 Architecture & Folder Structure

The app follows a **Feature-First Clean Architecture** approach, meaning files are organized primarily by features, and then by architectural layers (`domain`, `data`, `presentation`).

```text
lib/
├── core/                       # Shared modules across all features
│   ├── constants/              # App constants (strings, colors, dimensions)
│   ├── database/               # Sqflite database initialization and helpers
│   │   ├── database_helper.dart
│   │   ├── pending_action_dao.dart
│   │   └── task_dao.dart
│   ├── di/                     # Dependency Injection bindings (GetX Bindings)
│   │   └── initial_binding.dart
│   ├── routes/                 # App routing definition and configurations
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   ├── services/               # Background services (Connectivity & Sync engines)
│   │   ├── connectivity_service.dart
│   │   └── sync_service.dart
│   ├── theme/                  # Premium Light/Dark style guidelines
│   │   └── app_theme.dart
│   ├── utils/                  # Utility helpers and validators
│   └── widgets/                # Reusable cross-feature custom UI widgets
│
├── features/                   # Core business features
│   ├── auth/                   # User account features
│   │   ├── data/               # Auth repositories & data models
│   │   ├── domain/             # Auth contracts and entities
│   │   └── presentation/       # Login, Register, Forgot Password, Splash Screens
│   ├── tasks/                  # Task management system
│   │   ├── data/               # Tasks models and Sqflite/Firestore sync repository
│   │   │   ├── task_model.dart
│   │   │   └── task_repository_impl.dart
│   │   ├── domain/             # Task entities, interfaces, and specific use cases
│   │   │   ├── task_entity.dart
│   │   │   ├── task_repository.dart
│   │   │   ├── get_tasks_usecase.dart
│   │   │   ├── create_task_usecase.dart
│   │   │   └── ...
│   │   └── presentation/       # Dashboard, task list, editor, details, widgets
│   │       ├── controllers/    # GetX state managers (e.g. TaskController)
│   │       ├── screens/        # Dashboard, Task List, Detail, Create/Edit Screens
│   │       └── widgets/        # Growth banners, task cards, filter chips
│   ├── profile/                # User Profile configurations
│   ├── settings/               # Preferences & App settings (theme management)
│   └── notifications/          # FCM Push & Local notifications ledger
│
├── firebase_options.dart       # Firebase configuration options
└── main.dart                   # Application entry point & service initialization
```

---

## 🗄️ Database Schema & Offline Sync Model

To support full offline durability, the app initializes four critical tables inside local SQLite (`smart_task.db`).

### SQLite Schema Detail

#### 1. `tasks` Table
Stores the primary task details. Synchronized closely with Cloud Firestore.
| Column Name | SQLite Data Type | Description |
| :--- | :--- | :--- |
| `id` | `INTEGER` PRIMARY KEY AUTOINCREMENT | Local SQLite unique database identifier. |
| `firestore_id` | `TEXT` | Remote Document ID generated by Cloud Firestore (null if offline). |
| `title` | `TEXT` NOT NULL | Task title. |
| `description` | `TEXT` | Detailed task description. |
| `priority` | `INTEGER` | Priority scale: `1` (Low), `2` (Medium), `3` (High). |
| `status` | `INTEGER` | Status: `0` (Active/Pending), `1` (Completed). |
| `due_date` | `TEXT` | Due date formatted as `yyyy-MM-dd`. |
| `user_id` | `TEXT` NOT NULL | Firebase Auth UID corresponding to the owner. |
| `is_synced` | `INTEGER` DEFAULT `0` | Synchronization status flag: `0` (Unsynced), `1` (Synced). |
| `created_at` | `TEXT` | Timestamp of creation in ISO-8601. |
| `updated_at` | `TEXT` | Timestamp of last modification in ISO-8601. |

#### 2. `pending_actions` Table
Acts as a transaction log (queue) for synchronization.
*   **Action Types:** `CREATE`, `UPDATE`, `DELETE`.
*   **Payload JSON:** Encapsulates the complete entity data required to replicate the operation remotely.

#### 3. `users_cache` Table
Caches user credentials securely to support instantaneous profile loading on launch.

#### 4. `notifications` Table
Stores the visual notification ledger loaded inside the Notifications Screen (aggregates local alert triggers and FCM pushes).

---

## 🛠️ Project Setup & Installation

Follow these steps to run the project on your local machine:

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `>= 3.0.0`)
*   [Dart SDK](https://dart.dev/get-started)
*   [Android Studio](https://developer.android.com/studio) / [Xcode](https://developer.apple.com/xcode/)
*   [Firebase CLI](https://firebase.google.com/docs/cli) (configured and logged in)

### Step 1: Clone and Dependencies
Clone the repository to your local system and fetch the dependencies:
```bash
flutter pub get
```

### Step 2: Configure Firebase
1.  Initialize Firebase inside your Flutter project workspace:
    ```bash
    flutterfire configure
    ```
2.  Select your Firebase project or create a new one.
3.  Configure platforms (Android and iOS). This will update/generate `lib/firebase_options.dart` automatically.

### Step 3: Run the Application
Start your preferred simulator/emulator or connect a physical device, then run:
```bash
flutter run
```

---

## 🧪 Testing & Verification Guide

### 📱 Testing Offline Sync
1.  Launch the app and login.
2.  Enable **Airplane Mode** or disconnect the internet on your testing device.
3.  Add, update, or delete a few tasks. Notice the UI updates instantly due to local SQLite writes.
4.  Disable **Airplane Mode** or reconnect the internet.
5.  Open your **Cloud Firestore Console**. Observe the remote records automatically synchronize and match your local state.

### 🔔 Verification of Due Date Notifications
*   When editing or creating a task, set the **Due Date** to the current date.
*   The `TaskController` automatically schedules a local reminder via `NotificationService`.
*   A local notification is configured to trigger on the morning (9:00 AM) of the due date.
*   Additionally, a transaction entry is instantly added to your in-app **Notifications Ledger** under the "Due Date Reminder Set" type for transparency.

### 🧩 Diagnostic Traces
*   **Crash Reports:** Firebase Crashlytics is configured to capture fatal and non-fatal Dart exceptions. Unhandled issues are routed immediately to the Firebase Console.
*   **FCM Token Printing:** On startup, the FCM registration token is logged in the debug console inside a prominent header:
    ```text
    ╔══════════════════════════════════════════════════════╗
    ║  FCM TOKEN (copy this to send test notifications)    ║
    ╚══════════════════════════════════════════════════════╝
    ```
    Use this token in your Firebase Cloud Messaging Console to test targeted push notifications.

---

## 📦 Primary Packages Used

| Dependency | Purpose |
| :--- | :--- |
| **`get`** | High-performance state management, dependency injection, and app routing. |
| **`firebase_core` / `firebase_auth`** | Project initialization and email/password user authentication. |
| **`cloud_firestore`** | Cloud-based real-time remote document storage. |
| **`sqflite` / `path`** | Local relational SQLite database management for offline persistence. |
| **`flutter_local_notifications`** | Custom, high-precision local scheduled notifications. |
| **`connectivity_plus`** | Live internet and connection state tracking. |
| **`google_fonts`** | Sleek and premium typography (Inter / Outfit). |
| **`flutter_secure_storage`** | Encrypted key-value persistence for secure data. |
| **`lottie`** | Dynamic vector animations across views (e.g. splash screens, empty states). |
| **`shimmer`** | Elegant loader components for network-bound cards. |
