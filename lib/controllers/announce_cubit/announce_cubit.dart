import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:system_manage/models/anncounce_model.dart';
import 'package:system_manage/services/system_service.dart';

import '../../models/member_model.dart';

part 'announce_state.dart';

class AnnounceCubit extends Cubit<AnnounceState> {
  final SystemService systemService;

  AnnounceCubit(this.systemService) : super(AnnounceInitial());

  Future<void> addAnncounce(
    String systemCode,
    String name,
    String desc,
    List<MemberModel> mems,
  ) async {
    emit(AnnounceLoading());
    try {
      await systemService.addAnncounce(systemCode, name, desc, mems);
      emit(AnnounceLoaded());
    } catch (e) {
      emit(AnnounceError(error: e.toString()));
    }
  }

  Future<void> getAnncounce(String systemCode, String uid) async {
    emit(AnnounceLoading());
    try {
      final list = await systemService.getAnncounce(systemCode, uid);
      emit(AnnounceUserLoaded(anncounces: list));
    } catch (e) {
      emit(AnnounceError(error: e.toString()));
    }
  }
}
