import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:system_manage/core/utils/text_styles.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_padding.dart';

class CustomContainer extends StatelessWidget {
  final String label;
  final String subtitle;

  const CustomContainer({
    super.key,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppPadding.medium),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(AppPadding.small),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.font16Black600),
          SizedBox(height: AppPadding.small,),
          Text(
            subtitle,
            style: AppTextStyles.font16Black600.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
