import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final TextEditingController _tokenController = TextEditingController();
  bool _isJoining = false;
  String userName = '사용자';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.data()?['nickname'] ?? user.displayName ?? '사용자';
        });
      }
    }
  }

  Future<void> _joinGroup() async {
    if (_tokenController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('초대 코드를 입력해주세요.')));
      }
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
        }
        return;
      }

      final groupToken = _tokenController.text.trim();
      print('🔍 Trying to join group: $groupToken');

      // groupToken 필드로 그룹 검색
      final querySnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('groupToken', isEqualTo: groupToken)
          .limit(1)
          .get();

      print('📦 Query result: ${querySnapshot.docs.length} groups found');

      if (querySnapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('존재하지 않는 그룹 코드입니다: $groupToken'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final groupDoc = querySnapshot.docs.first;
      final groupData = groupDoc.data();
      print('📊 Group data: $groupData');
      print('📄 Group document ID: ${groupDoc.id}');

      // 이미 가입된 그룹인지 확인
      final members = List<String>.from(groupData['members'] ?? []);
      print('👥 Current members: $members');
      print('🆔 My UID: ${user.uid}');

      if (members.contains(user.uid)) {
        print('ℹ️ Already a member of this group, navigating to todo page...');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이미 참여한 그룹입니다. 해당 그룹으로 이동합니다.'),
              backgroundColor: Colors.orange,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.pushReplacementNamed(
            context,
            '/todo',
            arguments: {'joinedGroupToken': groupToken},
          );
        }
        return;
      }

      // 그룹에 사용자 추가 (문서 ID 사용)
      print('➕ Adding user to group...');
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupDoc.id) // 문서 ID 사용
          .update({
            'members': FieldValue.arrayUnion([user.uid]),
            'points.${user.uid}': 0,
          });

      // 사용자 문서에 그룹 토큰 추가
      print('📝 Updating user document...');
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'groupTokens': FieldValue.arrayUnion([groupToken]),
        },
      );

      print('✅ Successfully joined group!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('그룹에 참여했습니다!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // 잠시 대기 후 해당 그룹으로 이동
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushReplacementNamed(
          context,
          '/todo',
          arguments: {'joinedGroupToken': groupToken},
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error joining group: $e');
      print('📚 Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('그룹 참여 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
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
                    '$userName!',
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
              controller: _tokenController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '초대 코드를 입력해주세요.',
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
            onPressed: _isJoining ? null : _joinGroup,
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(156, 35),
              backgroundColor: Color(0XFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24), // 테두리 둥글기 조정
              ),
            ),
            child: _isJoining
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
