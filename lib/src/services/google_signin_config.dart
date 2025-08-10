import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInConfig {
  // Platform-specific client IDs
  static const String _webClientId = '19841551899-4j8l95t0t75m1j1oov0c6n5t2bmhqhfb.apps.googleusercontent.com';
  static const String _serverClientId = '19841551899-4j8l95t0t75m1j1oov0c6n5t2bmhqhfb.apps.googleusercontent.com';
  
  /// Get configured GoogleSignIn instance for the current platform
  static GoogleSignIn get instance {
    if (kIsWeb) {
      // Web platform configuration
      return GoogleSignIn(
        clientId: _webClientId,
        scopes: ['email', 'profile'],
      );
    } else {
      // Mobile platforms (Android/iOS)
      return GoogleSignIn(
        serverClientId: _serverClientId,
        scopes: ['email', 'profile'],
      );
    }
  }
}
