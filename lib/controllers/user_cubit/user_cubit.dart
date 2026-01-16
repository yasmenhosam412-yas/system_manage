import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:system_manage/models/user_model.dart';
import 'package:system_manage/services/user_data_service.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserDataService userDataService;

  UserCubit(this.userDataService) : super(UserInitial());

  final Map<String, UserModel> _users = {};

  Future<void> getUserData(String uid) async {
    emit(UserLoading());
    try {
      final result = await userDataService.getUserData(uid);
      if (result != null) {
        _users[uid] = result;
      }
      emit(UserLoaded(users: Map.from(_users)));
    } catch (e) {
      emit(UserError(error: e.toString()));
    }
  }

  void updateUser(UserModel updatedUser) {
    if (state is UserLoaded) {
      final users = Map<String, UserModel>.from((state as UserLoaded).users);
      users[updatedUser.uid] = updatedUser;
      emit(UserLoaded(users: users));
    }
  }
}
