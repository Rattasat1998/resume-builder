import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/uid.dart';
import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/sections/hobby.dart';
import '../../bloc/builder/builder_bloc.dart';
import '../../bloc/builder/builder_event.dart';
import '../../bloc/builder/builder_state.dart';

/// Form for editing the hobbies/interests section
class HobbiesForm extends StatelessWidget {
  final List<Hobby> hobbies;

  const HobbiesForm({super.key, required this.hobbies});

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
              label: Text(strings.addHobby),
              onPressed: () => _showHobbyDialog(context, lang),
            ),
            const SizedBox(height: 16),

            // Hobbies list
            if (hobbies.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    strings.noHobbies,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: hobbies.map((hobby) {
                  return _HobbyChip(
                    hobby: hobby,
                    language: lang,
                    onEdit: () => _showHobbyDialog(context, lang, hobby),
                    onDelete: () {
                      context.read<BuilderBloc>().add(BuilderHobbyRemoved(hobby.id));
                    },
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  void _showHobbyDialog(BuildContext context, ResumeLanguage language, [Hobby? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _HobbyEditSheet(
        hobby: existing,
        language: language,
        onSave: (hobby) {
          if (existing != null) {
            context.read<BuilderBloc>().add(BuilderHobbyUpdated(hobby));
          } else {
            context.read<BuilderBloc>().add(BuilderHobbyAdded(hobby));
          }
        },
      ),
    );
  }
}

class _HobbyChip extends StatelessWidget {
  final Hobby hobby;
  final ResumeLanguage language;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HobbyChip({
    required this.hobby,
    required this.language,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getHobbyIcon() {
    final name = hobby.name.toLowerCase();
    if (name.contains('read')) return Icons.menu_book;
    if (name.contains('music') || name.contains('guitar') || name.contains('piano')) return Icons.music_note;
    if (name.contains('sport') || name.contains('football') || name.contains('basketball')) return Icons.sports;
    if (name.contains('game') || name.contains('gaming')) return Icons.sports_esports;
    if (name.contains('travel')) return Icons.flight;
    if (name.contains('photo')) return Icons.camera_alt;
    if (name.contains('cook') || name.contains('baking')) return Icons.restaurant;
    if (name.contains('movie') || name.contains('film')) return Icons.movie;
    if (name.contains('art') || name.contains('draw') || name.contains('paint')) return Icons.palette;
    if (name.contains('code') || name.contains('program')) return Icons.code;
    if (name.contains('yoga') || name.contains('meditat')) return Icons.self_improvement;
    if (name.contains('garden')) return Icons.local_florist;
    if (name.contains('swim')) return Icons.pool;
    if (name.contains('run') || name.contains('jog')) return Icons.directions_run;
    if (name.contains('bike') || name.contains('cycl')) return Icons.directions_bike;
    if (name.contains('write') || name.contains('blog')) return Icons.edit_note;
    return Icons.favorite;
  }

  @override
  Widget build(BuildContext context) {
    final strings = ResumeStrings(language);
    return InputChip(
      avatar: Icon(_getHobbyIcon(), size: 18),
      label: Text(hobby.name),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(strings.confirmDelete),
            content: Text(strings.deleteConfirmMessage(hobby.name)),
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
      onPressed: onEdit,
    );
  }
}

class _HobbyEditSheet extends StatefulWidget {
  final Hobby? hobby;
  final ResumeLanguage language;
  final Function(Hobby) onSave;

  const _HobbyEditSheet({
    this.hobby,
    required this.language,
    required this.onSave,
  });

  @override
  State<_HobbyEditSheet> createState() => _HobbyEditSheetState();
}

class _HobbyEditSheetState extends State<_HobbyEditSheet> {
  late TextEditingController _nameController;

  ResumeStrings get _strings => ResumeStrings(widget.language);

  // Common hobbies suggestions
  final List<String> _suggestions = [
    'Reading',
    'Traveling',
    'Photography',
    'Music',
    'Gaming',
    'Cooking',
    'Sports',
    'Movies',
    'Art & Drawing',
    'Writing',
    'Yoga',
    'Running',
    'Swimming',
    'Cycling',
    'Gardening',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hobby?.name ?? '');
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
                widget.hobby != null ? _strings.editHobby : _strings.addHobby,
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
              labelText: _strings.hobbyName,
              hintText: _strings.hintHobbyName,
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // Suggestions
          if (widget.hobby == null) ...[
            Text(
              'Quick Add:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions.map((suggestion) {
                return ActionChip(
                  label: Text(suggestion),
                  onPressed: () {
                    _nameController.text = suggestion;
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Save button
          FilledButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_strings.hobbyName)),
                );
                return;
              }

              final hobby = Hobby(
                id: widget.hobby?.id ?? Uid.generate(),
                name: _nameController.text.trim(),
              );

              widget.onSave(hobby);
              Navigator.pop(context);
            },
            child: Text(_strings.save),
          ),
        ],
      ),
    );
  }
}

