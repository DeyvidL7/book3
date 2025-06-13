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
    apiKey: 'AIzaSyBI2ahzudkkAoTmluR_kiXWFYAY_QbKvSo',
    appId: '1:1072251839491:web:bca3556dd6dd70ddd69a36',
    messagingSenderId: '1072251839491',
    projectId: 'ng-task-18-aff84',
    authDomain: 'ng-task-18-aff84.firebaseapp.com',
    storageBucket: 'ng-task-18-aff84.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDKEXs6NoDpkvdUvBdQTJLFdDcc0M0TmEQ',
    appId: '1:1072251839491:android:70b1849e00e1fff7d69a36',
    messagingSenderId: '1072251839491',
    projectId: 'ng-task-18-aff84',
    storageBucket: 'ng-task-18-aff84.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDKEXs6NoDpkvdUvBdQTJLFdDcc0M0TmEQ',
    appId: '1:1072251839491:ios:70b1849e00e1fff7d69a36',
    messagingSenderId: '1072251839491',
    projectId: 'ng-task-18-aff84',
    storageBucket: 'ng-task-18-aff84.firebasestorage.app',
    iosBundleId: 'com.capsule.book',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDKEXs6NoDpkvdUvBdQTJLFdDcc0M0TmEQ',
    appId: '1:1072251839491:macos:70b1849e00e1fff7d69a36',
    messagingSenderId: '1072251839491',
    projectId: 'ng-task-18-aff84',
    storageBucket: 'ng-task-18-aff84.firebasestorage.app',
    iosBundleId: 'com.capsule.book',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDKEXs6NoDpkvdUvBdQTJLFdDcc0M0TmEQ',
    appId: '1:1072251839491:windows:70b1849e00e1fff7d69a36',
    messagingSenderId: '1072251839491',
    projectId: 'ng-task-18-aff84',
    authDomain: 'ng-task-18-aff84.firebaseapp.com',
    storageBucket: 'ng-task-18-aff84.firebasestorage.app',
  );
}