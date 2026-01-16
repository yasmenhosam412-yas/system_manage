import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:system_manage/models/member_model.dart';
import 'package:system_manage/services/system_service.dart';

part 'system_state.dart';

class SystemCubit extends Cubit<SystemState> {
  final SystemService service;

  SystemCubit(this.service) : super(SystemInitial());

  Future<void> getSystemMembersAndDeps(String systemCode) async {
    emit(SystemLoading());
    try {
      final result = await service.getSystemMembers(systemCode);
      final deps = await service.getSystemDeps(systemCode);
      emit(SystemLoaded(members: result, departments: deps));
    } catch (e) {
      emit(SystemError(error: e.toString()));
    }
  }

  Future<void> getProjectMembers(String systemCode, String docId) async {
    emit(SystemLoading());
    try {
      final result = await service.getProjectMembers(systemCode, docId);

      emit(SystemLoaded(members: result, departments: []));
    } catch (e) {
      emit(SystemError(error: e.toString()));
    }
  }
}
