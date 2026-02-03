import 'package:equatable/equatable.dart';

import 'resume_language.dart';
import 'sections/contact.dart';
import 'sections/education.dart';
import 'sections/experience.dart';
import 'sections/hobby.dart';
import 'sections/language.dart';
import 'sections/profile.dart';
import 'sections/project.dart';
import 'sections/skill.dart';
import 'template.dart';

/// The main resume draft entity containing all sections
class ResumeDraft extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Template template;
  final Profile profile;
  final Contact contact;
  final List<Experience> experiences;
  final List<Education> educations;
  final List<Skill> skills;
  final List<Project> projects;
  final List<Language> languages;
  final List<Hobby> hobbies;
  final bool isDraft;
  final ResumeLanguage resumeLanguage;
  final bool isCloudSynced;

  const ResumeDraft({
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
    this.resumeLanguage = ResumeLanguage.english,
    this.isCloudSynced = false,
  });

  ResumeDraft copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    Template? template,
    Profile? profile,
    Contact? contact,
    List<Experience>? experiences,
    List<Education>? educations,
    List<Skill>? skills,
    List<Project>? projects,
    List<Language>? languages,
    List<Hobby>? hobbies,
    bool? isDraft,
    ResumeLanguage? resumeLanguage,
    bool? isCloudSynced,
  }) {
    return ResumeDraft(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      template: template ?? this.template,
      profile: profile ?? this.profile,
      contact: contact ?? this.contact,
      experiences: experiences ?? this.experiences,
      educations: educations ?? this.educations,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      languages: languages ?? this.languages,
      hobbies: hobbies ?? this.hobbies,
      isDraft: isDraft ?? this.isDraft,
      resumeLanguage: resumeLanguage ?? this.resumeLanguage,
      isCloudSynced: isCloudSynced ?? this.isCloudSynced,
    );
  }

  factory ResumeDraft.create({
    required String id,
    required String profileId,
    required String contactId,
    required String templateId,
    String title = 'Untitled Resume',
  }) {
    final now = DateTime.now();
    return ResumeDraft(
      id: id,
      title: title,
      createdAt: now,
      updatedAt: now,
      template: Template.defaultTemplate(templateId),
      profile: Profile.empty(profileId),
      contact: Contact.empty(contactId),
      isCloudSynced: false,
    );
  }

  /// Progress percentage based on completed sections
  double get completionPercentage {
    int completed = 0;
    int total =
        8; // profile, contact, experiences, educations, skills, projects, languages, hobbies

    if (profile.isNotEmpty) completed++;
    if (contact.isNotEmpty) completed++;
    if (experiences.isNotEmpty) completed++;
    if (educations.isNotEmpty) completed++;
    if (skills.isNotEmpty) completed++;
    if (projects.isNotEmpty) completed++;
    if (languages.isNotEmpty) completed++;
    if (hobbies.isNotEmpty) completed++;

    return (completed / total) * 100;
  }

  /// Check if the resume has minimum required information
  bool get isValid {
    return profile.isNotEmpty && contact.isNotEmpty;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    createdAt,
    updatedAt,
    template,
    profile,
    contact,
    experiences,
    educations,
    skills,
    projects,
    languages,
    hobbies,
    isDraft,
    resumeLanguage,
    isCloudSynced,
  ];
}
