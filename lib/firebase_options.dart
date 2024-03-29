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
    apiKey: 'AIzaSyAzbz-3LuSl0_8h2M7Rw3lFCwCuJBlC5HE',
    appId: '1:856957140303:web:84d618b329271fae6c593a',
    messagingSenderId: '856957140303',
    projectId: 'flutterrntstudentsapp',
    authDomain: 'flutterrntstudentsapp.firebaseapp.com',
    storageBucket: 'flutterrntstudentsapp.appspot.com',
    measurementId: 'G-TV4356PGMT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCpVjvrCmaxRvbNDgykwoTfYI2cb4FJQRU',
    appId: '1:856957140303:android:4c67f7791eda188c6c593a',
    messagingSenderId: '856957140303',
    projectId: 'flutterrntstudentsapp',
    storageBucket: 'flutterrntstudentsapp.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCtpDhaCiXlIUxqzPSPbKh1iupS7oyCubs',
    appId: '1:856957140303:ios:3ee83489e7fcecc36c593a',
    messagingSenderId: '856957140303',
    projectId: 'flutterrntstudentsapp',
    storageBucket: 'flutterrntstudentsapp.appspot.com',
    iosClientId: '856957140303-735s6ukb54d57qqgh5ilo5girltqi1h6.apps.googleusercontent.com',
    iosBundleId: 'com.example.rntApp',
  );
}
