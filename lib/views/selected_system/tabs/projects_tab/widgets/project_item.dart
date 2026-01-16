import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/projects_cubit/projects_cubit.dart';
import 'package:system_manage/controllers/user_cubit/user_cubit.dart';
import 'package:system_manage/core/config/routes.dart';
import 'package:system_manage/core/utils/app_images.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/models/member_model.dart';
import 'package:system_manage/models/project_models.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_padding.dart';
import '../../../../../core/utils/text_styles.dart';
import 'linear_progress.dart';

class ProjectItem extends StatefulWidget {
  final String projectName;
  final String projectDesc;
  final String projectStatus;
  final double projectProgress;
  final List<String> projectMembers;
  final List<MemberModel> members;
  final List<String> steps;
  final List<String> links;
  final String date;
  final String systemCode;
  final String docId;
  final String startTime;
  final String endTime;
  final bool isAdmin;

  const ProjectItem({
    super.key,
    required this.projectName,
    required this.projectStatus,
    required this.projectProgress,
    required this.projectMembers,
    required this.date,
    required this.systemCode,
    required this.docId,
    required this.startTime,
    required this.endTime,
    required this.projectDesc,
    required this.steps,
    required this.links,
    required this.members,
    required this.isAdmin,
  });

  @override
  State<ProjectItem> createState() => _ProjectItemState();
}

class _ProjectItemState extends State<ProjectItem> {
  final GlobalKey _menuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(AppPadding.small),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppPadding.small),
          border: Border.all(color: AppColors.grey200, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.projectName, style: AppTextStyles.font16Black600),
                Spacer(),
                IconButton(
                  key: _menuKey,
                  onPressed: () async {
                    final RenderBox button =
                        _menuKey.currentContext!.findRenderObject()
                            as RenderBox;
                    final RenderBox overlay =
                        Overlay.of(context).context.findRenderObject()
                            as RenderBox;

                    final Offset position = button.localToGlobal(
                      Offset.zero,
                      ancestor: overlay,
                    );

                    final value = await showMenu(
                      color: Colors.white,
                      context: context,
                      position: RelativeRect.fromLTRB(
                        position.dx,
                        position.dy + button.size.height,
                        position.dx + button.size.width,
                        0,
                      ),
                      items: (widget.isAdmin)
                          ? [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(AppTexts.Edit),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(AppTexts.Delete),
                              ),
                              PopupMenuItem(
                                value: 'view',
                                child: Text(AppTexts.View),
                              ),
                            ]
                          : [
                              PopupMenuItem(
                                value: 'view',
                                child: Text(AppTexts.View),
                              ),
                            ],
                    );

                    if (value == 'edit') {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.addProject,
                        arguments: {
                          'systemCode': widget.systemCode,
                          'docId': widget.docId,
                          'projectName': widget.projectName,
                          'projectStatus': widget.projectStatus,
                          'projectProgress': widget.projectProgress,
                          'projectMembers': widget.projectMembers,
                          'date': widget.date,
                          "start": widget.startTime,
                          "end": widget.endTime,
                          "desc": widget.projectDesc,
                          "steps": widget.steps,
                          "links": widget.links,
                        },
                      );
                    } else if (value == 'delete') {
                      context.read<ProjectsCubit>().deleteProject(
                        systemCode: widget.systemCode,
                        projectId: widget.docId,
                      );
                    } else if (value == 'view') {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.viewProject,
                        arguments: ProjectModel(
                          projectId: widget.docId,
                          name: widget.projectName,
                          description: widget.projectDesc,
                          startDate: widget.startTime,
                          endDate: widget.endTime,
                          status: widget.projectStatus,
                          members: widget.members,
                          links: widget.links,
                          steps: widget.steps,
                          progress: widget.projectProgress,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.more_vert, color: Colors.grey),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: getBgColor(widget.projectStatus),
                borderRadius: BorderRadius.circular(AppPadding.medium),
              ),
              child: Text(
                widget.projectStatus,
                style: AppTextStyles.font16Black600.copyWith(
                  color: getTextColor(widget.projectStatus),
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: AppPadding.small),
            LinearPercentIndicator(
              percent: widget.projectProgress,
              color: getTextColor(widget.projectStatus),
              title: "Progress",
            ),
            Divider(color: AppColors.grey200, thickness: 1),
            Row(
              children: [
                Row(
                  children: List.generate(widget.projectMembers.length, (
                    index,
                  ) {
                    final member = widget.members[index];

                    return Transform.translate(
                      offset: Offset(-index * 12, 0),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: (member.image.isNotEmpty)
                            ? CachedNetworkImageProvider(member.image)
                            : null,
                        child: (member.image.isEmpty)
                            ? Text(
                                member.username.substring(0, 2).toUpperCase() ??
                                    "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    );
                  }),
                ),
                Spacer(),
                Text(widget.date, style: AppTextStyles.font16Black600),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color getTextColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Active":
        return Colors.blue;
      case "In Progress":
        return Colors.orange;
      case "Stopped":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getBgColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green.shade100;
      case "Active":
        return Colors.blue.shade100;
      case "In Progress":
        return Colors.orange.shade100;
      case "Stopped":
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}
