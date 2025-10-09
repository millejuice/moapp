import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'util/notifi_service.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationService().initNotification();
  runApp(const PixelNSemicolon());
}
