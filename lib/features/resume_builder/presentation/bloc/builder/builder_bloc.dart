import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/debounce.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/usecases/autosave_draft.dart';
import '../../../domain/usecases/create_draft.dart';
import '../../../domain/usecases/export_pdf.dart';
import '../../../domain/usecases/load_draft.dart';
import '../../../domain/usecases/remove_item.dart';
import '../../../domain/usecases/reorder_item.dart';
import '../../../domain/usecases/update_section.dart';
import 'builder_event.dart';
import 'builder_state.dart';

/// BLoC for managing the resume builder state
class BuilderBloc extends Bloc<BuilderEvent, BuilderState> {
  final CreateDraft _createDraft;
  final LoadDraft _loadDraft;
  final AutosaveDraft _autosaveDraft;
  final UpdateProfile _updateProfile;
  final UpdateContact _updateContact;
  final UpdateExperience _updateExperience;
  final UpdateEducation _updateEducation;
  final UpdateSkill _updateSkill;
  final UpdateProject _updateProject;
  final UpdateTemplate _updateTemplate;
  final RemoveItem _removeItem;
  final ReorderItem _reorderItem;
  final ExportPdf _exportPdf;

  final Debounce _autosaveDebounce = Debounce(
    duration: const Duration(seconds: 2),
  );

  BuilderBloc({
    required CreateDraft createDraft,
    required LoadDraft loadDraft,
    required AutosaveDraft autosaveDraft,
    required UpdateProfile updateProfile,
    required UpdateContact updateContact,
    required UpdateExperience updateExperience,
    required UpdateEducation updateEducation,
    required UpdateSkill updateSkill,
    required UpdateProject updateProject,
    required UpdateTemplate updateTemplate,
    required RemoveItem removeItem,
    required ReorderItem reorderItem,
    required ExportPdf exportPdf,
  }) : _createDraft = createDraft,
       _loadDraft = loadDraft,
       _autosaveDraft = autosaveDraft,
       _updateProfile = updateProfile,
       _updateContact = updateContact,
       _updateExperience = updateExperience,
       _updateEducation = updateEducation,
       _updateSkill = updateSkill,
       _updateProject = updateProject,
       _updateTemplate = updateTemplate,
       _removeItem = removeItem,
       _reorderItem = reorderItem,
       _exportPdf = exportPdf,
       super(const BuilderInitial()) {
    on<BuilderInitialized>(_onInitialized);
    on<BuilderDraftLoaded>(_onDraftLoaded);
    on<BuilderDraftCreated>(_onDraftCreated);
    on<BuilderTitleUpdated>(_onTitleUpdated);
    on<BuilderProfileUpdated>(_onProfileUpdated);
    on<BuilderContactUpdated>(_onContactUpdated);
    on<BuilderExperienceAdded>(_onExperienceAdded);
    on<BuilderExperienceUpdated>(_onExperienceUpdated);
    on<BuilderExperienceRemoved>(_onExperienceRemoved);
    on<BuilderExperiencesReordered>(_onExperiencesReordered);
    on<BuilderEducationAdded>(_onEducationAdded);
    on<BuilderEducationUpdated>(_onEducationUpdated);
    on<BuilderEducationRemoved>(_onEducationRemoved);
    on<BuilderEducationsReordered>(_onEducationsReordered);
    on<BuilderSkillAdded>(_onSkillAdded);
    on<BuilderSkillUpdated>(_onSkillUpdated);
    on<BuilderSkillRemoved>(_onSkillRemoved);
    on<BuilderSkillsReordered>(_onSkillsReordered);
    on<BuilderProjectAdded>(_onProjectAdded);
    on<BuilderProjectUpdated>(_onProjectUpdated);
    on<BuilderProjectRemoved>(_onProjectRemoved);
    on<BuilderProjectsReordered>(_onProjectsReordered);
    on<BuilderLanguageAdded>(_onLanguageAdded);
    on<BuilderLanguageUpdated>(_onLanguageUpdated);
    on<BuilderLanguageRemoved>(_onLanguageRemoved);
    on<BuilderHobbyAdded>(_onHobbyAdded);
    on<BuilderHobbyUpdated>(_onHobbyUpdated);
    on<BuilderHobbyRemoved>(_onHobbyRemoved);
    on<BuilderTemplateUpdated>(_onTemplateUpdated);
    on<BuilderSectionChanged>(_onSectionChanged);
    on<BuilderAutosaveRequested>(_onAutosaveRequested);
    on<BuilderExportRequested>(_onExportRequested);
    on<BuilderUILanguageChanged>(_onUILanguageChanged);
  }

  @override
  Future<void> close() {
    _autosaveDebounce.dispose();
    return super.close();
  }

  void _scheduleAutosave() {
    _autosaveDebounce.run(() {
      add(const BuilderAutosaveRequested());
    });
  }

  Future<void> _onInitialized(
    BuilderInitialized event,
    Emitter<BuilderState> emit,
  ) async {
    emit(const BuilderLoading());

    if (event.draftId != null) {
      final result = await _loadDraft(event.draftId!);
      result.fold(
        onSuccess: (draft) =>
            emit(BuilderLoaded(draft: draft, uiLanguage: draft.resumeLanguage)),
        onFailure: (failure) => emit(BuilderError(failure.message)),
      );
    } else {
      final result = await _createDraft();
      result.fold(
        onSuccess: (draft) =>
            emit(BuilderLoaded(draft: draft, uiLanguage: draft.resumeLanguage)),
        onFailure: (failure) => emit(BuilderError(failure.message)),
      );
    }
  }

  Future<void> _onDraftLoaded(
    BuilderDraftLoaded event,
    Emitter<BuilderState> emit,
  ) async {
    emit(const BuilderLoading());

    final result = await _loadDraft(event.draftId);
    result.fold(
      onSuccess: (draft) =>
          emit(BuilderLoaded(draft: draft, uiLanguage: draft.resumeLanguage)),
      onFailure: (failure) => emit(BuilderError(failure.message)),
    );
  }

  Future<void> _onDraftCreated(
    BuilderDraftCreated event,
    Emitter<BuilderState> emit,
  ) async {
    emit(const BuilderLoading());

    final result = await _createDraft(title: event.title);
    result.fold(
      onSuccess: (draft) => emit(BuilderLoaded(draft: draft)),
      onFailure: (failure) =>
          emit(BuilderError(failure.message, errorCode: failure.code)),
    );
  }

  Future<void> _onTitleUpdated(
    BuilderTitleUpdated event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final updatedDraft = currentState.draft.copyWith(title: event.title);
    emit(currentState.copyWith(draft: updatedDraft, hasUnsavedChanges: true));
    _scheduleAutosave();
  }

  Future<void> _onProfileUpdated(
    BuilderProfileUpdated event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _updateProfile(currentState.draft.id, event.profile);
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onContactUpdated(
    BuilderContactUpdated event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _updateContact(currentState.draft.id, event.contact);
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onExperienceAdded(
    BuilderExperienceAdded event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _updateExperience.add(
      currentState.draft.id,
      event.experience,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onExperienceUpdated(
    BuilderExperienceUpdated event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _updateExperience.update(
      currentState.draft.id,
      event.experience,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onExperienceRemoved(
    BuilderExperienceRemoved event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _removeItem.removeExperience(
      currentState.draft.id,
      event.experienceId,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onExperiencesReordered(
    BuilderExperiencesReordered event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _reorderItem.reorderExperiences(
      currentState.draft.id,
      event.orderedIds,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onEducationAdded(
    BuilderEducationAdded event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _updateEducation.add(
      currentState.draft.id,
      event.education,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onEducationUpdated(
    BuilderEducationUpdated event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _updateEducation.update(
      currentState.draft.id,
      event.education,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onEducationRemoved(
    BuilderEducationRemoved event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _removeItem.removeEducation(
      currentState.draft.id,
      event.educationId,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onEducationsReordered(
    BuilderEducationsReordered event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _reorderItem.reorderEducations(
      currentState.draft.id,
      event.orderedIds,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onSkillAdded(
    BuilderSkillAdded event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _updateSkill.add(currentState.draft.id, event.skill);
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onSkillUpdated(
    BuilderSkillUpdated event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _updateSkill.update(
      currentState.draft.id,
      event.skill,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onSkillRemoved(
    BuilderSkillRemoved event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _removeItem.removeSkill(
      currentState.draft.id,
      event.skillId,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onSkillsReordered(
    BuilderSkillsReordered event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _reorderItem.reorderSkills(
      currentState.draft.id,
      event.orderedIds,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onProjectAdded(
    BuilderProjectAdded event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _updateProject.add(
      currentState.draft.id,
      event.project,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onProjectUpdated(
    BuilderProjectUpdated event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _updateProject.update(
      currentState.draft.id,
      event.project,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onProjectRemoved(
    BuilderProjectRemoved event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _removeItem.removeProject(
      currentState.draft.id,
      event.projectId,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onProjectsReordered(
    BuilderProjectsReordered event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _reorderItem.reorderProjects(
      currentState.draft.id,
      event.orderedIds,
    );
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  Future<void> _onLanguageAdded(
    BuilderLanguageAdded event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final updatedLanguages = [...currentState.draft.languages, event.language];
    final updatedDraft = currentState.draft.copyWith(
      languages: updatedLanguages,
    );
    emit(currentState.copyWith(draft: updatedDraft, hasUnsavedChanges: true));
    _scheduleAutosave();
  }

  Future<void> _onLanguageUpdated(
    BuilderLanguageUpdated event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final updatedLanguages = currentState.draft.languages.map((lang) {
      return lang.id == event.language.id ? event.language : lang;
    }).toList();
    final updatedDraft = currentState.draft.copyWith(
      languages: updatedLanguages,
    );
    emit(currentState.copyWith(draft: updatedDraft, hasUnsavedChanges: true));
    _scheduleAutosave();
  }

  Future<void> _onLanguageRemoved(
    BuilderLanguageRemoved event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final updatedLanguages = currentState.draft.languages
        .where((lang) => lang.id != event.languageId)
        .toList();
    final updatedDraft = currentState.draft.copyWith(
      languages: updatedLanguages,
    );
    emit(currentState.copyWith(draft: updatedDraft, hasUnsavedChanges: true));
    _scheduleAutosave();
  }

  Future<void> _onHobbyAdded(
    BuilderHobbyAdded event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final updatedHobbies = [...currentState.draft.hobbies, event.hobby];
    final updatedDraft = currentState.draft.copyWith(hobbies: updatedHobbies);
    emit(currentState.copyWith(draft: updatedDraft, hasUnsavedChanges: true));
    _scheduleAutosave();
  }

  Future<void> _onHobbyUpdated(
    BuilderHobbyUpdated event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final updatedHobbies = currentState.draft.hobbies.map((hobby) {
      return hobby.id == event.hobby.id ? event.hobby : hobby;
    }).toList();
    final updatedDraft = currentState.draft.copyWith(hobbies: updatedHobbies);
    emit(currentState.copyWith(draft: updatedDraft, hasUnsavedChanges: true));
    _scheduleAutosave();
  }

  Future<void> _onHobbyRemoved(
    BuilderHobbyRemoved event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final updatedHobbies = currentState.draft.hobbies
        .where((hobby) => hobby.id != event.hobbyId)
        .toList();
    final updatedDraft = currentState.draft.copyWith(hobbies: updatedHobbies);
    emit(currentState.copyWith(draft: updatedDraft, hasUnsavedChanges: true));
    _scheduleAutosave();
  }

  Future<void> _onTemplateUpdated(
    BuilderTemplateUpdated event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final result = await _updateTemplate(currentState.draft.id, event.template);
    result.fold(
      onSuccess: (draft) => emit(currentState.copyWith(draft: draft)),
      onFailure: (failure) =>
          emit(currentState.copyWith(errorMessage: failure.message)),
    );
  }

  void _onSectionChanged(
    BuilderSectionChanged event,
    Emitter<BuilderState> emit,
  ) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final section = BuilderSection.values[event.sectionIndex];
    emit(currentState.copyWith(currentSection: section));
  }

  Future<void> _onAutosaveRequested(
    BuilderAutosaveRequested event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;
    if (!currentState.hasUnsavedChanges) return;

    emit(currentState.copyWith(isSaving: true));

    final result = await _autosaveDraft(currentState.draft);
    result.fold(
      onSuccess: (draft) => emit(
        currentState.copyWith(
          draft: draft,
          isSaving: false,
          hasUnsavedChanges: false,
        ),
      ),
      onFailure: (failure) => emit(
        currentState.copyWith(isSaving: false, errorMessage: failure.message),
      ),
    );
  }

  Future<void> _onExportRequested(
    BuilderExportRequested event,
    Emitter<BuilderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    emit(BuilderExporting(draft: currentState.draft));

    final result = await _exportPdf(currentState.draft);
    result.fold(
      onSuccess: (pdfData) =>
          emit(BuilderExported(draft: currentState.draft, pdfData: pdfData)),
      onFailure: (failure) => emit(
        currentState.copyWith(exportError: failure.code ?? failure.message),
      ),
    );
  }

  void _onUILanguageChanged(
    BuilderUILanguageChanged event,
    Emitter<BuilderState> emit,
  ) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    // Update both UI language and save to draft
    final updatedDraft = currentState.draft.copyWith(
      resumeLanguage: event.language,
      updatedAt: DateTime.now(),
    );

    emit(
      currentState.copyWith(
        uiLanguage: event.language,
        draft: updatedDraft,
        hasUnsavedChanges: true,
      ),
    );

    // Trigger autosave
    _autosaveDebounce.run(() => add(const BuilderAutosaveRequested()));
  }
}
