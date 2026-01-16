import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:system_manage/services/system_service.dart';

import '../../models/member_model.dart';
import '../../models/task_model.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final SystemService systemService;

  TasksCubit(this.systemService) : super(TasksInitial());

  Future<void> addTask(
    String systemCode,
    String name,
    String desc,
    MemberModel member,
    String memberName,
    String projectId,
    String deadline,
  ) async {
    emit(TasksAdding());
    try {
      await systemService.addTask(
        systemCode,
        name,
        desc,
        member,
        memberName,
        projectId,
        deadline,
      );
      emit(TasksAdded());
      final tasks = await systemService.getProjectsWithTasks(systemCode);
      emit(GetTasksLoaded(tasks: tasks));
    } catch (e) {
      emit(TasksError(error: e.toString()));
    }
  }

  Future<void> getTasksOfProject(String systemCode) async {
    emit(GetTasksLoading());
    try {
      final tasks = await systemService.getProjectsWithTasks(systemCode);
      emit(GetTasksLoaded(tasks: tasks));
    } catch (e) {
      emit(GetTasksLoadError(error: e.toString()));
    }
  }
}
