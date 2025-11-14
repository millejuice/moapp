import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shrine/app.dart';
import 'firebase_options.dart';
import 'services/wishlist_provider.dart';
import 'package:shrine/services/user_profile_provider.dart';
import 'package:shrine/services/login_provider.dart';
import 'package:shrine/services/dropdown_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // 🔥 중요
  );
  // Ensure guest users are signed in anonymously so they can perform actions
  // that require authentication (e.g. liking products). If a user is already
  // signed in (Google or previous anonymous), keep that session.
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    try {
      final cred = await auth.signInAnonymously();
      final user = cred.user;
      if (user != null) {
        // Ensure user document exists in Firestore
        await FirestoreService().createUserIfNotExists(user);
      }
    } catch (e) {
      // Ignore sign-in errors here; actions that require auth will show errors.
      // You may want to log this in production.
    }
  }
  runApp(
    MultiProvider(
      providers: [
  ChangeNotifierProvider(create: (_) => WishlistProvider()),
  ChangeNotifierProvider(create: (_) => UserProfileProvider()),
  ChangeNotifierProvider(create: (_) => LoginProvider()),
  ChangeNotifierProvider(create: (_) => DropDownProvider()),
      ],
      child: const ShrineApp(),
    ),
  );
}
