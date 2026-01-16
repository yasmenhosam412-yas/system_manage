import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/attendance_cubit/attendance_cubit.dart';
import 'package:system_manage/core/utils/app_texts.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_padding.dart';
import '../../../../../core/utils/text_styles.dart';
import 'avatar_label.dart';

class Attendace extends StatefulWidget {
  final String present;
  final String remote;
  final String leave;
  final String absent;
  final String code;

  const Attendace({
    super.key,
    required this.present,
    required this.remote,
    required this.leave,
    required this.absent,
    required this.code,
  });

  @override
  State<Attendace> createState() => _AttendaceState();
}

class _AttendaceState extends State<Attendace> {
  List<Map<String, dynamic>> types = [
    {"type": AppTexts.presentToday, "status": "present"},
    // {"type": AppTexts.finishedToday, "status": "done"},
    {"type": AppTexts.remoteToday, "status": "remote"},
    {"type": AppTexts.absentToday, "status": "absent"},
  ];

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
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppTexts.attendance,
                              style: AppTextStyles.font16Black600.copyWith(
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: AppPadding.medium),
                            ...List.generate(types.length, (index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    Navigator.pop(context, types[index]);
                                    await context
                                        .read<AttendanceCubit>()
                                        .addToAttendance(
                                          types[index]['status'],
                                          widget.code,
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid,
                                        );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      types[index]['type'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(width: AppPadding.small),
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
                numbers: widget.present,
              ),

              AvatarLabel(
                bg: Colors.orange.shade100,
                iconData: Icons.home,
                iconColor: Colors.orangeAccent,
                label: "Remote",
                numbers: widget.remote,
              ),
              // AvatarLabel(
              //   label: "Finish Tasks",
              //   bg: AppColors.primaryColor.withOpacity(0.1),
              //   iconData: Icons.done,
              //   iconColor: AppColors.primaryColor,
              //   numbers: widget.leave,
              // ),
              AvatarLabel(
                label: "Absent",
                bg: Colors.red.withOpacity(0.1),
                iconData: Icons.exit_to_app_sharp,
                iconColor: Colors.red,
                numbers: widget.absent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
