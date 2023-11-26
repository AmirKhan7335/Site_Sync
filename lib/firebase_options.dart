// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDPxxQ-ughvjEwubUSBB5fnr-UPDBwD7nw',
    appId: '1:619023235306:web:7abebf961050e2566e3f93',
    messagingSenderId: '619023235306',
    projectId: 'progress-tracking-90a2c',
    authDomain: 'progress-tracking-90a2c.firebaseapp.com',
    databaseURL: 'https://progress-tracking-90a2c-default-rtdb.firebaseio.com',
    storageBucket: 'progress-tracking-90a2c.appspot.com',
    measurementId: 'G-JCT7RWEMV7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDjzsedspJ8sVc7EaHBESj577g2k7iEsm0',
    appId: '1:619023235306:android:ee90a254f311fe426e3f93',
    messagingSenderId: '619023235306',
    projectId: 'progress-tracking-90a2c',
    databaseURL: 'https://progress-tracking-90a2c-default-rtdb.firebaseio.com',
    storageBucket: 'progress-tracking-90a2c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDH_DRln-fhqorzqsWIJTEf4cWLpJTafqQ',
    appId: '1:619023235306:ios:951ad1ed96d2dfcb6e3f93',
    messagingSenderId: '619023235306',
    projectId: 'progress-tracking-90a2c',
    databaseURL: 'https://progress-tracking-90a2c-default-rtdb.firebaseio.com',
    storageBucket: 'progress-tracking-90a2c.appspot.com',
    iosBundleId: 'com.example.amirKhan1',
  );
}
