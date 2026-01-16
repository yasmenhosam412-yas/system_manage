import 'package:flutter/material.dart';
import 'package:system_manage/core/utils/app_colors.dart';

class WeekDaysSelector extends StatefulWidget {
  final Function(List<String> days) onSelect;
  final List<String> initialDays;

  const WeekDaysSelector({
    super.key,
    required this.onSelect,
    this.initialDays = const [],
  });

  @override
  State<WeekDaysSelector> createState() => _WeekDaysSelectorState();
}

class _WeekDaysSelectorState extends State<WeekDaysSelector> {
  List<int> selectedDays = [];

  final List<String> weekDays = [
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
  ];

  @override
  void initState() {
    super.initState();

    for (var day in widget.initialDays) {
      final index = weekDays.indexOf(day);
      if (index != -1) {
        selectedDays.add(index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: List.generate(weekDays.length, (index) {
        final isSelected = selectedDays.contains(index);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedDays.remove(index);
              } else {
                selectedDays.add(index);
              }
            });

            widget.onSelect(selectedDays.map((i) => weekDays[i]).toList());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(3),
            child: Text(
              weekDays[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}
