part of 'create_system_cubit.dart';

sealed class CreateSystemState extends Equatable {
  const CreateSystemState();
}

final class CreateSystemInitial extends CreateSystemState {
  @override
  List<Object> get props => [];
}

final class CreateSystemLoading extends CreateSystemState {
  @override
  List<Object> get props => [];
}

final class CreateSystemLoaded extends CreateSystemState {
  @override
  List<Object> get props => [];
}

final class CreateSystemError extends CreateSystemState {
  final String error;

  const CreateSystemError({required this.error});

  @override
  List<Object> get props => [error];
}

final class GetSystemLoading extends CreateSystemState {
  @override
  List<Object> get props => [];
}

final class GetSystemLoaded extends CreateSystemState {
  final List<SystemModelSelection> systems;

  const GetSystemLoaded({required this.systems});
  @override
  List<Object> get props => [];
}

final class GetSystemError extends CreateSystemState {
  final String error;

  const GetSystemError({required this.error});

  @override
  List<Object> get props => [error];
}
