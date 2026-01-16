part of 'attendance_cubit.dart';

@immutable
sealed class AttendanceState {}

final class AttendanceInitial extends AttendanceState {}

final class AttendanceLoading extends AttendanceState {}

final class AttendanceLoaded extends AttendanceState {}

final class GetAttendanceLoaded extends AttendanceState {
  final List<Map<String, dynamic>> attendance;

  GetAttendanceLoaded({required this.attendance});
}

final class AttendanceError extends AttendanceState {
  final String error;

  AttendanceError({required this.error});
}
