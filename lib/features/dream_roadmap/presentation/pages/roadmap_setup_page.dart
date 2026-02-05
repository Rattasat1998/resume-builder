import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_language_cubit.dart';
import '../../../subscription/domain/entities/user_plan.dart';
import '../../../subscription/presentation/bloc/subscription_bloc.dart';
import '../cubit/roadmap_cubit.dart';

class RoadmapSetupPage extends StatefulWidget {
  const RoadmapSetupPage({super.key});

  @override
  State<RoadmapSetupPage> createState() => _RoadmapSetupPageState();
}

class _RoadmapSetupPageState extends State<RoadmapSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  String _currentLevel = 'Junior'; // Default

  final List<String> _levels = [
    'Student',
    'Junior',
    'Mid-Level',
    'Senior',
    'Career Switcher',
    'Manager',
  ];

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _generateRoadmap(AppStrings strings) {
    if (_formKey.currentState!.validate()) {
      // Check Subscription
      final subscriptionState = context.read<SubscriptionBloc>().state;
      if (subscriptionState.userPlan == UserPlan.free) {
        Navigator.of(context).pushNamed('/paywall');
        return;
      }

      context.read<RoadmapCubit>().generateRoadmap(
        jobTitle: _jobTitleController.text.trim(),
        company: _companyController.text.trim().isNotEmpty
            ? _companyController.text.trim()
            : null,
        currentLevel: _currentLevel,
        languageCode: strings.language == AppLanguage.thai ? 'th' : 'en',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLanguageCubit, AppLanguage>(
      builder: (context, appLanguage) {
        final strings = AppStrings(appLanguage);

        return Scaffold(
          appBar: AppBar(
            title: Text(strings.dreamJobRoadmap),
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
          ),
          body: BlocBuilder<RoadmapCubit, RoadmapState>(
            builder: (context, state) {
              if (state is RoadmapLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(strings.consultingCoach),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        strings.whereDoYouWantToBe,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.defineGoal,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _jobTitleController,
                        decoration: InputDecoration(
                          labelText: strings.targetJobTitle,
                          hintText: 'e.g. Senior Flutter Developer',
                          prefixIcon: const Icon(Icons.work_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) =>
                            v?.isEmpty == true ? strings.required : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _companyController,
                        decoration: InputDecoration(
                          labelText: strings.dreamCompanyOptional,
                          hintText: 'e.g. Google, Spotify',
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _currentLevel,
                        decoration: InputDecoration(
                          labelText: strings.currentLevel,
                          prefixIcon: const Icon(Icons.timeline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _levels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _currentLevel = val);
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => _generateRoadmap(strings),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          strings.generateRoadmap,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
