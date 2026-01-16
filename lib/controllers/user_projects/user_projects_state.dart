part of 'user_projects_cubit.dart';

sealed class UserProjectsState extends Equatable {
  const UserProjectsState();
}

final class UserProjectsInitial extends UserProjectsState {
  @override
  List<Object> get props => [];
}

final class UserProjectsLoading extends UserProjectsState {
  @override
  List<Object> get props => [];
}

final class UserProjectsLoaded extends UserProjectsState {
  final List<ProjectModel> projects;

  const UserProjectsLoaded({required this.projects});

  @override
  List<Object> get props => [projects];
}

final class UserProjectsError extends UserProjectsState {
  final String error;

  const UserProjectsError({required this.error});

  @override
  List<Object> get props => [error];
}
