import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthService {
  bool _googleReady = false;

  Future<void> _ensureGoogleInit() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize();
    _googleReady = true;
  }

  Future<String?> signInWithGoogle() async {
    await _ensureGoogleInit();
    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
    final auth = account.authentication;
    final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
    return _firebaseIdToken(credential);
  }

  Future<String?> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login();
    switch (result.status) {
      case LoginStatus.success:
        final token = result.accessToken;
        if (token == null) return null;
        final credential = FacebookAuthProvider.credential(token.tokenString);
        return _firebaseIdToken(credential);
      case LoginStatus.cancelled:
        return null;
      default:
        throw Exception(result.message ?? 'Đăng nhập Facebook thất bại');
    }
  }

  Future<String?> _firebaseIdToken(AuthCredential credential) async {
    final userCred = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    return userCred.user?.getIdToken();
  }
}
