import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Chọn nhầm tài khoản khác với email đang cần liên kết hai cách đăng nhập
class LoiSaiTaiKhoanLienKet implements Exception {
  const LoiSaiTaiKhoanLienKet(this.email);

  final String email;
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
    return _dangNhapFirebase(credential, _credentialFacebook);
  }

  Future<String?> signInWithFacebook() async {
    final credential = await _credentialFacebook();
    if (credential == null) return null;
    return _dangNhapFirebase(credential, _credentialGoogle);
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

  // Firebase giữ một tài khoản cho mỗi email nên cách đăng nhập thứ hai phải gắn vào tài khoản cũ
  Future<String?> _dangNhapFirebase(
    AuthCredential credential,
    Future<AuthCredential?> Function() layCachDaCo,
  ) async {
    final auth = FirebaseAuth.instance;
    try {
      final ketQua = await auth.signInWithCredential(credential);
      return ketQua.user?.getIdToken();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'account-exists-with-different-credential') rethrow;
      final cachDaCo = await layCachDaCo();
      if (cachDaCo == null) return null;
      final ketQua = await auth.signInWithCredential(cachDaCo);
      final user = ketQua.user;
      if (user == null) return null;
      final emailCanLienKet = e.email?.toLowerCase();
      if (emailCanLienKet != null &&
          user.email?.toLowerCase() != emailCanLienKet) {
        await auth.signOut();
        throw LoiSaiTaiKhoanLienKet(e.email!);
      }
      await _gan(user, e.credential ?? credential);
      return user.getIdToken();
    }
  }

  Future<void> _gan(User user, AuthCredential credential) async {
    try {
      await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code != 'provider-already-linked') rethrow;
    }
  }
}
