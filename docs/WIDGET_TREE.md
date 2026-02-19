# Nozofibi - Widget Tree & Component Hierarchy

## Overall App Structure

```
MyApp
├── MaterialApp
│   ├── theme: AppTheme.lightTheme (Material 3)
│   ├── home: LoginScreen (initial route)
│   └── routes:
│       ├── /login → LoginScreen
│       ├── /home → HomeScreen
│       ├── /timer → StudyTimerScreen
│       ├── /add-task → AddTaskScreen
│       └── /stats → StatsScreen
│
├── MultiProvider
│   ├── ChangeNotifierProvider<StudyTimerProvider>
│   ├── ChangeNotifierProvider<TaskProvider>
│   └── ChangeNotifierProvider<StudySessionProvider>
```

---

## Screen Widget Trees

### LoginScreen
```
Scaffold(backgroundColor: cream)
└── SafeArea
    └── Center
        └── SingleChildScrollView
            └── Column
                ├── Text("Nozofibi")
                ├── BooksStackIllustration(size: 150)
                ├── Text("Ready to focus today?")
                ├── TextField(email)
                ├── TextField(password)
                └── ElevatedButton("Start Studying")
```

### HomeScreen (Navigation Hub)
```
Scaffold(backgroundColor: cream)
├── AppBar(title: "Nozofibi")
├── TabBar (BottomNavigationBar):
│   ├── Home (index: 0) → HomeOverviewScreen
│   ├── Tasks (index: 1) → TaskListScreen
│   ├── Timer (index: 2) → StudyTimerScreen
│   └── Stats (index: 3) → StatsScreen
├── FloatingActionButton(+) → /add-task
└── IndexedStack([HomeOverviewScreen, TaskListScreen, ...])
```

### HomeOverviewScreen
```
SafeArea
└── SingleChildScrollView
    └── Column
        ├── Card (Hero Card)
        │   ├── ClipRRect
        │   │   └── StudyDeskIllustration(height: 220)
        │   └── Padding
        │       ├── Text("Today's Study Time")
        │       ├── ProgressIndicator(60, 120)
        │       └── ElevatedButton("Start Studying")
        └── Column (Upcoming Tasks)
            ├── Text("Upcoming Tasks")
            ├── Consumer<TaskProvider>
            │   └── ListView
            │       └── TaskItemCard(×3)
            └── TextButton("See all tasks →")
```

### StudyTimerScreen
```
SafeArea
└── SingleChildScrollView
    └── Column
        └── Card (Hero Card)
            ├── ClipRRect
            │   └── StudyDeskIllustration(height: 200)
            └── Padding
                ├── Text("Today's Study Time")
                ├── Container (Circular Timer)
                │   ├── Border.all(primaryLavender, width: 4)
                │   └── Consumer<StudyTimerProvider>
                │       └── Text(formatted_time)
                ├── Text("Keep it up! You're doing great.")
                ├── Row (Control Buttons)
                │   ├── ElevatedButton(Pause)
                │   └── ElevatedButton(Reset)
                ├── ElevatedButton(Start) [conditional]
                └── ElevatedButton(Save Session, green)
```

### TaskListScreen
```
SafeArea
└── SingleChildScrollView
    └── Column
        ├── TextField(search)
        ├── Wrap (Filter Chips)
        │   ├── FilterChip(Due)
        │   ├── FilterChip(Subjects)
        │   └── FilterChip(All)
        ├── Column (Due Soon)
        │   ├── Text("Due Soon")
        │   └── Consumer<TaskProvider>
        │       └── ListView
        │           └── TaskItemCard(×n)
        ├── Column (Completed) [conditional]
        │   ├── Text("Completed")
        │   └── Consumer<TaskProvider>
        │       └── ListView
        │           └── TaskItemCard(×n)
        └── Center (Empty State) [conditional]
            ├── Text(emoji)
            └── Text("No tasks yet...")
```

### AddTaskScreen
```
Scaffold(backgroundColor: cream)
├── AppBar(title: "Add Task")
└── SafeArea
    └── SingleChildScrollView
        └── Column
            ├── Text("Task Title", style: titleMedium)
            ├── TextField(controller: title)
            ├── Text("Deadline", style: titleMedium)
            ├── GestureDetector
            │   └── Card
            │       └── ListTile
            │           ├── Icon(calendar)
            │           ├── Text(date)
            │           └── Icon(arrow)
            │               → showDatePicker()
            └── ElevatedButton("Add Task", full width)
```

### StatsScreen
```
SafeArea
└── SingleChildScrollView
    └── Column
        ├── Card (Monthly Summary)
        │   ├── BoxDecoration(gradient)
        │   └── Column
        │       ├── Text("This Month")
        │       ├── Row
        │       │   ├── Column
        │       │   │   ├── Text(hours, large)
        │       │   │   ├── Text(sessions)
        │       │   │   └── Text(average)
        │       │   └── Text(emoji)
        ├── Consumer2<SessionProvider, TaskProvider>
        │   └── Column (4 Stats)
        │       ├── StatsCard(totalTime)
        │       ├── StatsCard(sessions)
        │       ├── StatsCard(average)
        │       └── StatsCard(completed)
        └── Card (Weekly Chart)
            └── Row
                └── Column(×7)
                    ├── Container(bar, height: variable)
                    └── Text(day)
```

---

## Custom Widget Trees

### BooksStackIllustration
```
SizedBox(height: 120, width: 120)
└── Stack
    ├── Transform.rotate
    │   └── Container(book1, purple)
    ├── Transform.translate
    │   └── Transform.rotate
    │       └── Container(book2, darker_purple)
    ├── Transform.translate
    │   └── Transform.rotate
    │       └── Container(book3, darkest_purple)
    └── Transform.translate
        └── Container(character, circle with shape)
```

### StudyDeskIllustration
```
Container(height: 200-220)
├── BoxDecoration(gradient, borderRadius: 20)
└── Stack
    ├── Container(sky_gradient)
    ├── Positioned(window)
    │   └── Container(frame)
    │       ├── Gradient(sunset)
    │       ├── Circle(sun)
    │       └── Grid(window_panes)
    ├── Positioned(lamp)
    │   ├── Container(pole)
    │   └── Circle(lightbulb)
    └── Positioned(books)
        └── Row(book1, open_book, book3)
```

### TaskItemCard
```
Card
└── ListTile
    ├── leading: Checkbox(check_icon)
    ├── title: Text(task_title)
    │         [decoration: strikethrough if completed]
    ├── subtitle: Text(due_date)
    └── trailing: Row
                  ├── Badge(priority) [conditional]
                  └── IconButton(delete)
```

### StatsCard
```
Card
└── Padding
    └── Row
        ├── Container(circle_bg)
        │   └── Icon(colored)
        └── Expanded
            └── Column
                ├── Text(title, small)
                └── Text(value, large)
```

### ProgressIndicator
```
Column
├── Text("XX / YY min")
├── ClipRRect
│   └── LinearProgressIndicator
│       ├── ValueColor: lavender
│       └── height: 12
```

---

## Provider Integration Pattern

### StudyTimerProvider Usage
```
Consumer<StudyTimerProvider>(
  builder: (context, timerProvider, _) {
    // timerProvider.duration
    // timerProvider.isRunning
    // timerProvider.getFormattedTime()
    // timerProvider.start()
    // timerProvider.pause()
    // timerProvider.reset()
  }
)
```

### TaskProvider Usage
```
Consumer<TaskProvider>(
  builder: (context, taskProvider, _) {
    // taskProvider.tasks (List<Task>)
    // taskProvider.addTask(task)
    // taskProvider.updateTask(id, task)
    // taskProvider.deleteTask(id)
    // taskProvider.toggleTaskCompletion(id)
    // taskProvider.getCompletedTasks()
    // taskProvider.getPendingTasks()
  }
)
```

### StudySessionProvider Usage
```
Consumer<StudySessionProvider>(
  builder: (context, sessionProvider, _) {
    // sessionProvider.sessions (List<StudySession>)
    // sessionProvider.addSession(session)
    // sessionProvider.getTotalStudyTime()
    // sessionProvider.getTotalSessions()
    // sessionProvider.getAverageSessionDuration()
  }
)
```

---

## Responsive Design Patterns

### SafeArea Usage
All screens wrapped in SafeArea to handle:
- Top status bar
- Bottom navigation bar
- Notches and rounded corners

### SingleChildScrollView
Prevents overflow when content exceeds screen:
- Allows vertical scrolling
- Automatic keyboard handling
- FittedBox for responsive text

### Flexible/Expanded
Dynamic sizing based on screen:
- Buttons: `SizedBox(width: double.infinity)`
- Content: `Expanded(child: ...)`
- Spacers: `SizedBox(height: 16)`

### Card Constraints
Cards handle different screen sizes:
- Min/max widths maintained
- Content padding consistent
- Overflow handled by ListView wrapping

---

## Theme Integration Points

Every widget uses:
```dart
// Text styles
Theme.of(context).textTheme.headlineMedium

// Colors
Theme.of(context).colorScheme.primary

// Component themes
ElevatedButtonThemeData
OutlinedButtonThemeData
InputDecorationTheme
CardTheme
AppBarTheme
```

This ensures consistent application of Material 3 design system throughout.
