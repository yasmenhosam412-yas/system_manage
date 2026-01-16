import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/helpers/create_material_color.dart';
import 'package:system_manage/views/select_of_systems/steps/customize_system.dart';
import 'package:system_manage/views/select_of_systems/steps/finish_code.dart';
import 'package:system_manage/views/select_of_systems/steps/system_data.dart';

class CreateSystemScreen extends StatefulWidget {
  const CreateSystemScreen({super.key});

  @override
  State<CreateSystemScreen> createState() => _CreateSystemScreenState();
}

class _CreateSystemScreenState extends State<CreateSystemScreen> {
  int currentIndex = 0;

  String? imagePath;
  MaterialColor? primary_color;
  String? systemName;
  List<String>? departments;
  String? startTimeSelected;
  String? endTimeSelected;
  List<String>? workDaysSelected;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentIndex != 0) {
          setState(() {
            currentIndex--;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: AppPadding.medium),
                EasyStepper(
                  enableStepTapping: true,
                  activeStepBackgroundColor: AppColors.primaryColor,
                  showLoadingAnimation: false,
                  activeStep: currentIndex,
                  unreachedStepBackgroundColor: Colors.grey.shade300,
                  finishedStepBackgroundColor: AppColors.primaryColor,
                  lineStyle: LineStyle(
                    lineType: LineType.normal,
                    activeLineColor: AppColors.primaryColor,
                    defaultLineColor: AppColors.primaryColor,
                    unreachedLineColor: Colors.grey.shade300,
                  ),
                  showStepBorder: false,
                  steps: List.generate(3, (index) {
                    return EasyStep(
                      customStep: Padding(
                        padding: const EdgeInsets.all(AppPadding.medium),
                        child: Text(
                          "${index + 1}",
                          style: AppTextStyles.font16Black600.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: AppPadding.small),
                _buildStepWidget(currentIndex, () {
                  currentIndex++;
                  print(currentIndex);
                  setState(() {});
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepWidget(int currentIndex, VoidCallback onNext) {
    switch (currentIndex) {
      case 0:
        return SystemData(
          onNext: (name, deps, startTime, endTime, workDays) {
            setState(() {
              systemName = name;
              departments = deps;
              startTimeSelected = startTime;
              endTimeSelected = endTime;
              workDaysSelected = workDays;
            });
            onNext();
          },
        );
      case 1:
        return CustomizeSystem(
          onNext: (image) {
            setState(() {
              imagePath = image;
            });
            onNext();
          },
        );
      case 2:
        return FinishCode(
          name: systemName ?? "unknown",
          deps: departments ?? [],
          endTime: endTimeSelected ?? "",
          startTime: startTimeSelected ?? "",
          image: imagePath ?? "",
          workDays: workDaysSelected ?? [],
        );
      default:
        return SizedBox.shrink();
    }
  }
}
