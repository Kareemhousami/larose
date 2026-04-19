import 'package:firebase_core/firebase_core.dart';

import '../config/app_firebase_options.dart';

/// Initializes Firebase before the app starts.
class FirebaseBootstrapService {
  FirebaseBootstrapService._();

  static Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: AppFirebaseOptions.currentPlatform,
      );
    }
  }
}
