import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/uid.dart';
import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/sections/experience.dart';
import '../../bloc/builder/builder_bloc.dart';
import '../../bloc/builder/builder_event.dart';
import '../../bloc/builder/builder_state.dart';

/// Form for editing the experience section
class ExperienceForm extends StatelessWidget {
  final List<Experience> experiences;

  const ExperienceForm({super.key, required this.experiences});

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
              label: Text(strings.addExperience),
              onPressed: () => _showExperienceDialog(context, lang),
            ),
            const SizedBox(height: 16),

            // Experience list
            if (experiences.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    strings.noExperience,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: experiences.length,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  final orderedIds = experiences.map((e) => e.id).toList();
                  final id = orderedIds.removeAt(oldIndex);
                  orderedIds.insert(newIndex, id);
                  context.read<BuilderBloc>().add(BuilderExperiencesReordered(orderedIds));
                },
                itemBuilder: (context, index) {
                  final experience = experiences[index];
                  return _ExperienceCard(
                    key: ValueKey(experience.id),
                    experience: experience,
                    language: lang,
                    onEdit: () => _showExperienceDialog(context, lang, experience),
                    onDelete: () {
                      context.read<BuilderBloc>().add(BuilderExperienceRemoved(experience.id));
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _showExperienceDialog(BuildContext context, ResumeLanguage language, [Experience? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _ExperienceEditSheet(
        experience: existing,
        language: language,
        onSave: (experience) {
          if (existing != null) {
            context.read<BuilderBloc>().add(BuilderExperienceUpdated(experience));
          } else {
            context.read<BuilderBloc>().add(BuilderExperienceAdded(experience));
          }
        },
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final Experience experience;
  final ResumeLanguage language;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExperienceCard({
    super.key,
    required this.experience,
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
        title: Text(experience.position),
        subtitle: Text('${experience.companyName}\n${experience.dateRange}'),
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
                    content: Text(strings.deleteConfirmMessage(experience.position)),
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

class _ExperienceEditSheet extends StatefulWidget {
  final Experience? experience;
  final ResumeLanguage language;
  final ValueChanged<Experience> onSave;

  const _ExperienceEditSheet({
    this.experience,
    required this.language,
    required this.onSave,
  });

  @override
  State<_ExperienceEditSheet> createState() => _ExperienceEditSheetState();
}

class _ExperienceEditSheetState extends State<_ExperienceEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _companyController;
  late final TextEditingController _positionController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _isCurrentJob;

  ResumeStrings get _strings => ResumeStrings(widget.language);

  @override
  void initState() {
    super.initState();
    final exp = widget.experience;
    _companyController = TextEditingController(text: exp?.companyName ?? '');
    _positionController = TextEditingController(text: exp?.position ?? '');
    _locationController = TextEditingController(text: exp?.location ?? '');
    _descriptionController = TextEditingController(text: exp?.description ?? '');
    _startDate = exp?.startDate ?? DateTime.now();
    _endDate = exp?.endDate;
    _isCurrentJob = exp?.isCurrentJob ?? false;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final experience = Experience(
        id: widget.experience?.id ?? Uid.generate(),
        companyName: _companyController.text.trim(),
        position: _positionController.text.trim(),
        location: _locationController.text.trim(),
        startDate: _startDate,
        endDate: _isCurrentJob ? null : _endDate,
        isCurrentJob: _isCurrentJob,
        description: _descriptionController.text.trim(),
        achievements: widget.experience?.achievements ?? [],
      );
      widget.onSave(experience);
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.experience != null;

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
                isEditing ? _strings.editExperience : _strings.addExperience,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(
                  labelText: '${_strings.companyName} *',
                  hintText: _strings.hintCompanyName,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? _strings.required : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _positionController,
                decoration: InputDecoration(
                  labelText: '${_strings.position} *',
                  hintText: _strings.hintPosition,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? _strings.required : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: _strings.location,
                  hintText: _strings.hintLocation,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(true),
                      child: Text('${_strings.startDate}: ${_startDate.month}/${_startDate.year}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isCurrentJob ? null : () => _selectDate(false),
                      child: Text(
                        _isCurrentJob
                            ? _strings.present
                            : (_endDate != null
                                ? '${_strings.endDate}: ${_endDate!.month}/${_endDate!.year}'
                                : _strings.endDate),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              CheckboxListTile(
                value: _isCurrentJob,
                onChanged: (v) => setState(() => _isCurrentJob = v ?? false),
                title: Text(_strings.currentJob),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: _strings.description,
                  hintText: _strings.hintDescription,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
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

