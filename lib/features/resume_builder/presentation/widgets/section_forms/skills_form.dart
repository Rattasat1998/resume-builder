import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/uid.dart';
import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/sections/skill.dart';
import '../../bloc/builder/builder_bloc.dart';
import '../../bloc/builder/builder_event.dart';
import '../../bloc/builder/builder_state.dart';

/// Form for editing the skills section
class SkillsForm extends StatelessWidget {
  final List<Skill> skills;

  const SkillsForm({super.key, required this.skills});

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
              label: Text(strings.addSkill),
              onPressed: () => _showSkillDialog(context, lang),
            ),
            const SizedBox(height: 16),

            // Skills list
            if (skills.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    strings.noSkills,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((skill) {
                  return _SkillChip(
                    skill: skill,
                    language: lang,
                    onEdit: () => _showSkillDialog(context, lang, skill),
                    onDelete: () {
                      context.read<BuilderBloc>().add(BuilderSkillRemoved(skill.id));
                    },
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  void _showSkillDialog(BuildContext context, ResumeLanguage language, [Skill? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _SkillEditSheet(
        skill: existing,
        language: language,
        onSave: (skill) {
          if (existing != null) {
            context.read<BuilderBloc>().add(BuilderSkillUpdated(skill));
          } else {
            context.read<BuilderBloc>().add(BuilderSkillAdded(skill));
          }
        },
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final Skill skill;
  final ResumeLanguage language;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SkillChip({
    required this.skill,
    required this.language,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final strings = ResumeStrings(language);
    return InputChip(
      label: Text('${skill.name} (${skill.level.displayName})'),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(strings.confirmDelete),
            content: Text(strings.deleteConfirmMessage(skill.name)),
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
      onPressed: onEdit,
    );
  }
}

class _SkillEditSheet extends StatefulWidget {
  final Skill? skill;
  final ResumeLanguage language;
  final ValueChanged<Skill> onSave;

  const _SkillEditSheet({
    this.skill,
    required this.language,
    required this.onSave,
  });

  @override
  State<_SkillEditSheet> createState() => _SkillEditSheetState();
}

class _SkillEditSheetState extends State<_SkillEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late SkillLevel _level;

  ResumeStrings get _strings => ResumeStrings(widget.language);

  @override
  void initState() {
    super.initState();
    final skill = widget.skill;
    _nameController = TextEditingController(text: skill?.name ?? '');
    _categoryController = TextEditingController(text: skill?.category ?? '');
    _level = skill?.level ?? SkillLevel.intermediate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final skill = Skill(
        id: widget.skill?.id ?? Uid.generate(),
        name: _nameController.text.trim(),
        level: _level,
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
      );
      widget.onSave(skill);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.skill != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? _strings.editSkill : _strings.addSkill,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${_strings.skillName} *',
                  hintText: _strings.hintSkillName,
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v?.trim().isEmpty ?? true ? _strings.required : null,
              ),
              const SizedBox(height: 16),

              Text(
                _strings.skillLevel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),

              SegmentedButton<SkillLevel>(
                segments: SkillLevel.values.map((level) {
                  return ButtonSegment(
                    value: level,
                    label: Text(
                      level.displayName,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
                selected: {_level},
                onSelectionChanged: (selection) {
                  setState(() {
                    _level = selection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: _strings.category,
                  hintText: _strings.hintCategory,
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
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

