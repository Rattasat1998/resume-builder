import 'package:equatable/equatable.dart';

import '../../../domain/entities/resume_language.dart';
import '../../../domain/entities/sections/contact.dart';
import '../../../domain/entities/sections/education.dart';
import '../../../domain/entities/sections/experience.dart';
import '../../../domain/entities/sections/hobby.dart';
import '../../../domain/entities/sections/language.dart';
import '../../../domain/entities/sections/profile.dart';
import '../../../domain/entities/sections/project.dart';
import '../../../domain/entities/sections/skill.dart';
import '../../../domain/entities/template.dart';

/// Events for the BuilderBloc
sealed class BuilderEvent extends Equatable {
  const BuilderEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the builder with a new or existing draft
class BuilderInitialized extends BuilderEvent {
  final String? draftId;

  const BuilderInitialized({this.draftId});

  @override
  List<Object?> get props => [draftId];
}

/// Load an existing draft
class BuilderDraftLoaded extends BuilderEvent {
  final String draftId;

  const BuilderDraftLoaded(this.draftId);

  @override
  List<Object?> get props => [draftId];
}

/// Create a new draft
class BuilderDraftCreated extends BuilderEvent {
  final String? title;

  const BuilderDraftCreated({this.title});

  @override
  List<Object?> get props => [title];
}

/// Update the draft title
class BuilderTitleUpdated extends BuilderEvent {
  final String title;

  const BuilderTitleUpdated(this.title);

  @override
  List<Object?> get props => [title];
}

/// Update the profile section
class BuilderProfileUpdated extends BuilderEvent {
  final Profile profile;

  const BuilderProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Update the contact section
class BuilderContactUpdated extends BuilderEvent {
  final Contact contact;

  const BuilderContactUpdated(this.contact);

  @override
  List<Object?> get props => [contact];
}

/// Add an experience item
class BuilderExperienceAdded extends BuilderEvent {
  final Experience experience;

  const BuilderExperienceAdded(this.experience);

  @override
  List<Object?> get props => [experience];
}

/// Update an experience item
class BuilderExperienceUpdated extends BuilderEvent {
  final Experience experience;

  const BuilderExperienceUpdated(this.experience);

  @override
  List<Object?> get props => [experience];
}

/// Remove an experience item
class BuilderExperienceRemoved extends BuilderEvent {
  final String experienceId;

  const BuilderExperienceRemoved(this.experienceId);

  @override
  List<Object?> get props => [experienceId];
}

/// Reorder experience items
class BuilderExperiencesReordered extends BuilderEvent {
  final List<String> orderedIds;

  const BuilderExperiencesReordered(this.orderedIds);

  @override
  List<Object?> get props => [orderedIds];
}

/// Add an education item
class BuilderEducationAdded extends BuilderEvent {
  final Education education;

  const BuilderEducationAdded(this.education);

  @override
  List<Object?> get props => [education];
}

/// Update an education item
class BuilderEducationUpdated extends BuilderEvent {
  final Education education;

  const BuilderEducationUpdated(this.education);

  @override
  List<Object?> get props => [education];
}

/// Remove an education item
class BuilderEducationRemoved extends BuilderEvent {
  final String educationId;

  const BuilderEducationRemoved(this.educationId);

  @override
  List<Object?> get props => [educationId];
}

/// Reorder education items
class BuilderEducationsReordered extends BuilderEvent {
  final List<String> orderedIds;

  const BuilderEducationsReordered(this.orderedIds);

  @override
  List<Object?> get props => [orderedIds];
}

/// Add a skill item
class BuilderSkillAdded extends BuilderEvent {
  final Skill skill;

  const BuilderSkillAdded(this.skill);

  @override
  List<Object?> get props => [skill];
}

/// Update a skill item
class BuilderSkillUpdated extends BuilderEvent {
  final Skill skill;

  const BuilderSkillUpdated(this.skill);

  @override
  List<Object?> get props => [skill];
}

/// Remove a skill item
class BuilderSkillRemoved extends BuilderEvent {
  final String skillId;

  const BuilderSkillRemoved(this.skillId);

  @override
  List<Object?> get props => [skillId];
}

/// Reorder skill items
class BuilderSkillsReordered extends BuilderEvent {
  final List<String> orderedIds;

  const BuilderSkillsReordered(this.orderedIds);

  @override
  List<Object?> get props => [orderedIds];
}

/// Add a project item
class BuilderProjectAdded extends BuilderEvent {
  final Project project;

  const BuilderProjectAdded(this.project);

  @override
  List<Object?> get props => [project];
}

/// Update a project item
class BuilderProjectUpdated extends BuilderEvent {
  final Project project;

  const BuilderProjectUpdated(this.project);

  @override
  List<Object?> get props => [project];
}

/// Remove a project item
class BuilderProjectRemoved extends BuilderEvent {
  final String projectId;

  const BuilderProjectRemoved(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Reorder project items
class BuilderProjectsReordered extends BuilderEvent {
  final List<String> orderedIds;

  const BuilderProjectsReordered(this.orderedIds);

  @override
  List<Object?> get props => [orderedIds];
}

/// Add a language item
class BuilderLanguageAdded extends BuilderEvent {
  final Language language;

  const BuilderLanguageAdded(this.language);

  @override
  List<Object?> get props => [language];
}

/// Update a language item
class BuilderLanguageUpdated extends BuilderEvent {
  final Language language;

  const BuilderLanguageUpdated(this.language);

  @override
  List<Object?> get props => [language];
}

/// Remove a language item
class BuilderLanguageRemoved extends BuilderEvent {
  final String languageId;

  const BuilderLanguageRemoved(this.languageId);

  @override
  List<Object?> get props => [languageId];
}

/// Add a hobby item
class BuilderHobbyAdded extends BuilderEvent {
  final Hobby hobby;

  const BuilderHobbyAdded(this.hobby);

  @override
  List<Object?> get props => [hobby];
}

/// Update a hobby item
class BuilderHobbyUpdated extends BuilderEvent {
  final Hobby hobby;

  const BuilderHobbyUpdated(this.hobby);

  @override
  List<Object?> get props => [hobby];
}

/// Remove a hobby item
class BuilderHobbyRemoved extends BuilderEvent {
  final String hobbyId;

  const BuilderHobbyRemoved(this.hobbyId);

  @override
  List<Object?> get props => [hobbyId];
}

/// Update the template
class BuilderTemplateUpdated extends BuilderEvent {
  final Template template;

  const BuilderTemplateUpdated(this.template);

  @override
  List<Object?> get props => [template];
}

/// Navigate to a specific section
class BuilderSectionChanged extends BuilderEvent {
  final int sectionIndex;

  const BuilderSectionChanged(this.sectionIndex);

  @override
  List<Object?> get props => [sectionIndex];
}

/// Trigger autosave
class BuilderAutosaveRequested extends BuilderEvent {
  const BuilderAutosaveRequested();
}

/// Export the resume as PDF
class BuilderExportRequested extends BuilderEvent {
  const BuilderExportRequested();
}

/// Change UI language
class BuilderUILanguageChanged extends BuilderEvent {
  final ResumeLanguage language;

  const BuilderUILanguageChanged(this.language);

  @override
  List<Object?> get props => [language];
}

