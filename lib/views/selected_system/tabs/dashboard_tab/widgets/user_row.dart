import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:system_manage/core/utils/app_colors.dart';

import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/app_padding.dart';

class UserRow extends StatelessWidget {
  final String username;
  final String? image;

  const UserRow({super.key, required this.username, this.image});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.primaryColor.withOpacity(0.3),
          backgroundImage: (image != null && image!.isNotEmpty)
              ? CachedNetworkImageProvider(image!)
              : null,
          child: (image == null || image!.isEmpty)
              ? Text(
                  username.substring(0, 2).toUpperCase() ?? "",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        SizedBox(width: AppPadding.small),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "Hello, "),
              TextSpan(text: username),
            ],
          ),
        ),
        Spacer(),
        IconButton(onPressed: () {}, icon: Icon(Icons.notifications_outlined)),
      ],
    );
  }
}
