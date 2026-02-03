import 'package:equatable/equatable.dart';

/// Project item in the resume
class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? url;
  final String? repositoryUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> technologies;
  final List<String> highlights;

  const Project({
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

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? url,
    String? repositoryUrl,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? technologies,
    List<String>? highlights,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      url: url ?? this.url,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      technologies: technologies ?? this.technologies,
      highlights: highlights ?? this.highlights,
    );
  }

  factory Project.empty(String id) => Project(
    id: id,
    name: '',
    description: '',
  );

  bool get isEmpty => name.isEmpty && description.isEmpty;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    url,
    repositoryUrl,
    startDate,
    endDate,
    technologies,
    highlights,
  ];
}

