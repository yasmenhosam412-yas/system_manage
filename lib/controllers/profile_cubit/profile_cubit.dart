import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:system_manage/helpers/error_helper.dart';
import 'package:system_manage/models/system_model.dart';
import 'package:system_manage/services/profile_service.dart';
import 'package:system_manage/services/user_data_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService profileService;

  ProfileCubit(this.profileService) : super(ProfileInitial());

  Future<void> changePass(String currentPass, String newPass) async {
    emit(ProfileLoading());
    try {
      await profileService.updatePass(currentPass, newPass);
      emit(ProfileLoaded());
    } catch (e) {
      emit(ProfileError(error: ErrorHelper.format(e.toString())));
    }
  }

  Future<void> changeUsername(String username) async {
    emit(ProfileLoading());
    try {
      await profileService.updateUsername(username);
      emit(ProfileLoaded());
    } catch (e) {
      emit(ProfileError(error: ErrorHelper.format(e.toString())));
    }
  }

  Future<void> changeImage(String image) async {
    emit(ProfileLoading());
    try {
      await profileService.updateImage(image);
      emit(ProfileLoaded());
    } catch (e) {
      emit(ProfileError(error: ErrorHelper.format(e.toString())));
    }
  }

  Future<void> getSsyetmInfo(String code) async {
    emit(ProfileLoading());
    try {
      final systemModel = await profileService.getSystem(code);
      emit(ProfileSystemLoaded(systemModel: systemModel));
    } catch (e) {
      emit(ProfileError(error: e.toString()));
    }
  }

  Future<void> updateSystem(String code, SystemModel model) async {
    emit(ProfileLoading());
    try {
      final updatedModel = await profileService.updateSystem(code, model);

      emit(ProfileSystemLoaded(systemModel: updatedModel));
    } catch (e) {
      emit(ProfileError(error: e.toString()));
    }
  }
}
