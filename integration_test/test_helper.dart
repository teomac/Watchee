import 'package:firebase_core/firebase_core.dart';

class TestHelper {
  static Future<void> setupFirebaseForTesting() async {
    const firebaseOptions = FirebaseOptions(
      apiKey: 'AIzaSyD1dzyvbwL4TK_I5sYYtNFilRfnNNuUXXE', // Your Android API key
      appId:
          '1:1036229847304:android:c8c4a79f97d02ab6cd64bd', // Your Android App ID
      messagingSenderId: '1036229847304',
      projectId: 'dima-project-matteo',
      storageBucket: 'dima-project-matteo.appspot.com',
    );

    await Firebase.initializeApp(
      options: firebaseOptions,
    );
  }
}
