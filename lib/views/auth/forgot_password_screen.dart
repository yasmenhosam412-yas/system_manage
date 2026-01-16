import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/core/utils/app_images.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_regrex.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/toasts.dart';
import 'package:system_manage/core/widgets/custom_button.dart';
import 'package:system_manage/core/widgets/custom_text_field.dart';

import '../../controllers/auth_cubit/auth_cubit.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late TextEditingController emailController;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.medium),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: AppPadding.small,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(AppImages.logo, width: 65, height: 65),
                  ),
                  Center(
                    child: Text(
                      AppTexts.forgotTitle,
                      style: AppTextStyles.font18Black800.copyWith(
                        color: AppColors.grey900,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Text(
                      AppTexts.forgotSubtitle,
                      style: AppTextStyles.font16Black600.copyWith(
                        color: AppColors.grey800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppPadding.medium),
                  Text(
                    AppTexts.forgotEmailLabel,
                    style: AppTextStyles.font16Black600.copyWith(
                      color: AppColors.grey900,
                    ),
                  ),
                  CustomTextField(
                    controller: emailController,
                    validator: (value) {
                      return AppRegex.validateNotEmpty(
                        value,
                        fieldName: "email",
                      );
                    },
                    keyboardType: TextInputType.emailAddress,
                    hintText: AppTexts.forgotEmailHint,
                  ),
                  SizedBox(height: AppPadding.medium),
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthForgotEmailSent) {
                        Toasts.displayToast(state.message);
                        Navigator.pop(context);
                      }
                      if (state is AuthForgotError) {
                        Toasts.displayToast(state.error);
                      }
                    },
                    builder: (context, state) {
                      return CustomButton(
                        text: state is AuthForgotLoading
                            ? AppTexts.forgotSending
                            : AppTexts.forgotSendButton,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().forgotPassword(
                              emailController.text,
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
        ),
      ),
    );
  }
}
