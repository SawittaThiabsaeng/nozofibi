import 'package:flutter/material.dart';

class RollerTimePicker extends StatefulWidget {
  const RollerTimePicker({
    required this.initialTime,
    required this.onTimeSelected,
    super.key,
  });
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;

  @override
  State<RollerTimePicker> createState() => _RollerTimePickerState();
}

class _RollerTimePickerState extends State<RollerTimePicker> {
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late int selectedHour;
  late int selectedMinute;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hour;
    selectedMinute = widget.initialTime.minute;
    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final newTime = TimeOfDay(hour: selectedHour, minute: selectedMinute);
    widget.onTimeSelected(newTime);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(
  16,
  24,
  16,
  MediaQuery.of(context).padding.bottom + 24, // ✅ เพิ่ม safe area bottom
),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display selected time
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedHour.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    selectedMinute.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Roller picker
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  // Hours
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Selection highlight
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.grey[300]!,
                              ),
                              bottom: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.grey[300]!,
                              ),
                            ),
                          ),
                        ),
                        // Hour roller
                        ListWheelScrollView(
                          controller: hourController,
                          itemExtent: 50,
                          diameterRatio: 1.2,
                          onSelectedItemChanged: (index) {
                            setState(() => selectedHour = index);
                            _updateTime();
                          },
                          physics: const FixedExtentScrollPhysics(),
                          children: List.generate(
                            24,
                            (index) => Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Separator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  // Minutes
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Selection highlight
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.grey[300]!,
                              ),
                              bottom: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.grey[300]!,
                              ),
                            ),
                          ),
                        ),
                        // Minute roller
                        ListWheelScrollView(
                          controller: minuteController,
                          itemExtent: 50,
                          diameterRatio: 1.2,
                          onSelectedItemChanged: (index) {
                            setState(() => selectedMinute = index);
                            _updateTime();
                          },
                          physics: const FixedExtentScrollPhysics(),
                          children: List.generate(
                            60,
                            (index) => Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final selectedTime =
                        TimeOfDay(hour: selectedHour, minute: selectedMinute);
                    Navigator.pop(context, selectedTime);
                  },
                  child: const Text('Set'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<TimeOfDay?> showRollerTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) =>
    showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,  // ✅ เพิ่ม
      useSafeArea: true,          // ✅ เพิ่ม — ป้องกันโดน navigation bar บัง
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // ✅ เพิ่ม
        ),
        child: RollerTimePicker(
          initialTime: initialTime,
          onTimeSelected: (_) {},
        ),
      ),
    );
