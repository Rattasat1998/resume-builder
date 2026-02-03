import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/uid.dart';
import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/sections/project.dart';
import '../../bloc/builder/builder_bloc.dart';
import '../../bloc/builder/builder_event.dart';
import '../../bloc/builder/builder_state.dart';

/// Form for editing the projects section
class ProjectsForm extends StatelessWidget {
  final List<Project> projects;

  const ProjectsForm({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuilderBloc, BuilderState>(
      buildWhen: (previous, current) {
        if (previous is BuilderLoaded && current is BuilderLoaded) {
          return previous.uiLanguage != current.uiLanguage;
        }
        return false;
      },
      builder: (context, state) {
        final lang = state is BuilderLoaded ? state.uiLanguage : ResumeLanguage.english;
        final strings = ResumeStrings(lang);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add button
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(strings.addProject),
              onPressed: () => _showProjectDialog(context, lang),
            ),
            const SizedBox(height: 16),

            // Projects list
            if (projects.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    strings.noProjects,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.length,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  final orderedIds = projects.map((p) => p.id).toList();
                  final id = orderedIds.removeAt(oldIndex);
                  orderedIds.insert(newIndex, id);
                  context.read<BuilderBloc>().add(BuilderProjectsReordered(orderedIds));
                },
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return _ProjectCard(
                    key: ValueKey(project.id),
                    project: project,
                    language: lang,
                    onEdit: () => _showProjectDialog(context, lang, project),
                    onDelete: () {
                      context.read<BuilderBloc>().add(BuilderProjectRemoved(project.id));
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _showProjectDialog(BuildContext context, ResumeLanguage language, [Project? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _ProjectEditSheet(
        project: existing,
        language: language,
        onSave: (project) {
          if (existing != null) {
            context.read<BuilderBloc>().add(BuilderProjectUpdated(project));
          } else {
            context.read<BuilderBloc>().add(BuilderProjectAdded(project));
          }
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final ResumeLanguage language;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectCard({
    super.key,
    required this.project,
    required this.language,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final strings = ResumeStrings(language);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.drag_handle),
        title: Text(project.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (project.technologies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  children: project.technologies.take(3).map((tech) {
                    return Chip(
                      label: Text(tech, style: const TextStyle(fontSize: 10)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(strings.confirmDelete),
                    content: Text(strings.deleteConfirmMessage(project.name)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(strings.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onDelete();
                        },
                        child: Text(strings.delete, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectEditSheet extends StatefulWidget {
  final Project? project;
  final ResumeLanguage language;
  final ValueChanged<Project> onSave;

  const _ProjectEditSheet({
    this.project,
    required this.language,
    required this.onSave,
  });

  @override
  State<_ProjectEditSheet> createState() => _ProjectEditSheetState();
}

class _ProjectEditSheetState extends State<_ProjectEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _urlController;
  late final TextEditingController _repoUrlController;
  late final TextEditingController _techController;
  late List<String> _technologies;

  ResumeStrings get _strings => ResumeStrings(widget.language);

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    _nameController = TextEditingController(text: project?.name ?? '');
    _descriptionController = TextEditingController(text: project?.description ?? '');
    _urlController = TextEditingController(text: project?.url ?? '');
    _repoUrlController = TextEditingController(text: project?.repositoryUrl ?? '');
    _techController = TextEditingController();
    _technologies = List.from(project?.technologies ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _repoUrlController.dispose();
    _techController.dispose();
    super.dispose();
  }

  void _addTechnology() {
    final tech = _techController.text.trim();
    if (tech.isNotEmpty && !_technologies.contains(tech)) {
      setState(() {
        _technologies.add(tech);
        _techController.clear();
      });
    }
  }

  void _removeTechnology(String tech) {
    setState(() {
      _technologies.remove(tech);
    });
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final project = Project(
        id: widget.project?.id ?? Uid.generate(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        url: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
        repositoryUrl: _repoUrlController.text.trim().isEmpty ? null : _repoUrlController.text.trim(),
        technologies: _technologies,
        highlights: widget.project?.highlights ?? [],
      );
      widget.onSave(project);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                isEditing ? _strings.editProject : _strings.addProject,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${_strings.projectName} *',
                  hintText: _strings.hintProjectName,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? _strings.required : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: '${_strings.description} *',
                  hintText: _strings.hintProjectDescription,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (v) => v?.trim().isEmpty ?? true ? _strings.required : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: _strings.projectUrl,
                  hintText: _strings.hintProjectUrl,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _repoUrlController,
                decoration: InputDecoration(
                  labelText: 'Repository URL',
                  hintText: _strings.hintGitHub,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              Text(
                _strings.technologies,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _techController,
                      decoration: InputDecoration(
                        hintText: _strings.hintTechnologies,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onFieldSubmitted: (_) => _addTechnology(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: _addTechnology,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_technologies.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _technologies.map((tech) {
                    return Chip(
                      label: Text(tech),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeTechnology(tech),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(_strings.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    child: Text(_strings.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

