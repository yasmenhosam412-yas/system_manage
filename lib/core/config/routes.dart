import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:system_manage/models/project_models.dart';
import 'package:system_manage/views/select_of_systems/create_system_screen.dart';
import 'package:system_manage/views/select_of_systems/select_system_screen.dart';
import 'package:system_manage/views/auth/forgot_password_screen.dart';
import 'package:system_manage/views/selected_system/system_selected.dart';
import 'package:system_manage/views/selected_system_owner/selected_system_owner.dart';
import 'package:system_manage/views/selected_system_owner/tabs/owner_dashboard/actions/add_anncounce.dart';
import 'package:system_manage/views/selected_system_owner/tabs/owner_dashboard/actions/add_project.dart';
import 'package:system_manage/views/selected_system_owner/tabs/owner_dashboard/actions/add_task.dart';
import 'package:system_manage/views/selected_system_owner/tabs/owner_projects/view_project.dart';
import 'package:system_manage/views/selected_system_owner/tabs/owner_settings_tab/requests_screen.dart';
import 'package:system_manage/views/selected_system_owner/tabs/owner_settings_tab/system_info.dart';

import '../../views/auth/login_screen.dart';
import '../../views/auth/signup_screen.dart';

class AppRoutes {
  static const String login = "/login";
  static const String signup = "/signup";
  static const String forgot_pass = "/forgot_pass";
  static const String userSystems = "/userSystems";
  static const String createUserSystem = "/createUserSystem";
  static const String systemSelected = "/systemSelected";
  static const String systemSelectedOwnerScreen = "/systemSelectedOwnerScreen";
  static const String requests = "/requests";
  static const String addProject = "/addProject";
  static const String addAnncounce = "/addAnncounce";
  static const String viewProject = "/viewProject";
  static const String addTask = "/addTask";
  static const String systmeInfo = "/systmeInfo";
}

class AppRouters {
  static PageRoute onGenerateRoute(RouteSettings? settings) {
    Widget page;

    switch (settings?.name) {
      case AppRoutes.login:
        page = LoginScreen();
        break;
      case AppRoutes.signup:
        page = SignupScreen();
        break;
      case AppRoutes.forgot_pass:
        page = ForgotPasswordScreen();
        break;
      case AppRoutes.userSystems:
        final uid = settings?.arguments as String;
        page = SelectSystemScreen(uid: uid);
        break;
      case AppRoutes.createUserSystem:
        page = CreateSystemScreen();
        break;
      case AppRoutes.systemSelected:
        final args = settings?.arguments as String;
        page = SystemSelected(code: args,);
        break;
      case AppRoutes.systemSelectedOwnerScreen:
        final args = settings?.arguments as String;

        page = SelectedSystemOwner(systemCode: args);
        break;
      case AppRoutes.requests:
        final args = settings?.arguments as String;
        page = RequestsScreen(systemCode: args);
        break;
      case AppRoutes.addProject:
        final args = settings?.arguments as Map<String, dynamic>;
        page = AddProject(
          systemCode: args['systemCode'],
          startTime: args['start'],
          endTime: args['end'],
          docId: args['docId'],
          projectStatus: args['projectStatus'],
          projectProgress: args['projectProgress'],
          projectMembers: args['projectMembers'],
          date: args['date'],
          projectName: args['projectName'],
          projectDesc: args['desc'],
          links: args['links'],
          steps: args['steps'],
        );
        break;
      case AppRoutes.addAnncounce:
        final args = settings?.arguments as String;
        page = AddAnncounce(systemCode: args);
        break;
      case AppRoutes.viewProject:
        final args = settings?.arguments as ProjectModel;
        page = ViewProject(projectModel: args);
        break;
      case AppRoutes.addTask:
        final args = settings?.arguments as String;
        page = AddTask(systemCode: args);
        break;
      case AppRoutes.systmeInfo:
        final args = settings?.arguments as String;
        page = SystemInfo(code: args);
        break;
      default:
        page = Scaffold(body: Center(child: Text("Unknown Route")));
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const beginOffset = Offset(1.0, 0.0);
        const endOffset = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(
          begin: beginOffset,
          end: endOffset,
        ).chain(CurveTween(curve: curve));

        var fadeTween = Tween<double>(begin: 0, end: 1);

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
