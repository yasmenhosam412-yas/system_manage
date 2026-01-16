import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:system_manage/controllers/profile_cubit/profile_cubit.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/helpers/cloudinary.dart';
import 'package:system_manage/models/system_model.dart';

import '../../../../core/utils/app_padding.dart';
import '../../../../core/utils/app_regrex.dart';
import '../../../../core/utils/toasts.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../select_of_systems/widgets/week_day_selector.dart';

class SystemInfo extends StatefulWidget {
  final String code;

  const SystemInfo({super.key, required this.code});

  @override
  State<SystemInfo> createState() => _SystemInfoState();
}

class _SystemInfoState extends State<SystemInfo> {
  late TextEditingController systemNameController;
  late TextEditingController departmentController;
  late TextEditingController startTime;
  late TextEditingController endTime;

  List<String> departments = [];
  List<String> selected_days = [];
  SystemModel? systemModel;

  final GlobalKey<FormState> _globalKey = GlobalKey();

  bool isInitialized = false;
  XFile? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getSsyetmInfo(widget.code);

    systemNameController = TextEditingController();
    departmentController = TextEditingController();
    startTime = TextEditingController();
    endTime = TextEditingController();
  }

  @override
  void dispose() {
    systemNameController.dispose();
    departmentController.dispose();
    startTime.dispose();
    endTime.dispose();
    super.dispose();
  }

  void addDepartment() {
    final value = departmentController.text.trim();
    if (value.isNotEmpty) {
      setState(() {
        departments.add(value);
        departmentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          AppTexts.systemInfo,
          style: AppTextStyles.font16Black600.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (state is ProfileError) {
            return Center(child: Text(state.error));
          }

          if (state is ProfileSystemLoaded) {
            systemModel = state.systemModel;

            if (!isInitialized) {
              systemNameController.text = systemModel?.name ?? "";
              startTime.text = systemModel?.startTime ?? "";
              endTime.text = systemModel?.endTime ?? "";
              departments = [...(systemModel?.deps ?? [])];
              selected_days = [...(systemModel?.workDays ?? [])];
              isInitialized = true;
            }

            return Padding(
              padding: const EdgeInsets.all(AppPadding.medium),
              child: Form(
                key: _globalKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey.shade200,
                              child: _selectedImage != null
                                  ? Image.file(
                                      File(_selectedImage!.path),
                                      fit: BoxFit.cover,
                                    )
                                  : (systemModel?.systemImage != null &&
                                            systemModel!.systemImage.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: systemModel!.systemImage,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: AppColors
                                                            .primaryColor,
                                                      ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error, size: 50),
                                          )
                                        : Icon(
                                            Icons.image,
                                            size: 50,
                                            color: Colors.grey,
                                          )),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppPadding.medium),
                      Center(
                        child: Text(
                          "${AppTexts.code.toUpperCase()} : ${systemModel!.code}",
                          style: AppTextStyles.font16Black600,
                        ),
                      ),
                      SizedBox(height: AppPadding.small),
                      Text(AppTexts.systemName),
                      SizedBox(height: AppPadding.small),
                      CustomTextField(
                        controller: systemNameController,
                        hintText: AppTexts.enterSystemName,
                        validator: (value) {
                          return AppRegex.validateNotEmpty(
                            value,
                            fieldName: "system name",
                          );
                        },
                      ),
                      SizedBox(height: AppPadding.medium),

                      Text(AppTexts.systemDepartments),
                      SizedBox(height: AppPadding.small),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: departmentController,
                              hintText: AppTexts.enterDepartment,
                            ),
                          ),
                          SizedBox(width: AppPadding.small),
                          CustomButton(
                            text: AppTexts.add,
                            onPressed: addDepartment,
                            width: 100,
                            height: 50,
                          ),
                        ],
                      ),

                      SizedBox(height: AppPadding.small),

                      if (departments.isNotEmpty)
                        Wrap(
                          spacing: AppPadding.small,
                          runSpacing: AppPadding.small,
                          children: departments
                              .map(
                                (dep) => Chip(
                                  label: Text(dep),
                                  backgroundColor: Colors.white,
                                  onDeleted: () {
                                    setState(() {
                                      departments.remove(dep);
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),

                      SizedBox(height: AppPadding.medium),

                      Text(AppTexts.startTime),
                      SizedBox(height: AppPadding.small),

                      CustomTextField(
                        controller: startTime,
                        readOnly: true,
                        hintText: AppTexts.enterStartTime,
                        prefixIcon: IconButton(
                          icon: Icon(Icons.access_time_rounded),
                          onPressed: () async {
                            final start = await _openTimePickerDialog();
                            if (start != null) {
                              startTime.text = start.format(context);
                            }
                          },
                        ),
                      ),

                      SizedBox(height: AppPadding.small),

                      Text(AppTexts.endTime),
                      SizedBox(height: AppPadding.small),

                      CustomTextField(
                        controller: endTime,
                        readOnly: true,
                        hintText: AppTexts.enterEndTime,
                        prefixIcon: IconButton(
                          icon: Icon(Icons.access_time_rounded),
                          onPressed: () async {
                            final end = await _openTimePickerDialog();
                            if (end != null) {
                              endTime.text = end.format(context);
                            }
                          },
                        ),
                      ),

                      SizedBox(height: AppPadding.medium),

                      Text(AppTexts.workDays),
                      SizedBox(height: AppPadding.small),

                      WeekDaysSelector(
                        initialDays: selected_days,
                        onSelect: (days) {
                          setState(() {
                            selected_days = days;
                          });
                        },
                      ),

                      SizedBox(height: AppPadding.xlarge),

                      BlocConsumer<ProfileCubit, ProfileState>(
                        listener: (context, state) {
                          if (state is ProfileError) {
                            Toasts.displayToast(state.error);
                          }
                          if (state is ProfileSystemLoaded) {
                            Toasts.displayToast(AppTexts.changedSucc);
                            Navigator.pop(context);
                          }
                        },
                        builder: (context, state) {
                          return CustomButton(
                            text: (state is ProfileLoading)
                                ? AppTexts.pleaseWait
                                : AppTexts.change,
                            onPressed: (state is ProfileLoading)
                                ? null
                                : () async {
                                    if (_globalKey.currentState!.validate()) {
                                      if (departments.isEmpty ||
                                          selected_days.isEmpty) {
                                        Toasts.displayToast(
                                          AppTexts.enterAllData,
                                          AppColors.grey800,
                                        );
                                        return;
                                      }
                                      final myImage = await saveToCloudinary(
                                        _selectedImage?.path ??
                                            systemModel!.systemImage,
                                      );
                                      context.read<ProfileCubit>().updateSystem(
                                        widget.code,
                                        SystemModel(
                                          name: systemNameController.text,
                                          code: widget.code,
                                          deps: departments,
                                          startTime: startTime.text,
                                          endTime: endTime.text,
                                          workDays: selected_days,
                                          systemImage: myImage,
                                        ),
                                      );
                                    }
                                  },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }

  Future<TimeOfDay?> _openTimePickerDialog() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 8, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.white,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              dayPeriodColor: Colors.grey,
              hourMinuteTextColor: AppColors.primaryColor,
              dayPeriodTextColor: AppColors.primaryColor,
              dialHandColor: AppColors.primaryColor,
              dialTextColor: Colors.black,
              entryModeIconColor: AppColors.primaryColor,
              cancelButtonStyle: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(AppColors.primaryColor),
                textStyle: WidgetStatePropertyAll(
                  TextStyle(color: Colors.white),
                ),
              ),
              confirmButtonStyle: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(AppColors.primaryColor),
                textStyle: WidgetStatePropertyAll(
                  TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    return selectedTime;
  }
}
