import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/models/user_model.dart';
import 'package:system_manage/services/create_system_service.dart';

part 'requests_state.dart';

class RequestsCubit extends Cubit<RequestsState> {
  final CreateSystemService createSystemService;

  RequestsCubit(this.createSystemService) : super(RequestsInitial());

  Future<void> getRequests(String systemCode) async {
    emit(const RequestsUsersLoaded(users: [], isRequestLoading: true));

    try {
      final users = await createSystemService.getRequests(systemCode);
      emit(RequestsUsersLoaded(users: users));
    } catch (e) {
      emit(RequestsUsersLoaded(users: const [], actionMessage: e.toString()));
    }
  }

  Future<void> requestJoinSystem({
    required String systemCode,
    required String username,
    required String image,
    required String email,
    required String jopTitle,
    required int prefomance,
  }) async {
    emit(RequestsActionLoading());

    try {
      final result = await createSystemService.requestJoinSystem(
          systemCode,
          username,
          image,
          email,
          jopTitle,
          prefomance
      );

      emit(RequestsActionCompleted(
        success: result,
        message: result ? AppTexts.requestSent : AppTexts.unnfound,
      ));
    } catch (e) {
      emit(RequestsActionCompleted(
        success: false,
        message: e.toString(),
      ));
    }
  }


  Future<void> acceptRequest({
    required String systemCode,
    required UserModel user,
    required String depart,
  }) async {
    final currentState = state;

    if (currentState is RequestsUsersLoaded) {
      emit(currentState.copyWith(isActionLoading: true));

      try {
        await createSystemService.acceptRequest(
          systemCode: systemCode,
          user: user,
          department: depart,
        );

        emit(
          currentState.copyWith(
            users: currentState.users.where((u) => u.uid != user.uid).toList(),
            isActionLoading: false,
            actionMessage: "Request approved",
          ),
        );
      } catch (e) {
        emit(
          currentState.copyWith(
            isActionLoading: false,
            actionMessage: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> rejectRequest({
    required String systemCode,
    required String userUid,
  }) async {
    final currentState = state;

    if (currentState is RequestsUsersLoaded) {
      emit(currentState.copyWith(isActionLoading: true));

      try {
        await createSystemService.rejectRequest(
          systemCode: systemCode,
          userUid: userUid,
        );

        emit(
          currentState.copyWith(
            users: currentState.users.where((u) => u.uid != userUid).toList(),
            isActionLoading: false,
            actionMessage: "Request rejected",
          ),
        );
      } catch (e) {
        emit(
          currentState.copyWith(
            isActionLoading: false,
            actionMessage: e.toString(),
          ),
        );
      }
    }
  }
}
