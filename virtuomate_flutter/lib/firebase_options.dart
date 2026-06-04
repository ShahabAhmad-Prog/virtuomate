// Firebase configuration for project `virtuomate`.
// Regenerate with: flutterfire configure --project=virtuomate
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Linux Firebase not configured.');
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAgQNXG2nIwzZPBzTVNCvWyI7grcMPAKCE',
    appId: '1:671835013493:web:virtuomate',
    messagingSenderId: '671835013493',
    projectId: 'virtuomate',
    authDomain: 'virtuomate.firebaseapp.com',
    storageBucket: 'virtuomate.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgQNXG2nIwzZPBzTVNCvWyI7grcMPAKCE',
    appId: '1:671835013493:android:d91e70b9dc7642ab0b133c',
    messagingSenderId: '671835013493',
    projectId: 'virtuomate',
    storageBucket: 'virtuomate.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALTM_mZ-UtDcNcdpRHnhhvcV-MYN-KflQ',
    appId: '1:671835013493:ios:fafa7966712942880b133c',
    messagingSenderId: '671835013493',
    projectId: 'virtuomate',
    storageBucket: 'virtuomate.firebasestorage.app',
    androidClientId: '671835013493-op5pv14ol9afsasu6u5kb6qq3mg5ege9.apps.googleusercontent.com',
    iosClientId: '671835013493-51l32nbs1bqah3ms96dbklskvu220k77.apps.googleusercontent.com',
    iosBundleId: 'com.example.virtuomateFlutter',
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAgQNXG2nIwzZPBzTVNCvWyI7grcMPAKCE',
    appId: '1:671835013493:web:virtuomate',
    messagingSenderId: '671835013493',
    projectId: 'virtuomate',
    storageBucket: 'virtuomate.firebasestorage.app',
  );
}