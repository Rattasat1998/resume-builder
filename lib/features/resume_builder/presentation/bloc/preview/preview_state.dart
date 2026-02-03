part of 'preview_cubit.dart';

/// States for the PreviewCubit
sealed class PreviewState extends Equatable {
  const PreviewState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
class PreviewInitial extends PreviewState {
  const PreviewInitial();
}

/// State when the preview is loaded and ready
class PreviewLoaded extends PreviewState {
  final ResumeDraft draft;
  final TemplateType currentTemplate;
  final ResumeLanguage previewLanguage;
  final bool isZoomed;
  final double zoomLevel;

  const PreviewLoaded({
    required this.draft,
    required this.currentTemplate,
    this.previewLanguage = ResumeLanguage.english,
    this.isZoomed = false,
    this.zoomLevel = 1.0,
  });

  PreviewLoaded copyWith({
    ResumeDraft? draft,
    TemplateType? currentTemplate,
    ResumeLanguage? previewLanguage,
    bool? isZoomed,
    double? zoomLevel,
  }) {
    return PreviewLoaded(
      draft: draft ?? this.draft,
      currentTemplate: currentTemplate ?? this.currentTemplate,
      previewLanguage: previewLanguage ?? this.previewLanguage,
      isZoomed: isZoomed ?? this.isZoomed,
      zoomLevel: zoomLevel ?? this.zoomLevel,
    );
  }

  @override
  List<Object?> get props => [draft, currentTemplate, previewLanguage, isZoomed, zoomLevel];
}

/// State when PDF export is in progress
class PreviewExporting extends PreviewState {
  final ResumeDraft draft;
  final TemplateType currentTemplate;
  final ResumeLanguage previewLanguage;

  const PreviewExporting({
    required this.draft,
    required this.currentTemplate,
    this.previewLanguage = ResumeLanguage.english,
  });

  @override
  List<Object?> get props => [draft, currentTemplate, previewLanguage];
}

/// State when PDF export is completed
class PreviewExported extends PreviewState {
  final ResumeDraft draft;
  final TemplateType currentTemplate;
  final ResumeLanguage previewLanguage;
  final Uint8List pdfData;

  const PreviewExported({
    required this.draft,
    required this.currentTemplate,
    this.previewLanguage = ResumeLanguage.english,
    required this.pdfData,
  });

  @override
  List<Object?> get props => [draft, currentTemplate, previewLanguage, pdfData];
}

/// Error state
class PreviewError extends PreviewState {
  final String message;

  const PreviewError(this.message);

  @override
  List<Object?> get props => [message];
}

