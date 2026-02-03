import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/sections/profile.dart';
import '../../bloc/builder/builder_bloc.dart';
import '../../bloc/builder/builder_event.dart';
import '../../bloc/builder/builder_state.dart';

/// Form for editing the profile section
class ProfileForm extends StatefulWidget {
  final Profile profile;

  const ProfileForm({super.key, required this.profile});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _summaryController;
  final ImagePicker _imagePicker = ImagePicker();
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _jobTitleController = TextEditingController(text: widget.profile.jobTitle);
    _summaryController = TextEditingController(text: widget.profile.summary);
    _avatarPath = widget.profile.avatarUrl;
  }

  @override
  void didUpdateWidget(ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      // Check if avatar URL changed (e.g., after upload to Supabase)
      final avatarChanged =
          oldWidget.profile.avatarUrl != widget.profile.avatarUrl;

      _fullNameController.text = widget.profile.fullName;
      _jobTitleController.text = widget.profile.jobTitle;
      _summaryController.text = widget.profile.summary;

      if (avatarChanged) {
        setState(() {
          _avatarPath = widget.profile.avatarUrl;
        });
      } else {
        _avatarPath = widget.profile.avatarUrl;
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedProfile = widget.profile.copyWith(
        fullName: _fullNameController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        summary: _summaryController.text.trim(),
        avatarUrl: _avatarPath,
      );
      context.read<BuilderBloc>().add(BuilderProfileUpdated(updatedProfile));
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _getImage(ImageSource.gallery);
              },
            ),
            if (_avatarPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Copy to app directory to preserve the file
        final savedPath = await _saveImageToAppDirectory(pickedFile);

        setState(() {
          _avatarPath = savedPath;
        });
        _saveProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  /// Copy image to app's documents directory to preserve it
  Future<String> _saveImageToAppDirectory(XFile pickedFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory('${appDir.path}/avatars');

    // Create avatars directory if it doesn't exist
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }

    // Generate unique filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = pickedFile.path.split('.').last;
    final newPath = '${avatarsDir.path}/avatar_$timestamp.$extension';

    // Copy file
    final bytes = await pickedFile.readAsBytes();
    final newFile = File(newPath);
    await newFile.writeAsBytes(bytes);

    return newPath;
  }

  void _removeImage() {
    setState(() {
      _avatarPath = null;
    });
    _saveProfile();
  }

  Widget _buildAvatar() {
    ImageProvider? imageProvider;

    if (_avatarPath != null && _avatarPath!.isNotEmpty) {
      if (_avatarPath!.startsWith('http')) {
        // Network URL (from Supabase storage)
        imageProvider = NetworkImage(_avatarPath!);
      } else {
        // Local file path
        final file = File(_avatarPath!);
        if (file.existsSync()) {
          imageProvider = FileImage(file);
        }
      }
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        final lang = state is BuilderLoaded
            ? state.uiLanguage
            : ResumeLanguage.english;
        final strings = ResumeStrings(lang);

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar with image picker
              Center(child: _buildAvatar()),
              const SizedBox(height: 24),

              // Full name
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: strings.fullName,
                  hintText: strings.hintFullName,
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return strings.required;
                  }
                  return null;
                },
                onChanged: (_) => _saveProfile(),
              ),
              const SizedBox(height: 16),

              // Job title
              TextFormField(
                controller: _jobTitleController,
                decoration: InputDecoration(
                  labelText: strings.jobTitle,
                  hintText: strings.hintJobTitle,
                  prefixIcon: const Icon(Icons.work),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return strings.required;
                  }
                  return null;
                },
                onChanged: (_) => _saveProfile(),
              ),
              const SizedBox(height: 16),

              // Summary
              TextFormField(
                controller: _summaryController,
                decoration: InputDecoration(
                  labelText: strings.summary,
                  hintText: strings.hintSummary,
                  prefixIcon: const Icon(Icons.description),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return strings.required;
                  }
                  return null;
                },
                onChanged: (_) => _saveProfile(),
              ),
            ],
          ),
        );
      },
    );
  }
}
