class AppConstants {
  static const bool useMockApi = false; // Set to false to use real FastAPI backend + PostgreSQL
  
  // Real backend URL (Render Cloud 24/7)
  static const String apiBaseUrl = 'https://mentality-38jh.onrender.com'; 

  // Keys
  static const String tokenKey = 'jwt_token';
  static const String onboardedKey = 'has_seen_onboarding';

  // Google OAuth
  static const String googleServerClientId = '1028134720370-g39rh2ojgtdkl3646cc0uacjaq9k31mr.apps.googleusercontent.com';
}
