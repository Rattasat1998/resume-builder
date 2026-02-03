import 'package:flutter/material.dart';
import 'package:resume_builder/features/resume_builder/domain/entities/sections/language.dart';

import '../../../domain/entities/resume_draft.dart';
import '../../../domain/entities/resume_language.dart';


/// Template A preview - Classic style
class TemplateAPreview extends StatelessWidget {
  final ResumeDraft draft;
  final ResumeLanguage previewLanguage;

  const TemplateAPreview({
    super.key,
    required this.draft,
    this.previewLanguage = ResumeLanguage.english,
  });

  ResumeStrings get _strings => ResumeStrings(previewLanguage);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Name & Title
            _buildHeader(),
            const Divider(height: 32),

            // Contact Info
            _buildContactSection(),
            const SizedBox(height: 24),

            // Summary
            if (draft.profile.summary.isNotEmpty) ...[
              _buildSectionTitle(_strings.professionalSummary),
              const SizedBox(height: 8),
              Text(
                draft.profile.summary,
                style: const TextStyle(fontSize: 11, height: 1.5),
              ),
              const SizedBox(height: 24),
            ],

            // Experience
            if (draft.experiences.isNotEmpty) ...[
              _buildSectionTitle(_strings.workExperience),
              const SizedBox(height: 12),
              ...draft.experiences.take(3).map(_buildExperienceItem),
              const SizedBox(height: 16),
            ],

            // Education
            if (draft.educations.isNotEmpty) ...[
              _buildSectionTitle(_strings.education),
              const SizedBox(height: 12),
              ...draft.educations.take(2).map(_buildEducationItem),
              const SizedBox(height: 16),
            ],

            // Skills
            if (draft.skills.isNotEmpty) ...[
              _buildSectionTitle(_strings.skills),
              const SizedBox(height: 12),
              _buildSkillsSection(),
              const SizedBox(height: 16),
            ],

            // Projects
            if (draft.projects.isNotEmpty) ...[
              _buildSectionTitle(_strings.projects),
              const SizedBox(height: 12),
              ...draft.projects.take(2).map(_buildProjectItem),
              const SizedBox(height: 16),
            ],

            // Languages
            if (draft.languages.isNotEmpty) ...[
              _buildSectionTitle(_strings.languages),
              const SizedBox(height: 12),
              _buildLanguagesSection(),
              const SizedBox(height: 16),
            ],

            // Hobbies
            if (draft.hobbies.isNotEmpty) ...[
              _buildSectionTitle(_strings.hobbies),
              const SizedBox(height: 12),
              _buildHobbiesSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          draft.profile.fullName.isEmpty ? _strings.yourName : draft.profile.fullName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a1a),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          draft.profile.jobTitle.isEmpty ? _strings.jobTitle : draft.profile.jobTitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    final contactItems = <Widget>[];

    if (draft.contact.email.isNotEmpty) {
      contactItems.add(_buildContactItem(Icons.email, draft.contact.email));
    }
    if (draft.contact.phone.isNotEmpty) {
      contactItems.add(_buildContactItem(Icons.phone, draft.contact.phone));
    }
    if (draft.contact.location.isNotEmpty) {
      contactItems.add(_buildContactItem(Icons.location_on, draft.contact.location));
    }
    if (draft.contact.linkedIn != null && draft.contact.linkedIn!.isNotEmpty) {
      contactItems.add(_buildContactItem(Icons.link, draft.contact.linkedIn!));
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: contactItems,
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a1a),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: 40,
          color: const Color(0xFF1a1a1a),
        ),
      ],
    );
  }

  Widget _buildExperienceItem(experience) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  experience.position,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                experience.dateRange,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${experience.companyName} • ${experience.location}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          if (experience.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              experience.description,
              style: const TextStyle(fontSize: 10, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationItem(education) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${education.degree} in ${education.fieldOfStudy}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                education.dateRange,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            education.institution,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          if (education.gpa != null) ...[
            const SizedBox(height: 2),
            Text(
              'GPA: ${education.gpa}',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: draft.skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            skill.name,
            style: const TextStyle(fontSize: 10),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjectItem(project) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            project.description,
            style: const TextStyle(fontSize: 10, height: 1.4),
          ),
          if (project.technologies.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              project.technologies.join(' • '),
              style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguagesSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: draft.languages.map((language) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              language.name,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _strings.languageLevel(language.level.displayName),
                style: TextStyle(fontSize: 9, color: Colors.grey.shade700),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHobbiesSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: draft.hobbies.map((hobby) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            hobby.name,
            style: const TextStyle(fontSize: 10),
          ),
        );
      }).toList(),
    );
  }
}
