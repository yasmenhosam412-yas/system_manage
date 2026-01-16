import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:system_manage/controllers/requests/requests_cubit.dart';
import 'package:system_manage/controllers/system_cubit/system_cubit.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_images.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/core/utils/toasts.dart';
import 'package:system_manage/core/widgets/custom_button.dart';
import 'package:system_manage/models/user_model.dart';

class RequestsScreen extends StatefulWidget {
  final String systemCode;

  const RequestsScreen({super.key, required this.systemCode});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final Map<String, String> _selectedDepartments = {};

  @override
  void initState() {
    super.initState();
    context.read<RequestsCubit>().getRequests(widget.systemCode);
    context.read<SystemCubit>().getSystemMembersAndDeps(widget.systemCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          AppTexts.joinRequests,
          style: AppTextStyles.font16Black600.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<RequestsCubit, RequestsState>(
        listener: (context, state) {
          if (state is RequestsUsersLoaded && state.actionMessage != null) {
            Toasts.displayToast(state.actionMessage!);
          }
        },
        builder: (context, state) {
          if (state is RequestsUsersLoaded) {
            if (state.isRequestLoading) {
              return Skeletonizer(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  itemBuilder: (_, __) => _buildSkeletonCard(),
                ),
              );
            }

            if (state.users.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final request = state.users[index];
                return _buildRequestCard(request, state.isActionLoading);
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildRequestCard(UserModel request, bool isActionLoading) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                  backgroundImage:
                      request.image == null || request.image!.isEmpty
                      ? AssetImage(AppImages.placeholder)
                      : NetworkImage(request.image!) as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.username,
                        style: AppTextStyles.font16Black600,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.email,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Requested as: ${request.title}",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      _buildDepartmentDropdown(request.uid),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isActionLoading
                        ? null
                        : () {
                            if (!_selectedDepartments.containsKey(
                              request.uid,
                            )) {
                              Toasts.displayToast(AppTexts.pleaseSelectDepart);
                              return;
                            }

                            context.read<RequestsCubit>().rejectRequest(
                              systemCode: widget.systemCode,
                              userUid: request.uid,
                            );

                            setState(() {
                              _selectedDepartments.remove(request.uid);
                            });
                          },
                    child: Text(
                      isActionLoading ? AppTexts.pleaseWait : AppTexts.reject,
                      style: AppTextStyles.font16Black600.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isActionLoading
                        ? null
                        : () {
                            if (!_selectedDepartments.containsKey(
                              request.uid,
                            )) {
                              Toasts.displayToast(AppTexts.pleaseSelectDepart);
                              return;
                            }

                            context.read<RequestsCubit>().acceptRequest(
                              systemCode: widget.systemCode,
                              user: request,
                              depart: _selectedDepartments[request.uid]!,
                            );

                            setState(() {
                              _selectedDepartments.remove(request.uid);
                            });
                          },
                    child: Text(
                      isActionLoading ? AppTexts.pleaseWait : AppTexts.accept,
                      style: AppTextStyles.font16Black600.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown(String userUid) {
    return BlocBuilder<SystemCubit, SystemState>(
      builder: (context, state) {
        if (state is SystemLoaded) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDepartments[userUid],
                dropdownColor: Colors.white,
                items: state.departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDepartments[userUid] = value!;
                  });
                },
                hint: Text(
                  AppTexts.pleaseSelectDepart,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ),
          );
        }
        if (state is SystemLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const ListTile(
        leading: CircleAvatar(radius: 26),
        title: Text(AppTexts.pleaseWait),
        subtitle: Text(AppTexts.pleaseWait),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No pending requests",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
