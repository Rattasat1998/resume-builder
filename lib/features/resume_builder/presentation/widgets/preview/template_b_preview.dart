// Avatar helper handles file/network images internally

import 'package:flutter/material.dart';

import '../../../../../core/utils/avatar_image_helper.dart';
import '../../../domain/entities/resume_draft.dart';
import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/sections/language.dart';
import '../../../domain/entities/sections/skill.dart';

/// Template B preview - Modern style with split layout
class TemplateBPreview extends StatelessWidget {
  final ResumeDraft draft;
  final ResumeLanguage previewLanguage;

  const TemplateBPreview({
    super.key,
    required this.draft,
    this.previewLanguage = ResumeLanguage.english,
  });

  ResumeStrings get _strings => ResumeStrings(previewLanguage);

  Color get _primaryColor {
    try {
      final hex = draft.template.primaryColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF2c3e50);
    }
  }

  Color get _accentColor {
    try {
      final hex = draft.template.secondaryColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF3498db);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Header with geometric design
            _buildModernHeader(),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Section
                  if (draft.profile.summary.isNotEmpty) ...[
                    _buildModernSection(_strings.profile, Icons.person_outline),
                    const SizedBox(height: 12),
                    Text(
                      draft.profile.summary,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.7,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Two Column Layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column - Experience
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildModernSection(
                              _strings.workExperience,
                              Icons.work_outline,
                            ),
                            const SizedBox(height: 16),
                            ...draft.experiences
                                .take(3)
                                .map((exp) => _buildModernExperience(exp)),

                            const SizedBox(height: 24),

                            _buildModernSection(
                              _strings.education,
                              Icons.school_outlined,
                            ),
                            const SizedBox(height: 16),
                            ...draft.educations
                                .take(2)
                                .map((edu) => _buildModernEducation(edu)),
                          ],
                        ),
                      ),

                      const SizedBox(width: 28),

                      // Right Column - Skills & Projects
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildModernSection(
                              _strings.skills,
                              Icons.psychology_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildSkillsGrid(),

                            if (draft.projects.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildModernSection(
                                _strings.projects,
                                Icons.folder_outlined,
                              ),
                              const SizedBox(height: 16),
                              ...draft.projects
                                  .take(2)
                                  .map((proj) => _buildModernProject(proj)),
                            ],

                            if (draft.languages.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildModernSection(
                                _strings.languages,
                                Icons.language,
                              ),
                              const SizedBox(height: 16),
                              _buildLanguagesSection(),
                            ],

                            if (draft.hobbies.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildModernSection(
                                _strings.interests,
                                Icons.interests,
                              ),
                              const SizedBox(height: 16),
                              _buildHobbiesSection(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      height: 180,
      child: Stack(
        children: [
          // Background with geometric shapes
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primaryColor,
                    _primaryColor.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),

          // Geometric decorations
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            right: 60,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      image: AvatarImageHelper.getDecorationImage(
                        draft.profile.avatarUrl,
                      ),
                    ),
                    child:
                        AvatarImageHelper.getImageProvider(
                              draft.profile.avatarUrl,
                            ) ==
                            null
                        ? Icon(
                            Icons.person,
                            size: 45,
                            color: _primaryColor.withValues(alpha: 0.3),
                          )
                        : null,
                  ),
                  const SizedBox(width: 24),

                  // Name & Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          draft.profile.fullName.isEmpty
                              ? _strings.yourName
                              : draft.profile.fullName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            draft.profile.jobTitle.isEmpty
                                ? _strings.professionalTitle
                                : draft.profile.jobTitle,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Contact Row
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            if (draft.contact.email.isNotEmpty)
                              _buildHeaderContact(
                                Icons.email_outlined,
                                draft.contact.email,
                              ),
                            if (draft.contact.phone.isNotEmpty)
                              _buildHeaderContact(
                                Icons.phone_outlined,
                                draft.contact.phone,
                              ),
                            if (draft.contact.location.isNotEmpty)
                              _buildHeaderContact(
                                Icons.location_on_outlined,
                                draft.contact.location,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContact(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSection(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: _accentColor),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _accentColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernExperience(dynamic exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: _accentColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exp.position,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  exp.dateRange,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: _primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            exp.companyName,
            style: TextStyle(
              fontSize: 10,
              color: _accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (exp.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              exp.description,
              style: TextStyle(
                fontSize: 9,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernEducation(dynamic edu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edu.degree,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${edu.institution} • ${edu.dateRange}',
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsGrid() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: draft.skills.take(10).map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _primaryColor.withValues(alpha: 0.05),
                _accentColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _accentColor.withValues(alpha: 0.2)),
          ),
          child: Text(
            skill.name,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: _primaryColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModernProject(dynamic project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, size: 12, color: _accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  project.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (project.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              project.description,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (project.technologies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: project.technologies
                  .take(3)
                  .map<Widget>(
                    (tech) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        tech,
                        style: TextStyle(
                          fontSize: 7,
                          color: _accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguagesSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: draft.languages.map((language) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _primaryColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                language.name,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  _strings.languageLevel(language.level.displayName),
                  style: TextStyle(
                    fontSize: 7,
                    color: _accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHobbiesSection() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: draft.hobbies.map((hobby) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            hobby.name,
            style: TextStyle(fontSize: 9, color: Colors.grey.shade700),
          ),
        );
      }).toList(),
    );
  }
}
