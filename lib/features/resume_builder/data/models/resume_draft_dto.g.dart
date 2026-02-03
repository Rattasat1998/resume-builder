// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_draft_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileDto _$ProfileDtoFromJson(Map<String, dynamic> json) => ProfileDto(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  jobTitle: json['jobTitle'] as String,
  summary: json['summary'] as String,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$ProfileDtoToJson(ProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'jobTitle': instance.jobTitle,
      'summary': instance.summary,
      'avatarUrl': instance.avatarUrl,
    };

ContactDto _$ContactDtoFromJson(Map<String, dynamic> json) => ContactDto(
  id: json['id'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  website: json['website'] as String?,
  linkedIn: json['linkedIn'] as String?,
  github: json['github'] as String?,
  twitter: json['twitter'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
);

Map<String, dynamic> _$ContactDtoToJson(ContactDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone': instance.phone,
      'website': instance.website,
      'linkedIn': instance.linkedIn,
      'github': instance.github,
      'twitter': instance.twitter,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
    };

ExperienceDto _$ExperienceDtoFromJson(Map<String, dynamic> json) =>
    ExperienceDto(
      id: json['id'] as String,
      companyName: json['companyName'] as String,
      position: json['position'] as String,
      location: json['location'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      isCurrentJob: json['isCurrentJob'] as bool? ?? false,
      description: json['description'] as String,
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ExperienceDtoToJson(ExperienceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyName': instance.companyName,
      'position': instance.position,
      'location': instance.location,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'isCurrentJob': instance.isCurrentJob,
      'description': instance.description,
      'achievements': instance.achievements,
    };

EducationDto _$EducationDtoFromJson(Map<String, dynamic> json) => EducationDto(
  id: json['id'] as String,
  institution: json['institution'] as String,
  degree: json['degree'] as String,
  fieldOfStudy: json['fieldOfStudy'] as String,
  location: json['location'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  isCurrentlyStudying: json['isCurrentlyStudying'] as bool? ?? false,
  gpa: (json['gpa'] as num?)?.toDouble(),
  description: json['description'] as String?,
  achievements:
      (json['achievements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$EducationDtoToJson(EducationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'institution': instance.institution,
      'degree': instance.degree,
      'fieldOfStudy': instance.fieldOfStudy,
      'location': instance.location,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'isCurrentlyStudying': instance.isCurrentlyStudying,
      'gpa': instance.gpa,
      'description': instance.description,
      'achievements': instance.achievements,
    };

SkillDto _$SkillDtoFromJson(Map<String, dynamic> json) => SkillDto(
  id: json['id'] as String,
  name: json['name'] as String,
  level: json['level'] as String,
  category: json['category'] as String?,
);

Map<String, dynamic> _$SkillDtoToJson(SkillDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'level': instance.level,
  'category': instance.category,
};

ProjectDto _$ProjectDtoFromJson(Map<String, dynamic> json) => ProjectDto(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  url: json['url'] as String?,
  repositoryUrl: json['repositoryUrl'] as String?,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  technologies:
      (json['technologies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  highlights:
      (json['highlights'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ProjectDtoToJson(ProjectDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'url': instance.url,
      'repositoryUrl': instance.repositoryUrl,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'technologies': instance.technologies,
      'highlights': instance.highlights,
    };

LanguageDto _$LanguageDtoFromJson(Map<String, dynamic> json) => LanguageDto(
  id: json['id'] as String,
  name: json['name'] as String,
  level: json['level'] as String,
);

Map<String, dynamic> _$LanguageDtoToJson(LanguageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'level': instance.level,
    };

HobbyDto _$HobbyDtoFromJson(Map<String, dynamic> json) => HobbyDto(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String?,
);

Map<String, dynamic> _$HobbyDtoToJson(HobbyDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': instance.icon,
};

TemplateDto _$TemplateDtoFromJson(Map<String, dynamic> json) => TemplateDto(
  id: json['id'] as String,
  type: json['type'] as String,
  primaryColor: json['primaryColor'] as String,
  secondaryColor: json['secondaryColor'] as String,
  fontFamily: json['fontFamily'] as String,
  fontSize: (json['fontSize'] as num).toDouble(),
);

Map<String, dynamic> _$TemplateDtoToJson(TemplateDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'primaryColor': instance.primaryColor,
      'secondaryColor': instance.secondaryColor,
      'fontFamily': instance.fontFamily,
      'fontSize': instance.fontSize,
    };

ResumeDraftDto _$ResumeDraftDtoFromJson(Map<String, dynamic> json) =>
    ResumeDraftDto(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      template: TemplateDto.fromJson(json['template'] as Map<String, dynamic>),
      profile: ProfileDto.fromJson(json['profile'] as Map<String, dynamic>),
      contact: ContactDto.fromJson(json['contact'] as Map<String, dynamic>),
      experiences:
          (json['experiences'] as List<dynamic>?)
              ?.map((e) => ExperienceDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      educations:
          (json['educations'] as List<dynamic>?)
              ?.map((e) => EducationDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((e) => SkillDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      projects:
          (json['projects'] as List<dynamic>?)
              ?.map((e) => ProjectDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      languages:
          (json['languages'] as List<dynamic>?)
              ?.map((e) => LanguageDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hobbies:
          (json['hobbies'] as List<dynamic>?)
              ?.map((e) => HobbyDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isDraft: json['isDraft'] as bool? ?? true,
      resumeLanguage: json['resumeLanguage'] as String? ?? 'english',
      isCloudSynced: json['isCloudSynced'] as bool? ?? false,
    );

Map<String, dynamic> _$ResumeDraftDtoToJson(ResumeDraftDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'template': instance.template,
      'profile': instance.profile,
      'contact': instance.contact,
      'experiences': instance.experiences,
      'educations': instance.educations,
      'skills': instance.skills,
      'projects': instance.projects,
      'languages': instance.languages,
      'hobbies': instance.hobbies,
      'isDraft': instance.isDraft,
      'resumeLanguage': instance.resumeLanguage,
      'isCloudSynced': instance.isCloudSynced,
    };
