import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:system_manage/models/project_models.dart';
import 'package:system_manage/services/user_services.dart';

part 'user_projects_state.dart';

class UserProjectsCubit extends Cubit<UserProjectsState> {
  final UserService userService;

  UserProjectsCubit(this.userService) : super(UserProjectsInitial());

  Future<void> getUserProjects(String code, String uid) async {
    emit(UserProjectsLoading());
    try {
      final result = await userService.getUserProjects(code, uid);
      emit(UserProjectsLoaded(projects: result));
    } catch (e) {
      emit(UserProjectsError(error: e.toString()));
    }
  }
}
