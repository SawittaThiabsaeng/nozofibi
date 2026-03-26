import 'package:flutter/material.dart';

class RollerDurationPicker extends StatefulWidget {
  final int initialTotalSeconds;
  final Function(int) onDurationSelected;

  const RollerDurationPicker({
    super.key,
    required this.initialTotalSeconds,
    required this.onDurationSelected,
  });

  @override
  State<RollerDurationPicker> createState() => _RollerDurationPickerState();
}

class _RollerDurationPickerState extends State<RollerDurationPicker> {
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController secondController;
  late int selectedHours;
  late int selectedMinutes;
  late int selectedSeconds;

  @override
  void initState() {
    super.initState();
    selectedHours = widget.initialTotalSeconds ~/ 3600;
    selectedMinutes = (widget.initialTotalSeconds % 3600) ~/ 60;
    selectedSeconds = widget.initialTotalSeconds % 60;
    hourController = FixedExtentScrollController(initialItem: selectedHours);
    minuteController = FixedExtentScrollController(initialItem: selectedMinutes);
    secondController =
        FixedExtentScrollController(initialItem: selectedSeconds);
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    secondController.dispose();
    super.dispose();
  }

  void _updateDuration() {
    final totalSeconds =
        (selectedHours * 3600) + (selectedMinutes * 60) + selectedSeconds;
    widget.onDurationSelected(totalSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display selected duration
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
                    selectedHours.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    selectedMinutes.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    selectedSeconds.toString().padLeft(2, '0'),
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
                            setState(() => selectedHours = index);
                            _updateDuration();
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
                    padding: const EdgeInsets.symmetric(horizontal: 6),
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
                            setState(() => selectedMinutes = index);
                            _updateDuration();
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
                  // Separator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  // Seconds
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
                        // Second roller
                        ListWheelScrollView(
                          controller: secondController,
                          itemExtent: 50,
                          diameterRatio: 1.2,
                          onSelectedItemChanged: (index) {
                            setState(() => selectedSeconds = index);
                            _updateDuration();
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
                    final totalSeconds = (selectedHours * 3600) +
                        (selectedMinutes * 60) +
                        selectedSeconds;
                    Navigator.pop(context, totalSeconds);
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

Future<int?> showRollerDurationPicker({
  required BuildContext context,
  required int initialTotalSeconds,
}) {
  return showModalBottomSheet<int>(
    context: context,
    builder: (context) => RollerDurationPicker(
      initialTotalSeconds: initialTotalSeconds,
      onDurationSelected: (_) {},
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  );
}
