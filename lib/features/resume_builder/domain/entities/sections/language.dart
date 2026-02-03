import 'package:equatable/equatable.dart';

/// Language proficiency level
enum LanguageLevel {
  beginner,
  elementary,
  intermediate,
  upperIntermediate,
  advanced,
  native,
}

extension LanguageLevelExtension on LanguageLevel {
  String get displayName {
    switch (this) {
      case LanguageLevel.beginner:
        return 'Beginner';
      case LanguageLevel.elementary:
        return 'Elementary';
      case LanguageLevel.intermediate:
        return 'Intermediate';
      case LanguageLevel.upperIntermediate:
        return 'Upper Intermediate';
      case LanguageLevel.advanced:
        return 'Advanced';
      case LanguageLevel.native:
        return 'Native';
    }
  }

  /// CEFR equivalent
  String get cefrLevel {
    switch (this) {
      case LanguageLevel.beginner:
        return 'A1';
      case LanguageLevel.elementary:
        return 'A2';
      case LanguageLevel.intermediate:
        return 'B1';
      case LanguageLevel.upperIntermediate:
        return 'B2';
      case LanguageLevel.advanced:
        return 'C1';
      case LanguageLevel.native:
        return 'C2';
    }
  }

  int get percentage {
    switch (this) {
      case LanguageLevel.beginner:
        return 17;
      case LanguageLevel.elementary:
        return 33;
      case LanguageLevel.intermediate:
        return 50;
      case LanguageLevel.upperIntermediate:
        return 67;
      case LanguageLevel.advanced:
        return 83;
      case LanguageLevel.native:
        return 100;
    }
  }
}

/// Language item in the resume
class Language extends Equatable {
  final String id;
  final String name;
  final LanguageLevel level;

  const Language({
    required this.id,
    required this.name,
    required this.level,
  });

  Language copyWith({
    String? id,
    String? name,
    LanguageLevel? level,
  }) {
    return Language(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
    );
  }

  factory Language.empty() {
    return Language(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
      level: LanguageLevel.intermediate,
    );
  }

  @override
  List<Object?> get props => [id, name, level];
}

