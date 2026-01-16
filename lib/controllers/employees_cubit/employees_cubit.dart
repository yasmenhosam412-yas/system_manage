import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:system_manage/models/member_model.dart';
import 'package:system_manage/services/system_service.dart';

import '../../models/employee_model.dart';

part 'employees_state.dart';

class EmployeesCubit extends Cubit<EmployeesState> {
  final SystemService systemService;

  EmployeesCubit(this.systemService) : super(EmployeesInitial());

  Future<void> getEmployees(String systemCode) async {
    emit(EmployeesLoading());

    try {
      final result = await systemService.getSystemEmployees(systemCode);

      if (state is EmployeesLoaded) {
        final currentState = state as EmployeesLoaded;
        emit(currentState.copyWith(employees: result));
      } else {
        emit(EmployeesLoaded(employees: result));
      }
    } catch (e) {
      emit(EmployeesError(error: e.toString()));
    }
  }

  Future<void> getEmployeesProjects(String systemCode, String uid) async {
    if (state is! EmployeesLoaded) return;
    final currentState = state as EmployeesLoaded;

    try {
      final result = await systemService.getEmployeeProject(uid, systemCode);
      var updatedProjects = List<String>.from(currentState.projects);
      updatedProjects = result;

      emit(currentState.copyWith(projects: updatedProjects));
    } catch (e) {
      emit(EmployeesError(error: e.toString()));
    }
  }

  Future<void> getEmployeeTasks(String systemCode, String uid) async {
    final currentState = state;

    emit(EmployeesLoading());

    try {
      final result = await systemService.getUserTasksInProjects(
        uid,
        systemCode,
      );

      if (currentState is EmployeesLoaded) {
        emit(currentState.copyWith(tasks: result));
      } else {
        emit(EmployeesLoaded(employees: [], projects: [], tasks: result));
      }
    } catch (e) {
      emit(EmployeesError(error: e.toString()));
    }
  }

  Future<void> updateTaskStatus({
    required String systemCode,
    required String taskId,
    required String status,
    required String projectId,
  }) async {
    try {
      await systemService.updateTaskStatus(
        systemCode: systemCode,
        taskId: taskId,
        status: status,
        projectId: projectId,
      );

      final currentState = state as EmployeesLoaded;

      final updatedTasks = currentState.tasks.map((project, tasks) {
        final newTasks = tasks.map((task) {
          if (task['id'] == taskId) {
            return {...task, 'status': status};
          }
          return task;
        }).toList();

        return MapEntry(project, newTasks);
      });

      emit(currentState.copyWith(tasks: updatedTasks));
    } catch (e) {
      emit(EmployeesError(error: e.toString()));
    }
  }
}
