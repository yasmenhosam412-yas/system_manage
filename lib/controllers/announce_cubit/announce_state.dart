part of 'announce_cubit.dart';

@immutable
sealed class AnnounceState {}

final class AnnounceInitial extends AnnounceState {}

final class AnnounceLoaded extends AnnounceState {}

final class AnnounceUserLoaded extends AnnounceState {
  final List<AnnounceModel> anncounces;

  AnnounceUserLoaded({required this.anncounces});
}

final class AnnounceLoading extends AnnounceState {}

final class AnnounceError extends AnnounceState {
  final String error;

  AnnounceError({required this.error});
}
