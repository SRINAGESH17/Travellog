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
        return macos;
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
    apiKey: 'AIzaSyD7yUtMKxWnVWsfYsYdipws8TT4DeAJy0c',
    appId: '1:703016876748:web:47127da11fe374453aa069',
    messagingSenderId: '703016876748',
    projectId: 'travellog-4d387',
    authDomain: 'travellog-4d387.firebaseapp.com',
    databaseURL: 'https://travellog-4d387-default-rtdb.firebaseio.com',
    storageBucket: 'travellog-4d387.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBfO4-fL_svWjIf4eNOs8Zy4PKanBdQjHU',
    appId: '1:703016876748:android:e53ef81565ad10313aa069',
    messagingSenderId: '703016876748',
    projectId: 'travellog-4d387',
    databaseURL: 'https://travellog-4d387-default-rtdb.firebaseio.com',
    storageBucket: 'travellog-4d387.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCtlb2vdNPHHTNRPMJTXA5cxwMrgBtZVYE',
    appId: '1:703016876748:ios:1862294dee6c99e63aa069',
    messagingSenderId: '703016876748',
    projectId: 'travellog-4d387',
    databaseURL: 'https://travellog-4d387-default-rtdb.firebaseio.com',
    storageBucket: 'travellog-4d387.appspot.com',
    iosClientId: '703016876748-t6ft7psidfkc2b168s37b86q7o35607f.apps.googleusercontent.com',
    iosBundleId: 'com.skygoal.travellog',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCtlb2vdNPHHTNRPMJTXA5cxwMrgBtZVYE',
    appId: '1:703016876748:ios:1862294dee6c99e63aa069',
    messagingSenderId: '703016876748',
    projectId: 'travellog-4d387',
    databaseURL: 'https://travellog-4d387-default-rtdb.firebaseio.com',
    storageBucket: 'travellog-4d387.appspot.com',
    iosClientId: '703016876748-t6ft7psidfkc2b168s37b86q7o35607f.apps.googleusercontent.com',
    iosBundleId: 'com.skygoal.travellog',
  );
}
