import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:system_manage/core/config/routes.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/views/selected_system/tabs/dashboard_tab/dashboard_tab.dart';
import 'package:system_manage/views/selected_system_owner/tabs/emploees_tab_owner/employees_tab_owner.dart';
import 'package:system_manage/views/selected_system/tabs/projects_tab/projects_tab.dart';
import 'package:system_manage/views/selected_system/tabs/tasks_tab/tasks_tab.dart';

class SystemSelected extends StatefulWidget {
  final String code;

  const SystemSelected({super.key, required this.code});

  @override
  State<SystemSelected> createState() => _SystemSelectedState();
}

class _SystemSelectedState extends State<SystemSelected> {
  int currentIndex = 0;
  List<Widget> screens = [];

  @override
  void initState() {
    super.initState();
    screens = [
      DashboardTab(code: widget.code),
      ProjectsTab(code: widget.code),
      TasksTab(code: widget.code),
      GestureDetector(
        onTap: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        },
        child: Center(
          child: Text(AppTexts.logout, style: TextStyle(fontSize: 24)),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.grey500,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 0.2,
        type: BottomNavigationBarType.fixed,
        onTap: (value) => setState(() => currentIndex = value),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: AppTexts.Dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: AppTexts.Projects,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            label: AppTexts.Tasks,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppTexts.Settings,
          ),
        ],
      ),
    );
  }
}
