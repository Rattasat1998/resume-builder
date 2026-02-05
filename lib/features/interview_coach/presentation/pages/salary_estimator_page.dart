import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_language_cubit.dart';
import '../../../subscription/domain/entities/user_plan.dart';
import '../../../subscription/presentation/bloc/subscription_bloc.dart';

class SalaryEstimatorPage extends StatefulWidget {
  const SalaryEstimatorPage({super.key});

  @override
  State<SalaryEstimatorPage> createState() => _SalaryEstimatorAuthState();
}

class _SalaryEstimatorAuthState extends State<SalaryEstimatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _jobPositionController = TextEditingController();
  final _experienceController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _jobPositionController.dispose();
    _experienceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _estimateSalary(AppStrings strings) async {
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();

    // Check Subscription
    final subscriptionState = context.read<SubscriptionBloc>().state;
    if (subscriptionState.userPlan == UserPlan.free) {
      Navigator.of(context).pushNamed('/paywall');
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      // Simulate network delay for better UX if needed, but here we just call API
      final response = await Supabase.instance.client.functions.invoke(
        'interview-coach',
        body: {
          'action': 'salary',
          'jobPosition': _jobPositionController.text.trim(),
          'yearsOfExperience': _experienceController.text.trim(),
          'location': _locationController.text.trim(),
          'practiceLanguage': strings.language == AppLanguage.thai
              ? 'th'
              : 'en',
        },
      );

      if (response.status == 200 && response.data != null) {
        setState(() {
          _result = response.data['salary'];
        });
      }
    } catch (e) {
      String errorMessage = '${strings.errorOccurred}: $e';
      if (e.toString().contains('400') ||
          e.toString().toLowerCase().contains('quota') ||
          e.toString().toLowerCase().contains('resource exhausted')) {
        errorMessage =
            'AI Service is busy (Quota Exceeded). Please try again later.';
      } else if (e.toString().toLowerCase().contains('gemini error')) {
        errorMessage =
            'AI Error: ${e.toString().split('Gemini Error:').last.trim()}';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLanguageCubit, AppLanguage>(
      builder: (context, appLanguage) {
        final strings = AppStrings(appLanguage);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              strings.salaryEstimator,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2563EB),
                  const Color(0xFF1E40AF),
                  Colors.grey.shade50,
                ],
                stops: const [0.0, 0.3, 0.3],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      strings.salaryEstimatorDesc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildFormCard(strings),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      _buildLoadingIndicator()
                    else if (_result != null)
                      _buildResultCard(strings),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormCard(AppStrings strings) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _jobPositionController,
                label: strings.jobPosition,
                hint: strings.jobPositionHint,
                icon: Icons.work_outline_rounded,
                validator: (v) => v?.isEmpty == true ? strings.required : null,
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  _buildTextField(
                    controller: _experienceController,
                    label: strings.yearsOfExperience,
                    hint: '0-50',
                    icon: Icons.timeline_rounded,
                    isNumber: true,
                    validator: (v) =>
                        v?.isEmpty == true ? strings.required : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _locationController,
                    label: strings.location,
                    hint: strings.locationHint,
                    icon: Icons.location_on_outlined,
                    validator: (v) =>
                        v?.isEmpty == true ? strings.required : null,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _estimateSalary(strings),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.analytics_rounded),
                            const SizedBox(width: 8),
                            Text(
                              strings.estimateSalary,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: validator,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF2563EB).withOpacity(0.7),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.blue.shade700),
            ),
            const SizedBox(height: 16),
            Text(
              "Analyzing market data...",
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(AppStrings strings) {
    final currency = _result!['currency'] ?? '';
    final min = _result!['min'];
    final max = _result!['max'];
    final median = _result!['median'];
    final trend = _result!['trend'];
    final factors = List<String>.from(_result!['factors'] ?? []);

    return Card(
      elevation: 10,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF2563EB).withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      strings.estimatedSalaryRange,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    _buildTrendBadge(trend),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        '$min - $max',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E3A8A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$currency / ${strings.month}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Median',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$median $currency',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        size: 20,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      strings.keyFactors,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...factors.map(
                  (factor) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            factor,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBadge(String trend) {
    Color color = _getTrendColor(trend);
    IconData icon = _getTrendIcon(trend);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            trend,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(String trend) {
    if (trend.toLowerCase().contains('increase') ||
        trend.toLowerCase().contains('up')) {
      return Colors.green;
    }
    if (trend.toLowerCase().contains('decrease') ||
        trend.toLowerCase().contains('down')) {
      return Colors.red;
    }
    return Colors.amber.shade700;
  }

  IconData _getTrendIcon(String trend) {
    if (trend.toLowerCase().contains('increase') ||
        trend.toLowerCase().contains('up')) {
      return Icons.trending_up_rounded;
    }
    if (trend.toLowerCase().contains('decrease') ||
        trend.toLowerCase().contains('down')) {
      return Icons.trending_down_rounded;
    }
    return Icons.trending_flat_rounded;
  }
}
