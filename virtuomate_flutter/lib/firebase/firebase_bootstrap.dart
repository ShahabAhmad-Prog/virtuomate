import 'package:firebase_core/firebase_core.dart';
import 'package:virtuomate_flutter/firebase_options.dart';

Future<void> initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
