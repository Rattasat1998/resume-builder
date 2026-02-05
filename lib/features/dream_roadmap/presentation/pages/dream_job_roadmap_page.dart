import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/roadmap_cubit.dart';
import 'roadmap_setup_page.dart';
import 'roadmap_view_page.dart';

class DreamJobRoadmapPage extends StatelessWidget {
  const DreamJobRoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoadmapCubit()..loadRoadmap(),
      child: BlocBuilder<RoadmapCubit, RoadmapState>(
        builder: (context, state) {
          if (state is RoadmapLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is RoadmapLoaded) {
            return RoadmapViewPage(roadmap: state.roadmap);
          } else if (state is RoadmapError) {
            // In case of error (except loading error intended for empty state), maybe show setup?
            // Actually, if fetching fails, we might want to retry.
            // But if it returns null (RoadmapInitial), we show Setup.
            // If actual error:
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<RoadmapCubit>().loadRoadmap(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Initial State -> Setup Page
          return const RoadmapSetupPage();
        },
      ),
    );
  }
}
