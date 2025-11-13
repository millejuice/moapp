import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Google 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Step 1: Google 로그인 화면 호출
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // 로그인 취소
      }

      // Step 2: 구글 인증 정보 받아오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: Firebase Auth Credential 생성
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken, // iOS/Android 모두 안정적
      );

      // Step 4: Firebase 로그인 처리
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Login Error: $e');
      return null;
    }
  }

  /// 익명 로그인
  Future<UserCredential?> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }
}
