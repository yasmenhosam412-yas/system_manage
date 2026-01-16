import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/auth_cubit/auth_cubit.dart';
import 'package:system_manage/core/config/routes.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_images.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_regrex.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/core/widgets/custom_button.dart';
import 'package:system_manage/core/widgets/custom_text_field.dart';

import '../../core/utils/toasts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final GlobalKey<FormState> _formKey = GlobalKey();
  DateTime? lastBackPressTime;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
    passwordController.dispose();
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (lastBackPressTime == null ||
        now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
      lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppTexts.pressBackToExit),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryColor,
        ),
      );
      return false;
    }
    SystemNavigator.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                        AppTexts.loginTitle,
                        style: AppTextStyles.font18Black800,
                      ),
                    ),
                    Center(
                      child: Text(
                        AppTexts.loginSubtitle,
                        style: AppTextStyles.font16Black600.copyWith(
                          color: AppColors.grey800,
                        ),
                      ),
                    ),
                    SizedBox(height: AppPadding.small),
                    Text(
                      AppTexts.loginEmailLabel,
                      style: AppTextStyles.font16Black600.copyWith(
                        color: AppColors.grey900,
                      ),
                    ),
                    CustomTextField(
                      controller: emailController,
                      hintText: AppTexts.loginEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        return AppRegex.validateNotEmpty(
                          fieldName: "email",
                          value,
                        );
                      },
                    ),
                    SizedBox(height: AppPadding.small),
                    Text(
                      AppTexts.loginPasswordLabel,
                      style: AppTextStyles.font16Black600.copyWith(
                        color: AppColors.grey900,
                      ),
                    ),
                    CustomTextField(
                      controller: passwordController,
                      hintText: AppTexts.loginPasswordHint,
                      obscureText: true,
                      validator: (value) {
                        return AppRegex.validateNotEmpty(
                          fieldName: "password",
                          value,
                        );
                      },
                    ),
                    SizedBox(height: AppPadding.small),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.forgot_pass);
                        },
                        child: Text(
                          AppTexts.forgotPassword,
                          style: AppTextStyles.font16Black600.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppPadding.medium),
                    BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is AuthLoginLoaded) {
                          Toasts.displayToast(state.message);
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.userSystems,
                            arguments: FirebaseAuth.instance.currentUser?.uid
                          );
                          print(FirebaseAuth.instance.currentUser!.uid);
                        }
                        if (state is AuthLoginError) {
                          Toasts.displayToast(state.error);
                        }
                      },
                      builder: (context, state) {
                        if (state is AuthLoginLoading) {
                          return CustomButton(
                            text: AppTexts.pleaseWait,
                            onPressed: null,
                          );
                        }
                        return CustomButton(
                          text: AppTexts.loginButton,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().login(
                                emailController.text,
                                passwordController.text,
                              );
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: AppPadding.small),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.signup);
                      },
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: AppTexts.loginDontHaveAccount,
                                style: AppTextStyles.font16Black600.copyWith(
                                  color: AppColors.grey800,
                                ),
                              ),
                              TextSpan(
                                text: AppTexts.loginCreateAccount,
                                style: AppTextStyles.font16Black600.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
