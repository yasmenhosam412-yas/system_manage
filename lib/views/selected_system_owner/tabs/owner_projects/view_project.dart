import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_manage/controllers/user_cubit/user_cubit.dart';
import 'package:system_manage/models/project_models.dart';
import 'package:system_manage/models/member_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_padding.dart';
import '../../../../../core/utils/text_styles.dart';

class ViewProject extends StatefulWidget {
  final ProjectModel projectModel;

  const ViewProject({super.key, required this.projectModel});

  @override
  State<ViewProject> createState() => _ViewProjectState();
}

class _ViewProjectState extends State<ViewProject> {
  @override
  void initState() {
    super.initState();
    for (var member in widget.projectModel.members) {
      context.read<UserCubit>().getUserData(member.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.projectModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project.name,
          style: AppTextStyles.font16Black600.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              title: 'Project Details',
              child: Column(
                children: [
                  _infoRow('Name', project.name),
                  _infoRow('Description', project.description),
                  _infoRow('Status', project.status),
                  _infoRow('Start Date', project.startDate),
                  _infoRow('End Date', project.endDate),
                ],
              ),
            ),

            const SizedBox(height: AppPadding.medium),

            _buildCard(
              title: 'Progress',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: project.progress / 100,
                      minHeight: 14,
                      color: AppColors.primaryColor,
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${project.progress.toStringAsFixed(1)}% completed',
                    style: AppTextStyles.font16Black600,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppPadding.medium),

            _buildCard(
              title: 'Team Members',
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  if (project.members.isEmpty) {
                    return const Text('No members assigned');
                  }
                  if (state is UserLoaded) {
                    return SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.12,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: project.members.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final member = project.members[index];
                          final user = state.users[member.uid];
                          return Column(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primaryColor
                                    .withOpacity(0.1),
                                backgroundImage:
                                    (user?.image != null &&
                                        user!.image!.isNotEmpty)
                                    ? CachedNetworkImageProvider(user.image!)
                                    : null,
                                child:
                                    (user?.image == null ||
                                        user!.image!.isEmpty)
                                    ? Text(
                                        user?.username
                                                .substring(0, 2)
                                                .toUpperCase() ??
                                            "",
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user?.username ?? "Unknown",
                                style: AppTextStyles.font16Black600,
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),

            const SizedBox(height: AppPadding.medium),

            _buildCard(
              title: 'Project Links',
              child: project.links.isEmpty
                  ? const Text('No links added')
                  : Column(
                      children: project.links.map((link) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.link,
                            color: AppColors.primaryColor,
                          ),
                          title: Text(
                            link,
                            style: AppTextStyles.font16Black600,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () async {
                            _launchUrl(link);
                          },
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: AppPadding.medium),

            _buildCard(
              title: 'Steps',
              child: project.steps.isEmpty
                  ? const Text('No steps defined')
                  : Column(
                      children: project.steps.asMap().entries.map((entry) {
                        int idx = entry.key;
                        String step = entry.value;
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryColor.withOpacity(
                              0.1,
                            ),
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            step,
                            style: AppTextStyles.font16Black600,
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
