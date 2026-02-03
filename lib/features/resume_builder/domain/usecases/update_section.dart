import '../../../../core/utils/result.dart';
import '../entities/resume_draft.dart';
import '../entities/sections/contact.dart';
import '../entities/sections/education.dart';
import '../entities/sections/experience.dart';
import '../entities/sections/profile.dart';
import '../entities/sections/project.dart';
import '../entities/sections/skill.dart';
import '../entities/template.dart';
import '../repositories/resume_builder_repository.dart';

/// Use case for updating the profile section
class UpdateProfile {
  final ResumeBuilderRepository _repository;

  UpdateProfile(this._repository);

  Future<Result<ResumeDraft>> call(String draftId, Profile profile) {
    return _repository.updateProfile(draftId, profile);
  }
}

/// Use case for updating the contact section
class UpdateContact {
  final ResumeBuilderRepository _repository;

  UpdateContact(this._repository);

  Future<Result<ResumeDraft>> call(String draftId, Contact contact) {
    return _repository.updateContact(draftId, contact);
  }
}

/// Use case for adding/updating an experience item
class UpdateExperience {
  final ResumeBuilderRepository _repository;

  UpdateExperience(this._repository);

  Future<Result<ResumeDraft>> add(String draftId, Experience experience) {
    return _repository.addExperience(draftId, experience);
  }

  Future<Result<ResumeDraft>> update(String draftId, Experience experience) {
    return _repository.updateExperience(draftId, experience);
  }
}

/// Use case for adding/updating an education item
class UpdateEducation {
  final ResumeBuilderRepository _repository;

  UpdateEducation(this._repository);

  Future<Result<ResumeDraft>> add(String draftId, Education education) {
    return _repository.addEducation(draftId, education);
  }

  Future<Result<ResumeDraft>> update(String draftId, Education education) {
    return _repository.updateEducation(draftId, education);
  }
}

/// Use case for adding/updating a skill item
class UpdateSkill {
  final ResumeBuilderRepository _repository;

  UpdateSkill(this._repository);

  Future<Result<ResumeDraft>> add(String draftId, Skill skill) {
    return _repository.addSkill(draftId, skill);
  }

  Future<Result<ResumeDraft>> update(String draftId, Skill skill) {
    return _repository.updateSkill(draftId, skill);
  }
}

/// Use case for adding/updating a project item
class UpdateProject {
  final ResumeBuilderRepository _repository;

  UpdateProject(this._repository);

  Future<Result<ResumeDraft>> add(String draftId, Project project) {
    return _repository.addProject(draftId, project);
  }

  Future<Result<ResumeDraft>> update(String draftId, Project project) {
    return _repository.updateProject(draftId, project);
  }
}

/// Use case for updating the template
class UpdateTemplate {
  final ResumeBuilderRepository _repository;

  UpdateTemplate(this._repository);

  Future<Result<ResumeDraft>> call(String draftId, Template template) {
    return _repository.updateTemplate(draftId, template);
  }
}

