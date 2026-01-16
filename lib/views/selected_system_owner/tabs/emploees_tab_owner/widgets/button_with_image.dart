import 'package:flutter/material.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import '../../../../../core/utils/app_colors.dart';

class ButtonWithImage extends StatelessWidget {
  final String label;
  final IconData iconData;
  final VoidCallback onPress;

  const ButtonWithImage({
    super.key,
    required this.label,
    required this.iconData,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: onPress,
          child: Container(
            padding: const EdgeInsets.all(AppPadding.small),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppPadding.small),
            ),
            child: Column(
              children: [
                Icon(iconData, color: AppColors.primaryColor),
                Text(
                  label,
                  style: AppTextStyles.font16Black600.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
