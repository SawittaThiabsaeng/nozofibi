import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_strings.dart';
import '../models/task.dart';
import '../screens/timer_view.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/roller_time_picker.dart';
import '../widgets/soft_background.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({
    required this.tasks,
    required this.onAddTask,
    required this.onToggle,
    required this.onDelete,
    super.key,
    this.onSessionSaved,
  });

  final List<ScheduleTask> tasks;
  final Function(ScheduleTask) onAddTask;
  final Function(String) onToggle;
  final Function(String) onDelete;
  final VoidCallback? onSessionSaved;

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = widget.tasks
        .where((t) => DateUtils.isSameDay(t.date, selectedDate))
        .toList();

    return Scaffold(
      extendBody: true,
      body: SoftBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.schedule,
                  style: isDark
                      ? AppTheme.h1.copyWith(color: Colors.white)
                      : AppTheme.h1,
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: _pickDateFromCalendar,
                      icon: const Icon(Icons.calendar_month_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white,
                        fixedSize: const Size(52, 52),
                        foregroundColor: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: _addTaskDialog,
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        fixedSize: const Size(52, 52),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              DateFormat('MMMM yyyy', localeTag).format(selectedDate),
              style: AppTheme.caption.copyWith(
                color: isDark ? Colors.white70 : AppTheme.textMuted,
              ),
            ),

            const SizedBox(height: 24),

            /// DATE SELECTOR
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 92,
                itemBuilder: (context, i) {
                  final start = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  );
                  final d = start.add(Duration(days: i));
                  final isSel = DateUtils.isSameDay(d, selectedDate);

                  return GestureDetector(
                    onTap: () => setState(() => selectedDate = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 68,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppTheme.primary
                            : isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E').format(d).toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSel ? Colors.white70 : AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            d.day.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isSel
                                  ? Colors.white
                                  : isDark
                                      ? Colors.white
                                      : AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            /// TASK LIST
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(
                  child: Text(
                    s.noPlansToday,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : AppTheme.textMuted,
                    ),
                  ),
                ),
              )
            else
              ...filtered.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TimerView(
                            task: t,
                            fromSchedule: true,
                            onSaved: widget.onSessionSaved,
                          ),
                        ),
                      );

                      if (result == true) {
                        setState(() {});
                      }
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _icon(t.type),
                            size: 20,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(t.time, style: AppTheme.caption),
                              const SizedBox(height: 4),
                              Text(
                                t.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  decoration: t.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: t.completed
                                      ? AppTheme.textMuted
                                      : isDark
                                          ? Colors.white
                                          : AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _taskTypeLabel(t.type, s),
                                style: AppTheme.caption.copyWith(
                                  color: isDark
                                      ? Colors.white70
                                      : AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          t.completed
                              ? Icons.check_circle
                              : Icons.radio_button_off,
                          size: 22,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: () => widget.onDelete(t.id),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTaskDialog() async {
    await _addTaskDialogForDate(selectedDate);
  }

  Future<void> _addTaskDialogForDate(DateTime date) async {
    final controller = TextEditingController();
    var selectedType = TaskType.study;
    var selectedTime = TimeOfDay.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              32,
              24,
              MediaQuery.of(context).viewInsets.bottom + 48,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.of(context).addNewPlan,
                  style: isDark
                      ? AppTheme.h2.copyWith(color: Colors.white)
                      : AppTheme.h2,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Color(0xFF111827)),
                  decoration: InputDecoration(
                    hintText: AppStrings.of(context).whatPlanning,
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.of(context).planType,
                    style: AppTheme.caption,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final type in const [
                      TaskType.breakTime,
                      TaskType.study,
                      TaskType.exercise,
                      TaskType.rest,
                    ])
                      ChoiceChip(
                        avatar: Icon(
                          _icon(type),
                          size: 16,
                          color: selectedType == type
                              ? Colors.white
                              : AppTheme.primary,
                        ),
                        label: Text(_taskTypeLabel(type, AppStrings.of(context))),
                        selected: selectedType == type,
                        onSelected: (_) {
                          setModalState(() => selectedType = type);
                        },
                        selectedColor: AppTheme.primary,
                        labelStyle: TextStyle(
                          color: selectedType == type ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    final picked = await showRollerTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setModalState(() => selectedTime = picked);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.of(context).setTime,
                                style: AppTheme.caption,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedTime.format(context),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          AppStrings.of(context).tapToChangeTime,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.of(context).quickPick,
                    style: AppTheme.caption,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final preset in const [
                      TimeOfDay(hour: 8, minute: 0),
                      TimeOfDay(hour: 13, minute: 0),
                      TimeOfDay(hour: 19, minute: 0),
                    ])
                      ChoiceChip(
                        label: Text(preset.format(context)),
                        selected: preset.hour == selectedTime.hour &&
                            preset.minute == selectedTime.minute,
                        onSelected: (_) {
                          setModalState(() => selectedTime = preset);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final title = controller.text.trim();
                      if (title.isEmpty) {
                        return;
                      }

                      widget.onAddTask(
                        ScheduleTask(
                          id: DateTime.now().toString(),
                          date: date,
                          time: selectedTime.format(context),
                          title: title,
                          type: selectedType,
                        ),
                      );
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      AppStrings.of(context).savePlan,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!mounted || saved != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.of(context).planSaved)),
    );
  }

  Future<void> _pickDateFromCalendar() async {
    final now = DateTime.now();
    final initialDate = selectedDate.isBefore(now) ? now : selectedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      helpText: AppStrings.of(context).schedule,
      builder: (context, child) {
        final pickerTheme = Theme.of(context).copyWith(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.primary,
            brightness: Brightness.light,
          ),
          datePickerTheme: const DatePickerThemeData(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
        );
        return Theme(
          data: pickerTheme,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      await _addTaskDialogForDate(picked);
    }
  }

  IconData _icon(TaskType t) {
    switch (t) {
      case TaskType.study:
        return Icons.menu_book;
      case TaskType.breakTime:
        return Icons.category_rounded;
      case TaskType.exercise:
        return Icons.fitness_center;
      case TaskType.rest:
        return Icons.assignment_rounded;
    }
  }

  String _taskTypeLabel(TaskType type, AppStrings s) {
    switch (type) {
      case TaskType.breakTime:
        return s.typeGeneral;
      case TaskType.study:
        return s.typeReading;
      case TaskType.exercise:
        return s.typeExercise;
      case TaskType.rest:
        return s.typeHomework;
    }
  }
}
