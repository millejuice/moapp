import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'group_code.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  bool _isCreating = false;

  // 랜덤 그룹 토큰 생성 함수
  String _generateGroupToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
      12,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('그룹 이름을 입력해주세요.')));
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 그룹 토큰 생성
      String groupToken = _generateGroupToken();
      print('🎲 Generated token: $groupToken');

      // 중복 확인 (문서 ID로)
      var existingDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupToken)
          .get();

      while (existingDoc.exists) {
        print('⚠️ Token collision detected, generating new token...');
        groupToken = _generateGroupToken();
        existingDoc = await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupToken)
            .get();
      }

      print('✨ Final group token: $groupToken');

      // Firestore에 그룹 생성 (문서 ID = groupToken)
      await FirebaseFirestore.instance.collection('groups').doc(groupToken).set(
        {
          'groupToken': groupToken,
          'groupName': _groupNameController.text.trim(),
          'creatorUid': user.uid,
          'members': [user.uid],
          'points': {user.uid: 0},
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      print('✅ Group created in Firestore with ID: $groupToken');

      // 사용자 문서에 그룹 토큰 추가
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'groupTokens': FieldValue.arrayUnion([groupToken]),
        },
      );

      print('✅ User document updated');

      // 그룹 코드 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GroupCodeScreen(
            groupToken: groupToken,
            groupName: _groupNameController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      print('❌ Error creating group: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('그룹 생성 실패: $e')));
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: 192),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 85.12,
                height: 85.12,
                child: Image.asset('assets/group2.png'),
              ),
              SizedBox(width: 11.8),
              Column(
                children: [
                  Text(
                    '환영한다!',
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  Text(
                    '김깔깔!',
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 97),
          Container(
            width: 265,
            height: 27,
            decoration: BoxDecoration(border: Border.all(color: Colors.white)),
            child: TextField(
              controller: _groupNameController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '그룹 이름을 작성해주세요.',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          ),
          SizedBox(height: 35),
          ElevatedButton(
            onPressed: _isCreating ? null : _createGroup,
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(156, 35),
              backgroundColor: Color(0XFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24), // 테두리 둥글기 조정
              ),
            ),
            child: _isCreating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const Text(
                    '확인',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
          ),
          SizedBox(height: 13),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(156, 35),
              backgroundColor: Color(0XFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24), // 테두리 둥글기 조정
              ),
            ),
            child: const Text(
              'back',
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
