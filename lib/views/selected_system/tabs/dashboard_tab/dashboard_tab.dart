import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:system_manage/controllers/announce_cubit/announce_cubit.dart';
import 'package:system_manage/controllers/attendance_cubit/attendance_cubit.dart';
import 'package:system_manage/controllers/employees_cubit/employees_cubit.dart';
import 'package:system_manage/controllers/preformance_cubit/performance_cubit.dart';
import 'package:system_manage/controllers/user_projects/user_projects_cubit.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/models/anncounce_model.dart';
import 'package:system_manage/views/selected_system/tabs/dashboard_tab/widgets/anncounce.dart';
import 'package:system_manage/views/selected_system/tabs/dashboard_tab/widgets/attendance.dart';
import 'package:system_manage/views/selected_system/tabs/dashboard_tab/widgets/custom_container.dart';
import 'package:system_manage/views/selected_system/tabs/dashboard_tab/widgets/performace_chat.dart';
import 'package:system_manage/views/selected_system/tabs/dashboard_tab/widgets/user_row.dart';
import '../../../../controllers/user_cubit/user_cubit.dart';

class DashboardTab extends StatefulWidget {
  final String code;

  const DashboardTab({super.key, required this.code});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  void initState() {
    super.initState();
    context.read<AnnounceCubit>().getAnncounce(
      widget.code,
      FirebaseAuth.instance.currentUser!.uid,
    );
    context.read<AttendanceCubit>().getUserAttendance(
      widget.code,
      FirebaseAuth.instance.currentUser!.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AnnounceCubit>().getAnncounce(
          widget.code,
          FirebaseAuth.instance.currentUser!.uid,
        );

        await context.read<AttendanceCubit>().getUserAttendance(
          widget.code,
          FirebaseAuth.instance.currentUser!.uid,
        );
      },
      color: AppColors.primaryColor,
      backgroundColor: Colors.white,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.medium),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(height: AppPadding.large),
                  BlocBuilder<AnnounceCubit, AnnounceState>(
                    builder: (context, state) {
                      if (state is AnnounceUserLoaded) {
                        if (state.anncounces.isEmpty) {
                          return SizedBox.shrink();
                        }
                        return Accouncement(list: state.anncounces);
                      }
                      if (state is AnnounceLoading) {
                        return Skeletonizer(
                          child: Accouncement(
                            list: [
                              AnnounceModel(name: "name", desc: "desc"),
                              AnnounceModel(name: "name", desc: "desc"),
                            ],
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                  SizedBox(height: AppPadding.large),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: AppPadding.medium,
                    children: [
                      Expanded(
                        child:
                            BlocBuilder<UserProjectsCubit, UserProjectsState>(
                              builder: (context, state) {
                                if (state is UserProjectsLoaded) {
                                  return CustomContainer(
                                    label: AppTexts.ongoingProjects,
                                    subtitle: state.projects
                                        .where((e) => e.status == "Active")
                                        .toList()
                                        .length
                                        .toString(),
                                  );
                                }
                                return Skeletonizer(
                                  child: CustomContainer(
                                    label: AppTexts.ongoingProjects,
                                    subtitle: '2',
                                  ),
                                );
                              },
                            ),
                      ),
                      Expanded(
                        child: BlocBuilder<EmployeesCubit, EmployeesState>(
                          builder: (context, state) {
                            if (state is EmployeesLoaded) {
                              final completedTasksCount = state.tasks.values
                                  .expand((taskList) => taskList)
                                  .where((task) => task['status'] == 'done')
                                  .length;

                              return CustomContainer(
                                label: AppTexts.completedTasks,
                                subtitle: completedTasksCount.toString(),
                              );
                            }
                            return Skeletonizer(
                              child: CustomContainer(
                                label: AppTexts.completedTasks,
                                subtitle: '21',
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppPadding.large),
                  SizedBox(height: AppPadding.medium),
                  BlocBuilder<AttendanceCubit, AttendanceState>(
                    builder: (context, state) {
                      if (state is GetAttendanceLoaded) {
                        return Attendace(
                          present: state.attendance
                              .where((e) => e['status'] == "present")
                              .toList()
                              .length
                              .toString(),
                          remote: state.attendance
                              .where((e) => e['status'] == "remote")
                              .toList()
                              .length
                              .toString(),
                          leave: state.attendance
                              .where((e) => e['status'] == "done")
                              .toList()
                              .length
                              .toString(),
                          absent: state.attendance
                              .where((e) => e['status'] == "absent")
                              .toList()
                              .length
                              .toString(),
                          code: widget.code,
                        );
                      }
                      if (state is AttendanceLoading) {
                        return Skeletonizer(
                          child: Attendace(
                            present: "25",
                            remote: '3',
                            leave: '2',
                            code: widget.code,
                            absent: '5',
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                  SizedBox(height: AppPadding.large),
                  BlocBuilder<AttendanceCubit, AttendanceState>(
                    builder: (context, state) {
                      int presentCount = 0;
                      int remoteCount = 0;
                      int leaveCount = 0;
                      int absentCount = 0;

                      if (state is GetAttendanceLoaded) {
                        presentCount = state.attendance
                            .where((e) => e['status'] == "present")
                            .length;
                        remoteCount = state.attendance
                            .where((e) => e['status'] == "remote")
                            .length;
                        absentCount = state.attendance
                            .where((e) => e['status'] == "absent")
                            .length;
                      }

                      return BlocBuilder<EmployeesCubit, EmployeesState>(
                        builder: (context, empState) {
                          int completedTasks = 0;
                          int allTasks = 0;

                          if (empState is EmployeesLoaded) {
                            completedTasks = empState.tasks.values
                                .expand((taskList) => taskList)
                                .where((task) => task['status'] == 'done')
                                .length;
                            allTasks = empState.tasks.values
                                .expand((taskList) => taskList)
                                .length;
                          }

                          context.read<PerformanceCubit>().updatePRefrmance(
                            FirebaseAuth.instance.currentUser!.uid,
                            present: presentCount,
                            remote: remoteCount,
                            onLeave: absentCount,
                            completedTasks: completedTasks,
                            allTasks: allTasks,
                            systemCode: widget.code,
                          );

                          return PerformanceChart(
                            present: presentCount,
                            remote: remoteCount,
                            onLeave: absentCount,
                            completedTasks: completedTasks,
                            allTasks: allTasks,
                          );
                        },
                      );
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
