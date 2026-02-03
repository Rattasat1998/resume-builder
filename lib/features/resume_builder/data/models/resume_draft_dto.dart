import 'package:json_annotation/json_annotation.dart';

part 'resume_draft_dto.g.dart';

/// DTO for Profile section
@JsonSerializable()
class ProfileDto {
  final String id;
  final String fullName;
  final String jobTitle;
  final String summary;
  final String? avatarUrl;

  const ProfileDto({
    required this.id,
    required this.fullName,
    required this.jobTitle,
    required this.summary,
    this.avatarUrl,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDtoToJson(this);
}

/// DTO for Contact section
@JsonSerializable()
class ContactDto {
  final String id;
  final String email;
  final String phone;
  final String? website;
  final String? linkedIn;
  final String? github;
  final String? twitter;
  final String? address;
  final String? city;
  final String? country;

  const ContactDto({
    required this.id,
    required this.email,
    required this.phone,
    this.website,
    this.linkedIn,
    this.github,
    this.twitter,
    this.address,
    this.city,
    this.country,
  });

  factory ContactDto.fromJson(Map<String, dynamic> json) =>
      _$ContactDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ContactDtoToJson(this);
}

/// DTO for Experience section
@JsonSerializable()
class ExperienceDto {
  final String id;
  final String companyName;
  final String position;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrentJob;
  final String description;
  final List<String> achievements;

  const ExperienceDto({
    required this.id,
    required this.companyName,
    required this.position,
    required this.location,
    required this.startDate,
    this.endDate,
    this.isCurrentJob = false,
    required this.description,
    this.achievements = const [],
  });

  factory ExperienceDto.fromJson(Map<String, dynamic> json) =>
      _$ExperienceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExperienceDtoToJson(this);
}

/// DTO for Education section
@JsonSerializable()
class EducationDto {
  final String id;
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrentlyStudying;
  final double? gpa;
  final String? description;
  final List<String> achievements;

  const EducationDto({
    required this.id,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.location,
    required this.startDate,
    this.endDate,
    this.isCurrentlyStudying = false,
    this.gpa,
    this.description,
    this.achievements = const [],
  });

  factory EducationDto.fromJson(Map<String, dynamic> json) =>
      _$EducationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EducationDtoToJson(this);
}

/// DTO for Skill section
@JsonSerializable()
class SkillDto {
  final String id;
  final String name;
  final String level;
  final String? category;

  const SkillDto({
    required this.id,
    required this.name,
    required this.level,
    this.category,
  });

  factory SkillDto.fromJson(Map<String, dynamic> json) =>
      _$SkillDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SkillDtoToJson(this);
}

/// DTO for Project section
@JsonSerializable()
class ProjectDto {
  final String id;
  final String name;
  final String description;
  final String? url;
  final String? repositoryUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> technologies;
  final List<String> highlights;

  const ProjectDto({
    required this.id,
    required this.name,
    required this.description,
    this.url,
    this.repositoryUrl,
    this.startDate,
    this.endDate,
    this.technologies = const [],
    this.highlights = const [],
  });

  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectDtoToJson(this);
}

/// DTO for Language section
@JsonSerializable()
class LanguageDto {
  final String id;
  final String name;
  final String level;

  const LanguageDto({
    required this.id,
    required this.name,
    required this.level,
  });

  factory LanguageDto.fromJson(Map<String, dynamic> json) =>
      _$LanguageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageDtoToJson(this);
}

/// DTO for Hobby section
@JsonSerializable()
class HobbyDto {
  final String id;
  final String name;
  final String? icon;

  const HobbyDto({required this.id, required this.name, this.icon});

  factory HobbyDto.fromJson(Map<String, dynamic> json) =>
      _$HobbyDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HobbyDtoToJson(this);
}

/// DTO for Template
@JsonSerializable()
class TemplateDto {
  final String id;
  final String type;
  final String primaryColor;
  final String secondaryColor;
  final String fontFamily;
  final double fontSize;

  const TemplateDto({
    required this.id,
    required this.type,
    required this.primaryColor,
    required this.secondaryColor,
    required this.fontFamily,
    required this.fontSize,
  });

  factory TemplateDto.fromJson(Map<String, dynamic> json) =>
      _$TemplateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateDtoToJson(this);
}

/// Main DTO for Resume Draft
@JsonSerializable()
class ResumeDraftDto {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TemplateDto template;
  final ProfileDto profile;
  final ContactDto contact;
  final List<ExperienceDto> experiences;
  final List<EducationDto> educations;
  final List<SkillDto> skills;
  final List<ProjectDto> projects;
  final List<LanguageDto> languages;
  final List<HobbyDto> hobbies;
  final bool isDraft;
  final String resumeLanguage;
  final bool isCloudSynced;

  const ResumeDraftDto({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.template,
    required this.profile,
    required this.contact,
    this.experiences = const [],
    this.educations = const [],
    this.skills = const [],
    this.projects = const [],
    this.languages = const [],
    this.hobbies = const [],
    this.isDraft = true,
    this.resumeLanguage = 'english',
    this.isCloudSynced = false,
  });

  factory ResumeDraftDto.fromJson(Map<String, dynamic> json) =>
      _$ResumeDraftDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeDraftDtoToJson(this);
}
