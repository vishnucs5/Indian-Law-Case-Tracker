// Firebase configuration options for CaseTrack
// TODO: Replace with your actual Firebase project configuration
// Run `flutterfire configure` to generate this file automatically

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDVnVL19X6-fdt4SYQcdcwy6mNCC_8UvUA',
    appId: '1:1048850954155:web:bdac7636e4e10d0ea584ee',
    messagingSenderId: '1048850954155',
    projectId: 'case-tracker-49cb5',
    authDomain: 'case-tracker-49cb5.firebaseapp.com',
    storageBucket: 'case-tracker-49cb5.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVnVL19X6-fdt4SYQcdcwy6mNCC_8UvUA',
    appId: '1:1048850954155:android:bdac7636e4e10d0ea584ee',
    messagingSenderId: '1048850954155',
    projectId: 'case-tracker-49cb5',
    storageBucket: 'case-tracker-49cb5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDVnVL19X6-fdt4SYQcdcwy6mNCC_8UvUA',
    appId: '1:1048850954155:ios:bdac7636e4e10d0ea584ee',
    messagingSenderId: '1048850954155',
    projectId: 'case-tracker-49cb5',
    storageBucket: 'case-tracker-49cb5.firebasestorage.app',
    iosBundleId: 'com.casetrack.casetrack',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDVnVL19X6-fdt4SYQcdcwy6mNCC_8UvUA',
    appId: '1:1048850954155:macos:bdac7636e4e10d0ea584ee',
    messagingSenderId: '1048850954155',
    projectId: 'case-tracker-49cb5',
    storageBucket: 'case-tracker-49cb5.firebasestorage.app',
    iosBundleId: 'com.casetrack.casetrack',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDVnVL19X6-fdt4SYQcdcwy6mNCC_8UvUA',
    appId: '1:1048850954155:windows:bdac7636e4e10d0ea584ee',
    messagingSenderId: '1048850954155',
    projectId: 'case-tracker-49cb5',
    storageBucket: 'case-tracker-49cb5.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDVnVL19X6-fdt4SYQcdcwy6mNCC_8UvUA',
    appId: '1:1048850954155:linux:bdac7636e4e10d0ea584ee',
    messagingSenderId: '1048850954155',
    projectId: 'case-tracker-49cb5',
    storageBucket: 'case-tracker-49cb5.firebasestorage.app',
  );
}