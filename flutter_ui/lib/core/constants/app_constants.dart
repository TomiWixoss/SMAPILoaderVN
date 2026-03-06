/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'SMAPI Launcher';
  static const String appVersion = '1.1.4';
  
  // Method Channel
  static const String methodChannelName = 'abc.smapi.gameloadervn/bridge';
  
  // Storage Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  
  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
}
