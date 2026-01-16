part of 'tasks_cubit.dart';

sealed class TasksState extends Equatable {
  const TasksState();
}

final class TasksInitial extends TasksState {
  @override
  List<Object> get props => [];
}

final class TasksAdded extends TasksState {
  @override
  List<Object> get props => [];
}

final class TasksAdding extends TasksState {
  @override
  List<Object> get props => [];
}

final class TasksError extends TasksState {
  final String error;

  const TasksError({required this.error});

  @override
  List<Object> get props => [];
}

final class GetTasksLoading extends TasksState {
  @override
  List<Object> get props => [];
}

final class GetTasksLoaded  extends TasksState {
  final List<ProjectTasksModel> tasks;

  const GetTasksLoaded({required this.tasks});
  @override
  List<Object> get props => [];
}

final class GetTasksLoadError extends TasksState {
  final String error;

  const GetTasksLoadError({required this.error});

  @override
  List<Object> get props => [];
}
