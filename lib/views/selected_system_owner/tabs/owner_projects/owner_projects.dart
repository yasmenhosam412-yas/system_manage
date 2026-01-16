import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/projects_cubit/projects_cubit.dart';
import 'package:system_manage/controllers/projects_cubit/projects_state.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/core/utils/toasts.dart';
import 'package:system_manage/models/project_models.dart';
import 'package:system_manage/views/selected_system/tabs/projects_tab/widgets/project_item.dart';

class OwnerProjectsTab extends StatefulWidget {
  final String systemCode;

  const OwnerProjectsTab({super.key, required this.systemCode});

  @override
  State<OwnerProjectsTab> createState() => _OwnerProjectsTabState();
}

class _OwnerProjectsTabState extends State<OwnerProjectsTab> {
  late TextEditingController search;

  final List<String> types = [
    AppTexts.all,
    AppTexts.active,
    AppTexts.completed,
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    search = TextEditingController();
    context.read<ProjectsCubit>().fetchProjects(widget.systemCode);
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ProjectsCubit>().fetchProjects(
          widget.systemCode,
          showLoader: true,
        );
      },
      color: AppColors.primaryColor,
      backgroundColor: Colors.white,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.medium),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppPadding.medium),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTexts.Projects,
                        style: AppTextStyles.font16Black600.copyWith(
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        AppTexts.trackAndManage,
                        style: AppTextStyles.font16Black600,
                      ),
                    ],
                  ),
                  SizedBox(height: AppPadding.medium),
                  SearchBar(
                    controller: search,
                    hintText: AppTexts.searchProjects,
                    hintStyle: WidgetStatePropertyAll(
                      AppTextStyles.font16Black600.copyWith(color: Colors.grey),
                    ),
                    elevation: WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(
                      Colors.grey.shade200,
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppPadding.small),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: AppPadding.small),
                  const Divider(color: Colors.grey, thickness: 1),
                  SizedBox(height: AppPadding.small),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(types.length, (index) {
                        final isSelected = currentIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Chip(
                              backgroundColor: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.white,
                              label: Text(
                                types[index],
                                style: AppTextStyles.font16Black600.copyWith(
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: AppPadding.medium),
                  BlocConsumer<ProjectsCubit, ProjectsState>(
                    listener: (context, state) {
                      if (state is DeleteProjectsSuccess) {
                        Toasts.displayToast(state.message);
                      } else if (state is DeleteProjectsError) {
                        Toasts.displayToast(state.error);
                      } else if (state is ProjectsSuccess) {
                        Toasts.displayToast(state.message);
                      }
                    },
                    builder: (context, state) {
                      if (state is GetProjectsLoading ||
                          state is ProjectsLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      }

                      if (state is GetProjectsError) {
                        return Center(child: Text(state.error));
                      }

                      if (state is GetProjectsLoaded) {
                        final filteredProjects = state.projects.where((p) {
                          bool matchesType =
                              (types[currentIndex] == AppTexts.all) ||
                              p.status.toLowerCase() ==
                                  types[currentIndex].toLowerCase();
                          bool matchesSearch = p.name.toLowerCase().contains(
                            search.text.toLowerCase(),
                          );
                          return matchesType && matchesSearch;
                        }).toList();

                        if (filteredProjects.isEmpty) {
                          return Center(child: Text(AppTexts.noProjectsYet));
                        }

                        return ListView.builder(
                          itemCount: filteredProjects.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final project = filteredProjects[index];
                            return ProjectItem(
                              projectName: project.name,
                              projectStatus: project.status,
                              projectProgress: project.progress,
                              projectMembers: project.members
                                  .map((e) => e.uid.toString())
                                  .toList(),
                              date: "${project.startDate} - ${project.endDate}",
                              systemCode: widget.systemCode,
                              docId: project.projectId,
                              endTime: project.endDate,
                              startTime: project.startDate,
                              projectDesc: project.description,
                              steps: project.steps,
                              links: project.links,
                              members: project.members,
                              isAdmin: true,
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
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
