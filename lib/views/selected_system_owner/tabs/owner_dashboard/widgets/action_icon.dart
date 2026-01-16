import 'package:flutter/material.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_padding.dart';
import '../../../../../core/utils/app_texts.dart';
import '../../../../../core/utils/text_styles.dart';

class ActionIcon extends StatelessWidget {
  final String label;
  final IconData iconData;
  final Color bg;
  final Color iconColor;
  final VoidCallback onTab;
  const ActionIcon({super.key, required this.label, required this.iconData, required this.bg, required this.iconColor, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTab,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: bg,
            child: Icon(iconData, color: iconColor),
          ),
          SizedBox(height: AppPadding.small),
          Text(
            label,
            style: AppTextStyles.font16Black600.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
