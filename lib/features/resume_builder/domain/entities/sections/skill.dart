import 'package:equatable/equatable.dart';

/// Skill proficiency level
enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

extension SkillLevelExtension on SkillLevel {
  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.expert:
        return 'Expert';
    }
  }

  int get percentage {
    switch (this) {
      case SkillLevel.beginner:
        return 25;
      case SkillLevel.intermediate:
        return 50;
      case SkillLevel.advanced:
        return 75;
      case SkillLevel.expert:
        return 100;
    }
  }
}

/// Skill item in the resume
class Skill extends Equatable {
  final String id;
  final String name;
  final SkillLevel level;
  final String? category;

  const Skill({
    required this.id,
    required this.name,
    required this.level,
    this.category,
  });

  Skill copyWith({
    String? id,
    String? name,
    SkillLevel? level,
    String? category,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      category: category ?? this.category,
    );
  }

  factory Skill.empty(String id) => Skill(
    id: id,
    name: '',
    level: SkillLevel.intermediate,
  );

  bool get isEmpty => name.isEmpty;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [id, name, level, category];
}

