class RoadmapModel {
  final String id;
  final String userId;
  final String targetJobTitle;
  final String? targetCompany;
  final String currentLevel;
  final List<RoadmapStep> steps;
  final String? motivationMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoadmapModel({
    required this.id,
    required this.userId,
    required this.targetJobTitle,
    this.targetCompany,
    required this.currentLevel,
    required this.steps,
    this.motivationMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    return RoadmapModel(
      id: json['id'],
      userId: json['user_id'],
      targetJobTitle: json['target_job_title'],
      targetCompany: json['target_company'],
      currentLevel: json['current_level'],
      steps: (json['steps'] as List)
          .map((e) => RoadmapStep.fromJson(e))
          .toList(),
      motivationMessage: json['motivation_message'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'target_job_title': targetJobTitle,
      'target_company': targetCompany,
      'current_level': currentLevel,
      'steps': steps.map((e) => e.toJson()).toList(),
      'motivation_message': motivationMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class RoadmapStep {
  final String title;
  final String description;
  final int estimatedWeeks;
  bool isCompleted;

  RoadmapStep({
    required this.title,
    required this.description,
    required this.estimatedWeeks,
    this.isCompleted = false,
  });

  factory RoadmapStep.fromJson(Map<String, dynamic> json) {
    return RoadmapStep(
      title: json['title'],
      description: json['description'],
      estimatedWeeks: json['estimated_weeks'],
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'estimated_weeks': estimatedWeeks,
      'is_completed': isCompleted,
    };
  }
}
