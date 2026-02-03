import 'package:equatable/equatable.dart';

/// Hobby/Interest item in the resume
class Hobby extends Equatable {
  final String id;
  final String name;
  final String? icon; // optional icon name

  const Hobby({
    required this.id,
    required this.name,
    this.icon,
  });

  Hobby copyWith({
    String? id,
    String? name,
    String? icon,
  }) {
    return Hobby(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

  factory Hobby.empty() {
    return Hobby(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
    );
  }

  @override
  List<Object?> get props => [id, name, icon];
}

