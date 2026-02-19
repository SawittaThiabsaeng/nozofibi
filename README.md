# Nozofibi - Study Timer App

A Flutter application for study session tracking, task management, and productivity statistics.

## Features

- **Study Timer**: Start, pause, and reset study sessions with real-time tracking
- **Task Management**: Create, update, complete, and delete tasks with deadlines
- **Session Tracking**: Track all study sessions and view statistics
- **Statistics Dashboard**: View detailed productivity metrics including:
  - Total study time
  - Number of sessions
  - Average session duration
  - Task completion rate
- **Bottom Tab Navigation**: Easy navigation between Study Timer, Tasks, and Stats
- **State Management**: Provider-based state management for clean architecture

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── task.dart            # Task model
│   ├── study_session.dart   # StudySession model
│   └── index.dart           # Model exports
├── providers/               # State management
│   ├── task_provider.dart           # Task state
│   ├── study_timer_provider.dart    # Timer state
│   ├── study_session_provider.dart  # Session state
│   └── index.dart                   # Provider exports
├── screens/                 # UI screens
│   ├── login_screen.dart    # Login page
│   ├── home_screen.dart     # Main home with tab navigation
│   ├── study_timer_screen.dart    # Timer screen
│   ├── task_list_screen.dart      # Task list screen
│   ├── add_task_screen.dart       # Add/edit task screen
│   ├── stats_screen.dart    # Statistics dashboard
│   └── index.dart           # Screen exports
└── widgets/                 # Reusable widgets
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. Clone or extract the repository
2. Navigate to the project directory:
   ```bash
   cd nozofibi
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

#### Android
```bash
flutter run -d android
```

#### iOS
```bash
flutter run -d ios
```

#### Web
```bash
flutter run -d chrome
```

#### Desktop (Windows/macOS/Linux)
```bash
flutter run -d windows
# or
flutter run -d macos
# or
flutter run -d linux
```

### Build Release

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## Data Models

### Task
```dart
Task {
  String id,
  String title,
  DateTime deadline,
  bool isCompleted
}
```

### StudySession
```dart
StudySession {
  String id,
  DateTime startTime,
  Duration duration
}
```

## Navigation Flow

```
Login Screen
    ↓
Home Screen (Bottom Tab Navigation)
    ├── Study Timer Tab
    ├── Tasks Tab
    │   └── Add Task Screen
    └── Stats Tab
```

## State Management

The app uses the `provider` package for state management with the following providers:

- **StudyTimerProvider**: Manages the study timer state (running, duration, formatted time)
- **TaskProvider**: Manages task list operations (CRUD)
- **StudySessionProvider**: Manages study sessions and statistics

## Dependencies

- **flutter**: Flutter SDK
- **provider**: State management solution
- **intl**: Internationalization and formatting

## Development

### Run with Debugging
```bash
flutter run --debug
```

### Run with Verbose Output
```bash
flutter run -v
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

### Analyze Code
```bash
flutter analyze
```

### Format Code
```bash
dart format lib/
```

## Future Enhancements

- User authentication and cloud sync
- Detailed session history with charts
- Task categories and priorities
- Notifications and reminders
- Dark mode support
- Multi-language support
- Offline capabilities with local database

## License

This project is open source and available under the MIT License.

## Support

For issues, questions, or suggestions, please open an issue in the project repository.
