// Bản giả cho CI: bản thật do FlutterFire sinh chứa khoá nên nằm ngoài Git
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
    apiKey: 'ci-gia',
    appId: 'ci-gia',
    messagingSenderId: 'ci-gia',
    projectId: 'ci-gia',
  );
}
