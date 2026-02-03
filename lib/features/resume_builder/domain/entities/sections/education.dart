import 'package:equatable/equatable.dart';

/// Education item in the resume
class Education extends Equatable {
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

  const Education({
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

  Education copyWith({
    String? id,
    String? institution,
    String? degree,
    String? fieldOfStudy,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrentlyStudying,
    double? gpa,
    String? description,
    List<String>? achievements,
  }) {
    return Education(
      id: id ?? this.id,
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrentlyStudying: isCurrentlyStudying ?? this.isCurrentlyStudying,
      gpa: gpa ?? this.gpa,
      description: description ?? this.description,
      achievements: achievements ?? this.achievements,
    );
  }

  factory Education.empty(String id) => Education(
    id: id,
    institution: '',
    degree: '',
    fieldOfStudy: '',
    location: '',
    startDate: DateTime.now(),
  );

  bool get isEmpty => institution.isEmpty && degree.isEmpty;
  bool get isNotEmpty => !isEmpty;

  String get dateRange {
    final start = '${startDate.year}';
    final end = isCurrentlyStudying ? 'Present' : (endDate != null ? '${endDate!.year}' : '');
    return '$start - $end';
  }

  @override
  List<Object?> get props => [
    id,
    institution,
    degree,
    fieldOfStudy,
    location,
    startDate,
    endDate,
    isCurrentlyStudying,
    gpa,
    description,
    achievements,
  ];
}

