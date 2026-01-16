import 'package:flutter/material.dart';
import 'package:system_manage/views/selected_system_owner/tabs/emploees_tab_owner/employees_tab_owner.dart';
import 'package:system_manage/views/selected_system_owner/tabs/owner_dashboard/owner_dashboard.dart';
import 'package:system_manage/views/selected_system_owner/tabs/owner_projects/owner_projects.dart';
import 'package:system_manage/views/selected_system_owner/tabs/owner_settings_tab/owner_settings.dart';
import 'package:system_manage/views/selected_system_owner/tabs/tasks_tab_owner/tasks_tab_owner.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_texts.dart';

class SelectedSystemOwner extends StatefulWidget {
  final String systemCode;

  const SelectedSystemOwner({super.key, required this.systemCode});

  @override
  State<SelectedSystemOwner> createState() => _SelectedSystemOwnerState();
}

class _SelectedSystemOwnerState extends State<SelectedSystemOwner> {
  int currentIndex = 0;
  List<Widget> screens = [];

  @override
  void initState() {
    super.initState();
    screens = [
      OwnerDashboard(systemCode: widget.systemCode),
      OwnerProjectsTab(systemCode: widget.systemCode),
      TasksTabOwner(systemCode: widget.systemCode,),
      OwnerEmployeesTab(systemCode: widget.systemCode,),
      OwnerSettings(systemCode: widget.systemCode),
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
            icon: Icon(Icons.group),
            label: AppTexts.Employees,
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
