import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

/// Cubit for managing app language state
class AppLanguageCubit extends Cubit<AppLanguage> {
  static const String _languageKey = 'app_language';

  AppLanguageCubit() : super(AppLanguage.english) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null) {
      final language = AppLanguage.values.firstWhere(
        (lang) => lang.code == savedLanguage,
        orElse: () => AppLanguage.english,
      );
      emit(language);
    }
  }

  Future<void> changeLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.code);
    emit(language);
  }

  void toggleLanguage() {
    final newLanguage = state == AppLanguage.english
        ? AppLanguage.thai
        : AppLanguage.english;
    changeLanguage(newLanguage);
  }
}

