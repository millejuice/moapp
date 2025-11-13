import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'login.dart';

class ShrineApp extends StatelessWidget {
  const ShrineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      theme: ThemeData.light(useMaterial3: true),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snapshot.data;
          // Treat anonymous users as not authenticated for routing purposes
          if (user != null && !user.isAnonymous) {
            return const HomePage();
          }
          return const LoginPage();
        },
      ),
      routes: {
        '/login': (BuildContext context) => const LoginPage(),
        // '/': (BuildContext context) => const HomePage(),
      },
    );
  }
}
