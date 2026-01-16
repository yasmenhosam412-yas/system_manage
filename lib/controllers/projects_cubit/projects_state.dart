import 'package:flutter/cupertino.dart';

import '../../models/project_models.dart';

@immutable
abstract class ProjectsState {}

class ProjectsInitial extends ProjectsState {}

class ProjectsLoading extends ProjectsState {}

class ProjectsSuccess extends ProjectsState {
  final String message;
  ProjectsSuccess({required this.message});
}

class ProjectsError extends ProjectsState {
  final String error;
  ProjectsError({required this.error});
}

class GetProjectsLoading extends ProjectsState {}

class GetProjectsLoaded extends ProjectsState {
  final List<ProjectModel> projects;
  GetProjectsLoaded({required this.projects});
}

class GetProjectsError extends ProjectsState {
  final String error;
  GetProjectsError({required this.error});
}

class DeleteProjectsLoading extends ProjectsState {}

class DeleteProjectsSuccess extends ProjectsState {
  final String message;
  DeleteProjectsSuccess({required this.message});
}

class DeleteProjectsError extends ProjectsState {
  final String error;
  DeleteProjectsError({required this.error});
}
