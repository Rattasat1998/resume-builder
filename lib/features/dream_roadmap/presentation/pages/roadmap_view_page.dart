import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_language_cubit.dart';
import '../../data/models/roadmap_model.dart';
import '../cubit/roadmap_cubit.dart';

class RoadmapViewPage extends StatelessWidget {
  final RoadmapModel roadmap;

  const RoadmapViewPage({super.key, required this.roadmap});

  @override
  Widget build(BuildContext context) {
    // Calculate progress
    final completedSteps = roadmap.steps.where((s) => s.isCompleted).length;
    final totalSteps = roadmap.steps.length;
    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;
    final strings = AppStrings(context.watch<AppLanguageCubit>().state);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.dreamJobRoadmap),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Regenerate',
            onPressed: () {
              // Option to regenerate or delete
              // For now, let's just show a snackbar or implement delete later
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, progress),
            const SizedBox(height: 24),
            if (roadmap.motivationMessage != null) ...[
              _buildMotivationCard(context, roadmap.motivationMessage!),
              const SizedBox(height: 24),
            ],
            Text(
              strings.yourSteps,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: roadmap.steps.length,
              itemBuilder: (context, index) {
                final step = roadmap.steps[index];
                return _buildStepCard(context, step, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double progress) {
    return Column(
      children: [
        Text(
          roadmap.targetJobTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        if (roadmap.targetCompany != null)
          Text(
            'at ${roadmap.targetCompany}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 24),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          color: Theme.of(context).primaryColor,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}% Completed',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationCard(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.amber),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '"$message"',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.amber.shade900,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, RoadmapStep step, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: CheckboxListTile(
        value: step.isCompleted,
        onChanged: (bool? value) {
          if (value != null) {
            context.read<RoadmapCubit>().updateStepProgress(
              roadmap,
              index,
              value,
            );
          }
        },
        title: Text(
          step.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: step.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(step.description),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${step.estimatedWeeks} weeks',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
        secondary: CircleAvatar(
          backgroundColor: step.isCompleted
              ? Colors.green.withOpacity(0.2)
              : Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: step.isCompleted
                  ? Colors.green
                  : Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
