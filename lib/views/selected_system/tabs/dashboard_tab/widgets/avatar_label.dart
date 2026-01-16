import 'package:flutter/material.dart';
import 'package:system_manage/core/utils/app_padding.dart';

class AvatarLabel extends StatelessWidget {
  final IconData iconData;
  final Color bg;
  final Color iconColor;
  final String label;
  final String numbers;

  const AvatarLabel({
    super.key,
    required this.iconData,
    required this.bg,
    required this.iconColor,
    required this.label, required this.numbers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: bg,
          child: Icon(iconData, color: iconColor),
        ),
        SizedBox(height: AppPadding.small,),
        Text(numbers),
        Text(label),
      ],
    );
  }
}
