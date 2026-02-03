import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:resume_builder/core/utils/neon_holo_tilt.dart';
import 'package:resume_builder/core/utils/tilt_glare.dart';

import '../../domain/entities/resume_draft.dart';
import '../../domain/entities/resume_language.dart';
import '../../domain/entities/template.dart';
import '../bloc/preview/preview_cubit.dart';
import '../widgets/preview/template_a_preview.dart';
import '../widgets/preview/template_b_preview.dart';
import '../widgets/preview/template_elegant_creative_professional.dart';
import '../widgets/preview/template_minimal_bold_tech_executive.dart';
import '../widgets/preview/template_infographic_timeline_gradient.dart';

/// Page for previewing the resume with different templates
class PreviewPage extends StatefulWidget {
  final ResumeDraft draft;

  const PreviewPage({super.key, required this.draft});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final GlobalKey _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Set capture key after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PreviewCubit>().setCaptureKey(_captureKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreviewCubit, PreviewState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F7),
          // backgroundColor: Colors.transparent,
          body: SafeArea(child: _buildBody(context, state)),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PreviewState state) {
    if (state is PreviewInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PreviewLoaded) {
      return _buildPreviewLayout(context, state);
    }

    if (state is PreviewExporting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Generating PDF...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (state is PreviewExported) {
      return _buildExportedView(context, state);
    }

    if (state is PreviewError) {
      return _buildErrorView(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildPreviewLayout(BuildContext context, PreviewLoaded state) {
    // A4 size in points
    const double a4Width = 595.28;
    const double a4Height = 841.89;

    final previewWidget = _getPreviewWidget(state);

    return Stack(
      children: [
        // Main visible layout
        Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(context, state),

            // Template Selector
            _buildTemplateSelector(context, state),

            // Preview Area
            Expanded(child: _buildPreviewArea(context, state)),

            // Bottom Action Bar
            _buildBottomActionBar(context, state),
          ],
        ),

        // Hidden capture widget at actual A4 size (off-screen)
        Positioned(
          left: -a4Width - 100, // Position off-screen
          top: 0,
          child: RepaintBoundary(
            key: _captureKey,
            child: Container(
              width: a4Width,
              height: a4Height,
              color: Colors.white,
              child: previewWidget,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getPreviewWidget(PreviewLoaded state) {
    final lang = state.previewLanguage;
    return switch (state.currentTemplate) {
      TemplateType.templateA => TemplateAPreview(draft: state.draft, previewLanguage: lang),
      TemplateType.templateB => TemplateBPreview(draft: state.draft, previewLanguage: lang),
      TemplateType.elegant => TemplateElegantPreview(draft: state.draft, previewLanguage: lang),
      TemplateType.creative => TemplateCreativePreview(draft: state.draft, previewLanguage: lang),
      TemplateType.professional => TemplateProfessionalPreview(
        draft: state.draft,
        previewLanguage: lang,
      ),
      TemplateType.minimal => TemplateMinimalPreview(draft: state.draft, previewLanguage: lang),
      TemplateType.bold => TemplateBoldPreview(draft: state.draft, previewLanguage: lang),
      TemplateType.tech => TemplateTechPreview(draft: state.draft, previewLanguage: lang),
      TemplateType.executive => TemplateExecutivePreview(draft: state.draft, previewLanguage: lang),
      TemplateType.infographic => TemplateInfographicPreview(
        draft: state.draft,
        previewLanguage: lang,
      ),
      TemplateType.timeline => TemplateTimelinePreview(draft: state.draft, previewLanguage: lang),
      TemplateType.gradient => TemplateGradientPreview(draft: state.draft, previewLanguage: lang),
    };
  }

  Widget _buildCustomAppBar(BuildContext context, PreviewLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Back',
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resume Preview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                ),
                Text(
                  state.currentTemplate.displayName,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Language Switcher
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: ResumeLanguage.values.map((lang) {
                final isSelected = state.previewLanguage == lang;
                return GestureDetector(
                  onTap: () => context.read<PreviewCubit>().changeLanguage(lang),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lang == ResumeLanguage.english ? 'EN' : 'TH',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Zoom Button
          Container(
            decoration: BoxDecoration(
              color: state.isZoomed
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                state.isZoomed ? Icons.zoom_out_rounded : Icons.zoom_in_rounded,
                color: state.isZoomed ? Theme.of(context).primaryColor : Colors.grey.shade700,
              ),
              onPressed: () => context.read<PreviewCubit>().toggleZoom(),
              tooltip: state.isZoomed ? 'Zoom Out' : 'Zoom In',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSelector(BuildContext context, PreviewLoaded state) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: TemplateType.values.length,
        itemBuilder: (context, index) {
          final template = TemplateType.values[index];
          final isSelected = state.currentTemplate == template;

          return GestureDetector(
            onTap: () => context.read<PreviewCubit>().changeTemplate(template),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getTemplateColor(template),
                          _getTemplateColor(template).withValues(alpha: 0.7),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _getTemplateColor(template).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getTemplateIcon(template),
                    size: 24,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    template.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewArea(BuildContext context, PreviewLoaded state) {
    final previewWidget = _getPreviewWidget(state);

    // A4 size in points: 595.28 x 841.89
    const double a4Width = 595.28;
    const double a4Height = 841.89;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate scale to fit A4 in available space with padding
        final availableWidth = constraints.maxWidth - 32; // 16px padding each side
        final availableHeight = constraints.maxHeight - 32;

        // Scale to fit while maintaining aspect ratio
        double scale = (availableWidth / a4Width).clamp(0.0, 1.0);
        if (a4Height * scale > availableHeight) {
          scale = availableHeight / a4Height;
        }

        // Apply zoom
        final zoomScale = state.isZoomed ? 1.0 : scale;
        final documentWidth = a4Width * zoomScale;
        final documentHeight = a4Height * zoomScale;

        final document = Container(
          width: documentWidth,
          height: documentHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 32,
                spreadRadius: 0,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(width: a4Width, height: a4Height, child: previewWidget),
          ),
        );

        if (state.isZoomed) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(200),
            child: Center(child: document),
          );
        }

        return Center(
          child: Padding(padding: const EdgeInsets.all(16), child: document),
        );
      },
    );
  }

  Widget _buildBottomActionBar(BuildContext context, PreviewLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Edit Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.edit_outlined, size: 20),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Export Button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => context.read<PreviewCubit>().exportPdf(),
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text('Export PDF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportedView(BuildContext context, PreviewExported state) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => context.read<PreviewCubit>().resetToLoaded(),
                  tooltip: 'Back to Preview',
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDF Ready',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Your resume is ready to share',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
              ),
            ],
          ),
        ),

        // PDF Preview
         SizedBox(
          width: 500,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: TiltGlareContainer(
              child: PdfPreview(
                build: (_) => state.pdfData,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                allowPrinting: false,
                allowSharing: false,
                maxPageWidth: 500,
                pdfFileName: '${state.draft.title}.pdf',
              ),
            ),
          ),
        ),
         /*Expanded(
          child: Container(
            color: const Color(0xFFF5F5F7),
            child: PdfPreview(
              build: (_) => state.pdfData,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              allowPrinting: false,
              allowSharing: false,
              maxPageWidth: 500,
              pdfFileName: '${state.draft.title}.pdf',
            ),
          ),
        ),*/

        // Action Buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Print Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _printPdf(context, state),
                  icon: const Icon(Icons.print_outlined, size: 20),
                  label: const Text('Print'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Share Button
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _sharePdf(context, state),
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: const Text('Share PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, PreviewError state) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade400),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<PreviewCubit>().loadPreview(widget.draft),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTemplateColor(TemplateType template) {
    switch (template) {
      case TemplateType.templateA:
        return const Color(0xFF1a1a1a);
      case TemplateType.templateB:
        return const Color(0xFF2c3e50);
      case TemplateType.elegant:
        return const Color(0xFF8B4513);
      case TemplateType.creative:
        return const Color(0xFFFF6B6B);
      case TemplateType.professional:
        return const Color(0xFF1E3A5F);
      case TemplateType.minimal:
        return const Color(0xFF333333);
      case TemplateType.bold:
        return const Color(0xFF000000);
      case TemplateType.tech:
        return const Color(0xFF00D4AA);
      case TemplateType.executive:
        return const Color(0xFF2C3E50);
      case TemplateType.infographic:
        return const Color(0xFF3498DB);
      case TemplateType.timeline:
        return const Color(0xFF9B59B6);
      case TemplateType.gradient:
        return const Color(0xFF667EEA);
    }
  }

  IconData _getTemplateIcon(TemplateType template) {
    switch (template) {
      case TemplateType.templateA:
        return Icons.description_outlined;
      case TemplateType.templateB:
        return Icons.dashboard_outlined;
      case TemplateType.elegant:
        return Icons.auto_awesome_outlined;
      case TemplateType.creative:
        return Icons.palette_outlined;
      case TemplateType.professional:
        return Icons.business_center_outlined;
      case TemplateType.minimal:
        return Icons.crop_square_outlined;
      case TemplateType.bold:
        return Icons.format_bold_outlined;
      case TemplateType.tech:
        return Icons.code_outlined;
      case TemplateType.executive:
        return Icons.workspace_premium_outlined;
      case TemplateType.infographic:
        return Icons.insert_chart_outlined;
      case TemplateType.timeline:
        return Icons.timeline_outlined;
      case TemplateType.gradient:
        return Icons.gradient_outlined;
    }
  }

  Future<void> _sharePdf(BuildContext context, PreviewExported state) async {
    try {
      await Printing.sharePdf(
        bytes: state.pdfData,
        filename: '${state.draft.title.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _printPdf(BuildContext context, PreviewExported state) async {
    await Printing.layoutPdf(onLayout: (_) async => state.pdfData, name: state.draft.title);
  }
}
