import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:system_manage/controllers/auth_cubit/auth_cubit.dart';
import 'package:system_manage/core/utils/app_images.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/core/utils/toasts.dart';
import 'package:system_manage/core/widgets/custom_button.dart';

import '../../core/config/routes.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_padding.dart';
import '../../core/utils/app_regrex.dart';
import '../../core/widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController titleController;
  final GlobalKey<FormState> _formKey = GlobalKey();
  ImagePicker? imagePicker;
  XFile? selectedImage;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    titleController = TextEditingController();
    passwordController = TextEditingController();
    imagePicker = ImagePicker();
  }

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
    passwordController.dispose();
    titleController.dispose();
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: AppPadding.small,
                children: [
                  Center(
                    child: Image.asset(AppImages.logo, width: 65, height: 65),
                  ),
                  Center(
                    child: Text(
                      AppTexts.signupTitle,
                      style: AppTextStyles.font18Black800,
                    ),
                  ),
                  Center(
                    child: Text(
                      AppTexts.signupSubtitle,
                      style: AppTextStyles.font16Black600.copyWith(
                        color: AppColors.grey800,
                      ),
                    ),
                  ),
                  SizedBox(height: AppPadding.small),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: AppColors.grey500,
                          backgroundImage: (selectedImage != null)
                              ? FileImage(File(selectedImage!.path))
                              : AssetImage(AppImages.placeholder),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              _openGallery();
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: AppColors.primaryColor,
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppPadding.small),
                  Text(
                    AppTexts.signupEmailLabel,
                    style: AppTextStyles.font16Black600.copyWith(
                      color: AppColors.grey900,
                    ),
                  ),
                  CustomTextField(
                    controller: emailController,
                    hintText: AppTexts.signupEmailHint,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      return AppRegex.validateNotEmpty(
                        fieldName: "email",
                        value,
                      );
                    },
                  ),
                  Text(
                    AppTexts.signupJobTitleLabel,
                    style: AppTextStyles.font16Black600.copyWith(
                      color: AppColors.grey900,
                    ),
                  ),
                  CustomTextField(
                    controller: titleController,
                    hintText: AppTexts.signupJobTitleHint,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      return AppRegex.validateNotEmpty(
                        fieldName: "title",
                        value,
                      );
                    },
                  ),
                  Text(
                    AppTexts.signupPasswordLabel,
                    style: AppTextStyles.font16Black600.copyWith(
                      color: AppColors.grey900,
                    ),
                  ),
                  CustomTextField(
                    controller: passwordController,
                    hintText: AppTexts.signupPasswordHint,
                    obscureText: true,
                    validator: (value) {
                      return AppRegex.validateNotEmpty(
                        fieldName: "password",
                        value,
                      );
                    },
                  ),
                  SizedBox(height: AppPadding.small),
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthLoaded) {
                        Toasts.displayToast(AppTexts.signupSuccess);
                        Navigator.pop(context);
                      }
                      if (state is AuthError) {
                        Toasts.displayToast(state.error);
                      }
                    },
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return CustomButton(
                          text: AppTexts.signupLoading,
                          onPressed: null,
                        );
                      }
                      return CustomButton(
                        text: AppTexts.signupButton,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().createAccount(
                              emailController.text,
                              passwordController.text,
                              titleController.text,
                              selectedImage?.path,
                            );
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(height: AppPadding.small),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: AppTexts.signupAlreadyHaveAccount,
                              style: AppTextStyles.font16Black600.copyWith(
                                color: AppColors.grey800,
                              ),
                            ),
                            TextSpan(
                              text: AppTexts.loginButton,
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
    );
  }

  Future<void> _openGallery() async {
    XFile? image = await imagePicker?.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = image;
      setState(() {});
    }
  }
}
