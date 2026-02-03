import 'dart:typed_data';

import '../../../../core/utils/result.dart';
import '../entities/resume_draft.dart';
import '../entities/sections/contact.dart';
import '../entities/sections/education.dart';
import '../entities/sections/experience.dart';
import '../entities/sections/profile.dart';
import '../entities/sections/project.dart';
import '../entities/sections/skill.dart';
import '../entities/template.dart';

/// Abstract repository interface for resume builder operations
abstract class ResumeBuilderRepository {
  /// Creates a new resume draft
  Future<Result<ResumeDraft>> createDraft({String? title});

  /// Loads a resume draft by ID
  Future<Result<ResumeDraft>> loadDraft(String draftId);

  /// Loads all saved drafts
  Future<Result<List<ResumeDraft>>> loadAllDrafts();

  /// Saves/autosaves a resume draft
  Future<Result<ResumeDraft>> saveDraft(ResumeDraft draft);

  /// Deletes a resume draft
  Future<Result<void>> deleteDraft(String draftId);

  /// Updates the profile section
  Future<Result<ResumeDraft>> updateProfile(String draftId, Profile profile);

  /// Updates the contact section
  Future<Result<ResumeDraft>> updateContact(String draftId, Contact contact);

  /// Adds an experience item
  Future<Result<ResumeDraft>> addExperience(String draftId, Experience experience);

  /// Updates an experience item
  Future<Result<ResumeDraft>> updateExperience(String draftId, Experience experience);

  /// Removes an experience item
  Future<Result<ResumeDraft>> removeExperience(String draftId, String experienceId);

  /// Reorders experience items
  Future<Result<ResumeDraft>> reorderExperiences(String draftId, List<String> orderedIds);

  /// Adds an education item
  Future<Result<ResumeDraft>> addEducation(String draftId, Education education);

  /// Updates an education item
  Future<Result<ResumeDraft>> updateEducation(String draftId, Education education);

  /// Removes an education item
  Future<Result<ResumeDraft>> removeEducation(String draftId, String educationId);

  /// Reorders education items
  Future<Result<ResumeDraft>> reorderEducations(String draftId, List<String> orderedIds);

  /// Adds a skill item
  Future<Result<ResumeDraft>> addSkill(String draftId, Skill skill);

  /// Updates a skill item
  Future<Result<ResumeDraft>> updateSkill(String draftId, Skill skill);

  /// Removes a skill item
  Future<Result<ResumeDraft>> removeSkill(String draftId, String skillId);

  /// Reorders skill items
  Future<Result<ResumeDraft>> reorderSkills(String draftId, List<String> orderedIds);

  /// Adds a project item
  Future<Result<ResumeDraft>> addProject(String draftId, Project project);

  /// Updates a project item
  Future<Result<ResumeDraft>> updateProject(String draftId, Project project);

  /// Removes a project item
  Future<Result<ResumeDraft>> removeProject(String draftId, String projectId);

  /// Reorders project items
  Future<Result<ResumeDraft>> reorderProjects(String draftId, List<String> orderedIds);

  /// Updates the template
  Future<Result<ResumeDraft>> updateTemplate(String draftId, Template template);

  /// Exports the resume as PDF
  Future<Result<Uint8List>> exportPdf(ResumeDraft draft);
}

