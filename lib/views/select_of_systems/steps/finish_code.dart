import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/create_system_cubit/create_system_cubit.dart';
import 'package:system_manage/core/config/routes.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_regrex.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/toasts.dart';
import 'package:system_manage/core/widgets/custom_button.dart';
import 'package:system_manage/core/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class FinishCode extends StatefulWidget {
  final String name;
  final List<String> deps;
  final String startTime;
  final String endTime;
  final List<String> workDays;
  final String image;

  const FinishCode({
    super.key,
    required this.name,
    required this.deps,
    required this.startTime,
    required this.endTime,
    required this.workDays,
    required this.image,
  });

  @override
  State<FinishCode> createState() => _FinishCodeState();
}

class _FinishCodeState extends State<FinishCode> {
  String? generatedCode;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    _generateCode();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  void _generateCode() {
    var uuid = Uuid();
    setState(() {
      generatedCode = uuid.v4().substring(0, 8).toUpperCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.medium),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                AppTexts.yourSystemCode,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppPadding.medium),
            Center(
              child: Text(
                generatedCode ?? "",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: AppPadding.large),
            CustomButton(
              onPressed: _generateCode,
              text: AppTexts.generateAnother,
            ),
            const SizedBox(height: AppPadding.medium),
            BlocConsumer<CreateSystemCubit, CreateSystemState>(
              listener: (context, state) {
                if (state is CreateSystemLoaded) {
                  Toasts.displayToast(AppTexts.createdSuccess);
                  Navigator.popAndPushNamed(context, AppRoutes.userSystems,arguments: FirebaseAuth.instance.currentUser?.uid);
                }
                if (state is CreateSystemError) {
                  Toasts.displayToast(state.error);
                }
              },
              builder: (context, state) {
                if (state is CreateSystemLoading) {
                  return CustomButton(
                    text: AppTexts.pleaseWait,
                    onPressed: null,
                    color: Colors.white,
                    borderColor: AppColors.primaryColor,
                    textColor: AppColors.primaryColor,
                  );
                }
                return CustomButton(
                  text: AppTexts.finish,
                  onPressed: () {
                    context.read<CreateSystemCubit>().createSystem(
                      widget.name,
                      widget.deps,
                      widget.startTime,
                      widget.endTime,
                      widget.workDays,
                      widget.image,
                      generatedCode ?? "",
                    );
                  },
                  color: Colors.white,
                  borderColor: AppColors.primaryColor,
                  textColor: AppColors.primaryColor,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
