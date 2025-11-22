import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'group_create.dart';
import 'group_join.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  String userName = '로딩중...';
  String userNickname = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Firestore에서 사용자 데이터 확인
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.data()?['name'] ?? user.displayName ?? '사용자';
          userNickname = userDoc.data()?['nickname'] ?? '';
        });
      } else {
        // 사용자 데이터가 없으면 생성
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? '사용자',
          'nickname': user.displayName?.split(' ')[0] ?? '닉네임',
          'groupTokens': [],
        });
        setState(() {
          userName = user.displayName ?? '사용자';
          userNickname = user.displayName?.split(' ')[0] ?? '닉네임';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: 192),
          Center(
            child: Text(
              '환영한다!',
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          Center(
            child: Text(
              '$userNickname!',
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          SizedBox(height: 66),
          SizedBox(
            width: 196.88,
            height: 196.88,
            child: Image.asset('assets/group2.png'),
          ),
          SizedBox(height: 49),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateGroupScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(156, 35),
              backgroundColor: Color(0XFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24), // 테두리 둥글기 조정
              ),
            ),
            child: const Text(
              '그룹 만들기',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/group_join');
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(156, 35),
              backgroundColor: Color(0XFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24), // 테두리 둥글기 조정
              ),
            ),
            child: const Text(
              '그룹 참여하기',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
