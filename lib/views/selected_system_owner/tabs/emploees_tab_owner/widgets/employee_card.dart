import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/employees_cubit/employees_cubit.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/models/member_model.dart';
import 'package:system_manage/views/selected_system/tabs/projects_tab/widgets/linear_progress.dart';
import 'package:system_manage/views/selected_system_owner/tabs/emploees_tab_owner/widgets/task_sheet.dart';
import 'button_with_image.dart';

class EmployeeCard extends StatelessWidget {
  final MemberModel user;
  final String code;

  const EmployeeCard(this.user, this.code, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppPadding.small),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              backgroundImage: user.image.isNotEmpty
                  ? CachedNetworkImageProvider(user.image)
                  : null,
              child: user.image.isEmpty
                  ? Text(
                      user.username.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            title: Text(user.username),
            subtitle: Text(user.title),
          ),
          Divider(color: AppColors.grey200),
          Padding(
            padding: const EdgeInsets.all(AppPadding.small),
            child: LinearPercentIndicator(
              percent: user.performance,
              color: AppColors.primaryColor,
              title: AppTexts.perfomance,
            ),
          ),
          const SizedBox(height: AppPadding.small),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ButtonWithImage(
                label: AppTexts.Projects,
                iconData: Icons.list_alt_rounded,
                onPress: () async {
                  await context.read<EmployeesCubit>().getEmployeesProjects(
                    code,
                    user.uid,
                  );
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    builder: (_) {
                      return BlocBuilder<EmployeesCubit, EmployeesState>(
                        builder: (context, state) {
                          if (state is EmployeesLoaded) {
                            final userProjects = state.projects;
                            if (userProjects.isEmpty) {
                              return Center(
                                child: Text(
                                  AppTexts.noProjectsYet,
                                  style: AppTextStyles.font16Black600,
                                ),
                              );
                            }

                            return Column(
                              children: [
                                SizedBox(height: AppPadding.medium),
                                Text(
                                  "Employee in this projects",
                                  style: AppTextStyles.font16Black600,
                                ),
                                SizedBox(height: AppPadding.medium),
                                ListView(
                                  shrinkWrap: true,
                                  children: userProjects
                                      .map(
                                        (p) => Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppPadding.small,
                                                  ),
                                            ),
                                            title: Text(
                                              "${AppTexts.projectName} : ${p}",
                                              style:
                                                  AppTextStyles.font16Black600,
                                            ),
                                            tileColor: AppColors.grey200,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              ButtonWithImage(
                label: AppTexts.Tasks,
                iconData: Icons.task_alt_outlined,
                onPress: () async {
                  await context.read<EmployeesCubit>().getEmployeeTasks(
                    code,
                    user.uid,
                  );

                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    builder: (_) => const EmployeeTasksSheet(),
                  );
                },
              ),

              ButtonWithImage(
                label: AppTexts.Chat,
                iconData: Icons.chat,
                onPress: () {},
              ),
            ],
          ),
          const SizedBox(height: AppPadding.small),
        ],
      ),
    );
  }
}
