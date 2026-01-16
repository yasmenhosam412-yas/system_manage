part of 'performance_cubit.dart';

@immutable
sealed class PerformanceState {}

final class PerformanceInitial extends PerformanceState {}

final class PerformanceLoaded extends PerformanceState {}

final class PerformanceLoading extends PerformanceState {}

final class PerformanceError extends PerformanceState {
  final String error;

  PerformanceError({required this.error});
}
