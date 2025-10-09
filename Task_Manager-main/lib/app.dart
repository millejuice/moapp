import 'package:flutter/material.dart';
import 'group_code.dart';
import 'group_create.dart';
import 'group_join.dart';
import 'lock_screen.dart';

import 'add.dart';
import 'group.dart';
import 'login.dart';
import 'ranking.dart';
import 'todo.dart';

class PixelNSemicolon extends StatelessWidget {
  const PixelNSemicolon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PixelNSemicolon',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (BuildContext context) => const LoginPage(),
        '/group': (BuildContext context) => const GroupPage(),
        '/group_code': (BuildContext context) => const GroupCodeScreen(),
        '/group_create': (BuildContext context) => const CreateGroupScreen(),
        '/group_join': (BuildContext context) => const JoinGroupScreen(),
        '/ranking': (BuildContext context) => const RankingPage(),
        '/todo': (BuildContext context) => const TodoPage(),
        '/add': (BuildContext context) => const AddPage(),
        '/lock': (BuildContext context) => const LockPage(),
      },
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'DungGeunMo',
      ),
    );
  }
}
