import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/task.dart';
import '../widgets/glass_card.dart';

class ScheduleView extends StatefulWidget {
  final List<ScheduleTask> tasks;
  final Function(ScheduleTask) onAddTask;
  final Function(String) onToggle;
  final Function(String) onDelete;
  const ScheduleView({super.key, required this.tasks, required this.onAddTask, required this.onToggle, required this.onDelete});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final filtered = widget.tasks.where((t) => DateUtils.isSameDay(t.date, selectedDate)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 150),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Schedule', style: AppTheme.h1),
          IconButton.filled(
            onPressed: () => _addTaskDialog(), 
            icon: const Icon(Icons.add), 
            style: IconButton.styleFrom(backgroundColor: AppTheme.primary, fixedSize: const Size(56, 56))
          ),
        ]),
        const SizedBox(height: 24),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            itemBuilder: (context, i) {
              final d = DateTime.now().add(Duration(days: i - 2));
              final isSel = DateUtils.isSameDay(d, selectedDate);
              return GestureDetector(
                onTap: () => setState(() => selectedDate = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 70, margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSel ? AppTheme.primary : Colors.white.withOpacity(0.4), 
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: isSel ? [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(DateFormat('E').format(d).toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? Colors.white70 : AppTheme.textMuted)),
                    Text(d.day.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isSel ? Colors.white : AppTheme.textDark)),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        if (filtered.isEmpty) 
          const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: Text('No plans for today', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMuted))))
        else 
          ...filtered.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassCard(
              onTap: () => widget.onToggle(t.id),
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(12), 
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), 
                  child: Icon(_icon(t.type), color: AppTheme.primary)
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.time, style: AppTheme.caption),
                  Text(t.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: t.completed ? TextDecoration.lineThrough : null, color: t.completed ? AppTheme.textMuted : AppTheme.textDark)),
                ])),
                Icon(t.completed ? Icons.check_circle : Icons.radio_button_off, color: AppTheme.primary),
                IconButton(onPressed: () => widget.onDelete(t.id), icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20)),
              ]),
            ),
          ))
      ],
    );
  }

  void _addTaskDialog() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Add New Plan', style: AppTheme.h2),
          const SizedBox(height: 24),
          TextField(
            controller: controller, 
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'What are you planning?', 
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)
            )
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, 
            child: ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  widget.onAddTask(ScheduleTask(id: DateTime.now().toString(), date: selectedDate, time: '10:00 AM', title: controller.text, type: TaskType.study));
                  Navigator.pop(context);
                }
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary, 
                foregroundColor: Colors.white, 
                padding: const EdgeInsets.symmetric(vertical: 20), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))
              ), 
              child: const Text('Save Plan', style: TextStyle(fontWeight: FontWeight.w900))
            )
          )
        ]),
      ),
    );
  }

  IconData _icon(TaskType t) {
    switch(t) { 
      case TaskType.study: return Icons.menu_book; 
      case TaskType.breakTime: return Icons.coffee; 
      case TaskType.exercise: return Icons.fitness_center; 
      case TaskType.rest: return Icons.nights_stay; 
    }
  }
}
