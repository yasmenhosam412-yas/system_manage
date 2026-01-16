import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/user_projects/user_projects_cubit.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/models/project_models.dart';
import 'package:system_manage/views/selected_system/tabs/projects_tab/widgets/project_item.dart';

class ProjectsTab extends StatefulWidget {
  final String code;

  const ProjectsTab({super.key, required this.code});

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  late TextEditingController search;
  List<ProjectModel> projects = [];
  List<ProjectModel> filteredProjects = [];

  List<String> types = [
    AppTexts.all,
    AppTexts.active,
    AppTexts.completed,
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    search = TextEditingController();
    search.addListener(() {
      filterProjects();
    });

    context.read<UserProjectsCubit>().getUserProjects(
      widget.code,
      FirebaseAuth.instance.currentUser!.uid,
    );
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void filterProjects() {
    String type = types[currentIndex];

    filteredProjects = projects.where((p) {
      final matchesType =
          type == AppTexts.all || p.status.toLowerCase() == type.toLowerCase();
      final matchesSearch = p.name.toLowerCase().contains(
        search.text.toLowerCase(),
      );
      return matchesType && matchesSearch;
    }).toList();

    setState(() {});
  }

  Future<void> _refreshProjects() async {
    await context.read<UserProjectsCubit>().getUserProjects(
      widget.code,
      FirebaseAuth.instance.currentUser!.uid,
    );
    filterProjects();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshProjects,
      color: AppColors.primaryColor,
      backgroundColor: Colors.white,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(
                      Colors.grey.shade200,
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppPadding.small),
                      ),
                    ),
                  ),
                  SizedBox(height: AppPadding.small),
                  Divider(color: AppColors.grey200, thickness: 1),
                  SizedBox(height: AppPadding.small),
                  Row(
                    children: List.generate(types.length, (index) {
                      final isSelected = currentIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            currentIndex = index;
                          });
                          filterProjects();
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
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: AppPadding.medium),
                  BlocListener<UserProjectsCubit, UserProjectsState>(
                    listener: (context, state) {
                      if (state is UserProjectsLoaded) {
                        projects = state.projects;
                        filterProjects();
                      }
                    },
                    child: BlocBuilder<UserProjectsCubit, UserProjectsState>(
                      builder: (context, state) {
                        if (state is UserProjectsLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          );
                        }

                        if (state is UserProjectsError) {
                          return Center(
                            child: Text(state.error)
                          );
                        }

                        if (filteredProjects.isEmpty) {
                          return Center(
                            child: Text(
                              AppTexts.noProjectsYet,
                              style: AppTextStyles.font16Black600,
                            ),
                          );
                        }

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: filteredProjects.length,
                          itemBuilder: (context, index) {
                            final p = filteredProjects[index];
                            return ProjectItem(
                              projectName: p.name,
                              date: "${p.startDate} - ${p.endDate}",
                              projectMembers: p.members
                                  .map((e) => e.uid)
                                  .toList(),
                              projectProgress: p.progress,
                              projectStatus: p.status,
                              systemCode: widget.code,
                              docId: p.projectId,
                              startTime: p.startDate,
                              endTime: p.endDate,
                              projectDesc: p.description,
                              steps: p.steps,
                              links: p.links,
                              members: p.members,
                              isAdmin: false,
                            );
                          },
                        );
                      },
                    ),
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
