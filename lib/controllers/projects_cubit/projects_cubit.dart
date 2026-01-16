import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:system_manage/controllers/projects_cubit/projects_state.dart';
import 'package:system_manage/models/project_models.dart';
import 'package:system_manage/services/project_service.dart';

import '../../models/member_model.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final ProjectService _projectService;

  ProjectsCubit(this._projectService) : super(ProjectsInitial());

  Future<void> addProject({
    required String systemCode,
    required String name,
    required String desc,
    required String startTime,
    required String endTime,
    required String status,
    required List<MemberModel> members,
    required List<String> links,
    required List<String> steps,
    required double progress,
  }) async {
    emit(ProjectsLoading());

    try {
      await _projectService.addProject(
        systemCode,
        name,
        desc,
        startTime,
        endTime,
        status,
        members,
        links,
        steps,
        progress,
      );

      emit(ProjectsSuccess(message: 'Project added successfully'));
      await fetchProjects(systemCode, showLoader: false);
    } catch (e) {
      emit(ProjectsError(error: _handleError(e)));
    }
  }

  Future<void> fetchProjects(
    String systemCode, {
    bool showLoader = true,
  }) async {
    if (showLoader) emit(GetProjectsLoading());

    try {
      final projects = await _projectService.getProjects(systemCode);
      emit(GetProjectsLoaded(projects: projects));
    } catch (e) {
      emit(GetProjectsError(error: _handleError(e)));
    }
  }

  Future<void> deleteProject({
    required String systemCode,
    required String projectId,
  }) async {
    emit(DeleteProjectsLoading());

    try {
      await _projectService.deleteProjects(systemCode, projectId);
      emit(DeleteProjectsSuccess(message: 'Project deleted successfully'));
      await fetchProjects(systemCode, showLoader: false);
    } catch (e) {
      emit(DeleteProjectsError(error: _handleError(e)));
    }
  }

  String _handleError(Object error) {
    return error.toString().replaceAll('Exception:', '').trim();
  }

  Future<void> updateProject({
    required String docId,
    required String systemCode,
    required String name,
    required String desc,
    required String startTime,
    required String endTime,
    required String status,
    required int progress,
    required List<MemberModel> members,
    required List<String> links,
    required List<String> steps,
  }) async {
    emit(ProjectsLoading());

    try {
      await _projectService.updateProjects(
        systemCode: systemCode,
        projectID: docId,
        name: name,
        desc: desc,
        startTime: startTime,
        endTime: endTime,
        status: status,
        progress: progress,
        members: members,
        links: links,
        steps: steps,
      );

      emit(ProjectsSuccess(message: 'Project updated successfully'));
      await fetchProjects(systemCode, showLoader: false);
    } catch (e) {
      emit(ProjectsError(error: _handleError(e)));
    }
  }
}
