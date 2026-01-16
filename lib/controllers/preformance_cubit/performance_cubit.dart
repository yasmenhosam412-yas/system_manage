import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:system_manage/services/user_services.dart';

part 'performance_state.dart';

class PerformanceCubit extends Cubit<PerformanceState> {
  final UserService userService;

  PerformanceCubit(this.userService) : super(PerformanceInitial());

  Future<void> updatePRefrmance(String uid, {
    required int present,
    required int remote,
    required int onLeave,
    required int completedTasks,
    required int allTasks,
    required String systemCode,
  }) async {
    emit(PerformanceLoading());
    try {
      await userService.updateUserPerformance(
        uid,
        present: present,
        remote: remote,
        onLeave: onLeave,
        completedTasks: completedTasks,
        allTasks: allTasks,
      );
      await userService.updateMemberPerformance(
          systemCode, FirebaseAuth.instance.currentUser!.uid, present: present,
          remote: remote,
          onLeave: onLeave,
          completedTasks: completedTasks,
          allTasks: allTasks);
      emit(PerformanceLoaded());
    } catch (e) {
      emit(PerformanceError(error: e.toString()));
    }
  }
}
