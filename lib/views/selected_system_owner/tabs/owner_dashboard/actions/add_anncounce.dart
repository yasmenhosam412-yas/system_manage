import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/announce_cubit/announce_cubit.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_regrex.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/text_styles.dart';
import 'package:system_manage/core/utils/toasts.dart';
import 'package:system_manage/core/widgets/custom_button.dart';
import 'package:system_manage/core/widgets/custom_text_field.dart';
import '../../../../../controllers/system_cubit/system_cubit.dart';
import '../../../../../controllers/user_cubit/user_cubit.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../models/member_model.dart';

class AddAnncounce extends StatefulWidget {
  final String systemCode;

  const AddAnncounce({super.key, required this.systemCode});

  @override
  State<AddAnncounce> createState() => _AddAnncounceState();
}

class _AddAnncounceState extends State<AddAnncounce> {
  Map<String, List<MemberModel>> _selectedMembersByDept = {};
  Map<String, String> _memberNames = {};
  int _selectedDepartmentIndex = 0;
  List<MemberModel> _filteredMembers = [];

  TextEditingController name = TextEditingController();
  TextEditingController desc = TextEditingController();
  final GlobalKey<FormState> _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<SystemCubit>().getSystemMembersAndDeps(widget.systemCode);

    context.read<UserCubit>().stream.listen((state) {
      if (state is UserLoaded) {
        bool updated = false;
        state.users.forEach((uid, user) {
          if (_memberNames[uid] != user.username) {
            _memberNames[uid] = user.username;
            updated = true;
          }
        });
        if (updated) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Form(
              key: _globalKey,
              child: Column(
                children: [
                  SizedBox(height: AppPadding.medium),
                  Center(
                    child: Text(
                      AppTexts.addAnnounce,
                      style: AppTextStyles.font16Black600.copyWith(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: AppPadding.medium),
                  CustomTextField(
                    controller: name,
                    hintText: AppTexts.titleA,
                    validator: (value) =>
                        AppRegex.validateNotEmpty(value, fieldName: "title"),
                  ),
                  SizedBox(height: AppPadding.medium),
                  CustomTextField(
                    controller: desc,
                    hintText: AppTexts.titleB,
                    maxLines: 5,
                    validator: (value) =>
                        AppRegex.validateNotEmpty(value, fieldName: "subtitle"),
                  ),
                  SizedBox(height: AppPadding.medium),
                  Text(
                    AppTexts.selectMembers,
                    style: AppTextStyles.font16Black600.copyWith(fontSize: 20),
                  ),
                  SizedBox(height: AppPadding.medium),
                  BlocBuilder<SystemCubit, SystemState>(
                    builder: (context, systemState) {
                      if (systemState is SystemLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      }

                      if (systemState is SystemError) {
                        return Center(child: Text(systemState.error));
                      }

                      if (systemState is SystemLoaded) {
                        _fetchMemberNames(systemState.members);
                        if (_filteredMembers.isEmpty &&
                            systemState.departments.isNotEmpty) {
                          _filterMembersByDepartment(
                            systemState.departments[_selectedDepartmentIndex],
                            systemState.members,
                          );
                        }

                        final currentDept =
                            systemState.departments[_selectedDepartmentIndex];
                        final selectedForDept =
                            _selectedMembersByDept[currentDept] ?? [];
                        final isAllSelected =
                            selectedForDept.length == _filteredMembers.length &&
                            _filteredMembers.isNotEmpty;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: AppPadding.small,
                              children: List.generate(
                                systemState.departments.length,
                                (index) {
                                  bool isSelected =
                                      index == _selectedDepartmentIndex;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDepartmentIndex = index;
                                        _filterMembersByDepartment(
                                          systemState.departments[index],
                                          systemState.members,
                                        );
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: isSelected
                                            ? AppColors.primaryColor
                                            : Colors.grey.shade200,
                                      ),
                                      child: Text(
                                        systemState.departments[index],
                                        style: AppTextStyles.font16Black600
                                            .copyWith(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (_filteredMembers.isNotEmpty)
                              CheckboxListTile(
                                title: Text(AppTexts.selectAll),
                                value: isAllSelected,
                                activeColor: AppColors.primaryColor,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedMembersByDept[currentDept] =
                                          List.from(_filteredMembers);
                                    } else {
                                      _selectedMembersByDept[currentDept] = [];
                                    }
                                  });
                                },
                              ),

                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 250),
                              child: SingleChildScrollView(
                                child: _filteredMembers.isEmpty
                                    ? Center(child: Text(AppTexts.noMemsYet))
                                    : Column(
                                        children: _filteredMembers.map((member) {
                                          final username =
                                              _memberNames[member.uid] ??
                                              AppTexts.loading;
                                          final isSelected = selectedForDept
                                              .contains(member);
                                          return CheckboxListTile(
                                            title: Text(username),
                                            value: isSelected,
                                            activeColor: AppColors.primaryColor,
                                            onChanged: (val) {
                                              setState(() {
                                                final deptList =
                                                    _selectedMembersByDept[currentDept] ??
                                                    [];
                                                if (val == true) {
                                                  if (!deptList.contains(member))
                                                    deptList.add(member);
                                                } else {
                                                  deptList.remove(member);
                                                }
                                                _selectedMembersByDept[currentDept] =
                                                    deptList;
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                              ),
                            ),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                 SizedBox(height: AppPadding.medium,),
                  BlocConsumer<AnnounceCubit, AnnounceState>(
                    listener: (context, state) {
                      if (state is AnnounceLoaded) {
                        Toasts.displayToast(AppTexts.added);
                        Navigator.pop(context);
                      }
                      if (state is AnnounceError) {
                        Toasts.displayToast(state.error);
                      }
                    },
                    builder: (context, state) {
                      if (state is AnnounceLoading) {
                        return CustomButton(
                          text: AppTexts.pleaseWait,
                          onPressed: null,
                        );
                      }
                      return CustomButton(
                        text: AppTexts.post,
                        onPressed: () {
                          if (_globalKey.currentState!.validate()) {
                            final allSelectedMembers = _selectedMembersByDept
                                .values
                                .expand((e) => e)
                                .toList();
                            if (allSelectedMembers.isEmpty) {
                              Toasts.displayToast(AppTexts.pleaseSelectMember);
                              return;
                            }

                            context.read<AnnounceCubit>().addAnncounce(
                              widget.systemCode,
                              name.text,
                              desc.text,
                              allSelectedMembers,
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _fetchMemberNames(List<MemberModel> members) {
    for (var member in members) {
      if (!_memberNames.containsKey(member.uid)) {
        context.read<UserCubit>().getUserData(member.uid);
      }
    }
  }

  void _filterMembersByDepartment(
    String department,
    List<MemberModel> allMembers,
  ) {
    _filteredMembers = allMembers
        .where((m) => m.department == department)
        .toList();
  }
}
