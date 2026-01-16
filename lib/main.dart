import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/core/config/routes.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'core/appBlocProviders.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiBlocProvider(providers: appBlocProviders, child: const MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: AppColors.primaryColor,
        fontFamily: "font",
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primaryColor,
          selectionColor: AppColors.grey500.withOpacity(0.2),
          selectionHandleColor: AppColors.primaryColor,
        ),
        appBarTheme: AppBarTheme(backgroundColor: AppColors.primaryColor),
        actionIconTheme: ActionIconThemeData(
          backButtonIconBuilder: (context) {
            return Icon(Icons.arrow_back_rounded, color: Colors.white);
          },
        ),
      ),
      onGenerateRoute: AppRouters.onGenerateRoute,
      initialRoute: (FirebaseAuth.instance.currentUser?.uid != null)
          ? AppRoutes.userSystems
          : AppRoutes.login,
    );
  }
}
