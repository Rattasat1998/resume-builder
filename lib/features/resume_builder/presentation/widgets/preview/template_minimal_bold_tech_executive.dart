import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/entities/resume_draft.dart';
import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/sections/skill.dart';

/// Minimal Template - Ultra clean, whitespace-focused design
class TemplateMinimalPreview extends StatelessWidget {
  final ResumeDraft draft;
  final ResumeLanguage previewLanguage;

  const TemplateMinimalPreview({
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
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Elegant minimal header
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.profile.fullName.isEmpty ? _strings.yourName : draft.profile.fullName,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w200,
                          letterSpacing: 2,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        child: Text(
                          draft.profile.jobTitle.isEmpty ? _strings.jobTitle : draft.profile.jobTitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Contact info aligned right
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (draft.contact.email.isNotEmpty)
                      _buildMinimalContact(draft.contact.email),
                    if (draft.contact.phone.isNotEmpty)
                      _buildMinimalContact(draft.contact.phone),
                    if (draft.contact.location.isNotEmpty)
                      _buildMinimalContact(draft.contact.location),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Elegant thin line
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade200, Colors.transparent],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Summary with refined typography
            if (draft.profile.summary.isNotEmpty) ...[
              Text(
                draft.profile.summary,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.9,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 40),
            ],

            // Two column layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Experience
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMinimalSectionTitle(_strings.workExperience),
                      const SizedBox(height: 16),
                      ...draft.experiences.take(3).map((exp) => _buildMinimalExperience(exp)),
                    ],
                  ),
                ),

                const SizedBox(width: 40),

                // Right column - Education & Skills
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMinimalSectionTitle(_strings.education),
                      const SizedBox(height: 16),
                      ...draft.educations.take(2).map((edu) => _buildMinimalEducation(edu)),

                      const SizedBox(height: 32),

                      _buildMinimalSectionTitle(_strings.expertise),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 0,
                        runSpacing: 8,
                        children: draft.skills.take(6).map((skill) =>
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Text(
                              skill.name,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
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

  Widget _buildMinimalContact(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMinimalSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 3,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildMinimalExperience(dynamic exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exp.position,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                exp.companyName,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Text(
                exp.dateRange,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          if (exp.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              exp.description,
              style: TextStyle(
                fontSize: 9,
                height: 1.6,
                color: Colors.grey.shade500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMinimalEducation(dynamic edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            edu.degree,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            edu.institution,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bold Template - High contrast, impactful design
class TemplateBoldPreview extends StatelessWidget {
  final ResumeDraft draft;
  final ResumeLanguage previewLanguage;

  const TemplateBoldPreview({
    super.key,
    required this.draft,
    this.previewLanguage = ResumeLanguage.english,
  });

  ResumeStrings get _strings => ResumeStrings(previewLanguage);

  Color get _accentColor {
    try {
      final hex = draft.template.secondaryColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFFFFD700);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0D0D),
      child: Column(
        children: [
          // Dramatic header
          Container(
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Accent line
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Name with dramatic typography
                Text(
                  draft.profile.fullName.isEmpty
                      ? _strings.yourName.toUpperCase()
                      : draft.profile.fullName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                    height: 0.9,
                  ),
                ),
                const SizedBox(height: 16),

                // Job title with accent background
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    draft.profile.jobTitle.isEmpty
                        ? _strings.jobTitle.toUpperCase()
                        : draft.profile.jobTitle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contact row
                    Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      children: [
                        if (draft.contact.email.isNotEmpty)
                          _buildBoldContact(Icons.email_outlined, draft.contact.email),
                        if (draft.contact.phone.isNotEmpty)
                          _buildBoldContact(Icons.phone_outlined, draft.contact.phone),
                        if (draft.contact.location.isNotEmpty)
                          _buildBoldContact(Icons.location_on_outlined, draft.contact.location),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Summary
                    if (draft.profile.summary.isNotEmpty) ...[
                      Text(
                        draft.profile.summary,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.8,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Experience
                    if (draft.experiences.isNotEmpty) ...[
                      _buildBoldSectionHeader(_strings.workExperience.toUpperCase()),
                      const SizedBox(height: 20),
                      ...draft.experiences.take(2).map((exp) => _buildBoldExperience(exp)),
                    ],

                    // Skills grid
                    if (draft.skills.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildBoldSectionHeader(_strings.skills.toUpperCase()),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: draft.skills.take(8).map((skill) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D0D0D),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            skill.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoldContact(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBoldSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: _accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildBoldExperience(dynamic exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade200,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exp.position.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exp.companyName}  •  ${exp.dateRange}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tech Template - Modern developer-focused design
class TemplateTechPreview extends StatelessWidget {
  final ResumeDraft draft;
  final ResumeLanguage previewLanguage;

  const TemplateTechPreview({
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
      return const Color(0xFF00D4AA);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0F1A),
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        ),
      ),
      child: Column(
        children: [
          // Terminal-style header
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Terminal bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      _buildTerminalDot(const Color(0xFFFF5F56)),
                      const SizedBox(width: 8),
                      _buildTerminalDot(const Color(0xFFFFBD2E)),
                      const SizedBox(width: 8),
                      _buildTerminalDot(const Color(0xFF27C93F)),
                      const SizedBox(width: 16),
                      Text(
                        '~/resume',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),

                // Terminal content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTerminalLine('const', 'developer', '= {'),
                      _buildTerminalProperty('name', draft.profile.fullName.isEmpty ? 'Developer' : draft.profile.fullName),
                      _buildTerminalProperty('role', draft.profile.jobTitle.isEmpty ? 'Software Engineer' : draft.profile.jobTitle),
                      _buildTerminalProperty('email', draft.contact.email),
                      Text(
                        '};',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // About
                        if (draft.profile.summary.isNotEmpty) ...[
                          _buildTechSection('// ${_strings.aboutMe.toLowerCase()}.md'),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            child: Text(
                              draft.profile.summary,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.7,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Experience
                        _buildTechSection('// ${_strings.workExperience.toLowerCase().replaceAll(' ', '_')}.json'),
                        const SizedBox(height: 12),
                        ...draft.experiences.take(2).map((exp) => _buildTechExperience(exp)),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Right column
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTechSection('// ${_strings.skills.toLowerCase().replaceAll(' ', '-')}.yml'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: draft.skills.take(10).map((skill) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _primaryColor.withValues(alpha: 0.2),
                                    _primaryColor.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _primaryColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                skill.name,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: _primaryColor,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Education
                        if (draft.educations.isNotEmpty) ...[
                          _buildTechSection('// ${_strings.education.toLowerCase()}.md'),
                          const SizedBox(height: 12),
                          ...draft.educations.take(2).map((edu) => _buildTechEducation(edu)),
                        ],
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

  Widget _buildTerminalDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTerminalLine(String keyword, String name, String bracket) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        children: [
          TextSpan(text: keyword, style: TextStyle(color: _primaryColor)),
          const TextSpan(text: ' ', style: TextStyle(color: Colors.white)),
          TextSpan(text: name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          TextSpan(text: ' $bracket', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildTerminalProperty(String key, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          children: [
            TextSpan(text: key, style: TextStyle(color: Colors.grey.shade500)),
            const TextSpan(text: ': ', style: TextStyle(color: Colors.white)),
            TextSpan(text: '"$value"', style: TextStyle(color: _primaryColor.withValues(alpha: 0.8))),
            const TextSpan(text: ',', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTechSection(String title) {
    return Row(
      children: [
        Icon(Icons.code, size: 14, color: _primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: _primaryColor,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTechExperience(dynamic exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  exp.dateRange,
                  style: TextStyle(
                    fontSize: 9,
                    color: _primaryColor,
                    fontFamily: 'monospace',
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
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechEducation(dynamic edu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: _primaryColor, width: 2)),
        color: Colors.white.withValues(alpha: 0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            edu.degree,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Text(
            edu.institution,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Executive Template - Premium, sophisticated design
class TemplateExecutivePreview extends StatelessWidget {
  final ResumeDraft draft;
  final ResumeLanguage previewLanguage;

  const TemplateExecutivePreview({
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
      return const Color(0xFF1C2331);
    }
  }

  Color get _goldColor {
    try {
      final hex = draft.template.secondaryColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFFD4AF37);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: Column(
        children: [
          // Premium header
          Container(
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
            child: Column(
              children: [
                // Gold accent line at top
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _goldColor.withValues(alpha: 0.3),
                        _goldColor,
                        _goldColor.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
                  child: Row(
                    children: [
                      // Professional photo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _goldColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: _goldColor.withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                          image: draft.profile.avatarUrl != null
                              ? DecorationImage(
                                  image: FileImage(File(draft.profile.avatarUrl!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.white,
                        ),
                        child: draft.profile.avatarUrl == null
                            ? Icon(Icons.person, size: 40, color: _primaryColor.withValues(alpha: 0.5))
                            : null,
                      ),
                      const SizedBox(width: 24),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              draft.profile.fullName.isEmpty ? _strings.yourName : draft.profile.fullName,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: _goldColor),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                draft.profile.jobTitle.isEmpty
                                    ? _strings.jobTitle.toUpperCase()
                                    : draft.profile.jobTitle.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: _goldColor,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (draft.contact.email.isNotEmpty)
                  _buildExecContact(Icons.email_outlined, draft.contact.email),
                if (draft.contact.phone.isNotEmpty)
                  _buildExecContact(Icons.phone_outlined, draft.contact.phone),
                if (draft.contact.location.isNotEmpty)
                  _buildExecContact(Icons.location_on_outlined, draft.contact.location),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Executive Summary
                  if (draft.profile.summary.isNotEmpty) ...[
                    _buildExecSection(_strings.professionalSummary),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        draft.profile.summary,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.8,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Professional Experience
                  _buildExecSection(_strings.workExperience),
                  const SizedBox(height: 16),
                  ...draft.experiences.take(2).map((exp) => _buildExecExperience(exp)),

                  const SizedBox(height: 24),

                  // Two column layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Education
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildExecSection(_strings.education),
                            const SizedBox(height: 16),
                            ...draft.educations.take(2).map((edu) => _buildExecEducation(edu)),
                          ],
                        ),
                      ),

                      const SizedBox(width: 32),

                      // Core Competencies
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildExecSection(_strings.expertise),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: draft.skills.take(6).map((skill) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [_primaryColor, _primaryColor.withValues(alpha: 0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  skill.name,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )).toList(),
                            ),
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

  Widget _buildExecContact(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _goldColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecSection(String title) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _goldColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildExecExperience(dynamic exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: _goldColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ),
              Text(
                exp.dateRange,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            exp.companyName,
            style: TextStyle(
              fontSize: 11,
              color: _goldColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (exp.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              exp.description,
              style: TextStyle(
                fontSize: 10,
                height: 1.6,
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

  Widget _buildExecEducation(dynamic edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              border: Border.all(color: _goldColor, width: 1.5),
              shape: BoxShape.circle,
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
                Text(
                  edu.institution,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
