import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'util/timer_widget.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController titleController = TextEditingController();
  int selectedPoints = 0;
  bool isAddingTodo = false;

  String? currentGroupToken;
  String? currentGroupDocId; // 실제 Firestore 문서 ID
  String? currentUid;
  String? userNickname;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      // Navigator arguments에서 현재 그룹 토큰 받기
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final passedGroupToken = args?['currentGroupToken'] as String?;
      _loadUserData(specificGroupToken: passedGroupToken);
    }
  }

  Future<void> _loadUserData({String? specificGroupToken}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUid = user.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final groupTokens = List<String>.from(userData?['groupTokens'] ?? []);
        userNickname = userData?['nickname'] ?? '사용자';

        // 전달받은 그룹 토큰 사용, 없으면 첫 번째 그룹
        currentGroupToken =
            specificGroupToken ??
            (groupTokens.isNotEmpty ? groupTokens[0] : null);

        if (currentGroupToken != null) {
          // groupToken 필드로 그룹 검색하여 문서 ID 얻기
          final querySnapshot = await FirebaseFirestore.instance
              .collection('groups')
              .where('groupToken', isEqualTo: currentGroupToken)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            setState(() {
              currentGroupDocId = querySnapshot.docs.first.id;
            });
          }
        }
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> addTodo() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('할 일을 입력해주세요!')));
      return;
    }

    if (selectedPoints == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('난이도를 선택해주세요!')));
      return;
    }

    if (currentGroupDocId == null || currentUid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('그룹에 먼저 참여해주세요!')));
      return;
    }

    setState(() {
      isAddingTodo = true;
    });

    try {
      await firestore
          .collection('groups')
          .doc(currentGroupDocId)
          .collection('todos')
          .add({
            'title': titleController.text.trim(),
            'points': selectedPoints,
            'createdBy': currentUid,
            'createdByName': userNickname ?? '사용자',
            'completedBy': [],
            'createdAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('할 일이 추가되었습니다!')));

      // 페이지 닫고 새로고침
      Navigator.pop(context, true);
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('추가 실패: $error')));
    } finally {
      setState(() {
        isAddingTodo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: null,
      child: Scaffold(
        backgroundColor: const Color(0xFF340B76),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF7B31),
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              Image.asset('assets/timer.png', width: 55, height: 55),
              const TimerWidget(),
              SizedBox(width: size.width * 0.1),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(color: Color(0xFF340B76)),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    backgroundColor: const Color(0xFFD9D9D9),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                  child: const Text(
                                    '<',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'To-do list',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: isAddingTodo ? null : addTodo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF7B31),
                              ),
                              child: isAddingTodo
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      '확인',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 10,
                        thickness: 2,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              controller: titleController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.black,
                                labelText: '너희 할일을 적어죠!',
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '얼마나 어렵니.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              '어려울수록 너는 포인트를 get.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 20),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 78,
                                        height: 30,
                                        child: Text(
                                          '누워서 \n숨쉬기',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        width: 78,
                                        height: 78,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: selectedPoints == 1
                                                ? const Color(0xFF4A2B7C)
                                                : const Color(0xFF201236),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                              side: selectedPoints == 1
                                                  ? const BorderSide(
                                                      color: Colors.white,
                                                      width: 2,
                                                    )
                                                  : BorderSide.none,
                                            ),
                                            padding: const EdgeInsets.all(12),
                                          ),
                                          child: const Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 26,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              selectedPoints = 1;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 9),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 78,
                                        height: 30,
                                        child: Text(
                                          '누워서\n죽먹기',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        width: 78,
                                        height: 78,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: selectedPoints == 2
                                                ? const Color(0xFF4A2B7C)
                                                : const Color(0xFF201236),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                              side: selectedPoints == 2
                                                  ? const BorderSide(
                                                      color: Colors.white,
                                                      width: 2,
                                                    )
                                                  : BorderSide.none,
                                            ),
                                            padding: const EdgeInsets.all(10),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: 26,
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: 26,
                                              ),
                                            ],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              selectedPoints = 2;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 9),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 78,
                                        height: 30,
                                        child: Text(
                                          '누워서\n밥먹기',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        width: 78,
                                        height: 78,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: selectedPoints == 3
                                                ? const Color(0xFF4A2B7C)
                                                : const Color(0xFF201236),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                              side: selectedPoints == 3
                                                  ? const BorderSide(
                                                      color: Colors.white,
                                                      width: 2,
                                                    )
                                                  : BorderSide.none,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                          ),
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                    size: 26,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 2),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                    size: 26,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                    size: 26,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              selectedPoints = 3;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 9),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 78,
                                        height: 30,
                                        child: Text(
                                          '누워서\n고기 굽기',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        width: 78,
                                        height: 78,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: selectedPoints == 4
                                                ? const Color(0xFF4A2B7C)
                                                : const Color(0xFF201236),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                              side: selectedPoints == 4
                                                  ? const BorderSide(
                                                      color: Colors.white,
                                                      width: 2,
                                                    )
                                                  : BorderSide.none,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                          ),
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                    size: 26,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                    size: 26,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 2),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                    size: 26,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                    size: 26,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              selectedPoints = 4;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
