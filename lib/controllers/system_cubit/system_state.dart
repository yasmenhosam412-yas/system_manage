part of 'system_cubit.dart';

sealed class SystemState extends Equatable {
  const SystemState();
}

final class SystemInitial extends SystemState {
  @override
  List<Object> get props => [];
}

final class SystemLoading extends SystemState {
  @override
  List<Object> get props => [];
}

final class SystemError extends SystemState {
  final String error;

  const SystemError({required this.error});
  @override
  List<Object> get props => [error];
}

final class SystemLoaded extends SystemState {
  final List<MemberModel> members;
  final List<String> departments;

  const SystemLoaded({
    required this.members,
    required this.departments,
  });

  SystemLoaded copyWith({
    List<MemberModel>? members,
    List<String>? departments,
  }) {
    return SystemLoaded(
      members: members ?? this.members,
      departments: departments ?? this.departments,
    );
  }

  @override
  List<Object> get props => [members, departments];
}
