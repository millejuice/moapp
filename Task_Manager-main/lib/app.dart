import 'package:flutter/material.dart';
import 'group_create.dart';
import 'group_join.dart';
import 'lock_screen.dart';

import 'add.dart';
import 'edit.dart';
import 'group.dart';
import 'login.dart';
import 'ranking.dart';
import 'todo.dart';

class PixelNSemicolon extends StatelessWidget {
  const PixelNSemicolon({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PixelNSemicolon',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (BuildContext context) => const LoginPage(),
        '/group': (BuildContext context) => const GroupPage(),
        '/group_create': (BuildContext context) => const CreateGroupScreen(),
        '/group_join': (BuildContext context) => const JoinGroupScreen(),
        '/ranking': (BuildContext context) => const RankingPage(),
        '/todo': (BuildContext context) => const TodoPage(),
        '/add': (BuildContext context) => const AddPage(),
        '/edit': (BuildContext context) => const EditPage(),
        '/lock': (BuildContext context) => const LockPage(),
      },
      theme: ThemeData(useMaterial3: true, fontFamily: 'DungGeunMo'),
    );
  }
}
