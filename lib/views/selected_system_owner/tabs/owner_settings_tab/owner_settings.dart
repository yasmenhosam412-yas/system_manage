import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/user_cubit/user_cubit.dart';
import 'package:system_manage/core/config/routes.dart';
import 'package:system_manage/core/utils/app_images.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/models/user_model.dart';

import 'methods_helpers/methods.dart';

class OwnerSettings extends StatefulWidget {
  final String systemCode;

  const OwnerSettings({super.key, required this.systemCode});

  @override
  State<OwnerSettings> createState() => _OwnerSettingsState();
}

class _OwnerSettingsState extends State<OwnerSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTexts.ownerSettings,
          style: AppTextStyles.font16Black600.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state is UserLoaded) {
                  return _buildProfileCard(
                    state.users[FirebaseAuth.instance.currentUser!.uid],
                  );
                }
                return SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),

            _buildSectionTitle(AppTexts.account),
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: AppTexts.editProfile,
              onTap: () {
                final user = (context.read<UserCubit>().state as UserLoaded)
                    .users[FirebaseAuth.instance.currentUser!.uid];
                showEditProfileBottomSheet(user, context);
              },
            ),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: AppTexts.changePass,
              onTap: () {
                showChangePasswordBottomSheet(context);
              },
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(AppTexts.system),
            _buildSettingsTile(
              icon: Icons.business_outlined,
              title: AppTexts.systemInfo,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.systmeInfo,
                  arguments: widget.systemCode,
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.group_outlined,
              title: AppTexts.manageRequests,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.requests,
                  arguments: widget.systemCode,
                );
              },
            ),

            const SizedBox(height: 24),

            _buildSectionTitle("Danger Zone"),
            _buildSettingsTile(
              icon: Icons.logout,
              title: "Logout",
              iconColor: Colors.redAccent,
              textColor: Colors.redAccent,
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: (user?.image != null && user!.image!.isNotEmpty)
                ? NetworkImage(user.image!) as ImageProvider
                : AssetImage(AppImages.placeholder),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.username ?? AppTexts.unknown,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  user?.email ?? AppTexts.unknown,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.black87),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
