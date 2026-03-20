import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/task.dart';
import '../widgets/glass_card.dart';
import '../widgets/soft_background.dart';
import '../screens/timer_view.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({
    super.key,
    required this.tasks,
    required this.onAddTask,
    required this.onToggle,
    required this.onDelete,
  });

  final List<ScheduleTask> tasks;
  final Function(ScheduleTask) onAddTask;
  final Function(String) onToggle;
  final Function(String) onDelete;

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
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
                  'Schedule',
                  style: isDark
                      ? AppTheme.h1.copyWith(color: Colors.white)
                      : AppTheme.h1,
                ),
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

            const SizedBox(height: 24),

            /// DATE SELECTOR
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                itemBuilder: (context, i) {
                  final d = DateTime.now().add(Duration(days: i - 2));
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
                                ? Colors.white.withOpacity(0.08)
                                : Colors.white.withOpacity(0.5),
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
                              color: isSel
                                  ? Colors.white70
                                  : AppTheme.textMuted,
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
                    'No plans for today',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white54
                          : AppTheme.textMuted,
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
                            color:
                                AppTheme.primary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(14),
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
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisSize:
                                MainAxisSize.min,
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
                          onPressed: () =>
                              widget.onDelete(t.id),
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

  void _addTaskDialog() {
    final controller = TextEditingController();
    TaskType selectedType = TaskType.study;
    TimeOfDay selectedTime = TimeOfDay.now();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(40)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            32,
            24,
            MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Plan',
                style: isDark
                    ? AppTheme.h2.copyWith(color: Colors.white)
                    : AppTheme.h2,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                style: TextStyle(
                    color:
                        isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'What are you planning?',
                  hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white54
                          : null),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  selectedTime.format(context),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setModalState(() => selectedTime = picked);
                  }
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      widget.onAddTask(
                        ScheduleTask(
                          id: DateTime.now().toString(),
                          date: selectedDate,
                          time:
                              selectedTime.format(context),
                          title: controller.text,
                          type: selectedType,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding:
                        const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Save Plan',
                    style:
                        TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(TaskType t) {
    switch (t) {
      case TaskType.study:
        return Icons.menu_book;
      case TaskType.breakTime:
        return Icons.coffee;
      case TaskType.exercise:
        return Icons.fitness_center;
      case TaskType.rest:
        return Icons.nights_stay;
    }
  }
}