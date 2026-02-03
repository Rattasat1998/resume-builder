import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/uid.dart';
import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/sections/language.dart';
import '../../bloc/builder/builder_bloc.dart';
import '../../bloc/builder/builder_event.dart';
import '../../bloc/builder/builder_state.dart';

/// Form for editing the languages section
class LanguagesForm extends StatelessWidget {
  final List<Language> languages;

  const LanguagesForm({super.key, required this.languages});

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
              label: Text(strings.addLanguage),
              onPressed: () => _showLanguageDialog(context, lang),
            ),
            const SizedBox(height: 16),

            // Languages list
            if (languages.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    strings.noLanguages,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: languages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final language = languages[index];
                  return _LanguageCard(
                    language: language,
                    uiLanguage: lang,
                    onEdit: () => _showLanguageDialog(context, lang, language),
                    onDelete: () {
                      context.read<BuilderBloc>().add(BuilderLanguageRemoved(language.id));
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, ResumeLanguage uiLanguage, [Language? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _LanguageEditSheet(
        language: existing,
        uiLanguage: uiLanguage,
        onSave: (language) {
          if (existing != null) {
            context.read<BuilderBloc>().add(BuilderLanguageUpdated(language));
          } else {
            context.read<BuilderBloc>().add(BuilderLanguageAdded(language));
          }
        },
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final Language language;
  final ResumeLanguage uiLanguage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LanguageCard({
    required this.language,
    required this.uiLanguage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final strings = ResumeStrings(uiLanguage);
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.language),
        ),
        title: Text(language.name),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                strings.languageLevel(language.level.displayName),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              language.level.cefrLevel,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(strings.confirmDelete),
                    content: Text(strings.deleteConfirmMessage(language.name)),
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
                        child: Text(strings.delete),
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

class _LanguageEditSheet extends StatefulWidget {
  final Language? language;
  final ResumeLanguage uiLanguage;
  final Function(Language) onSave;

  const _LanguageEditSheet({
    this.language,
    required this.uiLanguage,
    required this.onSave,
  });

  @override
  State<_LanguageEditSheet> createState() => _LanguageEditSheetState();
}

class _LanguageEditSheetState extends State<_LanguageEditSheet> {
  late TextEditingController _nameController;
  late LanguageLevel _selectedLevel;

  ResumeStrings get _strings => ResumeStrings(widget.uiLanguage);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.language?.name ?? '');
    _selectedLevel = widget.language?.level ?? LanguageLevel.intermediate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Text(
                widget.language != null ? _strings.editLanguage : _strings.addLanguage,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: _strings.languageName,
              hintText: _strings.hintLanguageName,
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // Level dropdown
          DropdownButtonFormField<LanguageLevel>(
            value: _selectedLevel,
            decoration: InputDecoration(
              labelText: _strings.proficiency,
              border: const OutlineInputBorder(),
            ),
            items: LanguageLevel.values.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Row(
                  children: [
                    Text(_strings.languageLevel(level.displayName)),
                    const SizedBox(width: 8),
                    Text(
                      '(${level.cefrLevel})',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedLevel = value);
              }
            },
          ),
          const SizedBox(height: 24),

          // Save button
          FilledButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_strings.languageName)),
                );
                return;
              }

              final language = Language(
                id: widget.language?.id ?? Uid.generate(),
                name: _nameController.text.trim(),
                level: _selectedLevel,
              );

              widget.onSave(language);
              Navigator.pop(context);
            },
            child: Text(_strings.save),
          ),
        ],
      ),
    );
  }
}

