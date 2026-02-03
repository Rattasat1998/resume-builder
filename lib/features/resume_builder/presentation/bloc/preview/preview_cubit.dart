import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/services/pdf_generator_service.dart';
import '../../../data/services/widget_to_pdf_service.dart';
import '../../../domain/entities/resume_draft.dart';
import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/template.dart';

part 'preview_state.dart';

/// Cubit for managing the resume preview state
class PreviewCubit extends Cubit<PreviewState> {
  final PdfGeneratorService _pdfService;
  final WidgetToPdfService _widgetToPdfService;
  GlobalKey? _captureKey;

  PreviewCubit({PdfGeneratorService? pdfService, WidgetToPdfService? widgetToPdfService})
      : _pdfService = pdfService ?? PdfGeneratorService(),
        _widgetToPdfService = widgetToPdfService ?? WidgetToPdfService(),
        super(const PreviewInitial());

  /// Set the capture key for widget-to-PDF conversion
  void setCaptureKey(GlobalKey key) {
    _captureKey = key;
  }

  void loadPreview(ResumeDraft draft) {
    emit(PreviewLoaded(
      draft: draft,
      currentTemplate: draft.template.type,
    ));
  }

  void updateDraft(ResumeDraft draft) {
    final currentState = state;
    if (currentState is PreviewLoaded) {
      emit(currentState.copyWith(draft: draft));
    } else {
      emit(PreviewLoaded(
        draft: draft,
        currentTemplate: draft.template.type,
      ));
    }
  }

  void changeTemplate(TemplateType templateType) {
    final currentState = state;
    if (currentState is PreviewLoaded) {
      emit(currentState.copyWith(currentTemplate: templateType));
    }
  }

  void changeLanguage(ResumeLanguage language) {
    final currentState = state;
    if (currentState is PreviewLoaded) {
      emit(currentState.copyWith(previewLanguage: language));
    }
  }

  void toggleZoom() {
    final currentState = state;
    if (currentState is PreviewLoaded) {
      emit(currentState.copyWith(isZoomed: !currentState.isZoomed));
    }
  }

  void setZoomLevel(double zoomLevel) {
    final currentState = state;
    if (currentState is PreviewLoaded) {
      emit(currentState.copyWith(zoomLevel: zoomLevel.clamp(0.5, 2.0)));
    }
  }

  /// Export PDF by capturing the preview widget
  /// This ensures the exported PDF looks exactly like the preview
  Future<void> exportPdf() async {
    final currentState = state;
    if (currentState is! PreviewLoaded) return;

    emit(PreviewExporting(
      draft: currentState.draft,
      currentTemplate: currentState.currentTemplate,
      previewLanguage: currentState.previewLanguage,
    ));

    try {
      Uint8List pdfData;

      // Try to capture widget first for exact match
      if (_captureKey != null) {
        try {
          pdfData = await _widgetToPdfService.generatePdfFromWidget(_captureKey!);
        } catch (e) {
          // Fallback to PDF generator if widget capture fails
          debugPrint('Widget capture failed, falling back to PDF generator: $e');
          pdfData = await _pdfService.generatePdf(
            currentState.draft,
            templateType: currentState.currentTemplate,
          );
        }
      } else {
        // No capture key, use PDF generator
        pdfData = await _pdfService.generatePdf(
          currentState.draft,
          templateType: currentState.currentTemplate,
        );
      }

      emit(PreviewExported(
        draft: currentState.draft,
        currentTemplate: currentState.currentTemplate,
        previewLanguage: currentState.previewLanguage,
        pdfData: pdfData,
      ));
    } catch (e) {
      emit(PreviewError('Failed to generate PDF: $e'));
    }
  }

  void resetToLoaded() {
    final currentState = state;
    if (currentState is PreviewExported) {
      emit(PreviewLoaded(
        draft: currentState.draft,
        currentTemplate: currentState.currentTemplate,
        previewLanguage: currentState.previewLanguage,
      ));
    }
  }
}

