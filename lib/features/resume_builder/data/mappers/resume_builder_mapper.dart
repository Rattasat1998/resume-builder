import '../../domain/entities/resume_draft.dart';
import '../../domain/entities/resume_language.dart';
import '../../domain/entities/sections/contact.dart';
import '../../domain/entities/sections/education.dart';
import '../../domain/entities/sections/experience.dart';
import '../../domain/entities/sections/hobby.dart';
import '../../domain/entities/sections/language.dart';
import '../../domain/entities/sections/profile.dart';
import '../../domain/entities/sections/project.dart';
import '../../domain/entities/sections/skill.dart';
import '../../domain/entities/template.dart';
import '../models/resume_draft_dto.dart';

/// Mapper for converting between domain entities and DTOs
class ResumeBuilderMapper {
  // Profile mappings
  static Profile profileFromDto(ProfileDto dto) {
    return Profile(
      id: dto.id,
      fullName: dto.fullName,
      jobTitle: dto.jobTitle,
      summary: dto.summary,
      avatarUrl: dto.avatarUrl,
    );
  }

  static ProfileDto profileToDto(Profile entity) {
    return ProfileDto(
      id: entity.id,
      fullName: entity.fullName,
      jobTitle: entity.jobTitle,
      summary: entity.summary,
      avatarUrl: entity.avatarUrl,
    );
  }

  // Contact mappings
  static Contact contactFromDto(ContactDto dto) {
    return Contact(
      id: dto.id,
      email: dto.email,
      phone: dto.phone,
      website: dto.website,
      linkedIn: dto.linkedIn,
      github: dto.github,
      twitter: dto.twitter,
      address: dto.address,
      city: dto.city,
      country: dto.country,
    );
  }

  static ContactDto contactToDto(Contact entity) {
    return ContactDto(
      id: entity.id,
      email: entity.email,
      phone: entity.phone,
      website: entity.website,
      linkedIn: entity.linkedIn,
      github: entity.github,
      twitter: entity.twitter,
      address: entity.address,
      city: entity.city,
      country: entity.country,
    );
  }

  // Experience mappings
  static Experience experienceFromDto(ExperienceDto dto) {
    return Experience(
      id: dto.id,
      companyName: dto.companyName,
      position: dto.position,
      location: dto.location,
      startDate: dto.startDate,
      endDate: dto.endDate,
      isCurrentJob: dto.isCurrentJob,
      description: dto.description,
      achievements: dto.achievements,
    );
  }

  static ExperienceDto experienceToDto(Experience entity) {
    return ExperienceDto(
      id: entity.id,
      companyName: entity.companyName,
      position: entity.position,
      location: entity.location,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isCurrentJob: entity.isCurrentJob,
      description: entity.description,
      achievements: entity.achievements,
    );
  }

  // Education mappings
  static Education educationFromDto(EducationDto dto) {
    return Education(
      id: dto.id,
      institution: dto.institution,
      degree: dto.degree,
      fieldOfStudy: dto.fieldOfStudy,
      location: dto.location,
      startDate: dto.startDate,
      endDate: dto.endDate,
      isCurrentlyStudying: dto.isCurrentlyStudying,
      gpa: dto.gpa,
      description: dto.description,
      achievements: dto.achievements,
    );
  }

  static EducationDto educationToDto(Education entity) {
    return EducationDto(
      id: entity.id,
      institution: entity.institution,
      degree: entity.degree,
      fieldOfStudy: entity.fieldOfStudy,
      location: entity.location,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isCurrentlyStudying: entity.isCurrentlyStudying,
      gpa: entity.gpa,
      description: entity.description,
      achievements: entity.achievements,
    );
  }

  // Skill mappings
  static Skill skillFromDto(SkillDto dto) {
    return Skill(
      id: dto.id,
      name: dto.name,
      level: _skillLevelFromString(dto.level),
      category: dto.category,
    );
  }

  static SkillDto skillToDto(Skill entity) {
    return SkillDto(
      id: entity.id,
      name: entity.name,
      level: entity.level.name,
      category: entity.category,
    );
  }

  static SkillLevel _skillLevelFromString(String level) {
    return SkillLevel.values.firstWhere(
      (e) => e.name == level,
      orElse: () => SkillLevel.intermediate,
    );
  }

  // Project mappings
  static Project projectFromDto(ProjectDto dto) {
    return Project(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      url: dto.url,
      repositoryUrl: dto.repositoryUrl,
      startDate: dto.startDate,
      endDate: dto.endDate,
      technologies: dto.technologies,
      highlights: dto.highlights,
    );
  }

  static ProjectDto projectToDto(Project entity) {
    return ProjectDto(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      url: entity.url,
      repositoryUrl: entity.repositoryUrl,
      startDate: entity.startDate,
      endDate: entity.endDate,
      technologies: entity.technologies,
      highlights: entity.highlights,
    );
  }

  // Template mappings
  static Template templateFromDto(TemplateDto dto) {
    return Template(
      id: dto.id,
      type: _templateTypeFromString(dto.type),
      primaryColor: dto.primaryColor,
      secondaryColor: dto.secondaryColor,
      fontFamily: dto.fontFamily,
      fontSize: dto.fontSize,
    );
  }

  static TemplateDto templateToDto(Template entity) {
    return TemplateDto(
      id: entity.id,
      type: entity.type.name,
      primaryColor: entity.primaryColor,
      secondaryColor: entity.secondaryColor,
      fontFamily: entity.fontFamily,
      fontSize: entity.fontSize,
    );
  }

  static TemplateType _templateTypeFromString(String type) {
    return TemplateType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => TemplateType.templateA,
    );
  }

  // Language mappings
  static Language languageFromDto(LanguageDto dto) {
    return Language(
      id: dto.id,
      name: dto.name,
      level: _languageLevelFromString(dto.level),
    );
  }

  static LanguageDto languageToDto(Language entity) {
    return LanguageDto(
      id: entity.id,
      name: entity.name,
      level: entity.level.name,
    );
  }

  static LanguageLevel _languageLevelFromString(String level) {
    return LanguageLevel.values.firstWhere(
      (e) => e.name == level,
      orElse: () => LanguageLevel.intermediate,
    );
  }

  // Hobby mappings
  static Hobby hobbyFromDto(HobbyDto dto) {
    return Hobby(id: dto.id, name: dto.name, icon: dto.icon);
  }

  static HobbyDto hobbyToDto(Hobby entity) {
    return HobbyDto(id: entity.id, name: entity.name, icon: entity.icon);
  }

  // ResumeDraft mappings
  static ResumeDraft resumeDraftFromDto(ResumeDraftDto dto) {
    return ResumeDraft(
      id: dto.id,
      title: dto.title,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      template: templateFromDto(dto.template),
      profile: profileFromDto(dto.profile),
      contact: contactFromDto(dto.contact),
      experiences: dto.experiences.map(experienceFromDto).toList(),
      educations: dto.educations.map(educationFromDto).toList(),
      skills: dto.skills.map(skillFromDto).toList(),
      projects: dto.projects.map(projectFromDto).toList(),
      languages: dto.languages.map(languageFromDto).toList(),
      hobbies: dto.hobbies.map(hobbyFromDto).toList(),
      isDraft: dto.isDraft,
      resumeLanguage: _parseResumeLanguage(dto.resumeLanguage),
      isCloudSynced: dto.isCloudSynced,
    );
  }

  static ResumeDraftDto resumeDraftToDto(ResumeDraft entity) {
    return ResumeDraftDto(
      id: entity.id,
      title: entity.title,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      template: templateToDto(entity.template),
      profile: profileToDto(entity.profile),
      contact: contactToDto(entity.contact),
      experiences: entity.experiences.map(experienceToDto).toList(),
      educations: entity.educations.map(educationToDto).toList(),
      skills: entity.skills.map(skillToDto).toList(),
      projects: entity.projects.map(projectToDto).toList(),
      languages: entity.languages.map(languageToDto).toList(),
      hobbies: entity.hobbies.map(hobbyToDto).toList(),
      isDraft: entity.isDraft,
      resumeLanguage: entity.resumeLanguage.name,
      isCloudSynced: entity.isCloudSynced,
    );
  }

  static ResumeLanguage _parseResumeLanguage(String value) {
    switch (value) {
      case 'thai':
        return ResumeLanguage.thai;
      case 'english':
      default:
        return ResumeLanguage.english;
    }
  }
}
