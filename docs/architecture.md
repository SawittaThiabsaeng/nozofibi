## App Architecture: Nozofibi

Screens:
- Login (Welcome screen with books illustration)
- Home (Overview with today's study progress)
- TaskList (Task management with filters)
- AddTask (Create new tasks with deadline picker)
- StudyTimer (Active timer screen)
- Stats (Analytics dashboard)

Navigation:
- Start at Login
- Login -> Home
- Home uses Bottom Tab Navigation (4 tabs):
  - Home (Overview)
  - Tasks (Task list)
  - Timer (Study timer)
  - Stats (Analytics)
- Floating Action Button (center) for quick add task

Core Features:
- Study Timer (start/pause/reset with motivational text)
- Session tracking (save sessions to history)
- Task management (create, complete, delete tasks)
- Task filtering (Due, Subjects, All)
- Analytics Dashboard (total time, sessions, average, completion rate)
- Weekly breakdown chart

Data Models:
- Task { id, title, deadline, isCompleted }
- StudySession { id, startTime, duration }

State Management:
- Provider
  - StudyTimerProvider: Timer state management
  - TaskProvider: Task CRUD operations
  - StudySessionProvider: Session tracking and stats

UI/UX Features:
- Pastel color palette (lavender purple, cream background)
- Rounded corners and soft shadows throughout
- Material 3 design system
- Responsive SafeArea layouts
- Custom illustrations (Study desk, Books stack)
- Progressive disclosure with cards
- Smooth interactions and feedback

Theme Colors:
- Primary: Lavender (#9B7BA8)
- Secondary: Soft Purple (#B8A5C8)
- Background: Cream (#FAF6F1)
- Accent: Gold (#E8C5A5)
