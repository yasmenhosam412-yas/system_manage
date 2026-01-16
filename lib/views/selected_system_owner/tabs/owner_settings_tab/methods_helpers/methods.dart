import 'package:firebase_auth/firebase_auth.dart';
import 'package:system_manage/controllers/user_cubit/user_cubit.dart';
import 'package:system_manage/helpers/cloudinary.dart';

import '../../../../../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/profile_cubit/profile_cubit.dart';
import 'package:system_manage/core/utils/app_images.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/toasts.dart';
import 'package:system_manage/core/widgets/custom_button.dart';
import 'package:system_manage/core/widgets/custom_text_field.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void showEditProfileBottomSheet(UserModel? user, BuildContext context) {
  final usernameController = TextEditingController(text: user?.username ?? "");
  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage() async {
            final XFile? image = await picker.pickImage(
              source: ImageSource.gallery,
            );
            if (image != null) {
              setState(() {
                selectedImage = File(image.path);
              });
              await context.read<ProfileCubit>().changeImage(
                selectedImage!.path,
              );

              final updatedUser = UserModel(
                uid: user!.uid,
                username: usernameController.text.trim(),
                email: user.email,
                image: selectedImage!.path,
                title: user.title,
                performance: user.performance,
              );
              context.read<UserCubit>().updateUser(updatedUser);
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppTexts.editProfile,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () async {
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() {
                        selectedImage = File(image.path);
                      });

                      await context.read<ProfileCubit>().changeImage(
                        selectedImage!.path,
                      );

                      final updatedUser = UserModel(
                        uid: user!.uid,
                        username: user.username,
                        email: user.email,
                        image: user.image,
                        title: user.title,
                        performance: user.performance,
                      );
                      context.read<UserCubit>().getUserData(user.uid);
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!) as ImageProvider
                        : (user?.image != null && user!.image!.isNotEmpty
                              ? NetworkImage(user.image!)
                              : AssetImage(AppImages.placeholder)),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                CustomTextField(controller: usernameController),
                const SizedBox(height: 12),

                BlocConsumer<ProfileCubit, ProfileState>(
                  listener: (context, state) {
                    if (state is ProfileLoaded) {
                      Toasts.displayToast(AppTexts.changedSuccUsernmae);

                      final updatedUser = UserModel(
                        uid: user!.uid,
                        username: usernameController.text.trim(),
                        email: user.email,
                        image: selectedImage?.path ?? user.image,
                        title: user.title,
                        performance: user.performance,
                      );
                      context.read<UserCubit>().updateUser(updatedUser);

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
                          : () {
                              final newUsername = usernameController.text
                                  .trim();
                              context.read<ProfileCubit>().changeUsername(
                                newUsername,
                              );
                            },
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );
}

void showChangePasswordBottomSheet(BuildContext context) {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final profileCubit = context.read<ProfileCubit>();

  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              AppTexts.changePass,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: currentPasswordController,
              obscureText: true,
              hintText: AppTexts.oldpass,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: newPasswordController,
              obscureText: true,
              hintText: AppTexts.newpass,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: confirmPasswordController,
              obscureText: true,
              hintText: AppTexts.confirmpass,
            ),
            const SizedBox(height: 20),
            BlocConsumer<ProfileCubit, ProfileState>(
              bloc: profileCubit, // explicitly use the cubit
              listener: (context, state) {
                if (state is ProfileLoaded) {
                  Toasts.displayToast(AppTexts.changedSucc);
                  Navigator.pop(context); // close bottom sheet after success
                }
                if (state is ProfileError) {
                  Toasts.displayToast(state.error);
                }
              },
              builder: (context, state) {
                return CustomButton(
                  onPressed: (state is ProfileLoading)
                      ? null
                      : () {
                          final currentPassword = currentPasswordController.text
                              .trim();
                          final newPassword = newPasswordController.text.trim();
                          final confirmPassword = confirmPasswordController.text
                              .trim();

                          if (currentPassword.isEmpty ||
                              newPassword.isEmpty ||
                              confirmPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("All fields are required"),
                              ),
                            );
                            return;
                          }

                          if (newPassword != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Passwords do not match"),
                              ),
                            );
                            return;
                          }

                          profileCubit.changePass(currentPassword, newPassword);
                        },
                  text: (state is ProfileLoading)
                      ? AppTexts.pleaseWait
                      : AppTexts.changePass,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
