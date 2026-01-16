import 'package:flutter/material.dart';
import 'package:system_manage/models/anncounce_model.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_padding.dart';
import '../../../../../core/utils/app_texts.dart';
import '../../../../../core/utils/text_styles.dart';

class Accouncement extends StatelessWidget {
  final List<AnnounceModel> list;
  final VoidCallback? onViewAll;

  const Accouncement({super.key, required this.list, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final displayList = list.length > 3 ? list.sublist(0, 3) : list;

    return Container(
      padding: const EdgeInsets.all(AppPadding.small),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(AppPadding.small),
      ),
      child: Column(
        children: List.generate(displayList.length, (index) {
          final announce = displayList[index];

          return Column(
            children: [
              if (index == 0) ...[
                _buildHeader(context),
                const SizedBox(height: AppPadding.small),
              ],

              _buildAnnounceItem(announce),

              if (index != displayList.length - 1)
                const SizedBox(height: AppPadding.medium),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primaryColor.withOpacity(0.3),
          child: Icon(
            Icons.record_voice_over_outlined,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: AppPadding.small),
        Text(AppTexts.announcements, style: AppTextStyles.font16Black600),
        const Spacer(),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            AppTexts.viewAll,
            style: AppTextStyles.font16Black600.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnounceItem(AnnounceModel announce) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppPadding.small),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(AppPadding.small),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "${announce.name} ",
              style: AppTextStyles.font16Black600.copyWith(color: Colors.black),
            ),
            TextSpan(
              text: announce.desc,
              style: AppTextStyles.font16Black600.copyWith(
                color: AppColors.grey800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
