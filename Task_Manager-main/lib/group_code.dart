import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupCodeScreen extends StatefulWidget {
  final String groupToken;
  final String groupName;

  const GroupCodeScreen({
    super.key,
    required this.groupToken,
    required this.groupName,
  });

  @override
  State<GroupCodeScreen> createState() => _GroupCodeScreenState();
}

class _GroupCodeScreenState extends State<GroupCodeScreen> {
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

  Future<void> _copyToken() async {
    await Clipboard.setData(ClipboardData(text: widget.groupToken));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('토큰이 복사되었습니다!'),
        duration: Duration(seconds: 2),
      ),
    );
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
          SizedBox(height: 94),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 160),
              Text(
                textAlign: TextAlign.right,
                '그룹 토큰:',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ],
          ),
          Text(
            widget.groupToken,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              //홈화면으로 이동!!!!
              Navigator.popUntil(context, (route) => false);
              Navigator.pushNamed(
                context,
                '/todo',
                arguments: {'joinedGroupToken': widget.groupToken},
              );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(170, 40),
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.white, width: 1), // 테두리 둥글기 조정
              ),
            ),
            child: const Text(
              '그룹 입장',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 30),
          Container(height: 21, width: 1, color: Colors.white),
          SizedBox(height: 30),
          Text(
            '공유해서 내 친구도 초대하기 ><',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 9),
          ElevatedButton(
            onPressed: _copyToken,
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(156, 35),
              backgroundColor: Color(0XFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24), // 테두리 둥글기 조정
              ),
            ),
            child: const Text(
              '토큰 복사하기',
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
