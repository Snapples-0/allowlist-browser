// Auto-filled from google-services.json
// Project: restricted-browser

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8h-VneuQS2ZGuJvXdC2skN1E6G-Ce3vE',
    appId: '1:265912103283:android:8b1d8a437805065a541506',
    messagingSenderId: '265912103283',
    projectId: 'restricted-browser',
    storageBucket: 'restricted-browser.firebasestorage.app',
  );

  // iOS: add an iOS app in Firebase Console to get real values
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD8h-VneuQS2ZGuJvXdC2skN1E6G-Ce3vE',
    appId: '1:265912103283:ios:PLACEHOLDER',
    messagingSenderId: '265912103283',
    projectId: 'restricted-browser',
    storageBucket: 'restricted-browser.firebasestorage.app',
    iosBundleId: 'com.example.allowlistBrowser',
  );

  // Web: add a Web app in Firebase Console to get real values
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD8h-VneuQS2ZGuJvXdC2skN1E6G-Ce3vE',
    appId: '1:265912103283:web:PLACEHOLDER',
    messagingSenderId: '265912103283',
    projectId: 'restricted-browser',
    authDomain: 'restricted-browser.firebaseapp.com',
    storageBucket: 'restricted-browser.firebasestorage.app',
  );
}
