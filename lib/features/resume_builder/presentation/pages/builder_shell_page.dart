import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_language_cubit.dart';
import '../../domain/entities/resume_language.dart';
import '../bloc/builder/builder_bloc.dart';
import '../bloc/builder/builder_event.dart';
import '../bloc/builder/builder_state.dart';
import '../widgets/section_forms/contact_form.dart';
import '../widgets/section_forms/education_form.dart';
import '../widgets/section_forms/experience_form.dart';
import '../widgets/section_forms/hobbies_form.dart';
import '../widgets/section_forms/languages_form.dart';
import '../widgets/section_forms/profile_form.dart';
import '../widgets/section_forms/projects_form.dart';
import '../widgets/section_forms/skills_form.dart';

/// Main shell page for the resume builder with tab navigation
class BuilderShellPage extends StatefulWidget {
  final String? draftId;

  const BuilderShellPage({super.key, this.draftId});

  @override
  State<BuilderShellPage> createState() => _BuilderShellPageState();
}

class _BuilderShellPageState extends State<BuilderShellPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: BuilderSection.values.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      context.read<BuilderBloc>().add(
        BuilderSectionChanged(_tabController.index),
      );
    }
  }

  void _showRenameDialog(BuildContext context, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);
    final appLanguage = context.read<AppLanguageCubit>().state;
    final strings = AppStrings(appLanguage);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.renameResume),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: strings.resumeName,
            hintText: strings.enterResumeName,
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              context.read<BuilderBloc>().add(
                BuilderTitleUpdated(value.trim()),
              );
              Navigator.of(dialogContext).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                context.read<BuilderBloc>().add(BuilderTitleUpdated(newTitle));
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(strings.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BuilderBloc, BuilderState>(
      listener: (context, state) {
        // Sync tab controller with bloc state
        if (state is BuilderLoaded) {
          if (_tabController.index != state.currentSection.index) {
            _tabController.animateTo(state.currentSection.index);
          }

          // Handle export error
          if (state.exportError != null) {
            _showExportErrorDialog(context, state.exportError!);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(body: _buildBody(context, state));
      },
    );
  }

  Widget _buildBody(BuildContext context, BuilderState state) {
    if (state is BuilderInitial || state is BuilderLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BuilderError) {
      return _buildErrorView(context, state);
    }

    if (state is BuilderLoaded) {
      return _buildMainContent(context, state);
    }

    if (state is BuilderExporting) {
      return _buildExportingView();
    }

    return const SizedBox.shrink();
  }

  Widget _buildMainContent(BuildContext context, BuilderLoaded state) {
    return Column(
      children: [
        // Custom Header with progress
        _buildHeader(context, state),

        // Section Tabs
        _buildSectionTabs(context, state),

        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: BuilderSection.values.map((section) {
              return _buildSectionContent(context, state, section);
            }).toList(),
          ),
        ),

        // Navigation buttons
        _buildNavigationButtons(context, state),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, BuilderLoaded state) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _showRenameDialog(context, state.draft.title),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      state.draft.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${state.draft.completionPercentage.toInt()}% complete',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (state.isSaving)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (state.hasUnsavedChanges)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Unsaved',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Language Switcher
              _buildLanguageSwitcher(context, state),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'Preview',
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/preview',
                    arguments: {
                      'draft': state.draft,
                      'language': state.uiLanguage,
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.draft.completionPercentage / 100,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context, BuilderLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ResumeLanguage.values.map((lang) {
          final isSelected = state.uiLanguage == lang;
          return GestureDetector(
            onTap: () =>
                context.read<BuilderBloc>().add(BuilderUILanguageChanged(lang)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                lang == ResumeLanguage.english ? 'EN' : 'TH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTabs(BuildContext context, BuilderLoaded state) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: BuilderSection.values.map((section) {
          final isCompleted = _isSectionCompleted(state, section);
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCompleted)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 10,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(_getSectionIcon(section), size: 18),
                if (!isCompleted) const SizedBox(width: 6),
                Text(
                  section.localizedTitle(state.uiLanguage),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isSectionCompleted(BuilderLoaded state, BuilderSection section) {
    switch (section) {
      case BuilderSection.profile:
        return state.draft.profile.isNotEmpty;
      case BuilderSection.contact:
        return state.draft.contact.isNotEmpty;
      case BuilderSection.experience:
        return state.draft.experiences.isNotEmpty;
      case BuilderSection.education:
        return state.draft.educations.isNotEmpty;
      case BuilderSection.skills:
        return state.draft.skills.isNotEmpty;
      case BuilderSection.projects:
        return state.draft.projects.isNotEmpty;
      case BuilderSection.languages:
        return state.draft.languages.isNotEmpty;
      case BuilderSection.hobbies:
        return state.draft.hobbies.isNotEmpty;
    }
  }

  Widget _buildSectionContent(
    BuildContext context,
    BuilderLoaded state,
    BuilderSection section,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section description
          _buildSectionDescription(section, state.uiLanguage),
          const SizedBox(height: 16),
          // Section form
          _buildSectionForm(context, state, section),
          const SizedBox(height: 80), // Space for navigation buttons
        ],
      ),
    );
  }

  Widget _buildSectionDescription(
    BuilderSection section,
    ResumeLanguage language,
  ) {
    final descriptionsEn = {
      BuilderSection.profile:
          'Add your personal information and professional summary.',
      BuilderSection.contact: 'How can employers reach you?',
      BuilderSection.experience:
          'List your work history, starting with the most recent.',
      BuilderSection.education: 'Add your educational background.',
      BuilderSection.skills: 'Highlight your technical and soft skills.',
      BuilderSection.projects: 'Showcase your notable projects.',
      BuilderSection.languages: 'List the languages you speak.',
      BuilderSection.hobbies: 'Share your interests and hobbies.',
    };

    final descriptionsTh = {
      BuilderSection.profile: 'เพิ่มข้อมูลส่วนตัวและสรุปประวัติการทำงาน',
      BuilderSection.contact: 'นายจ้างจะติดต่อคุณได้อย่างไร?',
      BuilderSection.experience: 'ระบุประวัติการทำงาน เริ่มจากล่าสุด',
      BuilderSection.education: 'เพิ่มข้อมูลการศึกษา',
      BuilderSection.skills: 'แสดงทักษะทางเทคนิคและทักษะอื่นๆ',
      BuilderSection.projects: 'แสดงผลงาน/โปรเจกต์ที่โดดเด่น',
      BuilderSection.languages: 'ระบุภาษาที่คุณสามารถใช้ได้',
      BuilderSection.hobbies: 'แบ่งปันความสนใจและงานอดิเรก',
    };

    final descriptions = language == ResumeLanguage.thai
        ? descriptionsTh
        : descriptionsEn;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              descriptions[section] ?? '',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionForm(
    BuildContext context,
    BuilderLoaded state,
    BuilderSection section,
  ) {
    switch (section) {
      case BuilderSection.profile:
        return ProfileForm(profile: state.draft.profile);
      case BuilderSection.contact:
        return ContactForm(contact: state.draft.contact);
      case BuilderSection.experience:
        return ExperienceForm(experiences: state.draft.experiences);
      case BuilderSection.education:
        return EducationForm(educations: state.draft.educations);
      case BuilderSection.skills:
        return SkillsForm(skills: state.draft.skills);
      case BuilderSection.projects:
        return ProjectsForm(projects: state.draft.projects);
      case BuilderSection.languages:
        return LanguagesForm(languages: state.draft.languages);
      case BuilderSection.hobbies:
        return HobbiesForm(hobbies: state.draft.hobbies);
    }
  }

  Widget _buildNavigationButtons(BuildContext context, BuilderLoaded state) {
    final isFirst = state.currentSection.index == 0;
    final isLast =
        state.currentSection.index == BuilderSection.values.length - 1;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (!isFirst)
            OutlinedButton.icon(
              onPressed: () {
                _tabController.animateTo(_tabController.index - 1);
              },
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(
                state.uiLanguage == ResumeLanguage.thai ? 'ย้อนกลับ' : 'Back',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            )
          else
            const SizedBox(width: 100),

          const Spacer(),

          // Next/Preview button
          if (isLast)
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/preview',
                  arguments: {
                    'draft': state.draft,
                    'language': state.uiLanguage,
                  },
                );
              },
              icon: const Icon(Icons.visibility, size: 18),
              label: Text(
                state.uiLanguage == ResumeLanguage.thai
                    ? 'ดูตัวอย่าง'
                    : 'Preview Resume',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            )
          else
            FilledButton.icon(
              onPressed: () {
                _tabController.animateTo(_tabController.index + 1);
              },
              label: Text(
                state.uiLanguage == ResumeLanguage.thai ? 'ถัดไป' : 'Next',
              ),
              icon: const Icon(Icons.arrow_forward, size: 18),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, BuilderError state) {
    final isLimitReached = state.errorCode == 'LIMIT_REACHED';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLimitReached ? Icons.workspace_premium : Icons.error_outline,
              size: 64,
              color: isLimitReached ? Colors.amber : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isLimitReached ? 'Limit Reached' : 'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (isLimitReached) {
                  Navigator.of(context).pushNamed('/paywall').then((_) {
                    // Retry creation after returning from paywall (in case they upgraded)
                    context.read<BuilderBloc>().add(
                      BuilderInitialized(draftId: widget.draftId),
                    );
                  });
                } else {
                  context.read<BuilderBloc>().add(
                    BuilderInitialized(draftId: widget.draftId),
                  );
                }
              },
              icon: Icon(isLimitReached ? Icons.star : Icons.refresh),
              label: Text(isLimitReached ? 'Upgrade Plan' : 'Try Again'),
              style: isLimitReached
                  ? ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    )
                  : null,
            ),
            if (isLimitReached) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExportingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('Generating PDF...', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text('This may take a moment', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showExportErrorDialog(BuildContext context, String error) {
    // Check if it's a limit reached error
    // In strict sense, we passed 'LIMIT_REACHED' code as error, or a message.
    // Let's check if it corresponds to our limit code 'LIMIT_REACHED'
    final isLimit = error == 'LIMIT_REACHED' || error.contains('limit reached');

    if (isLimit) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 8),
              Text('Premium Feature'),
            ],
          ),
          content: const Text(
            'You have reached the export limit for the Free plan. Upgrade to Premium to export unlimited resumes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushNamed('/paywall');
              },
              child: const Text('Upgrade Now'),
            ),
          ],
        ),
      );
    } else {
      // General error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData _getSectionIcon(BuilderSection section) {
    switch (section) {
      case BuilderSection.profile:
        return Icons.person_outline;
      case BuilderSection.contact:
        return Icons.mail_outline;
      case BuilderSection.experience:
        return Icons.work_outline;
      case BuilderSection.education:
        return Icons.school_outlined;
      case BuilderSection.skills:
        return Icons.psychology_outlined;
      case BuilderSection.projects:
        return Icons.folder_outlined;
      case BuilderSection.languages:
        return Icons.translate;
      case BuilderSection.hobbies:
        return Icons.interests;
    }
  }
}
