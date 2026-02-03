import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/uid.dart';
import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/sections/education.dart';
import '../../bloc/builder/builder_bloc.dart';
import '../../bloc/builder/builder_event.dart';
import '../../bloc/builder/builder_state.dart';

/// Form for editing the education section
class EducationForm extends StatelessWidget {
  final List<Education> educations;

  const EducationForm({super.key, required this.educations});

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
              label: Text(strings.addEducation),
              onPressed: () => _showEducationDialog(context, lang),
            ),
            const SizedBox(height: 16),

            // Education list
            if (educations.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    strings.noEducation,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: educations.length,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  final orderedIds = educations.map((e) => e.id).toList();
                  final id = orderedIds.removeAt(oldIndex);
                  orderedIds.insert(newIndex, id);
                  context.read<BuilderBloc>().add(BuilderEducationsReordered(orderedIds));
                },
                itemBuilder: (context, index) {
                  final education = educations[index];
                  return _EducationCard(
                    key: ValueKey(education.id),
                    education: education,
                    language: lang,
                    onEdit: () => _showEducationDialog(context, lang, education),
                    onDelete: () {
                      context.read<BuilderBloc>().add(BuilderEducationRemoved(education.id));
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _showEducationDialog(BuildContext context, ResumeLanguage language, [Education? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _EducationEditSheet(
        education: existing,
        language: language,
        onSave: (education) {
          if (existing != null) {
            context.read<BuilderBloc>().add(BuilderEducationUpdated(education));
          } else {
            context.read<BuilderBloc>().add(BuilderEducationAdded(education));
          }
        },
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  final Education education;
  final ResumeLanguage language;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EducationCard({
    super.key,
    required this.education,
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
        title: Text(education.degree),
        subtitle: Text('${education.institution}\n${education.dateRange}'),
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
                    content: Text(strings.deleteConfirmMessage(education.degree)),
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

class _EducationEditSheet extends StatefulWidget {
  final Education? education;
  final ResumeLanguage language;
  final ValueChanged<Education> onSave;

  const _EducationEditSheet({
    this.education,
    required this.language,
    required this.onSave,
  });

  @override
  State<_EducationEditSheet> createState() => _EducationEditSheetState();
}

class _EducationEditSheetState extends State<_EducationEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _institutionController;
  late final TextEditingController _degreeController;
  late final TextEditingController _fieldController;
  late final TextEditingController _locationController;
  late final TextEditingController _gpaController;
  late final TextEditingController _descriptionController;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _isCurrentlyStudying;

  ResumeStrings get _strings => ResumeStrings(widget.language);

  @override
  void initState() {
    super.initState();
    final edu = widget.education;
    _institutionController = TextEditingController(text: edu?.institution ?? '');
    _degreeController = TextEditingController(text: edu?.degree ?? '');
    _fieldController = TextEditingController(text: edu?.fieldOfStudy ?? '');
    _locationController = TextEditingController(text: edu?.location ?? '');
    _gpaController = TextEditingController(text: edu?.gpa?.toString() ?? '');
    _descriptionController = TextEditingController(text: edu?.description ?? '');
    _startDate = edu?.startDate ?? DateTime.now();
    _endDate = edu?.endDate;
    _isCurrentlyStudying = edu?.isCurrentlyStudying ?? false;
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _degreeController.dispose();
    _fieldController.dispose();
    _locationController.dispose();
    _gpaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final education = Education(
        id: widget.education?.id ?? Uid.generate(),
        institution: _institutionController.text.trim(),
        degree: _degreeController.text.trim(),
        fieldOfStudy: _fieldController.text.trim(),
        location: _locationController.text.trim(),
        startDate: _startDate,
        endDate: _isCurrentlyStudying ? null : _endDate,
        isCurrentlyStudying: _isCurrentlyStudying,
        gpa: double.tryParse(_gpaController.text.trim()),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        achievements: widget.education?.achievements ?? [],
      );
      widget.onSave(education);
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
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
    final isEditing = widget.education != null;

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
                isEditing ? _strings.editEducation : _strings.addEducation,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _institutionController,
                decoration: InputDecoration(
                  labelText: '${_strings.institution} *',
                  hintText: _strings.hintInstitution,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? _strings.required : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _degreeController,
                decoration: InputDecoration(
                  labelText: '${_strings.degree} *',
                  hintText: _strings.hintDegree,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? _strings.required : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _fieldController,
                decoration: InputDecoration(
                  labelText: '${_strings.fieldOfStudy} *',
                  hintText: _strings.hintFieldOfStudy,
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
                      child: Text('${_strings.startDate}: ${_startDate.year}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isCurrentlyStudying ? null : () => _selectDate(false),
                      child: Text(
                        _isCurrentlyStudying
                            ? _strings.present
                            : (_endDate != null ? '${_strings.endDate}: ${_endDate!.year}' : _strings.endDate),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              CheckboxListTile(
                value: _isCurrentlyStudying,
                onChanged: (v) => setState(() => _isCurrentlyStudying = v ?? false),
                title: Text(_strings.currentlyStudying),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _gpaController,
                decoration: InputDecoration(
                  labelText: _strings.gpa,
                  hintText: _strings.hintGpa,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                maxLines: 3,
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

