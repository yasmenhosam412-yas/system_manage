import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:system_manage/controllers/create_system_cubit/create_system_cubit.dart';
import 'package:system_manage/controllers/requests/requests_cubit.dart';
import 'package:system_manage/controllers/user_cubit/user_cubit.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_images.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_regrex.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/core/utils/toasts.dart';
import 'package:system_manage/core/widgets/custom_button.dart';
import 'package:system_manage/core/widgets/custom_text_field.dart';
import 'package:system_manage/models/user_model.dart';

import '../../core/config/routes.dart';

class SelectSystemScreen extends StatefulWidget {
  final String uid;

  const SelectSystemScreen({super.key, required this.uid});

  @override
  State<SelectSystemScreen> createState() => _SelectSystemScreenState();
}

class _SelectSystemScreenState extends State<SelectSystemScreen> {
  late TextEditingController systemCode;
  final GlobalKey<FormState> _formKey = GlobalKey();
  DateTime? lastBackPressTime;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    systemCode = TextEditingController();
    context.read<UserCubit>().getUserData(widget.uid);
    context.read<CreateSystemCubit>().getSystems(widget.uid);
  }

  @override
  void dispose() {
    super.dispose();
    systemCode.dispose();
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (lastBackPressTime == null ||
        now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
      lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppTexts.pressBackToLogin),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryColor,
        ),
      );
      return false;
    }
    Navigator.popAndPushNamed(context, AppRoutes.login);
    FirebaseAuth.instance.signOut();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            AppTexts.yourSystem,
            style: AppTextStyles.font16Black600.copyWith(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppPadding.medium),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: AppPadding.medium),
                Form(
                  key: _formKey,
                  child: BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      if (state is UserLoading) {
                        return Skeletonizer(
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: systemCode,
                                hintText: AppTexts.yourSystemCode,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  return AppRegex.validateNotEmpty(
                                    value,
                                    fieldName: "code",
                                  );
                                },
                              ),
                              SizedBox(height: AppPadding.medium),
                              CustomButton(
                                text: AppTexts.joinButtonText,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {}
                                },
                              ),
                            ],
                          ),
                        );
                      }
                      if (state is UserLoaded) {
                        userModel = state.users['${widget.uid}'];
                        return Column(
                          children: [
                            CustomTextField(
                              controller: systemCode,
                              hintText: AppTexts.yourSystemCode,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                return AppRegex.validateNotEmpty(
                                  value,
                                  fieldName: "code",
                                );
                              },
                            ),
                            SizedBox(height: AppPadding.medium),
                            BlocConsumer<RequestsCubit, RequestsState>(
                              listener: (context, state) {
                                if (state is RequestsActionCompleted) {
                                  Toasts.displayToast(state.message);
                                  if (state.success) systemCode.clear();
                                }
                              },
                              builder: (context, state) {
                                final isLoading =
                                    state is RequestsActionLoading;

                                return CustomButton(
                                  text: isLoading
                                      ? AppTexts.pleaseWait
                                      : AppTexts.joinButtonText,
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context
                                                .read<RequestsCubit>()
                                                .requestJoinSystem(
                                                  systemCode: systemCode.text
                                                      .trim(),
                                                  username:
                                                      userModel?.username ?? "",
                                                  image: userModel?.image ?? "",
                                                  email: userModel?.email ?? "",
                                                  jopTitle:
                                                      userModel?.title ?? "",
                                                  prefomance:
                                                      userModel?.performance ??
                                                      0,
                                                );
                                          }
                                        },
                                );
                              },
                            ),
                          ],
                        );
                      }

                      if (state is UserError) {
                        return Center(child: Text(state.error));
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
                SizedBox(height: AppPadding.medium),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppColors.grey800, thickness: 1),
                    ),
                    Text(AppTexts.orText, style: AppTextStyles.font16Black600),
                    Expanded(
                      child: Divider(color: AppColors.grey800, thickness: 1),
                    ),
                  ],
                ),
                SizedBox(height: AppPadding.medium),
                BlocBuilder<CreateSystemCubit, CreateSystemState>(
                  builder: (context, state) {
                    if (state is GetSystemLoading) {
                      return Skeletonizer(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: 3 + 1,
                          itemBuilder: (context, index) {
                            if (index == 3) {
                              return InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.createUserSystem,
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppPadding.small,
                                    ),
                                    border: Border.all(
                                      color: AppColors.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: AppColors.primaryColor,
                                    size: 40,
                                  ),
                                ),
                              );
                            }
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(
                                  AppPadding.small,
                                ),
                                image: DecorationImage(
                                  image: AssetImage(AppImages.placeholder),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }

                    if (state is GetSystemLoaded) {
                      if (state.systems.isNotEmpty) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: state.systems.length + 1,
                          itemBuilder: (context, index) {
                            if (index == state.systems.length) {
                              return InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.createUserSystem,
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppPadding.small,
                                    ),
                                    border: Border.all(
                                      color: AppColors.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: AppColors.primaryColor,
                                    size: 40,
                                  ),
                                ),
                              );
                            }
                            return GestureDetector(
                              onTap: () {
                                final myId = widget.uid;
                                if (state.systems[index].systemOwner == myId) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.systemSelectedOwnerScreen,
                                    (route) {
                                      return false;
                                    },
                                    arguments: state.systems[index].systemCode,
                                  );
                                } else {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.systemSelected,
                                    (route) {
                                      return false;
                                    },
                                    arguments: state.systems[index].systemCode,
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppPadding.small,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        AppPadding.small,
                                      ),
                                      child: Stack(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: state
                                                .systems[index]
                                                .systemImage,
                                            fit: BoxFit.cover,
                                            height:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).height *
                                                0.21,
                                            width: double.infinity,
                                            placeholder: (context, url) =>
                                                Container(
                                                  height:
                                                      MediaQuery.sizeOf(
                                                        context,
                                                      ).height *
                                                      0.21,
                                                  color: Colors.grey.shade200,
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: AppColors
                                                              .primaryColor,
                                                        ),
                                                  ),
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Container(
                                                  height:
                                                      MediaQuery.sizeOf(
                                                        context,
                                                      ).height *
                                                      0.21,
                                                  color: Colors.grey.shade200,
                                                  child: Icon(
                                                    Icons.error_outline,
                                                    color:
                                                        AppColors.primaryColor,
                                                    size: 40,
                                                  ),
                                                ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                    horizontal: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.black.withOpacity(
                                                      0.6,
                                                    ),
                                                    Colors.transparent,
                                                  ],
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    AppPadding.small,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    AppPadding.small,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                state.systems[index].systemName,
                                                style: AppTextStyles
                                                    .font16Black600
                                                    .copyWith(
                                                      color: Colors.white,
                                                    ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else if (state.systems.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              SizedBox(height: AppPadding.medium),
                              Image.asset(
                                AppImages.empty_box,
                                width: 85,
                                height: 85,
                              ),
                              SizedBox(height: AppPadding.medium),
                              Text(
                                AppTexts.noSystemsYet,
                                style: AppTextStyles.font16Black600,
                              ),
                              SizedBox(height: AppPadding.medium),
                              CustomButton(
                                text: AppTexts.createSystem,
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.createUserSystem,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    }

                    if (state is GetSystemError) {
                      return Center(child: Text(state.error));
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
