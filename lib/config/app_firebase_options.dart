import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase options for the configured La Rose project.
class AppFirebaseOptions {
  AppFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBIhKXrKgLmslRFV_wNEUDTwTLNGfTweOA',
    appId: '1:369888180682:web:7cdb571db0c72777e0b733',
    messagingSenderId: '369888180682',
    projectId: 'la-rose-15a8e',
    authDomain: 'la-rose-15a8e.firebaseapp.com',
    storageBucket: 'la-rose-15a8e.firebasestorage.app',
    measurementId: 'G-EGHM28L79C',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA2lcz1VWraSZics9xNE-5F3nFDQRYa_c0',
    appId: '1:369888180682:android:d8de65703e13c121e0b733',
    messagingSenderId: '369888180682',
    projectId: 'la-rose-15a8e',
    storageBucket: 'la-rose-15a8e.firebasestorage.app',
    androidClientId:
        '369888180682-75809oask90iahet7f3d3p02nmd5565b.apps.googleusercontent.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAgC6p1vJUaGc_nbk5W5itqluNxWGKUNU',
    appId: '1:369888180682:ios:13c45c50d529bcf4e0b733',
    messagingSenderId: '369888180682',
    projectId: 'la-rose-15a8e',
    storageBucket: 'la-rose-15a8e.firebasestorage.app',
    iosClientId:
        '369888180682-operau7adak1eqar6h2i959jv43ph5fs.apps.googleusercontent.com',
    iosBundleId: 'com.example.laRose',
  );
}
