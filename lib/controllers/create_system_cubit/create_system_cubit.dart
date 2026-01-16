import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:system_manage/helpers/error_helper.dart';
import 'package:system_manage/models/system_model_selection.dart';
import 'package:system_manage/services/create_system_service.dart';

part 'create_system_state.dart';

class CreateSystemCubit extends Cubit<CreateSystemState> {
  final CreateSystemService createSystemService;

  CreateSystemCubit(this.createSystemService) : super(CreateSystemInitial());

  Future<void> createSystem(
    String systemName,
    List<String> departments,
    String startTime,
    String endTime,
    List<String> workDays,
    String systemImage,
    String systemCode,
  ) async {
    emit(CreateSystemLoading());
    try {
      await createSystemService.createSystem(
        systemName,
        departments,
        startTime,
        endTime,
        workDays,
        systemImage,
        systemCode,
      );
      emit(CreateSystemLoaded());
    } catch (e) {
      emit(CreateSystemError(error: ErrorHelper.format(e.toString())));
    }
  }

  Future<void> getSystems(String uid) async {
    emit(GetSystemLoading());
    try {
      final result = await createSystemService.getSystem(uid);
      emit(GetSystemLoaded(systems: result));
    } catch (e) {
      emit(GetSystemError(error: ErrorHelper.format(e.toString())));
    }
  }
}
