part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final Map<String, UserModel> users;
  const UserLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class UserError extends UserState {
  final String error;
  const UserError({required this.error});

  @override
  List<Object?> get props => [error];
}
