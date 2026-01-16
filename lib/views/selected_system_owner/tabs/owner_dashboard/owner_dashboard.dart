import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:system_manage/controllers/employees_cubit/employees_cubit.dart';
import 'package:system_manage/controllers/projects_cubit/projects_cubit.dart';
import 'package:system_manage/controllers/projects_cubit/projects_state.dart';
import 'package:system_manage/controllers/user_cubit/user_cubit.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_images.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/models/user_model.dart';
import 'package:system_manage/views/selected_system/tabs/dashboard_tab/widgets/user_row.dart';
import 'package:system_manage/views/selected_system_owner/tabs/owner_dashboard/widgets/action_icon.dart';
import 'package:system_manage/views/selected_system_owner/tabs/owner_dashboard/widgets/attendance_summery.dart';
import '../../../../core/config/routes.dart';
import '../../../../models/member_model.dart';
import '../../../selected_system/tabs/dashboard_tab/widgets/custom_container.dart';

class OwnerDashboard extends StatefulWidget {
  final String systemCode;

  const OwnerDashboard({super.key, required this.systemCode});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  List<MemberModel> members = [];

  @override
  void initState() {
    super.initState();
    context.read<EmployeesCubit>().getEmployees(widget.systemCode);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<EmployeesCubit>().getEmployees(widget.systemCode);
      },
      color: AppColors.primaryColor,
      backgroundColor: Colors.white,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.small),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: AppPadding.small),
                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      if (state is UserLoaded) {
                        return UserRow(
                          username:
                              state
                                  .users[FirebaseAuth.instance.currentUser!.uid]
                                  ?.username ??
                              AppTexts.unknown,
                          image: state
                              .users[FirebaseAuth.instance.currentUser!.uid]
                              ?.image,
                        );
                      } else if (state is UserLoading) {
                        return Skeletonizer(
                          child: UserRow(username: "username", image: ""),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                  SizedBox(height: AppPadding.medium),
                  Container(
                    padding: EdgeInsets.all(AppPadding.small),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppPadding.small),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppTexts.actions,
                          style: AppTextStyles.font16Black600,
                        ),
                        SizedBox(height: AppPadding.medium),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ActionIcon(
                              iconData: Icons.add,
                              label: AppTexts.Project,
                              iconColor: AppColors.green,
                              bg: AppColors.green.withOpacity(0.3),
                              onTab: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.addProject,
                                  arguments: {"systemCode": widget.systemCode},
                                );
                              },
                            ),
                            ActionIcon(
                              iconData: Icons.add,
                              label: AppTexts.Announcement,
                              bg: AppColors.redd.withOpacity(0.3),
                              iconColor: AppColors.redd,
                              onTab: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.addAnncounce,
                                  arguments: widget.systemCode,
                                );
                              },
                            ),
                            ActionIcon(
                              iconData: Icons.add,
                              label: AppTexts.Task,

                              bg: AppColors.pinkk.withOpacity(0.3),
                              iconColor: AppColors.pinkk,
                              onTab: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.addTask,
                                  arguments: widget.systemCode,
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: AppPadding.medium),
                      ],
                    ),
                  ),

                  SizedBox(height: AppPadding.medium),
                  AttendaceSummery(present: "25", absent: "2", late: "3"),
                  SizedBox(height: AppPadding.medium),
                  BlocBuilder<ProjectsCubit, ProjectsState>(
                    builder: (context, state) {
                      if (state is GetProjectsLoaded) {
                        return Row(
                          spacing: AppPadding.medium,
                          children: [
                            Expanded(
                              child: CustomContainer(
                                label: AppTexts.stoppedProjects,
                                subtitle: state.projects
                                    .where((e) => e.status == "Stopped")
                                    .toList()
                                    .length
                                    .toString(),
                              ),
                            ),
                            Expanded(
                              child: CustomContainer(
                                label: AppTexts.ongoingProjects,
                                subtitle: state.projects
                                    .where((e) => e.status == "In Progress")
                                    .toList()
                                    .length
                                    .toString(),
                              ),
                            ),
                          ],
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                  SizedBox(height: AppPadding.small),
                  BlocBuilder<ProjectsCubit, ProjectsState>(
                    builder: (context, state) {
                      if (state is GetProjectsLoaded) {
                        return Row(
                          spacing: AppPadding.medium,
                          children: [
                            Expanded(
                              child: CustomContainer(
                                label: AppTexts.completedProjects,
                                subtitle: state.projects
                                    .where((e) => e.status == "Completed")
                                    .toList()
                                    .length
                                    .toString(),
                              ),
                            ),
                            Expanded(
                              child: CustomContainer(
                                label: AppTexts.activeProjects,
                                subtitle: state.projects
                                    .where((e) => e.status == "Active")
                                    .toList()
                                    .length
                                    .toString(),
                              ),
                            ),
                          ],
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                  SizedBox(height: AppPadding.medium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                    child: Text(
                      AppTexts.topTen,
                      style: AppTextStyles.font16Black600,
                    ),
                  ),
                  SizedBox(height: AppPadding.medium),
                  BlocBuilder<EmployeesCubit, EmployeesState>(
                    builder: (context, state) {
                      if (state is EmployeesLoaded) {
                        members =
                            state.employees
                                ?.where((e) => e.department != "Admin")
                                .toList() ??
                            [];

                        final sortedMembers = List.from(members)
                          ..sort((a, b) {
                            final perfA = a.performance ?? 0;
                            final perfB = b.performance ?? 0;
                            return perfB.compareTo(perfA);
                          });

                        final topMembers = sortedMembers.take(10).toList();

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: topMembers.length,
                          itemBuilder: (context, index) {
                            final user = topMembers[index];

                            return ListTile(
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primaryColor
                                    .withOpacity(0.1),
                                foregroundImage:
                                    (user.image != null &&
                                        user.image!.isNotEmpty)
                                    ? NetworkImage(user.image!)
                                    : null,
                                child:
                                    (user.image == null || user.image!.isEmpty)
                                    ? Text(
                                        user.username
                                            .substring(0, 2)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(user.username),
                              subtitle: Text(user.title),
                              trailing: Text(
                                "${user.performance} %",
                                style: AppTextStyles.font16Black600,
                              ),
                            );
                          },
                        );
                      }

                      if (state is EmployeesLoading) {
                        return Skeletonizer(
                          child: ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: [
                              ListTile(
                                title: Text("sssssssssssssssssss"),
                                subtitle: Text("ssssss"),
                              ),
                              ListTile(
                                title: Text("sssssssssssssssssss"),
                                subtitle: Text("ssssss"),
                              ),
                              ListTile(
                                title: Text("sssssssssssssssssss"),
                                subtitle: Text("ssssss"),
                              ),
                              ListTile(
                                title: Text("sssssssssssssssssss"),
                                subtitle: Text("ssssss"),
                              ),
                              ListTile(
                                title: Text("sssssssssssssssssss"),
                                subtitle: Text("ssssss"),
                              ),
                            ],
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
