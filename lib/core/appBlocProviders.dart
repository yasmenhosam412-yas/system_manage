import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:system_manage/controllers/announce_cubit/announce_cubit.dart';
import 'package:system_manage/controllers/attendance_cubit/attendance_cubit.dart';
import 'package:system_manage/controllers/auth_cubit/auth_cubit.dart';
import 'package:system_manage/controllers/create_system_cubit/create_system_cubit.dart';
import 'package:system_manage/controllers/employees_cubit/employees_cubit.dart';
import 'package:system_manage/controllers/preformance_cubit/performance_cubit.dart';
import 'package:system_manage/controllers/profile_cubit/profile_cubit.dart';
import 'package:system_manage/controllers/projects_cubit/projects_cubit.dart';
import 'package:system_manage/controllers/requests/requests_cubit.dart';
import 'package:system_manage/controllers/system_cubit/system_cubit.dart';
import 'package:system_manage/controllers/tasks_cubit/tasks_cubit.dart';
import 'package:system_manage/controllers/user_cubit/user_cubit.dart';
import 'package:system_manage/controllers/user_projects/user_projects_cubit.dart';
import 'package:system_manage/services/auth_service.dart';
import 'package:system_manage/services/create_system_service.dart';
import 'package:system_manage/services/profile_service.dart';
import 'package:system_manage/services/project_service.dart';
import 'package:system_manage/services/system_service.dart';
import 'package:system_manage/services/user_data_service.dart';
import 'package:system_manage/services/user_services.dart';

List<SingleChildWidget> appBlocProviders = [
  BlocProvider(create: (context) => AuthCubit(AuthService())),
  BlocProvider(create: (context) => CreateSystemCubit(CreateSystemService())),
  BlocProvider(create: (context) => UserCubit(UserDataService())),
  BlocProvider(create: (context) => SystemCubit(SystemService())),
  BlocProvider(create: (context) => RequestsCubit(CreateSystemService())),
  BlocProvider(create: (context) => AnnounceCubit(SystemService())),
  BlocProvider(create: (context) => ProjectsCubit(ProjectService())),
  BlocProvider(create: (context) => TasksCubit(SystemService())),
  BlocProvider(create: (context) => EmployeesCubit(SystemService())),
  BlocProvider(create: (context) => ProfileCubit(ProfileService())),
  BlocProvider(create: (context) => AttendanceCubit(UserService())),
  BlocProvider(create: (context) => UserProjectsCubit(UserService())),
  BlocProvider(create: (context) => PerformanceCubit(UserService())),
];
