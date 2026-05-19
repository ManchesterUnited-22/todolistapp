import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

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
      default:
        return web;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCAhmWAzSMt_tuzyS7w_2o-MQXtT3S4Rr8',
    appId: '1:314034792177:android:9bff8e4d9d6719bcd22b50',
    messagingSenderId: '314034792177',
    projectId: 'todolist-7bebc',
    storageBucket: 'todolist-7bebc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCAhmWAzSMt_tuzyS7w_2o-MQXtT3S4Rr8',
    appId: '1:314034792177:ios:example',
    messagingSenderId: '314034792177',
    projectId: 'todolist-7bebc',
    storageBucket: 'todolist-7bebc.firebasestorage.app',
    iosClientId: 'example.apps.googleusercontent.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBf9_Utm1ytapgNUN19tE3L8uSzDXEQcyM',
    appId: '1:314034792177:web:fe76bf8892bed5a2d22b50',
    messagingSenderId: '314034792177',
    projectId: 'todolist-7bebc',
    storageBucket: 'todolist-7bebc.firebasestorage.app',
    authDomain: 'todolist-7bebc.firebaseapp.com',
  );
}
