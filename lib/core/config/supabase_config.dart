/// Supabase configuration
///
/// Replace these values with your own Supabase project credentials
/// You can find these in your Supabase dashboard under Settings > API
class SupabaseConfig {
  /// Your Supabase project URL
  /// Example: https://xxxxx.supabase.co
  static const String url = 'https://molzzmuctakukfagmbxh.supabase.co';

  /// Your Supabase anonymous key
  /// This is safe to use in client-side code
  static const String anonKey = 'sb_publishable_J2HhOIl-1mixxOY6lLgBcg_7xttCkLI';

  /// Table names
  static const String resumesTable = 'resumes';

  /// Check if Supabase is configured
  static bool get isConfigured =>
      url != 'YOUR_SUPABASE_URL' && anonKey != 'YOUR_SUPABASE_ANON_KEY';
}

