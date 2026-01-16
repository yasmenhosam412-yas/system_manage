import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/projects_cubit/projects_cubit.dart';
import 'package:system_manage/controllers/system_cubit/system_cubit.dart';
import 'package:system_manage/controllers/user_cubit/user_cubit.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_regrex.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/core/utils/toasts.dart';
import 'package:system_manage/core/widgets/custom_text_field.dart';
import 'package:system_manage/models/member_model.dart';

import '../../../../../controllers/projects_cubit/projects_state.dart';
import '../../../../../core/utils/app_texts.dart';
import '../../../../../core/widgets/custom_button.dart';

class AddProject extends StatefulWidget {
  final String systemCode;
  final String? projectName;
  final String? projectDesc;
  final String? projectStatus;
  final int? projectProgress;
  final List<String>? projectMembers;
  final List<String>? steps;
  final List<String>? links;
  final String? date;
  final String? docId;
  final String? startTime;
  final String? endTime;

  const AddProject({
    super.key,
    required this.systemCode,
    this.projectName,
    this.projectStatus,
    this.projectProgress,
    this.projectMembers,
    this.date,
    this.docId,
    this.startTime,
    this.endTime,
    this.projectDesc,
    this.steps,
    this.links,
  });

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  late TextEditingController linkController;

  late TextEditingController stepController;

  List<String> links = [];
  List<String> steps = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String _status = 'Active';

  List<MemberModel> _selectedMembers = [];
  int _selectedDepartmentIndex = 0;
  List<MemberModel> _filteredMembers = [];

  @override
  void initState() {
    super.initState();

    context.read<SystemCubit>().getSystemMembersAndDeps(widget.systemCode);

    _nameController = TextEditingController(text: widget.projectName ?? '');
    _descriptionController = TextEditingController(
      text: widget.projectDesc ?? '',
    );

    steps = widget.steps ?? [];
    links = widget.links ?? [];

    linkController = TextEditingController();
    stepController = TextEditingController();

    if (widget.startTime != null && widget.startTime!.isNotEmpty) {
      _startDate = DateTime.parse(widget.startTime!);
    }
    if (widget.endTime != null && widget.endTime!.isNotEmpty) {
      _endDate = DateTime.parse(widget.endTime!);
    }

    _status = widget.projectStatus ?? 'Active';

    if (widget.projectMembers != null) {}
  }

  Future<void> _pickDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        if (isStart)
          _startDate = date;
        else
          _endDate = date;
      });
    }
  }

  void _filterMembersByDepartment(
    String department,
    List<MemberModel> allMembers,
  ) {
    _filteredMembers = allMembers
        .where((m) => m.department == department)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Project',
          style: AppTextStyles.font16Black600.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: "Project Name",
                validator: (value) =>
                    AppRegex.validateNotEmpty(value, fieldName: "project name"),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                maxLines: 5,
                hintText: "Project Description",
                validator: (value) => AppRegex.validateNotEmpty(
                  value,
                  fieldName: "project description",
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isStart: true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Select date',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isStart: false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Select date',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppPadding.medium),
              BlocBuilder<SystemCubit, SystemState>(
                builder: (context, systemState) {
                  if (systemState is SystemLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }

                  if (systemState is SystemError) {
                    return Center(child: Text(systemState.error));
                  }

                  if (systemState is SystemLoaded) {
                    if (_filteredMembers.isEmpty &&
                        systemState.departments.isNotEmpty) {
                      _filterMembersByDepartment(
                        systemState.departments[_selectedDepartmentIndex],
                        systemState.members,
                      );
                    }
                    if (widget.projectMembers != null &&
                        _selectedMembers.isEmpty) {
                      _selectedMembers = systemState.members
                          .where((m) => widget.projectMembers!.contains(m.uid))
                          .toList();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppPadding.small,
                          children: List.generate(
                            systemState.departments.length,
                            (index) {
                              bool isSelected =
                                  index == _selectedDepartmentIndex;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDepartmentIndex = index;
                                    _filterMembersByDepartment(
                                      systemState.departments[index],
                                      systemState.members,
                                    );
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : Colors.grey.shade200,
                                  ),
                                  child: Text(
                                    systemState.departments[index],
                                    style: AppTextStyles.font16Black600
                                        .copyWith(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: SingleChildScrollView(
                            child: _filteredMembers.isEmpty
                                ? const Center(
                                    child: Text("No Members Here Yet"),
                                  )
                                : Column(
                                    children: _filteredMembers.map((member) {
                                      return CheckboxListTile(
                                        title: Text(
                                          member.username,
                                          style: AppTextStyles.font16Black600
                                              .copyWith(fontSize: 14),
                                        ),
                                        subtitle: Text(
                                          member.title,
                                          style: AppTextStyles.font16Black600
                                              .copyWith(fontSize: 14),
                                        ),
                                        value: _selectedMembers.contains(
                                          member,
                                        ),
                                        activeColor: AppColors.primaryColor,
                                        onChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              if (!_selectedMembers.contains(
                                                member,
                                              )) {
                                                _selectedMembers.add(member);
                                              }
                                            } else {
                                              _selectedMembers.remove(member);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade200, thickness: 1),
              const SizedBox(height: 24),
              Text(AppTexts.addLink, style: AppTextStyles.font16Black600),
              const SizedBox(height: AppPadding.medium),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: linkController,
                      hintText: AppTexts.enterLink,
                    ),
                  ),
                  const SizedBox(width: AppPadding.small),
                  CustomButton(
                    text: AppTexts.add,
                    onPressed: () {
                      if (linkController.text.isEmpty) return;
                      setState(() {
                        links.add(linkController.text);
                      });
                      linkController.clear();
                    },
                    width: 100,
                    height: 50,
                  ),
                ],
              ),
              const SizedBox(height: AppPadding.small),
              if (links.isNotEmpty)
                Wrap(
                  spacing: AppPadding.small,
                  runSpacing: AppPadding.small,
                  children: links
                      .map(
                        (link) => Chip(
                          backgroundColor: Colors.white,
                          label: Text(link),
                          onDeleted: () {
                            setState(() {
                              links.remove(link);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: AppPadding.medium),
              Text(AppTexts.projectSteps, style: AppTextStyles.font16Black600),
              const SizedBox(height: AppPadding.medium),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: stepController,
                      hintText: AppTexts.enterStep,
                    ),
                  ),
                  const SizedBox(width: AppPadding.small),
                  CustomButton(
                    text: AppTexts.add,
                    onPressed: () {
                      if (stepController.text.isEmpty) return;
                      setState(() {
                        steps.add(stepController.text);
                      });
                      stepController.clear();
                    },
                    width: 100,
                    height: 50,
                  ),
                ],
              ),
              const SizedBox(height: AppPadding.small),
              if (steps.isNotEmpty)
                Wrap(
                  spacing: AppPadding.small,
                  runSpacing: AppPadding.small,
                  children: steps
                      .map(
                        (step) => Chip(
                          backgroundColor: Colors.white,
                          label: Text(step),
                          onDeleted: () {
                            setState(() {
                              steps.remove(step);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: AppPadding.medium),
              BlocConsumer<ProjectsCubit, ProjectsState>(
                listener: (context, state) {
                  if (state is ProjectsSuccess) {
                    Toasts.displayToast("Created Successfully!");
                    Navigator.pop(context);
                  } else if (state is ProjectsError) {
                    Toasts.displayToast(state.error);
                  }
                },
                builder: (context, state) {
                  if (state is ProjectsLoading) {
                    return CustomButton(
                      text: AppTexts.pleaseWait,
                      onPressed: null,
                    );
                  }
                  return CustomButton(
                    text: (widget.docId == null)
                        ? AppTexts.AddProject
                        : AppTexts.editProject,
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;

                      if (_selectedMembers.isEmpty) {
                        Toasts.displayToast(AppTexts.pleaseSelectMember);
                        return;
                      }
                      if (steps.isEmpty) {
                        Toasts.displayToast(AppTexts.enterStep);
                        return;
                      }

                      final formattedStart =
                          '${_startDate?.year}-${_startDate?.month.toString().padLeft(2, '0')}-${_startDate?.day.toString().padLeft(2, '0')}';

                      final formattedEnd =
                          '${_endDate?.year}-${_endDate?.month.toString().padLeft(2, '0')}-${_endDate?.day.toString().padLeft(2, '0')}';

                      if (widget.docId == null) {
                        context.read<ProjectsCubit>().addProject(
                          systemCode: widget.systemCode,
                          name: _nameController.text,
                          desc: _descriptionController.text,
                          startTime: formattedStart,
                          endTime: formattedEnd,
                          status: _status,
                          members: _selectedMembers,
                          links: links,
                          steps: steps,
                          progress: 0.0,
                        );
                      } else {
                        context.read<ProjectsCubit>().updateProject(
                          docId: widget.docId!,
                          systemCode: widget.systemCode,
                          name: _nameController.text,
                          desc: _descriptionController.text,
                          startTime: formattedStart,
                          endTime: formattedEnd,
                          status: _status,
                          members: _selectedMembers,
                          links: links,
                          steps: steps,
                          progress: widget.projectProgress ?? 0,
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
