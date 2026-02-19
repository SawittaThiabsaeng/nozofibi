# Nozofibi UI/UX Design Guide

## 🎨 Design Direction

**Theme**: Soft, warm, cozy, and minimal
**Target Audience**: Students focused on productive study sessions
**Design System**: Material 3 with custom pastel color palette

---

## 🌈 Color Palette

### Primary Colors
- **Primary Lavender**: `#9B7BA8` - Main accent color for buttons, highlights
- **Secondary Lavender**: `#B8A5C8` - Secondary accents and states
- **Tertiary Lavender**: `#D4A5D4` - Lighter accents for hover states

### Background Colors
- **Cream Background**: `#FAF6F1` - Main app background (warm, cozy)
- **Warm Background**: `#F5EFF3` - Card and overlay backgrounds
- **White**: `#FFFFFF` - Cards, text inputs

### Text Colors
- **Dark Text**: `#5A5A5A` - Primary text color
- **Muted Text**: `#9A9A9A` - Secondary text, subtitles
- **Accent Gold**: `#E8C5A5` - Highlight badges, warm accents

---

## 📐 Typography

**Font Family**: Segoe UI (system font, friendly and readable)

### Text Styles
```
Display Large:    32px, Bold
Display Medium:   28px, Bold
Headline Medium:  24px, Semi-Bold (700)
Headline Small:   20px, Semi-Bold (600)
Title Large:      18px, Semi-Bold (600)
Title Medium:     16px, Medium (500)
Body Large:       16px, Regular (400)
Body Medium:      14px, Regular (400)
Body Small:       12px, Regular (400)
```

---

## 🎯 Component Library

### Buttons
- **Elevated Button**: Rounded pill shape (20px radius), 4px elevation
- **Outlined Button**: Border style with 2px stroke
- **Text Button**: Underline on hover
- **Floating Action Button**: Circular, center-docked position

### Cards
- **Standard Card**: 24px border radius, 4px elevation, white background
- **Hero Card**: Image top, rounded corners, content padding
- **Stat Card**: Icon + text layout with colored circle background

### Input Fields
- **Text Field**: 16px border radius, filled background, rounded outline on focus
- **Search Field**: Rounded with prefix icon
- **Date Picker**: Card wrapper with calendar

### Progress Indicators
- **Linear Progress**: Rounded ends, lavender fill
- **Circular Progress**: For timer display
- **Bar Charts**: Rounded tops, soft color with opacity variations

### Task Items
- **Task Card**: Compact card with checkbox, title, date, action buttons
- **Task Badge**: Gold accent background for priority/notifications

---

## 📱 Screens & Layouts

### 1. Login Screen
```
Layout: Centered column
- Title: "Nozofibi" (muted gray)
- Illustration: Books stack (120px)
- Prompt: "Ready to focus today?"
- Email input field
- Password input field
- "Start Studying" button (full width)
```
**Colors**: Cream background, lavender buttons
**Key Elements**: Books illustration, warm welcome message

### 2. Home (Overview) Screen
```
Layout: Scrollable single column
- Hero Card (220px height):
  - Study desk illustration
  - "Today's Study Time" title
  - Progress bar (60/120 min)
  - "Start Studying" button
- Upcoming Tasks Section:
  - Title + see all link
  - Task items (max 3)
```
**Colors**: Card white, lavender progress bar
**Interactions**: Tap card to go to timer, tap task to edit

### 3. Study Timer Screen
```
Layout: Scrollable single column
- Hero Card:
  - Study desk illustration (200px)
  - "Today's Study Time" title
  - Large timer display in circle (HH:MM:SS)
  - "Keep it up! You're doing great." message
- Control buttons:
  - Pause button
  - Reset button
  - Start button (if paused)
- Green "Save Session" button
```
**Colors**: Lavender circle border, green save button
**Animations**: Smooth timer updates, button state changes

### 4. Task List Screen
```
Layout: Scrollable single column
- Search bar (16px radius)
- Filter chips: Due, Subjects, All
- Two sections:
  - "Due Soon" section with task cards
  - "Completed" section (muted)
- Empty state with emoji if no tasks
```
**Colors**: Lavender chips when selected, gold badge for priority
**Filters**: Chips update display dynamically

### 5. Add Task Screen
```
Layout: Centered card in scrollable column
- "Task Title" label + input
- "Deadline" label + date picker card
- Full-width "Add Task" button
```
**Colors**: Cream background, lavender button
**Interactions**: Date picker opens calendar modal

### 6. Analytics/Stats Screen
```
Layout: Scrollable single column
- Monthly Summary Card:
  - "This Month" subtitle
  - Large hours display
  - Sessions count
  - Average per day
  - Plant emoji decoration
- Stats Cards (4):
  - Icon + circle background
  - "Total Study Time", "Sessions", "Average", "Tasks Completed"
- Weekly Breakdown:
  - 7 bar chart representing days
  - Today's bar highlighted in full color
```
**Colors**: Gradient card background, colored icons
**Charts**: Rounded bars, varying opacities, today highlighted

---

## 🎬 Animations & Transitions

- **Button Press**: Scale down 0.95 on press, scale up on release
- **Card Entrance**: Fade + slide up from bottom (250ms)
- **Progress Update**: Smooth fill animation (300ms)
- **Screen Transition**: Fade in/out (200ms)
- **Snackbar**: Slide up from bottom (300ms)

---

## 🔄 Navigation Structure

```
Login
  ↓
Home Screen (Bottom Tab Navigation)
  ├─ Tab 1: Home Overview
  ├─ Tab 2: Task List
  ├─ Tab 3: Study Timer
  └─ Tab 4: Stats
  
Floating Action Button (all tabs)
  └─ Add Task Screen
```

---

## ♿ Accessibility Features

- **Text Contrast**: All text meets WCAG AA standards
- **Touch Targets**: All interactive elements 48px minimum
- **Focus States**: Clear focus indication on all inputs
- **Semantics**: Proper semantic HTML and Material widget usage
- **Animations**: Respects `prefers-reduced-motion` setting

---

## 📐 Spacing System

```
Consistent 8px grid:
- 8px: Minimal spacing
- 16px: Default padding/margin
- 24px: Card padding, section spacing
- 32px: Large gap between sections
- 48px: Hero section spacing
```

---

## 🎨 Implementation Notes

### Material 3 Adoption
- Using `useMaterial3: true` in ThemeData
- Custom ColorScheme with primary, secondary, tertiary
- Material 3 elevation and shadow system
- Shape overrides for rounded components

### Custom Widgets
- `BooksStackIllustration`: Welcome screen
- `StudyDeskIllustration`: Hero card for study screens
- `ProgressIndicator`: Custom styled progress bar
- `TaskItemCard`: Reusable task display component
- `StatsCard`: Stat display with icon

### Responsive Design
- SafeArea on all screens
- SingleChildScrollView for overflow handling
- Flexible/Expanded widgets for dynamic sizing
- FittedBox for responsive text scaling

---

## 🎯 Design Principles

1. **Warm & Inviting**: Soft colors evoke comfort and focus
2. **Clear Visual Hierarchy**: Size and color guide attention
3. **Consistent Spacing**: 8px grid creates rhythm
4. **Minimal Distractions**: Clean layouts with whitespace
5. **Friendly Interactions**: Smooth animations, encouraging messages
6. **Accessible to All**: High contrast, large touch targets
7. **Context Aware**: Illustrations support content meaning
