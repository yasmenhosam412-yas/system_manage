import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/employees_cubit/employees_cubit.dart';
import 'package:system_manage/controllers/system_cubit/system_cubit.dart';
import 'package:system_manage/core/config/routes.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/models/member_model.dart';
import 'package:system_manage/views/selected_system/tabs/projects_tab/widgets/linear_progress.dart';
import 'package:system_manage/views/selected_system_owner/tabs/emploees_tab_owner/widgets/employee_card.dart';

class OwnerEmployeesTab extends StatefulWidget {
  final String systemCode;

  const OwnerEmployeesTab({super.key, required this.systemCode});

  @override
  State<OwnerEmployeesTab> createState() => _OwnerEmployeesTabState();
}

class _OwnerEmployeesTabState extends State<OwnerEmployeesTab> {
  late TextEditingController search;
  List<MemberModel> allMembers = [];
  List<MemberModel> filteredMembers = [];
  bool filterByPerformance = false;

  @override
  void initState() {
    super.initState();
    search = TextEditingController();
    search.addListener(_onSearchChanged);
    context.read<EmployeesCubit>().getEmployees(widget.systemCode);
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    List<MemberModel> temp = allMembers
        .where((e) => e.title != "Admin")
        .toList();

    if (search.text.isNotEmpty) {
      temp = temp
          .where(
            (e) => e.username.toLowerCase().contains(search.text.toLowerCase()),
          )
          .toList();
    }

    if (filterByPerformance) {
      temp = temp.where((e) => e.performance >= 70).toList();
    }

    setState(() {
      filteredMembers = temp;
    });
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<EmployeesCubit, EmployeesState>(
          builder: (context, state) {
            if (state is EmployeesLoading && allMembers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is EmployeesError) {
              return GestureDetector(
                onTap: () async {
                  await context.read<EmployeesCubit>().getEmployees(
                    widget.systemCode,
                  );
                },
                child: Center(child: Text(state.error)),
              );
            }

            if (state is EmployeesLoaded) {
              allMembers = state.employees ?? [];

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _applyFilters();
                }
              });

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<EmployeesCubit>().getEmployees(
                    widget.systemCode,
                  );
                },
                color: AppColors.primaryColor,
                backgroundColor: Colors.white,
                child: ListView(
                  padding: const EdgeInsets.all(AppPadding.medium),
                  children: [
                    Center(
                      child: Text(
                        AppTexts.Employees,
                        style: AppTextStyles.font16Black600.copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppPadding.medium),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.75,
                      child: TextField(
                        controller: search,
                        decoration: InputDecoration(
                          hintText: AppTexts.searchEmployees,
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppPadding.medium),
                    if (filteredMembers.isEmpty)
                      const Center(child: Text("No employees found"))
                    else
                      ...filteredMembers
                          .map(
                            (user) => Padding(
                              padding: const EdgeInsets.all(AppPadding.small),
                              child: EmployeeCard(user, widget.systemCode),
                            ),
                          )
                          .toList(),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
