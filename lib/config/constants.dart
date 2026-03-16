class AppConstants {
  // App Info
  static const String appName = 'Heartly AI';
  static const String appVersion = '0.0.1';
  
  // Skin Metrics (11 metrics)
  static const List<String> skinMetrics = [
    'firmness',
    'red_areas',
    'eye_bag',
    'visible_pores',
    'wrinkles',
    'uv_damage',
    'crows_feet',
    'texture',
    'brown_spots',
    'dark_circle',
    'clogged_pores',
  ];
  
  static const Map<String, String> metricDisplayNames = {
    'firmness': 'Firmness',
    'red_areas': 'Red Areas',
    'eye_bag': 'Eye Bags',
    'visible_pores': 'Visible Pores',
    'wrinkles': 'Wrinkles',
    'uv_damage': 'UV Damage',
    'crows_feet': "Crow's Feet",
    'texture': 'Texture',
    'brown_spots': 'Brown Spots',
    'dark_circle': 'Dark Circles',
    'clogged_pores': 'Clogged Pores',
  };
  
  // Age Prediction
  static const int minAge = 13;
  static const int maxAge = 100;
  
  // Analysis
  static const int analysisTimeoutSeconds = 30;
  static const int imageGenerationTimeoutSeconds = 60;
  
  // Storage Keys
  static const String userBox = 'user_box';
  static const String analysisBox = 'analysis_box';
  static const String challengeBox = 'challenge_box';
  
  // Share
  static const String shareText = 'Check out my skin analysis on Heartly AI! What\'s your skin score?';
  static const String challengeText = 'I challenged you to a skin analysis duel! Who has better skin? 😏';
  
  // URLs
  static const String websiteUrl = 'https://heartly.ai';
  static const String privacyPolicyUrl = 'https://heartly.ai/privacy';
  static const String termsOfServiceUrl = 'https://heartly.ai/terms';
  
  // Social
  static const String instagramUrl = 'https://instagram.com/heartlyai';
  static const String tiktokUrl = 'https://tiktok.com/@heartlyai';
}
