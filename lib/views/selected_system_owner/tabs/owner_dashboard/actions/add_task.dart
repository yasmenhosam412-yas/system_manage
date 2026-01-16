import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:system_manage/controllers/projects_cubit/projects_cubit.dart';
import 'package:system_manage/controllers/projects_cubit/projects_state.dart';
import 'package:system_manage/controllers/system_cubit/system_cubit.dart';
import 'package:system_manage/controllers/tasks_cubit/tasks_cubit.dart';
import 'package:system_manage/controllers/user_cubit/user_cubit.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_regrex.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/core/widgets/custom_dropdown.dart';
import 'package:system_manage/core/widgets/custom_text_field.dart';
import 'package:system_manage/core/widgets/custom_button.dart';
import 'package:system_manage/core/utils/toasts.dart';
import 'package:system_manage/models/member_model.dart';

class AddTask extends StatefulWidget {
  final String systemCode;

  const AddTask({super.key, required this.systemCode});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  String? selectedProjectId;
  MemberModel? selectedMember;

  final Map<String, String> _memberNames = {};
  final Map<String, String> _memberTitles = {};

  @override
  void initState() {
    super.initState();

    context.read<ProjectsCubit>().fetchProjects(widget.systemCode);

    context.read<UserCubit>().stream.listen((state) {
      if (state is UserLoaded) {
        bool changed = false;
        state.users.forEach((uid, user) {
          if (_memberNames[uid] != user.username) {
            _memberNames[uid] = user.username;
            _memberTitles[uid] = user.title;
            changed = true;
          }
        });
        if (changed && mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppPadding.medium),
                Center(
                  child: Text(
                    AppTexts.addTask,
                    style: AppTextStyles.font16Black600.copyWith(fontSize: 20),
                  ),
                ),
                const SizedBox(height: AppPadding.medium),

                BlocBuilder<ProjectsCubit, ProjectsState>(
                  builder: (context, state) {
                    if (state is GetProjectsLoaded) {
                      return CustomDropdown<String>(
                        value: selectedProjectId,
                        hint: AppTexts.selectProject,
                        items: state.projects.map((project) {
                          return DropdownMenuItem<String>(
                            value: project.projectId,
                            child: Text(project.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProjectId = value;
                            selectedMember = null;
                          });
                          context.read<SystemCubit>().getProjectMembers(
                            widget.systemCode,
                            value!,
                          );
                        },
                      );
                    }

                    if (state is GetProjectsLoading) {
                      return Skeletonizer(
                        child: DropdownMenu(
                          dropdownMenuEntries: List.generate(
                            5,
                            (index) => const DropdownMenuEntry(
                              value: '0',
                              label: 'Loading',
                            ),
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: AppPadding.medium),

                CustomTextField(
                  controller: nameController,
                  hintText: AppTexts.taskTitle,
                  validator: (value) =>
                      AppRegex.validateNotEmpty(value, fieldName: "title"),
                ),
                const SizedBox(height: AppPadding.medium),

                CustomTextField(
                  controller: descController,
                  hintText: AppTexts.taskDesc,
                  maxLines: 5,
                  validator: (value) => AppRegex.validateNotEmpty(
                    value,
                    fieldName: "description",
                  ),
                ),
                const SizedBox(height: AppPadding.medium),

                GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();

                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppColors.primaryColor,
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                            dialogBackgroundColor: Colors.white,
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      deadlineController.text =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: deadlineController,
                      hintText: AppTexts.deadline,
                      maxLines: 1,
                      keyboardType: TextInputType.datetime,
                      validator: (value) => AppRegex.validateNotEmpty(
                        value,
                        fieldName: "deadline",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppPadding.medium),

                Text(
                  AppTexts.selectMembers,
                  style: AppTextStyles.font16Black600.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppPadding.small),

                BlocBuilder<SystemCubit, SystemState>(
                  builder: (context, state) {
                    if (state is SystemLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is SystemLoaded) {
                      if (state.members.isEmpty) {
                        return const Text("No members in this project");
                      }

                      _fetchMemberNames(state.members);

                      return Column(
                        children: state.members.map((member) {
                          final username =
                              _memberNames[member.uid] ?? 'Loading...';
                          final title =
                              _memberTitles[member.uid] ?? 'Loading...';

                          return RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              username,
                              style: AppTextStyles.font16Black600.copyWith(
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              title,
                              style: AppTextStyles.font16Black600.copyWith(
                                fontSize: 14,
                              ),
                            ),
                            value: member.uid,
                            groupValue: selectedMember?.uid,
                            activeColor: AppColors.primaryColor,
                            onChanged: (value) {
                              setState(() {
                                selectedMember = member;
                              });
                            },
                          );
                        }).toList(),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: AppPadding.medium),

                BlocConsumer<TasksCubit, TasksState>(
                  listener: (context, state) {
                    if (state is TasksAdded) {
                      Toasts.displayToast(AppTexts.added);
                      Navigator.pop(context);
                    }
                    if (state is TasksError) {
                      Toasts.displayToast(state.error);
                    }
                  },
                  builder: (context, state) {
                    return CustomButton(
                      text: state is TasksAdding
                          ? AppTexts.pleaseWait
                          : AppTexts.add,
                      onPressed: state is TasksAdding
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) return;

                              if (selectedProjectId == null) {
                                Toasts.displayToast(AppTexts.selectProject);
                                return;
                              }

                              if (selectedMember == null) {
                                Toasts.displayToast(
                                  AppTexts.pleaseSelectMember,
                                );
                                return;
                              }

                              context.read<TasksCubit>().addTask(
                                widget.systemCode,
                                nameController.text.trim(),
                                descController.text.trim(),
                                selectedMember!,
                                selectedMember!.username,
                                selectedProjectId!,
                                deadlineController.text,
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
    );
  }

  void _fetchMemberNames(List<MemberModel> members) {
    for (final member in members) {
      if (!_memberNames.containsKey(member.uid)) {
        context.read<UserCubit>().getUserData(member.uid);
      }
    }
  }
}
