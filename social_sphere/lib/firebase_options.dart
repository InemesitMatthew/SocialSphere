// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyClQ62iM0x2q54GDGEV-PsQNePH4x4U10A',
    appId: '1:379559331077:web:7545770e5ee42f1e6f636c',
    messagingSenderId: '379559331077',
    projectId: 'socialsphere-c2989',
    authDomain: 'socialsphere-c2989.firebaseapp.com',
    storageBucket: 'socialsphere-c2989.firebasestorage.app',
    measurementId: 'G-50Y6EYWXFR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARN4j7XgCSsKS_pb_AzH8q8xF_g74j01g',
    appId: '1:379559331077:android:a25392fd043ebc606f636c',
    messagingSenderId: '379559331077',
    projectId: 'socialsphere-c2989',
    storageBucket: 'socialsphere-c2989.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB3o1H3vInJXNycdVu5KK5JZG2ixeP2IUM',
    appId: '1:379559331077:ios:f26733945eaf61606f636c',
    messagingSenderId: '379559331077',
    projectId: 'socialsphere-c2989',
    storageBucket: 'socialsphere-c2989.firebasestorage.app',
    iosBundleId: 'com.senmid.socialsphere',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB3o1H3vInJXNycdVu5KK5JZG2ixeP2IUM',
    appId: '1:379559331077:ios:ed78b6cd55755e356f636c',
    messagingSenderId: '379559331077',
    projectId: 'socialsphere-c2989',
    storageBucket: 'socialsphere-c2989.firebasestorage.app',
    iosBundleId: 'com.example.socialSphere',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyClQ62iM0x2q54GDGEV-PsQNePH4x4U10A',
    appId: '1:379559331077:web:9c9e22e91a9efa6c6f636c',
    messagingSenderId: '379559331077',
    projectId: 'socialsphere-c2989',
    authDomain: 'socialsphere-c2989.firebaseapp.com',
    storageBucket: 'socialsphere-c2989.firebasestorage.app',
    measurementId: 'G-GT36J5N0RB',
  );

}