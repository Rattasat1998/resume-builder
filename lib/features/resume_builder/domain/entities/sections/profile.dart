import 'package:equatable/equatable.dart';

/// Profile section of the resume
class Profile extends Equatable {
  final String id;
  final String fullName;
  final String jobTitle;
  final String summary;
  final String? avatarUrl;

  const Profile({
    required this.id,
    required this.fullName,
    required this.jobTitle,
    required this.summary,
    this.avatarUrl,
  });

  Profile copyWith({
    String? id,
    String? fullName,
    String? jobTitle,
    String? summary,
    String? avatarUrl,
  }) {
    return Profile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      summary: summary ?? this.summary,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory Profile.empty(String id) => Profile(
    id: id,
    fullName: '',
    jobTitle: '',
    summary: '',
  );

  bool get isEmpty => fullName.isEmpty && jobTitle.isEmpty && summary.isEmpty;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [id, fullName, jobTitle, summary, avatarUrl];
}

