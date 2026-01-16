import 'package:flutter/material.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_padding.dart';
import '../../../../../core/utils/text_styles.dart';
import '../../../../selected_system/tabs/dashboard_tab/widgets/avatar_label.dart';

class AttendaceSummery extends StatelessWidget {
  final String present;
  final String absent;
  final String late;

  const AttendaceSummery({
    super.key,
    required this.present,
    required this.absent,
    required this.late,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppPadding.small),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(AppPadding.small),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text("Attendance Summery", style: AppTextStyles.font16Black600),
              Spacer(),
              Text(
                "View Details",
                style: AppTextStyles.font16Black600.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppPadding.medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AvatarLabel(
                bg: Colors.green.shade100,
                iconData: Icons.person,
                iconColor: Colors.green,
                label: "Present",
                numbers: present,
              ),

              AvatarLabel(
                bg: Colors.orange.shade100,
                iconData: Icons.home,
                iconColor: Colors.orangeAccent,
                label: "Absent",
                numbers: absent,
              ),
              AvatarLabel(
                label: "Late",
                bg: Colors.red.shade100,
                iconData: Icons.exit_to_app_sharp,
                iconColor: Colors.red,
                numbers: late,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
