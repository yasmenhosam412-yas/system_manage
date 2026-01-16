import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/employees_cubit/employees_cubit.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/core/widgets/custom_text_field.dart';
import 'package:system_manage/models/task_model.dart';

class TasksTab extends StatefulWidget {
  final String code;

  const TasksTab({super.key, required this.code});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  List<ProjectTasksModel> projectsWithTasks = [];

  @override
  void initState() {
    super.initState();
    context.read<EmployeesCubit>().getEmployeeTasks(
      widget.code,
      FirebaseAuth.instance.currentUser!.uid,
    );
  }

  double _calculateProgress(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) return 0.0;
    int completed = tasks.where((t) => t["done"] == true).length;
    return completed / tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<EmployeesCubit>().getEmployeeTasks(
          widget.code,
          FirebaseAuth.instance.currentUser!.uid,
        );
      },
      color: AppColors.primaryColor,
      backgroundColor: Colors.white,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    AppTexts.Tasks,
                    style: AppTextStyles.font16Black600.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              BlocBuilder<EmployeesCubit, EmployeesState>(
                builder: (context, state) {
                  if (state is EmployeesLoading) {
                    return Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }

                  if (state is EmployeesLoaded) {
                    final tasks = state.tasks;
                    if (tasks.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            AppTexts.noTasksYet,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 400,
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: tasks.entries.map((entry) {
                          final project = entry.key;
                          final projectTasks = entry.value;

                          return Card(
                            color: Colors.white,
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Theme(
                              data: ThemeData(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                title: Text(
                                  project,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                children: projectTasks.map((task) {
                                  return ListTile(
                                    title: Text(
                                      "${task["name"] ?? AppTexts.unknown} - ${task["description"] ?? AppTexts.unknown}",
                                    ),
                                    subtitle: Text(
                                      "Deadline : ${task["deadline"]}",
                                      style: AppTextStyles.font16Black600
                                          .copyWith(
                                            color: AppColors.primaryColor,
                                          ),
                                    ),
                                    leading: Checkbox(
                                      value: task['status'] == "done",
                                      activeColor: AppColors.primaryColor,
                                      onChanged: (value) {
                                        if (task['status'] != "done") {
                                          context
                                              .read<EmployeesCubit>()
                                              .updateTaskStatus(
                                                systemCode: widget.code,
                                                taskId: task['id'],
                                                status: 'done',
                                                projectId: task['projectId'],
                                              );
                                        } else if (task['status'] == "done") {
                                          context
                                              .read<EmployeesCubit>()
                                              .updateTaskStatus(
                                                systemCode: widget.code,
                                                taskId: task['id'],
                                                status: 'pending',
                                                projectId: task['projectId'],
                                              );
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }).toList(),
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
    );
  }
}
