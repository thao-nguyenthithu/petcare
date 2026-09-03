import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Email đã thuộc về một tài khoản đăng nhập bằng cách khác
class LoiEmailDaCoCachKhac implements Exception {
  const LoiEmailDaCoCachKhac();
}

class SocialAuthService {
  bool _googleReady = false;

  Future<void> _ensureGoogleInit() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize();
    _googleReady = true;
  }

  Future<String?> signInWithGoogle() async {
    final credential = await _credentialGoogle();
    if (credential == null) return null;
    return _dangNhapFirebase(credential);
  }

  Future<String?> signInWithFacebook() async {
    final credential = await _credentialFacebook();
    if (credential == null) return null;
    return _dangNhapFirebase(credential);
  }

  Future<AuthCredential?> _credentialGoogle() async {
    await _ensureGoogleInit();
    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
    final auth = account.authentication;
    return GoogleAuthProvider.credential(idToken: auth.idToken);
  }

  Future<AuthCredential?> _credentialFacebook() async {
    final result = await FacebookAuth.instance.login();
    switch (result.status) {
      case LoginStatus.success:
        final token = result.accessToken;
        if (token == null) return null;
        return FacebookAuthProvider.credential(token.tokenString);
      case LoginStatus.cancelled:
        return null;
      default:
        throw Exception(result.message ?? 'Đăng nhập Facebook thất bại');
    }
  }

  // Một email một tài khoản Firebase, cách thứ hai dừng ở đây chứ không tự gắn
  Future<String?> _dangNhapFirebase(AuthCredential credential) async {
    try {
      final ketQua = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      return ketQua.user?.getIdToken();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'account-exists-with-different-credential') rethrow;
      throw const LoiEmailDaCoCachKhac();
    }
  }
}
