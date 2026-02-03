import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/resume_draft.dart';
import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/sections/skill.dart';

/// Infographic Template - Visual data focused
class TemplateInfographicPreview extends StatelessWidget {
  final ResumeDraft draft;
  final ResumeLanguage previewLanguage;

  const TemplateInfographicPreview({
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
      return const Color(0xFF3498DB);
    }
  }

  Color get _secondaryColor {
    try {
      final hex = draft.template.secondaryColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFFE74C3C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Row(
        children: [
          // Left sidebar with visual elements
          Container(
            width: 200,
            padding: const EdgeInsets.all(20),
            color: _primaryColor,
            child: Column(
              children: [
                // Profile circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    color: Colors.white,
                    image: draft.profile.avatarUrl != null
                        ? DecorationImage(image: FileImage(File(draft.profile.avatarUrl!)), fit: BoxFit.cover)
                        : null,
                  ),
                  child: draft.profile.avatarUrl == null
                      ? Icon(Icons.person, size: 40, color: _primaryColor)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  draft.profile.fullName.isEmpty ? 'Your Name' : draft.profile.fullName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Text(
                  draft.profile.jobTitle.isEmpty ? 'Job Title' : draft.profile.jobTitle,
                  style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.9)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Contact icons
                _buildInfoContact(Icons.email, draft.contact.email),
                _buildInfoContact(Icons.phone, draft.contact.phone),
                _buildInfoContact(Icons.location_on, draft.contact.location),
                const SizedBox(height: 24),

                // Skills with visual bars
                Text(_strings.skills.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                const SizedBox(height: 12),
                ...draft.skills.take(5).map((skill) => _buildSkillBar(skill)),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary with icon
                  if (draft.profile.summary.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.person_outline, color: _primaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(_strings.aboutMe.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(draft.profile.summary, style: TextStyle(fontSize: 10, height: 1.6, color: Colors.grey.shade700)),
                    const SizedBox(height: 20),
                  ],

                  // Experience with timeline visual
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.work_outline, color: _secondaryColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(_strings.workExperience.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...draft.experiences.take(2).map((exp) => _buildInfoExp(exp)),
                  const SizedBox(height: 16),

                  // Education
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.school_outlined, color: Colors.green, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(_strings.education.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...draft.educations.take(2).map((edu) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(edu.degree, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                              Text(edu.institution, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContact(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.8)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.9)), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildSkillBar(Skill skill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(skill.name, style: const TextStyle(fontSize: 9, color: Colors.white)),
          const SizedBox(height: 3),
          Container(
            height: 4,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: skill.level.percentage / 100,
              child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoExp(dynamic exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _secondaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp.position, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                Text('${exp.companyName} • ${exp.dateRange}', style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Timeline Template - Career progression
class TemplateTimelinePreview extends StatelessWidget {
  final ResumeDraft draft;
  final ResumeLanguage previewLanguage;

  const TemplateTimelinePreview({
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
      return const Color(0xFF9B59B6);
    }
  }

  Color get _secondaryColor {
    try {
      final hex = draft.template.secondaryColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFFE91E63);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.profile.fullName.isEmpty ? _strings.yourName : draft.profile.fullName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        draft.profile.jobTitle.isEmpty ? _strings.jobTitle : draft.profile.jobTitle,
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
                // Contact
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (draft.contact.email.isNotEmpty)
                      Text(draft.contact.email, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.9))),
                    if (draft.contact.phone.isNotEmpty)
                      Text(draft.contact.phone, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ],
            ),
          ),

          // Body with timeline
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_strings.workExperience.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 16),
                        ...draft.experiences.asMap().entries.take(3).map((entry) {
                          final index = entry.key;
                          final exp = entry.value;
                          return _buildTimelineItem(exp, index == 0, index == math.min(2, draft.experiences.length - 1));
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Sidebar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Education
                        Text(_strings.education.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        ...draft.educations.take(2).map((edu) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _primaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _primaryColor.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(edu.degree, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                Text(edu.institution, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
                                Text(edu.dateRange, style: TextStyle(fontSize: 8, color: _primaryColor)),
                              ],
                            ),
                          ),
                        )),
                        const SizedBox(height: 16),

                        // Skills
                        Text(_strings.skills.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: draft.skills.take(8).map((skill) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [_primaryColor, _secondaryColor]),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(skill.name, style: const TextStyle(fontSize: 8, color: Colors.white)),
                          )).toList(),
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

  Widget _buildTimelineItem(dynamic exp, bool isFirst, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_primaryColor, _secondaryColor]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.circle, size: 6, color: Colors.white),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryColor, _secondaryColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exp.dateRange, style: TextStyle(fontSize: 9, color: _primaryColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(exp.position, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(exp.companyName, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                  if (exp.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(exp.description, style: TextStyle(fontSize: 9, color: Colors.grey.shade700, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient Template - Modern gradient colors
class TemplateGradientPreview extends StatelessWidget {
  final ResumeDraft draft;
  final ResumeLanguage previewLanguage;

  const TemplateGradientPreview({
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
      return const Color(0xFF667EEA);
    }
  }

  Color get _secondaryColor {
    try {
      final hex = draft.template.secondaryColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF764BA2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryColor.withValues(alpha: 0.05), _secondaryColor.withValues(alpha: 0.1)],
        ),
      ),
      child: Column(
        children: [
          // Gradient header card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryColor, _secondaryColor],
              ),
              borderRadius: BorderRadius.circular(20),
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
                // Avatar with gradient border
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.4)]),
                  ),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: draft.profile.avatarUrl != null
                          ? DecorationImage(image: FileImage(File(draft.profile.avatarUrl!)), fit: BoxFit.cover)
                          : null,
                    ),
                    child: draft.profile.avatarUrl == null
                        ? Icon(Icons.person, color: _primaryColor, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.profile.fullName.isEmpty ? _strings.yourName : draft.profile.fullName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        draft.profile.jobTitle.isEmpty ? _strings.jobTitle : draft.profile.jobTitle,
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main content
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (draft.profile.summary.isNotEmpty) ...[
                          _buildGradientSection(_strings.aboutMe),
                          Text(draft.profile.summary, style: TextStyle(fontSize: 10, height: 1.6, color: Colors.grey.shade700)),
                          const SizedBox(height: 16),
                        ],
                        _buildGradientSection(_strings.workExperience),
                        ...draft.experiences.take(2).map((exp) => _buildGradientCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(exp.position, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              Text('${exp.companyName} • ${exp.dateRange}', style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Sidebar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGradientSection(_strings.contact),
                        _buildGradientCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (draft.contact.email.isNotEmpty)
                                _buildGradientContact(Icons.email, draft.contact.email),
                              if (draft.contact.phone.isNotEmpty)
                                _buildGradientContact(Icons.phone, draft.contact.phone),
                              if (draft.contact.location.isNotEmpty)
                                _buildGradientContact(Icons.location_on, draft.contact.location),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildGradientSection(_strings.skills),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: draft.skills.take(6).map((skill) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [_primaryColor.withValues(alpha: 0.8), _secondaryColor.withValues(alpha: 0.8)]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(skill.name, style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w500)),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGradientSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(colors: [_primaryColor, _secondaryColor]).createShader(bounds),
        child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildGradientCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildGradientContact(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(colors: [_primaryColor, _secondaryColor]).createShader(bounds),
            child: Icon(icon, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 9, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

