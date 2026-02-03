import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/sections/contact.dart';
import '../../bloc/builder/builder_bloc.dart';
import '../../bloc/builder/builder_event.dart';
import '../../bloc/builder/builder_state.dart';


/// Form for editing the contact section
class ContactForm extends StatefulWidget {
  final Contact contact;

  const ContactForm({super.key, required this.contact});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _websiteController;
  late final TextEditingController _linkedInController;
  late final TextEditingController _githubController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.contact.email);
    _phoneController = TextEditingController(text: widget.contact.phone);
    _websiteController = TextEditingController(text: widget.contact.website ?? '');
    _linkedInController = TextEditingController(text: widget.contact.linkedIn ?? '');
    _githubController = TextEditingController(text: widget.contact.github ?? '');
    _cityController = TextEditingController(text: widget.contact.city ?? '');
    _countryController = TextEditingController(text: widget.contact.country ?? '');
  }

  @override
  void didUpdateWidget(ContactForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contact != widget.contact) {
      _emailController.text = widget.contact.email;
      _phoneController.text = widget.contact.phone;
      _websiteController.text = widget.contact.website ?? '';
      _linkedInController.text = widget.contact.linkedIn ?? '';
      _githubController.text = widget.contact.github ?? '';
      _cityController.text = widget.contact.city ?? '';
      _countryController.text = widget.contact.country ?? '';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _linkedInController.dispose();
    _githubController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveContact() {
    final updatedContact = widget.contact.copyWith(
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
      linkedIn: _linkedInController.text.trim().isEmpty ? null : _linkedInController.text.trim(),
      github: _githubController.text.trim().isEmpty ? null : _githubController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
    );
    context.read<BuilderBloc>().add(BuilderContactUpdated(updatedContact));
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
        final lang = state is BuilderLoaded ? state.uiLanguage : ResumeLanguage.english;
        final strings = ResumeStrings(lang);

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '${strings.email} *',
                  hintText: strings.hintEmail,
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return strings.required;
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return strings.required;
                  }
                  return null;
                },
                onChanged: (_) => _saveContact(),
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: '${strings.phone} *',
                  hintText: strings.hintPhone,
                  prefixIcon: const Icon(Icons.phone),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return strings.required;
                  }
                  return null;
                },
                onChanged: (_) => _saveContact(),
              ),
              const SizedBox(height: 16),

              // Website
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(
                  labelText: strings.website,
                  hintText: strings.hintWebsite,
                  prefixIcon: const Icon(Icons.language),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) => _saveContact(),
              ),
              const SizedBox(height: 16),

              // LinkedIn
              TextFormField(
                controller: _linkedInController,
                decoration: InputDecoration(
                  labelText: 'LinkedIn',
                  hintText: strings.hintLinkedIn,
                  prefixIcon: const Icon(Icons.link),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) => _saveContact(),
              ),
              const SizedBox(height: 16),

              // GitHub
              TextFormField(
                controller: _githubController,
                decoration: InputDecoration(
                  labelText: 'GitHub',
                  hintText: strings.hintGitHub,
                  prefixIcon: const Icon(Icons.code),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) => _saveContact(),
              ),
              const SizedBox(height: 16),

              // Location
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: strings.city,
                        hintText: strings.hintCity,
                        prefixIcon: const Icon(Icons.location_city),
                        border: const OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => _saveContact(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      decoration: InputDecoration(
                        labelText: strings.country,
                        hintText: strings.hintCountry,
                        prefixIcon: const Icon(Icons.flag),
                        border: const OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => _saveContact(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

