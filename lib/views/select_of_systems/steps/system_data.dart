import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_regrex.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/toasts.dart';
import 'package:system_manage/core/widgets/custom_button.dart';
import 'package:system_manage/core/widgets/custom_text_field.dart';
import 'package:system_manage/models/system_model.dart';
import 'package:system_manage/views/select_of_systems/widgets/week_day_selector.dart';

import '../../../core/utils/app_colors.dart';

class SystemData extends StatefulWidget {
  final Function(
    String name,
    List<String> deps,
    String startTime,
    String endTime,
    List<String> workDays,
  )
  onNext;
  final SystemModel? systemModel;

  const SystemData({super.key, required this.onNext, this.systemModel});

  @override
  State<SystemData> createState() => _SystemDataState();
}

class _SystemDataState extends State<SystemData> {
  late TextEditingController systemNameController;
  late TextEditingController departmentController;
  late TextEditingController startTime;
  late TextEditingController endTime;

  List<String> departments = [];
  List<String> selected_days = [];

  final GlobalKey<FormState> _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
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
    return Padding(
      padding: const EdgeInsets.all(AppPadding.medium),
      child: Form(
        key: _globalKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        backgroundColor: Colors.white,
                        label: Text(dep),
                        onDeleted: () {
                          setState(() {
                            departments.remove(dep);
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            SizedBox(height: AppPadding.small),
            Text(AppTexts.startTime),
            SizedBox(height: AppPadding.small),
            CustomTextField(
              controller: startTime,
              hintText: AppTexts.enterStartTime,
              readOnly: true,
              prefixIcon: IconButton(
                icon: Icon(Icons.access_time_rounded),
                onPressed: () async {
                  final start = await _openTimePickerDialog();
                  if (start != null) {
                    startTime.text = start.format(context);
                  }
                },
              ),
              validator: (value) {
                return AppRegex.validateNotEmpty(
                  value,
                  fieldName: "start time",
                );
              },
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
              validator: (value) {
                return AppRegex.validateNotEmpty(value, fieldName: "end time");
              },
            ),
            SizedBox(height: AppPadding.medium),
            Text(AppTexts.workDays),
            SizedBox(height: AppPadding.small),
            WeekDaysSelector(
              onSelect: (List<String> days) {
                setState(() {
                  selected_days = days;
                });
              },
            ),
            SizedBox(height: AppPadding.xlarge),
            CustomButton(
              text: AppTexts.next,
              onPressed: () {
                if (_globalKey.currentState!.validate()) {
                  if (departments.isEmpty || selected_days.isEmpty) {
                    Toasts.displayToast(
                      AppTexts.enterAllData,
                      AppColors.grey800,
                    );
                    return;
                  }
                  widget.onNext(
                    systemNameController.text,
                    departments,
                    startTime.text,
                    endTime.text,
                    selected_days,
                  );
                }
              },
            ),
          ],
        ),
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
