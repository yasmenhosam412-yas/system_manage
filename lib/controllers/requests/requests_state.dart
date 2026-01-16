part of 'requests_cubit.dart';

sealed class RequestsState extends Equatable {
  const RequestsState();
}

final class RequestsInitial extends RequestsState {
  @override
  List<Object> get props => [];
}

class RequestsActionLoading extends RequestsState {
  @override
  List<Object?> get props => [];
}

class RequestsActionCompleted extends RequestsState {
  final bool success;
  final String message;

  const RequestsActionCompleted({required this.success, required this.message});

  @override
  List<Object?> get props => [success, message];
}

final class RequestsUsersLoaded extends RequestsState {
  final List<UserModel> users;
  final bool isActionLoading;
  final bool isRequestLoading;
  final String? actionMessage;

  const RequestsUsersLoaded({
    required this.users,
    this.isActionLoading = false,
    this.isRequestLoading = false,
    this.actionMessage,
  });

  RequestsUsersLoaded copyWith({
    List<UserModel>? users,
    bool? isActionLoading,
    String? actionMessage,
    bool? isRequestLoading,
  }) {
    return RequestsUsersLoaded(
      users: users ?? this.users,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      isRequestLoading: isRequestLoading ?? this.isRequestLoading,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    users,
    isActionLoading,
    isRequestLoading,
    actionMessage,
  ];
}
