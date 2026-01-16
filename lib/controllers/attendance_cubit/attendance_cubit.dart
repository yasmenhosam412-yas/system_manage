import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:system_manage/core/utils/toasts.dart';
import 'package:system_manage/services/user_services.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final UserService userService;

  AttendanceCubit(this.userService) : super(AttendanceInitial());

  Future<void> addToAttendance(String status, String code, String uid) async {
    emit(AttendanceLoading());
    try {
      await userService.assignAttendanceToday(code, uid, status);
      emit(AttendanceLoaded());
      getUserAttendance(code, uid);
    } catch (e) {
      Toasts.displayToast(e.toString());
      emit(AttendanceError(error: e.toString()));
    }
  }

  Future<void> getUserAttendance(String code, String uid) async {
    emit(AttendanceLoading());
    try {
      final result = await userService.getUserAttendance(code, uid);
      emit(GetAttendanceLoaded(attendance: result));
    } catch (e) {
      Toasts.displayToast(e.toString());
      emit(AttendanceError(error: e.toString()));
    }
  }
}
