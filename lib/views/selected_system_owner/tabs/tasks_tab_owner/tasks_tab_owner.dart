import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../controllers/tasks_cubit/tasks_cubit.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_padding.dart';
import '../../../../core/utils/app_texts.dart';
import '../../../../core/utils/text_styles.dart';
import '../../../../models/task_model.dart';

class TasksTabOwner extends StatefulWidget {
  final String systemCode;

  const TasksTabOwner({super.key, required this.systemCode});

  @override
  State<TasksTabOwner> createState() => _TasksTabOwnerState();
}

class _TasksTabOwnerState extends State<TasksTabOwner> {
  @override
  void initState() {
    super.initState();
    context.read<TasksCubit>().getTasksOfProject(widget.systemCode);
  }

  double _calculateProgress(List<TaskModel> tasks) {
    if (tasks.isEmpty) return 0.0;
    int completed = tasks.where((t) => t.status == "done").length;
    return completed / tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Expanded(
              child: BlocBuilder<TasksCubit, TasksState>(
                builder: (context, state) {
                  if (state is GetTasksLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GetTasksLoadError) {
                    return Center(child: Text(state.error));
                  } else if (state is GetTasksLoaded) {
                    final projectsWithTasks = state.tasks;

                    if (projectsWithTasks.isEmpty) {
                      return Center(
                        child: Text(
                          AppTexts.noTasksYet,
                          style: AppTextStyles.font16Black600,
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: projectsWithTasks.length,
                      itemBuilder: (context, index) {
                        final project = projectsWithTasks[index];
                        final tasks = project.tasks;

                        double progress = _calculateProgress(tasks);

                        return Card(
                          elevation: 1.2,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            childrenPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  borderRadius: BorderRadius.circular(
                                    AppPadding.small,
                                  ),
                                  value: progress,
                                  backgroundColor: Colors.grey[300],
                                  color: AppColors.primaryColor,
                                  minHeight: 6,
                                ),
                              ],
                            ),
                            children: [
                              ...tasks.map((task) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  trailing: Text(
                                    task.assignedMemberName,
                                    style: AppTextStyles.font16Black600,
                                  ),
                                  title: Text(
                                    task.name,
                                    style: TextStyle(
                                      decoration: task.status == "done"
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  subtitle: Text(
                                    task.deadline ?? "",
                                    style: AppTextStyles.font16Black600
                                        .copyWith(
                                          color: AppColors.primaryColor,
                                        ),
                                  ),
                                  leading: GestureDetector(
                                    child: Icon(
                                      task.status == "done"
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: task.status == "done"
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  if (state is GetTasksLoadError) {
                    return Center(child: Text(state.error));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
