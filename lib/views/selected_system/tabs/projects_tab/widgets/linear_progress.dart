import 'package:flutter/material.dart';
import 'package:system_manage/core/utils/app_padding.dart';

class LinearPercentIndicator extends StatelessWidget {
  final num percent;
  final Color color;
  final String title;

  const LinearPercentIndicator({
    super.key,
    required this.percent,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    double progressValue = (percent / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ${percent.toStringAsFixed(1)}%",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppPadding.medium),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 10,
            color: color,
            backgroundColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}
