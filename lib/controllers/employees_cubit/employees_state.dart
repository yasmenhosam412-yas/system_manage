part of 'employees_cubit.dart';

@immutable
sealed class EmployeesState {}

final class EmployeesInitial extends EmployeesState {}

final class EmployeesLoading extends EmployeesState {}

final class EmployeesLoaded extends EmployeesState {
  final List<MemberModel> employees;
  final List<String> projects;

  final Map<String, List<Map<String, dynamic>>> tasks;

  EmployeesLoaded({
    required this.employees,
    this.projects = const [],
    this.tasks = const {},
  });

  EmployeesLoaded copyWith({
    List<MemberModel>? employees,
    List<String>? projects,
    Map<String, List<Map<String, dynamic>>>? tasks,
  }) {
    return EmployeesLoaded(
      employees: employees ?? this.employees,
      projects: projects ?? this.projects,
      tasks: tasks ?? this.tasks,
    );
  }
}

final class EmployeesError extends EmployeesState {
  final String error;

  EmployeesError({required this.error});

  EmployeesError copyWith({String? error}) {
    return EmployeesError(
      error: error ?? this.error,
    );
  }
}
