import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/resume_draft.dart';
import '../../../domain/entities/resume_language.dart';

/// Enum representing the different sections in the resume builder
enum BuilderSection {
  profile,
  contact,
  experience,
  education,
  skills,
  projects,
  languages,
  hobbies,
}

extension BuilderSectionExtension on BuilderSection {
  String get title {
    switch (this) {
      case BuilderSection.profile:
        return 'Profile';
      case BuilderSection.contact:
        return 'Contact';
      case BuilderSection.experience:
        return 'Experience';
      case BuilderSection.education:
        return 'Education';
      case BuilderSection.skills:
        return 'Skills';
      case BuilderSection.projects:
        return 'Projects';
      case BuilderSection.languages:
        return 'Languages';
      case BuilderSection.hobbies:
        return 'Hobbies';
    }
  }

  String localizedTitle(ResumeLanguage lang) {
    if (lang == ResumeLanguage.thai) {
      switch (this) {
        case BuilderSection.profile:
          return 'ข้อมูลส่วนตัว';
        case BuilderSection.contact:
          return 'ข้อมูลติดต่อ';
        case BuilderSection.experience:
          return 'ประสบการณ์';
        case BuilderSection.education:
          return 'การศึกษา';
        case BuilderSection.skills:
          return 'ทักษะ';
        case BuilderSection.projects:
          return 'ผลงาน';
        case BuilderSection.languages:
          return 'ภาษา';
        case BuilderSection.hobbies:
          return 'งานอดิเรก';
      }
    }
    return title;
  }

  int get index {
    return BuilderSection.values.indexOf(this);
  }
}

/// States for the BuilderBloc
sealed class BuilderState extends Equatable {
  const BuilderState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
class BuilderInitial extends BuilderState {
  const BuilderInitial();
}

/// Loading state
class BuilderLoading extends BuilderState {
  const BuilderLoading();
}

/// State when the draft is loaded and ready for editing
class BuilderLoaded extends BuilderState {
  final ResumeDraft draft;
  final BuilderSection currentSection;
  final ResumeLanguage uiLanguage;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final String? errorMessage;
  final String? exportError;

  const BuilderLoaded({
    required this.draft,
    this.currentSection = BuilderSection.profile,
    this.uiLanguage = ResumeLanguage.english,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.errorMessage,
    this.exportError,
  });

  BuilderLoaded copyWith({
    ResumeDraft? draft,
    BuilderSection? currentSection,
    ResumeLanguage? uiLanguage,
    bool? isSaving,
    bool? hasUnsavedChanges,
    String? errorMessage,
    String? exportError,
  }) {
    return BuilderLoaded(
      draft: draft ?? this.draft,
      currentSection: currentSection ?? this.currentSection,
      uiLanguage: uiLanguage ?? this.uiLanguage,
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      errorMessage: errorMessage,
      exportError: exportError,
    );
  }

  @override
  List<Object?> get props => [
    draft,
    currentSection,
    uiLanguage,
    isSaving,
    hasUnsavedChanges,
    errorMessage,
    exportError,
  ];
}

/// State when export is in progress
class BuilderExporting extends BuilderState {
  final ResumeDraft draft;

  const BuilderExporting({required this.draft});

  @override
  List<Object?> get props => [draft];
}

/// State when export is completed
class BuilderExported extends BuilderState {
  final ResumeDraft draft;
  final Uint8List pdfData;

  const BuilderExported({required this.draft, required this.pdfData});

  @override
  List<Object?> get props => [draft, pdfData];
}

/// Error state
class BuilderError extends BuilderState {
  final String message;
  final String? errorCode;

  const BuilderError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}
