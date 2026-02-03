import 'package:equatable/equatable.dart';

/// Experience/Work history item in the resume
class Experience extends Equatable {
  final String id;
  final String companyName;
  final String position;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrentJob;
  final String description;
  final List<String> achievements;

  const Experience({
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

  Experience copyWith({
    String? id,
    String? companyName,
    String? position,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrentJob,
    String? description,
    List<String>? achievements,
  }) {
    return Experience(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      position: position ?? this.position,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrentJob: isCurrentJob ?? this.isCurrentJob,
      description: description ?? this.description,
      achievements: achievements ?? this.achievements,
    );
  }

  factory Experience.empty(String id) => Experience(
    id: id,
    companyName: '',
    position: '',
    location: '',
    startDate: DateTime.now(),
    description: '',
  );

  bool get isEmpty => companyName.isEmpty && position.isEmpty;
  bool get isNotEmpty => !isEmpty;

  String get dateRange {
    final start = '${startDate.month}/${startDate.year}';
    final end = isCurrentJob ? 'Present' : (endDate != null ? '${endDate!.month}/${endDate!.year}' : '');
    return '$start - $end';
  }

  @override
  List<Object?> get props => [
    id,
    companyName,
    position,
    location,
    startDate,
    endDate,
    isCurrentJob,
    description,
    achievements,
  ];
}

