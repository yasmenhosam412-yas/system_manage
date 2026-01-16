import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/employees_cubit/employees_cubit.dart';
import 'package:system_manage/core/utils/app_texts.dart';

class EmployeeTasksSheet extends StatelessWidget {
  const EmployeeTasksSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeesCubit, EmployeesState>(
      builder: (context, state) {
        if (state is! EmployeesLoaded) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final tasks = state.tasks;

        if (tasks.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(AppTexts.noTasksYet, style: TextStyle(fontSize: 16)),
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: projectTasks.map((task) {
                      return ListTile(
                        title: Text(task["name"] ?? AppTexts.unknown),
                        subtitle: Text(task["status"] ?? ""),
                        leading: const Icon(Icons.task_alt_outlined),
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
