import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';

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
      final userCredential = await _auth.signInWithCredential(credential);
      // Ensure user document exists
      try {
        final user = userCredential.user;
        if (user != null) {
          await FirestoreService().createUserIfNotExists(user);
        }
      } catch (e) {
        print('Error ensuring user doc: $e');
      }
      return userCredential;
    } catch (e) {
      print('Google Login Error: $e');
      return null;
    }
  }

  /// 익명 로그인
  Future<UserCredential?> signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    try {
      final user = userCredential.user;
      if (user != null) {
        await FirestoreService().createUserIfNotExists(user);
      }
    } catch (e) {
      print('Error ensuring user doc: $e');
    }
    return userCredential;
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();
      // Also sign out from Google if signed in
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // ignore google sign out errors
      }
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }
}
