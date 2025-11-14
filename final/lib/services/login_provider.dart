import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class LoginProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _sub;

  String _displayName = '';
  bool _isAnonymous = true;

  LoginProvider() {
    // subscribe to auth state changes
    _sub = _auth.authStateChanges().listen((user) {
      if (user == null) {
        _displayName = '';
        _isAnonymous = true;
      } else {
        _isAnonymous = user.isAnonymous;
        _displayName = user.isAnonymous ? '' : (user.displayName ?? '');
      }
      notifyListeners();
    });
  }

  String get displayName => _displayName;
  bool get isAnonymous => _isAnonymous;

  String get appBarTitle {
    if (!_isAnonymous && _displayName.isNotEmpty) {
      return 'Welcome $_displayName!';
    }
    return 'Welcome Guest!';
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
