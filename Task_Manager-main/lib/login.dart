import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'util/google_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    // 로그인 페이지 진입 시 Google 로그인 세션 초기화
    _signOutSilently();
  }

  Future<void> _signOutSilently() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      // 로그아웃 에러는 무시 (이미 로그아웃 상태일 수 있음)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Image.asset('assets/splash.png', width: 116, height: 116),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Task Manager',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80.0),
                const GoogleSignInButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
