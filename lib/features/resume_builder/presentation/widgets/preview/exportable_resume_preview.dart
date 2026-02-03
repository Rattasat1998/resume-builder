import 'package:flutter/material.dart';

import '../../../domain/entities/resume_draft.dart';
import '../../../domain/entities/template.dart';
import 'template_a_preview.dart';
import 'template_b_preview.dart';
import 'template_elegant_creative_professional.dart';
import 'template_infographic_timeline_gradient.dart';
import 'template_minimal_bold_tech_executive.dart';

/// A4 size constants (in logical pixels at 72 DPI)
/// A4 = 210mm x 297mm = 595pt x 842pt
class A4Size {
  static const double width = 595.0;
  static const double height = 842.0;
  static const double aspectRatio = width / height;
}

/// Widget that renders resume preview at exact A4 size
/// Use this for both preview display and PDF export
class ExportableResumePreview extends StatelessWidget {
  final ResumeDraft draft;
  final TemplateType templateType;
  final GlobalKey? captureKey;

  const ExportableResumePreview({
    super.key,
    required this.draft,
    required this.templateType,
    this.captureKey,
  });

  @override
  Widget build(BuildContext context) {
    final content = RepaintBoundary(
      key: captureKey,
      child: Container(
        width: A4Size.width,
        height: A4Size.height,
        color: Colors.white,
        child: _buildTemplateContent(),
      ),
    );

    return content;
  }

  Widget _buildTemplateContent() {
    switch (templateType) {
      case TemplateType.templateA:
        return TemplateAPreview(draft: draft);
      case TemplateType.templateB:
        return TemplateBPreview(draft: draft);
      case TemplateType.creative:
        return TemplateCreativePreview(draft: draft);
      case TemplateType.professional:
        return TemplateProfessionalPreview(draft: draft);
      case TemplateType.infographic:
        return TemplateInfographicPreview(draft: draft);
      case TemplateType.timeline:
        return TemplateTimelinePreview(draft: draft);
      case TemplateType.gradient:
        return TemplateGradientPreview(draft: draft);
      case TemplateType.minimal:
        return TemplateMinimalPreview(draft: draft);
      case TemplateType.bold:
        return TemplateBoldPreview(draft: draft);
      case TemplateType.tech:
        return TemplateTechPreview(draft: draft);
      case TemplateType.executive:
        return TemplateExecutivePreview(draft: draft);
      case TemplateType.elegant:
        return TemplateElegantPreview(draft: draft);
    }
  }
}

/// Widget for displaying scaled preview (fits in available space)
class ScaledResumePreview extends StatelessWidget {
  final ResumeDraft draft;
  final TemplateType templateType;
  final GlobalKey? captureKey;

  const ScaledResumePreview({
    super.key,
    required this.draft,
    required this.templateType,
    this.captureKey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate scale to fit in available space
        final scaleX = constraints.maxWidth / A4Size.width;
        final scaleY = constraints.maxHeight / A4Size.height;
        final scale = scaleX < scaleY ? scaleX : scaleY;

        return Center(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Transform.scale(
                scale: scale,
                child: ExportableResumePreview(
                  draft: draft,
                  templateType: templateType,
                  captureKey: captureKey,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Full-screen preview with capture capability
class CaptureableResumePreview extends StatefulWidget {
  final ResumeDraft draft;
  final TemplateType templateType;
  final void Function(GlobalKey)? onKeyReady;

  const CaptureableResumePreview({
    super.key,
    required this.draft,
    required this.templateType,
    this.onKeyReady,
  });

  @override
  State<CaptureableResumePreview> createState() => _CaptureableResumePreviewState();
}

class _CaptureableResumePreviewState extends State<CaptureableResumePreview> {
  final GlobalKey _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onKeyReady?.call(_captureKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaledResumePreview(
      draft: widget.draft,
      templateType: widget.templateType,
      captureKey: _captureKey,
    );
  }
}

