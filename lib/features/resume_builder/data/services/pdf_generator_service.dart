import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/resume_draft.dart';
import '../../domain/entities/sections/skill.dart';
import '../../domain/entities/template.dart';

/// Service for generating PDF from resume draft
class PdfGeneratorService {
  pw.Font? _regularFont;
  pw.Font? _boldFont;
  pw.Font? _thaiRegularFont;
  pw.Font? _thaiBoldFont;

  /// Load fonts with Thai support
  Future<void> _loadFonts() async {
    if (_regularFont != null && _boldFont != null) return;

    // Load Noto Sans (Latin) as base font
    final regularData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');

    // Load Noto Sans Thai for Thai characters
    final thaiRegularData = await rootBundle.load('assets/fonts/NotoSansThai-Regular.ttf');
    final thaiBoldData = await rootBundle.load('assets/fonts/NotoSansThai-Bold.ttf');

    _regularFont = pw.Font.ttf(regularData);
    _boldFont = pw.Font.ttf(boldData);
    _thaiRegularFont = pw.Font.ttf(thaiRegularData);
    _thaiBoldFont = pw.Font.ttf(thaiBoldData);
  }

  pw.TextStyle _textStyle({
    double fontSize = 10,
    bool bold = false,
    PdfColor? color,
    double? lineSpacing,
    double? letterSpacing,
  }) {
    return pw.TextStyle(
      font: bold ? _boldFont : _regularFont,
      fontBold: _boldFont,
      fontFallback: [
        if (bold) _thaiBoldFont! else _thaiRegularFont!,
      ],
      fontSize: fontSize,
      color: color,
      lineSpacing: lineSpacing,
      letterSpacing: letterSpacing,
    );
  }

  /// Generate PDF bytes from a resume draft
  /// [templateType] - Optional template type to override the draft's template
  Future<Uint8List> generatePdf(ResumeDraft draft, {TemplateType? templateType}) async {
    // Load fonts first
    await _loadFonts();

    final pdf = pw.Document();

    // Load profile image if exists
    pw.ImageProvider? profileImage;
    if (draft.profile.avatarUrl != null) {
      try {
        final file = File(draft.profile.avatarUrl!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          profileImage = pw.MemoryImage(bytes);
        }
      } catch (_) {
        // Ignore image loading errors
      }
    }

    // Use provided templateType or fall back to draft's template
    final selectedTemplate = templateType ?? draft.template.type;

    // Use template's default colors if a different template is selected
    final String primaryColorHex;
    final String secondaryColorHex;

    if (templateType != null && templateType != draft.template.type) {
      // Use the selected template's default colors
      primaryColorHex = selectedTemplate.defaultPrimaryColor;
      secondaryColorHex = selectedTemplate.defaultSecondaryColor;
    } else {
      // Use the draft's custom colors
      primaryColorHex = draft.template.primaryColor;
      secondaryColorHex = draft.template.secondaryColor;
    }

    final primaryColor = _hexToColor(primaryColorHex);
    final secondaryColor = _hexToColor(secondaryColorHex);

    switch (selectedTemplate) {
      case TemplateType.templateA:
        pdf.addPage(_buildTemplateAPage(draft, primaryColor));
        break;
      case TemplateType.templateB:
      case TemplateType.creative:
      case TemplateType.infographic:
        pdf.addPage(_buildTemplateBPage(draft, primaryColor, profileImage));
        break;
      case TemplateType.elegant:
        pdf.addPage(_buildElegantPage(draft, primaryColor, secondaryColor));
        break;
      case TemplateType.professional:
      case TemplateType.executive:
        pdf.addPage(_buildProfessionalPage(draft, primaryColor, secondaryColor, profileImage));
        break;
      case TemplateType.minimal:
        pdf.addPage(_buildMinimalPage(draft, primaryColor));
        break;
      case TemplateType.bold:
        pdf.addPage(_buildBoldPage(draft, primaryColor, secondaryColor));
        break;
      case TemplateType.tech:
        pdf.addPage(_buildTechPage(draft, primaryColor));
        break;
      case TemplateType.timeline:
      case TemplateType.gradient:
        pdf.addPage(_buildTimelinePage(draft, primaryColor, secondaryColor));
        break;
    }

    return pdf.save();
  }

  PdfColor _hexToColor(String hex) {
    try {
      final hexCode = hex.replaceFirst('#', '');
      return PdfColor.fromHex(hexCode);
    } catch (_) {
      return PdfColors.blueGrey800;
    }
  }

  /// Template A - Classic style
  pw.Page _buildTemplateAPage(ResumeDraft draft, PdfColor primaryColor) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Text(
              draft.profile.fullName.isEmpty ? 'Your Name' : draft.profile.fullName,
              style: _textStyle(fontSize: 28, bold: true, color: primaryColor),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              draft.profile.jobTitle.isEmpty ? 'Job Title' : draft.profile.jobTitle,
              style: _textStyle(fontSize: 14, color: PdfColors.grey700),
            ),
            pw.Divider(height: 20, color: PdfColors.grey300),

            // Contact
            pw.Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (draft.contact.email.isNotEmpty)
                  _buildContactItem('Email: ${draft.contact.email}'),
                if (draft.contact.phone.isNotEmpty)
                  _buildContactItem('Phone: ${draft.contact.phone}'),
                if (draft.contact.location.isNotEmpty) _buildContactItem(draft.contact.location),
              ],
            ),
            pw.SizedBox(height: 20),

            // Summary
            if (draft.profile.summary.isNotEmpty) ...[
              _buildSectionTitle('Professional Summary', primaryColor),
              pw.SizedBox(height: 8),
              pw.Text(draft.profile.summary, style: _textStyle(fontSize: 10, lineSpacing: 4)),
              pw.SizedBox(height: 16),
            ],

            // Experience
            if (draft.experiences.isNotEmpty) ...[
              _buildSectionTitle('Work Experience', primaryColor),
              pw.SizedBox(height: 8),
              ...draft.experiences.map(
                (exp) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(exp.position, style: _textStyle(fontSize: 11, bold: true)),
                          pw.Text(
                            exp.dateRange,
                            style: _textStyle(fontSize: 9, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                      pw.Text(
                        '${exp.companyName} • ${exp.location}',
                        style: _textStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                      if (exp.description.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(exp.description, style: _textStyle(fontSize: 9, lineSpacing: 3)),
                      ],
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            // Education
            if (draft.educations.isNotEmpty) ...[
              _buildSectionTitle('Education', primaryColor),
              pw.SizedBox(height: 8),
              ...draft.educations.map(
                (edu) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              '${edu.degree} in ${edu.fieldOfStudy}',
                              style: _textStyle(fontSize: 11, bold: true),
                            ),
                          ),
                          pw.Text(
                            edu.dateRange,
                            style: _textStyle(fontSize: 9, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                      pw.Text(
                        edu.institution,
                        style: _textStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            // Skills
            if (draft.skills.isNotEmpty) ...[
              _buildSectionTitle('Skills', primaryColor),
              pw.SizedBox(height: 8),
              pw.Wrap(
                spacing: 8,
                runSpacing: 6,
                children: draft.skills
                    .map(
                      (skill) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(skill.name, style: _textStyle(fontSize: 9)),
                      ),
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 12),
            ],

            // Projects
            if (draft.projects.isNotEmpty) ...[
              _buildSectionTitle('Projects', primaryColor),
              pw.SizedBox(height: 8),
              ...draft.projects.map(
                (project) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(project.name, style: _textStyle(fontSize: 11, bold: true)),
                      pw.SizedBox(height: 2),
                      pw.Text(project.description, style: _textStyle(fontSize: 9, lineSpacing: 3)),
                      if (project.technologies.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          project.technologies.join(' • '),
                          style: _textStyle(fontSize: 8, color: PdfColors.grey600),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Template B - Modern style with sidebar
  pw.Page _buildTemplateBPage(
    ResumeDraft draft,
    PdfColor primaryColor,
    pw.ImageProvider? profileImage,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Sidebar
            pw.Container(
              width: 180,
              height: double.infinity,
              color: primaryColor,
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Avatar
                  pw.Center(
                    child: pw.Container(
                      width: 80,
                      height: 80,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: PdfColors.white,
                        image: profileImage != null
                            ? pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover)
                            : null,
                      ),
                      child: profileImage == null
                          ? pw.Center(
                              child: pw.Text(
                                draft.profile.fullName.isNotEmpty
                                    ? draft.profile.fullName[0].toUpperCase()
                                    : '?',
                                style: pw.TextStyle(
                                  fontSize: 32,
                                  color: primaryColor,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  pw.SizedBox(height: 24),

                  // Contact
                  _buildSidebarSection('Contact'),
                  if (draft.contact.email.isNotEmpty) _buildSidebarItem(draft.contact.email),
                  if (draft.contact.phone.isNotEmpty) _buildSidebarItem(draft.contact.phone),
                  if (draft.contact.location.isNotEmpty) _buildSidebarItem(draft.contact.location),
                  if (draft.contact.website != null) _buildSidebarItem(draft.contact.website!),
                  if (draft.contact.linkedIn != null) _buildSidebarItem(draft.contact.linkedIn!),
                  pw.SizedBox(height: 16),

                  // Skills
                  if (draft.skills.isNotEmpty) ...[
                    _buildSidebarSection('Skills'),
                    ...draft.skills.map((skill) => _buildSkillBar(skill)),
                  ],
                ],
              ),
            ),

            // Main content
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(24),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header
                    pw.Text(
                      draft.profile.fullName.isEmpty ? 'Your Name' : draft.profile.fullName,
                      style: _textStyle(fontSize: 26, bold: true, color: primaryColor),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: primaryColor.shade(0.9),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        draft.profile.jobTitle.isEmpty ? 'Job Title' : draft.profile.jobTitle,
                        style: _textStyle(fontSize: 12, bold: true, color: PdfColors.white),
                      ),
                    ),
                    pw.SizedBox(height: 20),

                    // Summary
                    if (draft.profile.summary.isNotEmpty) ...[
                      _buildMainSectionTitle('About Me', primaryColor),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        draft.profile.summary,
                        style: _textStyle(fontSize: 10, lineSpacing: 4),
                      ),
                      pw.SizedBox(height: 16),
                    ],

                    // Experience
                    if (draft.experiences.isNotEmpty) ...[
                      _buildMainSectionTitle('Experience', primaryColor),
                      pw.SizedBox(height: 8),
                      ...draft.experiences.map(
                        (exp) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 12),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(exp.position, style: _textStyle(fontSize: 11, bold: true)),
                              pw.Row(
                                children: [
                                  pw.Text(
                                    exp.companyName,
                                    style: _textStyle(fontSize: 10, color: primaryColor),
                                  ),
                                  pw.SizedBox(width: 8),
                                  pw.Text(
                                    exp.dateRange,
                                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                                  ),
                                ],
                              ),
                              if (exp.description.isNotEmpty) ...[
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  exp.description,
                                  style: _textStyle(fontSize: 9, lineSpacing: 3),
                                  maxLines: 3,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Education
                    if (draft.educations.isNotEmpty) ...[
                      _buildMainSectionTitle('Education', primaryColor),
                      pw.SizedBox(height: 8),
                      ...draft.educations.map(
                        (edu) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                '${edu.degree} in ${edu.fieldOfStudy}',
                                style: _textStyle(fontSize: 11, bold: true),
                              ),
                              pw.Text(
                                '${edu.institution} • ${edu.dateRange}',
                                style: _textStyle(fontSize: 9, color: PdfColors.grey600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Projects
                    if (draft.projects.isNotEmpty) ...[
                      _buildMainSectionTitle('Projects', primaryColor),
                      pw.SizedBox(height: 8),
                      ...draft.projects.map(
                        (project) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 10),
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(10),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey300),
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  project.name,
                                  style: _textStyle(fontSize: 11, bold: true, color: primaryColor),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  project.description,
                                  style: _textStyle(fontSize: 9, lineSpacing: 3),
                                  maxLines: 2,
                                ),
                                if (project.technologies.isNotEmpty) ...[
                                  pw.SizedBox(height: 4),
                                  pw.Wrap(
                                    spacing: 4,
                                    runSpacing: 2,
                                    children: project.technologies
                                        .take(4)
                                        .map(
                                          (tech) => pw.Container(
                                            padding: const pw.EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: pw.BoxDecoration(
                                              color: primaryColor.shade(0.9),
                                              borderRadius: pw.BorderRadius.circular(3),
                                            ),
                                            child: pw.Text(
                                              tech,
                                              style: _textStyle(fontSize: 8, color: primaryColor),
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
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  pw.Widget _buildContactItem(String text) {
    return pw.Text(text, style: _textStyle(fontSize: 10, color: PdfColors.grey700));
  }

  pw.Widget _buildSectionTitle(String title, PdfColor primaryColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: _textStyle(fontSize: 12, bold: true, color: primaryColor, letterSpacing: 1),
        ),
        pw.SizedBox(height: 4),
        pw.Container(height: 2, width: 40, color: primaryColor),
      ],
    );
  }

  pw.Widget _buildSidebarSection(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: _textStyle(fontSize: 10, bold: true, color: PdfColors.white, letterSpacing: 1),
          ),
          pw.SizedBox(height: 4),
          pw.Container(height: 2, width: 30, color: PdfColor.fromHex('FFFFFF80')),
        ],
      ),
    );
  }

  pw.Widget _buildSidebarItem(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(text, style: _textStyle(fontSize: 9, color: PdfColors.white)),
    );
  }

  pw.Widget _buildSkillBar(Skill skill) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(skill.name, style: _textStyle(fontSize: 9, color: PdfColors.white)),
          pw.SizedBox(height: 3),
          pw.Container(
            height: 4,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('FFFFFF50'),
              borderRadius: pw.BorderRadius.circular(2),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: skill.level.percentage,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(2),
                    ),
                  ),
                ),
                pw.Expanded(flex: 100 - skill.level.percentage, child: pw.SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMainSectionTitle(String title, PdfColor primaryColor) {
    return pw.Row(
      children: [
        pw.Container(width: 4, height: 16, color: primaryColor),
        pw.SizedBox(width: 8),
        pw.Text(
          title.toUpperCase(),
          style: _textStyle(fontSize: 12, bold: true, color: primaryColor, letterSpacing: 1),
        ),
      ],
    );
  }

  /// Elegant Template - Sophisticated with decorative elements
  pw.Page _buildElegantPage(ResumeDraft draft, PdfColor primaryColor, PdfColor secondaryColor) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Decorative header
            pw.Row(
              children: [
                pw.Expanded(child: pw.Divider(color: secondaryColor)),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                  child: pw.Transform.rotate(
                    angle: 0.785398, // 45 degrees
                    child: pw.Container(
                      width: 8,
                      height: 8,
                      color: secondaryColor,
                    ),
                  ),
                ),
                pw.Expanded(child: pw.Divider(color: secondaryColor)),
              ],
            ),
            pw.SizedBox(height: 20),

            // Name
            pw.Text(
              (draft.profile.fullName.isEmpty ? 'Your Name' : draft.profile.fullName).toUpperCase(),
              style: _textStyle(fontSize: 28, color: primaryColor, letterSpacing: 4),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              draft.profile.jobTitle.isEmpty ? 'Job Title' : draft.profile.jobTitle,
              style: _textStyle(fontSize: 12, color: secondaryColor),
            ),
            pw.SizedBox(height: 20),

            pw.Row(
              children: [
                pw.Expanded(child: pw.Divider(color: secondaryColor)),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                  child: pw.Transform.rotate(
                    angle: 0.785398, // 45 degrees
                    child: pw.Container(
                      width: 8,
                      height: 8,
                      color: secondaryColor,
                    ),
                  ),
                ),
                pw.Expanded(child: pw.Divider(color: secondaryColor)),
              ],
            ),
            pw.SizedBox(height: 20),

            // Contact
            pw.Wrap(
              spacing: 20,
              children: [
                if (draft.contact.email.isNotEmpty)
                  pw.Text(draft.contact.email, style: _textStyle(fontSize: 9, color: PdfColors.grey700)),
                if (draft.contact.phone.isNotEmpty)
                  pw.Text(draft.contact.phone, style: _textStyle(fontSize: 9, color: PdfColors.grey700)),
              ],
            ),
            pw.SizedBox(height: 20),

            // Summary
            if (draft.profile.summary.isNotEmpty) ...[
              pw.Text(
                draft.profile.summary,
                style: _textStyle(fontSize: 10, lineSpacing: 5),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 20),
            ],

            // Two columns
            pw.Expanded(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('EXPERIENCE', style: _textStyle(fontSize: 10, bold: true, color: primaryColor, letterSpacing: 2)),
                        pw.SizedBox(height: 4),
                        pw.Container(height: 1, width: 40, color: secondaryColor),
                        pw.SizedBox(height: 12),
                        ...draft.experiences.take(3).map((exp) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(exp.position, style: _textStyle(fontSize: 10, bold: true)),
                              pw.Text('${exp.companyName} • ${exp.dateRange}', style: _textStyle(fontSize: 9, color: PdfColors.grey600)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 24),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('EDUCATION', style: _textStyle(fontSize: 10, bold: true, color: primaryColor, letterSpacing: 2)),
                        pw.SizedBox(height: 4),
                        pw.Container(height: 1, width: 40, color: secondaryColor),
                        pw.SizedBox(height: 12),
                        ...draft.educations.take(2).map((edu) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(edu.degree, style: _textStyle(fontSize: 10, bold: true)),
                              pw.Text(edu.institution, style: _textStyle(fontSize: 9, color: PdfColors.grey600)),
                            ],
                          ),
                        )),
                        pw.SizedBox(height: 16),
                        pw.Text('SKILLS', style: _textStyle(fontSize: 10, bold: true, color: primaryColor, letterSpacing: 2)),
                        pw.SizedBox(height: 4),
                        pw.Container(height: 1, width: 40, color: secondaryColor),
                        pw.SizedBox(height: 12),
                        pw.Text(
                          draft.skills.take(8).map((s) => '• ${s.name}').join('  '),
                          style: _textStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Professional Template - Corporate style with photo
  pw.Page _buildProfessionalPage(ResumeDraft draft, PdfColor primaryColor, PdfColor secondaryColor, pw.ImageProvider? profileImage) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Column(
          children: [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              color: primaryColor,
              child: pw.Row(
                children: [
                  // Photo
                  pw.Container(
                    width: 60,
                    height: 60,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      color: PdfColors.white,
                      image: profileImage != null ? pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover) : null,
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          draft.profile.fullName.isEmpty ? 'Your Name' : draft.profile.fullName,
                          style: _textStyle(fontSize: 22, bold: true, color: PdfColors.white),
                        ),
                        pw.Text(
                          draft.profile.jobTitle.isEmpty ? 'Job Title' : draft.profile.jobTitle,
                          style: _textStyle(fontSize: 11, color: PdfColors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Contact bar
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              color: primaryColor.shade(0.9),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  if (draft.contact.email.isNotEmpty)
                    pw.Text(draft.contact.email, style: _textStyle(fontSize: 9, color: primaryColor)),
                  if (draft.contact.phone.isNotEmpty)
                    pw.Text(draft.contact.phone, style: _textStyle(fontSize: 9, color: primaryColor)),
                  if (draft.contact.location.isNotEmpty)
                    pw.Text(draft.contact.location, style: _textStyle(fontSize: 9, color: primaryColor)),
                ],
              ),
            ),
            // Body
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(24),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (draft.profile.summary.isNotEmpty) ...[
                      pw.Text('PROFESSIONAL SUMMARY', style: _textStyle(fontSize: 11, bold: true, color: primaryColor, letterSpacing: 1)),
                      pw.SizedBox(height: 8),
                      pw.Text(draft.profile.summary, style: _textStyle(fontSize: 10, lineSpacing: 4)),
                      pw.SizedBox(height: 16),
                    ],
                    pw.Text('EXPERIENCE', style: _textStyle(fontSize: 11, bold: true, color: primaryColor, letterSpacing: 1)),
                    pw.SizedBox(height: 8),
                    ...draft.experiences.take(3).map((exp) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 10),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(width: 6, height: 6, margin: const pw.EdgeInsets.only(top: 3), decoration: pw.BoxDecoration(color: primaryColor, shape: pw.BoxShape.circle)),
                          pw.SizedBox(width: 8),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(exp.position, style: _textStyle(fontSize: 10, bold: true)),
                                pw.Text('${exp.companyName} • ${exp.dateRange}', style: _textStyle(fontSize: 9, color: PdfColors.grey600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('EDUCATION', style: _textStyle(fontSize: 11, bold: true, color: primaryColor, letterSpacing: 1)),
                              pw.SizedBox(height: 8),
                              ...draft.educations.take(2).map((edu) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 8),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(edu.degree, style: _textStyle(fontSize: 10, bold: true)),
                                    pw.Text(edu.institution, style: _textStyle(fontSize: 9, color: PdfColors.grey600)),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 24),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('SKILLS', style: _textStyle(fontSize: 11, bold: true, color: primaryColor, letterSpacing: 1)),
                              pw.SizedBox(height: 8),
                              pw.Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: draft.skills.take(8).map((skill) => pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: pw.BoxDecoration(border: pw.Border.all(color: primaryColor), borderRadius: pw.BorderRadius.circular(3)),
                                  child: pw.Text(skill.name, style: _textStyle(fontSize: 8, color: primaryColor)),
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
        );
      },
    );
  }

  /// Minimal Template - Ultra clean
  pw.Page _buildMinimalPage(ResumeDraft draft, PdfColor primaryColor) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(48),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              draft.profile.fullName.isEmpty ? 'Your Name' : draft.profile.fullName,
              style: _textStyle(fontSize: 32),
            ),
            pw.SizedBox(height: 4),
            pw.Text(draft.profile.jobTitle.isEmpty ? 'Job Title' : draft.profile.jobTitle, style: _textStyle(fontSize: 12, color: PdfColors.grey500)),
            pw.SizedBox(height: 24),
            pw.Container(height: 0.5, color: PdfColors.grey300),
            pw.SizedBox(height: 24),
            pw.Wrap(
              spacing: 20,
              children: [
                if (draft.contact.email.isNotEmpty) pw.Text(draft.contact.email, style: _textStyle(fontSize: 9, color: PdfColors.grey600)),
                if (draft.contact.phone.isNotEmpty) pw.Text(draft.contact.phone, style: _textStyle(fontSize: 9, color: PdfColors.grey600)),
                if (draft.contact.location.isNotEmpty) pw.Text(draft.contact.location, style: _textStyle(fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
            pw.SizedBox(height: 24),
            if (draft.profile.summary.isNotEmpty) ...[
              pw.Text(draft.profile.summary, style: _textStyle(fontSize: 10, lineSpacing: 5, color: PdfColors.grey700)),
              pw.SizedBox(height: 24),
            ],
            if (draft.experiences.isNotEmpty) ...[
              pw.Text('Experience', style: _textStyle(fontSize: 10, bold: true, letterSpacing: 2)),
              pw.SizedBox(height: 12),
              ...draft.experiences.take(3).map((exp) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 12),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(width: 80, child: pw.Text(exp.dateRange, style: _textStyle(fontSize: 9, color: PdfColors.grey500))),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(exp.position, style: _textStyle(fontSize: 10, bold: true)),
                          pw.Text(exp.companyName, style: _textStyle(fontSize: 9, color: PdfColors.grey600)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              pw.SizedBox(height: 16),
            ],
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (draft.educations.isNotEmpty)
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Education', style: _textStyle(fontSize: 10, bold: true, letterSpacing: 2)),
                        pw.SizedBox(height: 8),
                        ...draft.educations.take(2).map((edu) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(edu.degree, style: _textStyle(fontSize: 10)),
                              pw.Text(edu.institution, style: _textStyle(fontSize: 9, color: PdfColors.grey500)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                if (draft.skills.isNotEmpty)
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Skills', style: _textStyle(fontSize: 10, bold: true, letterSpacing: 2)),
                        pw.SizedBox(height: 8),
                        pw.Text(draft.skills.take(8).map((s) => s.name).join(' • '), style: _textStyle(fontSize: 9, color: PdfColors.grey700, lineSpacing: 4)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Bold Template - Strong typography
  pw.Page _buildBoldPage(ResumeDraft draft, PdfColor primaryColor, PdfColor accentColor) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Column(
          children: [
            // Dark header
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              color: PdfColors.grey900,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    (draft.profile.fullName.isEmpty ? 'YOUR NAME' : draft.profile.fullName).toUpperCase(),
                    style: _textStyle(fontSize: 32, bold: true, color: PdfColors.white, letterSpacing: 2),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: accentColor,
                    child: pw.Text(
                      (draft.profile.jobTitle.isEmpty ? 'JOB TITLE' : draft.profile.jobTitle).toUpperCase(),
                      style: _textStyle(fontSize: 10, bold: true, color: PdfColors.black, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            pw.Expanded(
              child: pw.Container(
                margin: const pw.EdgeInsets.only(left: 24),
                decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: accentColor, width: 3))),
                child: pw.Container(
                  color: PdfColors.white,
                  padding: const pw.EdgeInsets.all(24),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Wrap(
                        spacing: 16,
                        children: [
                          if (draft.contact.email.isNotEmpty) pw.Text(draft.contact.email, style: _textStyle(fontSize: 9, color: PdfColors.grey700)),
                          if (draft.contact.phone.isNotEmpty) pw.Text(draft.contact.phone, style: _textStyle(fontSize: 9, color: PdfColors.grey700)),
                        ],
                      ),
                      pw.SizedBox(height: 20),
                      if (draft.profile.summary.isNotEmpty) ...[
                        pw.Text(draft.profile.summary, style: _textStyle(fontSize: 10, lineSpacing: 4)),
                        pw.SizedBox(height: 20),
                      ],
                      if (draft.experiences.isNotEmpty) ...[
                        pw.Row(children: [
                          pw.Container(width: 20, height: 2, color: accentColor),
                          pw.SizedBox(width: 8),
                          pw.Text('EXPERIENCE', style: _textStyle(fontSize: 11, bold: true, letterSpacing: 2)),
                        ]),
                        pw.SizedBox(height: 12),
                        ...draft.experiences.take(3).map((exp) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 12),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(exp.position.toUpperCase(), style: _textStyle(fontSize: 10, bold: true)),
                              pw.Text('${exp.companyName} | ${exp.dateRange}', style: _textStyle(fontSize: 9, color: PdfColors.grey600)),
                            ],
                          ),
                        )),
                        pw.SizedBox(height: 12),
                      ],
                      if (draft.skills.isNotEmpty) ...[
                        pw.Row(children: [
                          pw.Container(width: 20, height: 2, color: accentColor),
                          pw.SizedBox(width: 8),
                          pw.Text('SKILLS', style: _textStyle(fontSize: 11, bold: true, letterSpacing: 2)),
                        ]),
                        pw.SizedBox(height: 12),
                        pw.Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: draft.skills.take(8).map((skill) => pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            color: PdfColors.black,
                            child: pw.Text(skill.name.toUpperCase(), style: _textStyle(fontSize: 8, bold: true, color: PdfColors.white)),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Tech Template - Developer focused
  pw.Page _buildTechPage(ResumeDraft draft, PdfColor primaryColor) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: PdfColor.fromHex('1a1a2e'),
          child: pw.Column(
            children: [
              // Terminal header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(width: 10, height: 10, decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFF5F56), shape: pw.BoxShape.circle)),
                        pw.SizedBox(width: 6),
                        pw.Container(width: 10, height: 10, decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFBD2E), shape: pw.BoxShape.circle)),
                        pw.SizedBox(width: 6),
                        pw.Container(width: 10, height: 10, decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF27C93F), shape: pw.BoxShape.circle)),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(text: '> ', style: _textStyle(fontSize: 12, color: primaryColor)),
                          pw.TextSpan(text: draft.profile.fullName.isEmpty ? 'developer' : draft.profile.fullName, style: _textStyle(fontSize: 12, bold: true, color: PdfColors.white)),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(text: '  role: ', style: _textStyle(fontSize: 10, color: PdfColors.grey500)),
                          pw.TextSpan(text: '"${draft.profile.jobTitle.isEmpty ? 'Software Engineer' : draft.profile.jobTitle}"', style: _textStyle(fontSize: 10, color: primaryColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              pw.Expanded(
                child: pw.Container(
                  color: PdfColor.fromHex('16213e'),
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('// About', style: _textStyle(fontSize: 10, bold: true, color: primaryColor)),
                            pw.SizedBox(height: 8),
                            if (draft.profile.summary.isNotEmpty)
                              pw.Text(draft.profile.summary, style: _textStyle(fontSize: 9, color: PdfColors.grey300, lineSpacing: 4)),
                            pw.SizedBox(height: 16),
                            pw.Text('// Experience', style: _textStyle(fontSize: 10, bold: true, color: primaryColor)),
                            pw.SizedBox(height: 8),
                            ...draft.experiences.take(3).map((exp) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 10),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(exp.position, style: _textStyle(fontSize: 10, color: PdfColors.white)),
                                  pw.Text('${exp.companyName} • ${exp.dateRange}', style: _textStyle(fontSize: 9, color: PdfColors.grey500)),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('// Contact', style: _textStyle(fontSize: 10, bold: true, color: primaryColor)),
                            pw.SizedBox(height: 8),
                            if (draft.contact.email.isNotEmpty)
                              pw.Text('email: ${draft.contact.email}', style: _textStyle(fontSize: 9, color: PdfColors.white)),
                            if (draft.contact.phone.isNotEmpty)
                              pw.Text('phone: ${draft.contact.phone}', style: _textStyle(fontSize: 9, color: PdfColors.white)),
                            pw.SizedBox(height: 16),
                            pw.Text('// Tech Stack', style: _textStyle(fontSize: 10, bold: true, color: primaryColor)),
                            pw.SizedBox(height: 8),
                            pw.Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: draft.skills.take(8).map((skill) => pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: pw.BoxDecoration(border: pw.Border.all(color: primaryColor.shade(0.5)), borderRadius: pw.BorderRadius.circular(3)),
                                child: pw.Text(skill.name, style: _textStyle(fontSize: 8, color: primaryColor)),
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
      },
    );
  }


  /// Timeline Template - Career progression with gradient header
  pw.Page _buildTimelinePage(ResumeDraft draft, PdfColor primaryColor, PdfColor secondaryColor) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Column(
          children: [
            // Header with gradient effect (simulated)
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              color: primaryColor,
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          draft.profile.fullName.isEmpty ? 'Your Name' : draft.profile.fullName,
                          style: _textStyle(fontSize: 24, bold: true, color: PdfColors.white),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          draft.profile.jobTitle.isEmpty ? 'Job Title' : draft.profile.jobTitle,
                          style: _textStyle(fontSize: 11, color: PdfColors.white),
                        ),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      if (draft.contact.email.isNotEmpty)
                        pw.Text(draft.contact.email, style: _textStyle(fontSize: 9, color: PdfColors.white)),
                      if (draft.contact.phone.isNotEmpty)
                        pw.Text(draft.contact.phone, style: _textStyle(fontSize: 9, color: PdfColors.white)),
                    ],
                  ),
                ],
              ),
            ),
            // Body
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(24),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Timeline
                    pw.Expanded(
                      flex: 2,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('CAREER JOURNEY', style: _textStyle(fontSize: 11, bold: true, letterSpacing: 1)),
                          pw.SizedBox(height: 16),
                          ...draft.experiences.take(3).toList().asMap().entries.map((entry) {
                            final index = entry.key;
                            final exp = entry.value;
                            final isLast = index == 2 || index == draft.experiences.length - 1;
                            return pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Column(
                                  children: [
                                    pw.Container(
                                      width: 12,
                                      height: 12,
                                      decoration: pw.BoxDecoration(color: primaryColor, shape: pw.BoxShape.circle),
                                    ),
                                    if (!isLast) pw.Container(width: 2, height: 50, color: secondaryColor),
                                  ],
                                ),
                                pw.SizedBox(width: 12),
                                pw.Expanded(
                                  child: pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 16),
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(exp.dateRange, style: _textStyle(fontSize: 9, bold: true, color: primaryColor)),
                                        pw.SizedBox(height: 4),
                                        pw.Text(exp.position, style: _textStyle(fontSize: 10, bold: true)),
                                        pw.Text(exp.companyName, style: _textStyle(fontSize: 9, color: PdfColors.grey600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 24),
                    // Sidebar
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('EDUCATION', style: _textStyle(fontSize: 11, bold: true, letterSpacing: 1)),
                          pw.SizedBox(height: 12),
                          ...draft.educations.take(2).map((edu) => pw.Container(
                            margin: const pw.EdgeInsets.only(bottom: 10),
                            padding: const pw.EdgeInsets.all(10),
                            decoration: pw.BoxDecoration(
                              color: primaryColor.shade(0.95),
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(edu.degree, style: _textStyle(fontSize: 10, bold: true)),
                                pw.Text(edu.institution, style: _textStyle(fontSize: 9, color: PdfColors.grey600)),
                              ],
                            ),
                          )),
                          pw.SizedBox(height: 16),
                          pw.Text('SKILLS', style: _textStyle(fontSize: 11, bold: true, letterSpacing: 1)),
                          pw.SizedBox(height: 12),
                          pw.Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: draft.skills.take(8).map((skill) => pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: pw.BoxDecoration(color: primaryColor, borderRadius: pw.BorderRadius.circular(12)),
                              child: pw.Text(skill.name, style: _textStyle(fontSize: 8, color: PdfColors.white)),
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
        );
      },
    );
  }
}
