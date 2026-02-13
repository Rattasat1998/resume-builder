// Avatar helper handles file/network images internally
import 'package:flutter/material.dart';
import '../../../../../core/utils/avatar_image_helper.dart';
import '../../../domain/entities/resume_draft.dart';
import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/sections/language.dart';
import '../../../domain/entities/sections/skill.dart';

/// Elegant Template - Sophisticated with refined aesthetics
class TemplateElegantPreview extends StatelessWidget {
  final ResumeDraft draft;
  final ResumeLanguage previewLanguage;

  const TemplateElegantPreview({
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
      return const Color(0xFF8B4513);
    }
  }

  Color get _secondaryColor {
    try {
      final hex = draft.template.secondaryColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFFD4A574);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFFDF8F3), const Color(0xFFFAF6F1)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Elegant decorative header
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, _secondaryColor],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: _secondaryColor, width: 1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.diamond_outlined,
                      color: _secondaryColor,
                      size: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_secondaryColor, Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Name with elegant typography
            Text(
              draft.profile.fullName.isEmpty
                  ? 'Your Name'
                  : draft.profile.fullName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                letterSpacing: 8,
                color: _primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Job Title with decorative underline
            Column(
              children: [
                Text(
                  draft.profile.jobTitle.isEmpty
                      ? 'Professional Title'
                      : draft.profile.jobTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: _secondaryColor,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 1,
                  color: _secondaryColor.withValues(alpha: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Contact in elegant format
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _secondaryColor.withValues(alpha: 0.3),
                  ),
                  bottom: BorderSide(
                    color: _secondaryColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 32,
                children: [
                  if (draft.contact.email.isNotEmpty)
                    _buildElegantContact(
                      Icons.mail_outline,
                      draft.contact.email,
                    ),
                  if (draft.contact.phone.isNotEmpty)
                    _buildElegantContact(
                      Icons.phone_outlined,
                      draft.contact.phone,
                    ),
                  if (draft.contact.location.isNotEmpty)
                    _buildElegantContact(
                      Icons.place_outlined,
                      draft.contact.location,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Summary with elegant styling
            if (draft.profile.summary.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: _secondaryColor.withValues(alpha: 0.4),
                      size: 24,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      draft.profile.summary,
                      style: TextStyle(
                        fontSize: 11,
                        height: 2,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],

            // Two column layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Experience
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildElegantSection(_strings.workExperience),
                      const SizedBox(height: 16),
                      ...draft.experiences
                          .take(3)
                          .map((exp) => _buildElegantExperience(exp)),
                    ],
                  ),
                ),

                // Vertical divider
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  width: 1,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _secondaryColor.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Right column - Education & Skills
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildElegantSection(_strings.education),
                      const SizedBox(height: 16),
                      ...draft.educations
                          .take(2)
                          .map((edu) => _buildElegantEducation(edu)),

                      const SizedBox(height: 28),

                      _buildElegantSection(_strings.expertise),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 0,
                        runSpacing: 10,
                        children: draft.skills
                            .take(6)
                            .map(
                              (skill) => SizedBox(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: _secondaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      skill.name,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      if (draft.languages.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _buildElegantSection(_strings.languages),
                        const SizedBox(height: 16),
                        ...draft.languages.map(
                          (lang) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: _secondaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${lang.name} - ${_strings.languageLevel(lang.level.displayName)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      if (draft.hobbies.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _buildElegantSection(_strings.interests),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: draft.hobbies
                              .map(
                                (hobby) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _secondaryColor.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    hobby.name,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey.shade600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElegantContact(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: _secondaryColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildElegantSection(String title) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
            color: _primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: _secondaryColor.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildElegantExperience(dynamic exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exp.position,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _primaryColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                exp.companyName,
                style: TextStyle(
                  fontSize: 9,
                  fontStyle: FontStyle.italic,
                  color: _secondaryColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '•',
                  style: TextStyle(color: _secondaryColor, fontSize: 8),
                ),
              ),
              Text(
                exp.dateRange,
                style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElegantEducation(dynamic edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            edu.degree,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            edu.institution,
            style: TextStyle(
              fontSize: 9,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Creative Template - Bold colors and unique layout
class TemplateCreativePreview extends StatelessWidget {
  final ResumeDraft draft;
  final ResumeLanguage previewLanguage;

  const TemplateCreativePreview({
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
      return const Color(0xFFFF6B6B);
    }
  }

  Color get _secondaryColor {
    try {
      final hex = draft.template.secondaryColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF4ECDC4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Stunning gradient header
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryColor, _secondaryColor],
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  right: -40,
                  top: -40,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  bottom: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 40,
                  bottom: 20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        draft.profile.fullName.isEmpty
                            ? 'Your Name'
                            : draft.profile.fullName,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          draft.profile.jobTitle.isEmpty
                              ? 'Creative Professional'
                              : draft.profile.jobTitle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _primaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main content
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (draft.profile.summary.isNotEmpty) ...[
                          _buildCreativeSection(
                            _strings.aboutMe,
                            _primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            draft.profile.summary,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.7,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 24),
                        ],
                        _buildCreativeSection(
                          _strings.workExperience,
                          _primaryColor,
                        ),
                        const SizedBox(height: 12),
                        ...draft.experiences
                            .take(2)
                            .map((exp) => _buildCreativeExp(exp)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Sidebar
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCreativeSection(
                            _strings.contact,
                            _secondaryColor,
                          ),
                          const SizedBox(height: 12),
                          if (draft.contact.email.isNotEmpty)
                            _buildContactRow(
                              Icons.email_rounded,
                              draft.contact.email,
                            ),
                          if (draft.contact.phone.isNotEmpty)
                            _buildContactRow(
                              Icons.phone_rounded,
                              draft.contact.phone,
                            ),
                          if (draft.contact.location.isNotEmpty)
                            _buildContactRow(
                              Icons.location_on_rounded,
                              draft.contact.location,
                            ),
                          const SizedBox(height: 20),
                          _buildCreativeSection(
                            _strings.skills,
                            _secondaryColor,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: draft.skills
                                .take(6)
                                .map((skill) => _buildSkillChip(skill))
                                .toList(),
                          ),
                          if (draft.languages.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _buildCreativeSection(
                              _strings.languages,
                              _secondaryColor,
                            ),
                            const SizedBox(height: 12),
                            ...draft.languages.map(
                              (lang) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      lang.name,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _secondaryColor.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        _strings.languageLevel(
                                          lang.level.displayName,
                                        ),
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: _secondaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (draft.hobbies.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _buildCreativeSection(
                              _strings.interests,
                              _secondaryColor,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: draft.hobbies
                                  .map(
                                    (hobby) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _primaryColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        hobby.name,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: _primaryColor,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildCreativeSection(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0.3)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildCreativeExp(dynamic exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  exp.dateRange,
                  style: TextStyle(
                    fontSize: 9,
                    color: _secondaryColor,
                    fontWeight: FontWeight.w600,
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
              color: _primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: _secondaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(Skill skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryColor.withValues(alpha: 0.1),
            _secondaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        skill.name,
        style: TextStyle(
          fontSize: 9,
          color: _primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Professional Template - Corporate style
class TemplateProfessionalPreview extends StatelessWidget {
  final ResumeDraft draft;
  final ResumeLanguage previewLanguage;

  const TemplateProfessionalPreview({
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
      return const Color(0xFF1E3A5F);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Professional header with photo
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _primaryColor,
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
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
                      ? Icon(Icons.person, color: _primaryColor, size: 36)
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.profile.fullName.isEmpty
                            ? 'Your Name'
                            : draft.profile.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          draft.profile.jobTitle.isEmpty
                              ? 'Professional Title'
                              : draft.profile.jobTitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.95),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contact bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(color: _primaryColor.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (draft.contact.email.isNotEmpty)
                  _buildProfContact(Icons.email_outlined, draft.contact.email),
                if (draft.contact.phone.isNotEmpty)
                  _buildProfContact(Icons.phone_outlined, draft.contact.phone),
                if (draft.contact.location.isNotEmpty)
                  _buildProfContact(
                    Icons.location_on_outlined,
                    draft.contact.location,
                  ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (draft.profile.summary.isNotEmpty) ...[
                    _buildProfSection('Professional Summary'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(color: _primaryColor, width: 3),
                        ),
                      ),
                      child: Text(
                        draft.profile.summary,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.7,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildProfSection(_strings.workExperience),
                  const SizedBox(height: 12),
                  ...draft.experiences.take(2).map((exp) => _buildProfExp(exp)),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfSection(_strings.education),
                            const SizedBox(height: 12),
                            ...draft.educations
                                .take(2)
                                .map((edu) => _buildProfEdu(edu)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfSection(_strings.skills),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: draft.skills
                                  .take(8)
                                  .map(
                                    (skill) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _primaryColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        skill.name,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            if (draft.languages.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              _buildProfSection(_strings.languages),
                              const SizedBox(height: 12),
                              ...draft.languages.map(
                                (lang) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          lang.name,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _primaryColor.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          _strings.languageLevel(
                                            lang.level.displayName,
                                          ),
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: _primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (draft.hobbies.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              _buildProfSection(_strings.interests),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: draft.hobbies
                                    .map(
                                      (hobby) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _primaryColor.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          hobby.name,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: _primaryColor,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfContact(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _primaryColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: _primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfSection(String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
      ],
    );
  }

  Widget _buildProfExp(dynamic exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: _primaryColor, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exp.position,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      exp.dateRange,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  exp.companyName,
                  style: TextStyle(
                    fontSize: 10,
                    color: _primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfEdu(dynamic edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            edu.degree,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(
            edu.institution,
            style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
