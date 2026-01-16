part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {}

final class ProfileSystemLoaded extends ProfileState {
  final SystemModel systemModel;

  ProfileSystemLoaded({required this.systemModel});
}

final class ProfileError extends ProfileState {
  final String error;

  ProfileError({required this.error});
}
