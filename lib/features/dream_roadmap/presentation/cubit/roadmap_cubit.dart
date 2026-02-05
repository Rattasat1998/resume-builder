import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/roadmap_model.dart';
import '../../data/repositories/roadmap_repository.dart';

abstract class RoadmapState {}

class RoadmapInitial extends RoadmapState {}

class RoadmapLoading extends RoadmapState {}

class RoadmapLoaded extends RoadmapState {
  final RoadmapModel roadmap;
  RoadmapLoaded(this.roadmap);
}

class RoadmapError extends RoadmapState {
  final String message;
  RoadmapError(this.message);
}

class RoadmapCubit extends Cubit<RoadmapState> {
  final RoadmapRepository _repository;

  RoadmapCubit({RoadmapRepository? repository})
    : _repository = repository ?? RoadmapRepository(),
      super(RoadmapInitial());

  Future<void> loadRoadmap() async {
    try {
      emit(RoadmapLoading());
      final roadmap = await _repository.getUserRoadmap();
      if (roadmap != null) {
        emit(RoadmapLoaded(roadmap));
      } else {
        emit(RoadmapInitial());
      }
    } catch (e) {
      emit(RoadmapError('Failed to load roadmap: $e'));
    }
  }

  Future<void> generateRoadmap({
    required String jobTitle,
    String? company,
    required String currentLevel,
    required String languageCode,
  }) async {
    try {
      emit(RoadmapLoading());
      final roadmap = await _repository.generateAndSaveRoadmap(
        jobTitle: jobTitle,
        company: company,
        currentLevel: currentLevel,
        languageCode: languageCode,
      );
      emit(RoadmapLoaded(roadmap));
    } catch (e) {
      String errorMessage = 'Failed to generate roadmap';
      if (e.toString().contains('400') ||
          e.toString().toLowerCase().contains('quota') ||
          e.toString().toLowerCase().contains('resource exhausted')) {
        errorMessage =
            'AI Service is busy (Quota Exceeded). Please try again later.';
      } else if (e.toString().toLowerCase().contains('gemini error')) {
        errorMessage =
            'AI Error: ${e.toString().split('Gemini Error:').last.trim()}';
      }
      emit(RoadmapError(errorMessage));
    }
  }

  Future<void> updateStepProgress(
    RoadmapModel roadmap,
    int stepIndex,
    bool isCompleted,
  ) async {
    try {
      final updatedSteps = List<RoadmapStep>.from(roadmap.steps);
      updatedSteps[stepIndex].isCompleted = isCompleted;

      await _repository.updateStepProgress(roadmap.id, updatedSteps);

      // Ideally fetched fresh from DB, but for UI responsiveness we update local state
      // Be careful with immutability, here we constructed a new list but reused step objects?
      // Step objects are not immutable in my model definition (isCompleted is mutable).
      // So modifying it in place is "okay" for this simple app, but creating a new Model instance is better.

      // Let's create a partial update or just re-emit the same object knowing it's mutated.
      // Better:
      emit(
        RoadmapLoaded(
          RoadmapModel(
            id: roadmap.id,
            userId: roadmap.userId,
            targetJobTitle: roadmap.targetJobTitle,
            targetCompany: roadmap.targetCompany,
            currentLevel: roadmap.currentLevel,
            steps: updatedSteps,
            motivationMessage: roadmap.motivationMessage,
            createdAt: roadmap.createdAt,
            updatedAt: DateTime.now(),
          ),
        ),
      );
    } catch (e) {
      emit(RoadmapError('Failed to update progress: $e'));
      // Revert state if possible? user experience might be jarring.
      // For now just error.
    }
  }
}
