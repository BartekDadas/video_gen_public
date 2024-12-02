abstract class Environment {
  // Firebase Configuration
  static String get firebaseApiKey => 
      const String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
  
  static String get firebaseAuthDomain => 
      const String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: '');
  
  static String get firebaseProjectId => 
      const String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
  
  static String get firebaseStorageBucket => 
      const String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: '');
  
  static String get firebaseMessagingSenderId => 
      const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');
  
  static String get firebaseAppId => 
      const String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');

  // Authentication Credentials
  static String get loginUsername => 
      const String.fromEnvironment('LOGIN', defaultValue: 'test@test.com');
  
  static String get loginPassword => 
      const String.fromEnvironment('PASSWORD', defaultValue: 'test123');

  // API Tokens
  static String get recraftToken => 
      const String.fromEnvironment('RECRAFT_TOKEN', defaultValue: '');

  // Method to check if a required environment variable is set
  static bool isConfigured() {
    return firebaseApiKey.isNotEmpty && 
           firebaseAuthDomain.isNotEmpty && 
           firebaseProjectId.isNotEmpty;
  }
}
