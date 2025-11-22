import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'model/todo.dart';
import 'util/authentication.dart';
import 'util/timer_widget.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  int _selectedIndex = 0;
  int percent = 80;
  int userPoints = 0;
  Future<List<Map<String, dynamic>>> _todosFuture = Future.value([]);

  String userName = '로딩중...';
  String userNickname = '';
  String? currentGroupToken;
  String? currentGroupDocId; // 실제 Firestore 문서 ID
  String? currentUid;

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      await Navigator.pushNamed(context, '/ranking');
      // ranking에서 돌아왔을 때 데이터 새로고침 (현재 그룹 유지)
      setState(() {
        _selectedIndex = 0;
      });
      await _initializeData(specificGroupToken: _lastLoadedGroupToken);
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF340B76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('로그아웃', style: TextStyle(color: Colors.white)),
          content: const Text(
            '로그아웃 하시겠습니까?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // 로딩 표시
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );

                // 로그아웃 실행
                final auth = Authentication();
                await auth.signOut();

                // 로그인 페이지로 이동 (모든 이전 페이지 제거)
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  bool _hasInitialized = false;
  String? _lastLoadedGroupToken;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Navigator arguments 확인
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final joinedGroupToken = args?['joinedGroupToken'] as String?;

    print(
      '🔄 didChangeDependencies - _hasInitialized: $_hasInitialized, args: $args',
    );
    print(
      '🎫 joinedGroupToken: $joinedGroupToken, _lastLoadedGroupToken: $_lastLoadedGroupToken',
    );

    // 처음 초기화하거나, 새로운 그룹 토큰이 전달된 경우에만 재초기화
    if (!_hasInitialized) {
      _hasInitialized = true;
      print('✅ First initialization with token: $joinedGroupToken');
      _initializeData(specificGroupToken: joinedGroupToken);
    } else if (joinedGroupToken != null &&
        joinedGroupToken != _lastLoadedGroupToken) {
      print('✅ New group token detected, reinitializing: $joinedGroupToken');
      _initializeData(specificGroupToken: joinedGroupToken);
    } else {
      print('⏭️ Skipping reinitialization (already initialized)');
    }
  }

  Future<void> _initializeData({String? specificGroupToken}) async {
    print('🔄 _initializeData called with token: $specificGroupToken');

    // specificGroupToken이 명시적으로 전달되면 저장
    if (specificGroupToken != null) {
      _lastLoadedGroupToken = specificGroupToken;
      print('💾 Saved _lastLoadedGroupToken: $_lastLoadedGroupToken');
    }

    await _loadUserData(specificGroupToken: specificGroupToken);
    print('✅ _loadUserData completed. currentGroupDocId: $currentGroupDocId');
    // _loadUserData가 완료된 후에 todos 로드
    setState(() {
      _todosFuture = _fetchTodosFromFirestore();
    });
  }

  Future<void> _loadUserData({String? specificGroupToken}) async {
    print(
      '👤 _loadUserData called with specificGroupToken: $specificGroupToken',
    );
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUid = user.uid;
      print('🆔 Current UID: $currentUid');

      // 사용자 정보 가져오기
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final groupTokens = List<String>.from(userData?['groupTokens'] ?? []);
        print('📝 User groupTokens: $groupTokens');

        userName = userData?['name'] ?? '사용자';
        userNickname = userData?['nickname'] ?? '닉네임';

        // specificGroupToken 우선, 없으면 _lastLoadedGroupToken, 그것도 없으면 첫 번째 그룹
        currentGroupToken =
            specificGroupToken ??
            _lastLoadedGroupToken ??
            (groupTokens.isNotEmpty ? groupTokens[0] : null);
        print(
          '🎯 Selected group token: $currentGroupToken (from specific: $specificGroupToken, last: $_lastLoadedGroupToken)',
        );

        // 선택된 토큰을 저장 (specificGroupToken이 명시되지 않았고 새로운 토큰이 선택된 경우)
        if (specificGroupToken == null &&
            currentGroupToken != _lastLoadedGroupToken) {
          _lastLoadedGroupToken = currentGroupToken;
          print('💾 Updated _lastLoadedGroupToken to: $_lastLoadedGroupToken');
        }

        // 그룹에서 포인트 가져오기
        if (currentGroupToken != null) {
          // groupToken 필드로 그룹 검색
          final querySnapshot = await FirebaseFirestore.instance
              .collection('groups')
              .where('groupToken', isEqualTo: currentGroupToken)
              .limit(1)
              .get();

          print('🔍 Query found ${querySnapshot.docs.length} groups');
          if (querySnapshot.docs.isNotEmpty) {
            final groupDoc = querySnapshot.docs.first;
            currentGroupDocId = groupDoc.id; // 문서 ID 저장
            print('✅ Set currentGroupDocId: $currentGroupDocId');

            final points = groupDoc.data()['points'] as Map<String, dynamic>?;
            userPoints = points?[user.uid] ?? 0;
            print('💯 User points: $userPoints');
          } else {
            print('⚠️ No group found with token: $currentGroupToken');
          }
        } else {
          print('⚠️ currentGroupToken is null');
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchTodosFromFirestore() async {
    print(
      '📋 _fetchTodosFromFirestore called. currentGroupDocId: $currentGroupDocId',
    );
    if (currentGroupDocId == null) {
      print('⚠️ currentGroupDocId is null, returning empty list');
      return [];
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(currentGroupDocId)
        .collection('todos')
        .orderBy('createdAt', descending: true)
        .get();

    print('📦 Fetched ${snapshot.docs.length} todos');
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'title': data['title'] ?? '',
        'points': data['points'] ?? 0,
        'completedBy': List<String>.from(data['completedBy'] ?? []),
        'createdBy': data['createdBy'] ?? '',
        'createdByName': data['createdByName'] ?? '사용자',
      };
    }).toList();
  }

  void _showEditDeleteDialog(
    String todoId,
    String title,
    int points,
    String createdBy,
  ) {
    // 작성자 본인인지 확인
    final isOwner = currentUid == createdBy;

    if (!isOwner) {
      // 본인이 아니면 권한 없음 메시지 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF340B76),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('권한 없음', style: TextStyle(color: Colors.white)),
            content: const Text(
              '작성자만 수정/삭제할 수 있습니다.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('확인', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
      return;
    }

    // 작성자 본인이면 수정/삭제 다이얼로그 표시
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF340B76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('할 일 관리', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(
                  context,
                  '/edit',
                  arguments: {
                    'todoId': todoId,
                    'title': title,
                    'points': points,
                    'currentGroupToken': currentGroupToken,
                  },
                );
                await _initializeData(
                  specificGroupToken: _lastLoadedGroupToken,
                );
              },
              child: const Text(
                '수정',
                style: TextStyle(color: Color(0xFFFF9900)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog(todoId);
              },
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(String todoId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF340B76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('삭제 확인', style: TextStyle(color: Colors.white)),
          content: const Text(
            '이 할 일을 삭제하시겠습니까?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteTodo(todoId);
              },
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTodo(String todoId) async {
    if (currentGroupDocId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(currentGroupDocId)
          .collection('todos')
          .doc(todoId)
          .delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('할 일이 삭제되었습니다.')));

      setState(() {
        _todosFuture = _fetchTodosFromFirestore();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
    }
  }

  Future<void> _toggleTodoCompletion(
    String todoId,
    bool isCompleted,
    int points,
  ) async {
    if (currentGroupDocId == null || currentUid == null) return;

    try {
      final todoRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(currentGroupDocId)
          .collection('todos')
          .doc(todoId);

      final groupRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(currentGroupDocId);

      if (isCompleted) {
        // 완료 취소
        await todoRef.update({
          'completedBy': FieldValue.arrayRemove([currentUid]),
        });

        // 포인트 감소
        await groupRef.update({
          'points.$currentUid': FieldValue.increment(-points),
        });
      } else {
        // 완료
        await todoRef.update({
          'completedBy': FieldValue.arrayUnion([currentUid]),
        });

        // 포인트 증가
        await groupRef.update({
          'points.$currentUid': FieldValue.increment(points),
        });
      }

      // Firestore 업데이트 후 포인트를 다시 가져와서 정확한 값으로 업데이트
      final groupDoc = await groupRef.get();
      final updatedPoints = groupDoc.data()?['points'] as Map<String, dynamic>?;
      final newUserPoints = updatedPoints?[currentUid] ?? 0;

      setState(() {
        userPoints = newUserPoints;
        _todosFuture = _fetchTodosFromFirestore();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: null,
      child: Scaffold(
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
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 28),
              onPressed: _logout,
              tooltip: '로그아웃',
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.black),
              height: 150,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Image.asset(
                    'assets/group2.png',
                    width: 110,
                    height: 110,
                    scale: 0.6,
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            '너는 정말 좋은 친구야 ',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          Text(
                            userNickname,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          Text(
                            '${userPoints}points',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearPercentIndicator(
                        width: 180,
                        animation: true,
                        animationDuration: 1000,
                        lineHeight: 14.0,
                        percent: (userPoints / 100).clamp(0.0, 1.0),
                        barRadius: const Radius.circular(19),
                        progressColor: const Color(0xFFFF7272),
                        backgroundColor: Colors.grey[300],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFF340B76),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _todosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final todos = snapshot.data!;
                      return ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          final isCompleted =
                              (todo['completedBy'] as List<String>).contains(
                                currentUid,
                              );
                          final isMyTodo = todo['createdBy'] == currentUid;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? const Color(0xFFE8D4D4)
                                    : (isMyTodo
                                          ? Colors.white
                                          : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(44),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    // 커스텀 체크박스
                                    GestureDetector(
                                      onTap: isMyTodo
                                          ? () {
                                              _toggleTodoCompletion(
                                                todo['id'],
                                                isCompleted,
                                                todo['points'],
                                              );
                                            }
                                          : () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    '자신이 작성한 할 일만 체크할 수 있습니다.',
                                                  ),
                                                  duration: Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCompleted
                                              ? const Color(0xFFBE6B6B)
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isMyTodo
                                                ? (isCompleted
                                                      ? const Color(0xFFBE6B6B)
                                                      : Colors.grey)
                                                : Colors.grey.withOpacity(0.3),
                                            width: 3,
                                          ),
                                        ),
                                        child: isCompleted
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 24,
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // 제목 및 작성자
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            todo['title'],
                                            style: TextStyle(
                                              color: isMyTodo
                                                  ? Colors.black
                                                  : Colors.black.withOpacity(
                                                      0.5,
                                                    ),
                                              fontSize: 22,
                                              decoration: isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '작성자: ${todo['createdByName']}',
                                            style: TextStyle(
                                              color: isMyTodo
                                                  ? const Color(0xFFFF9900)
                                                  : Colors.grey,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // 포인트 배지
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF9900),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${todo['points']}pt',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // 메뉴 버튼
                                    IconButton(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        _showEditDeleteDialog(
                                          todo['id'],
                                          todo['title'],
                                          todo['points'],
                                          todo['createdBy'],
                                        );
                                      },
                                      tooltip: '수정/삭제',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          '아직 할 일이 없어요!\n+ 버튼을 눌러 추가해보세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width, height: 3),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFFF7B31),
          onPressed: () async {
            await Navigator.pushNamed(
              context,
              '/add',
              arguments: {'currentGroupToken': currentGroupToken},
            );
            // add에서 돌아왔을 때 데이터 새로고침 (현재 그룹 유지)
            await _initializeData(specificGroupToken: _lastLoadedGroupToken);
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist),
              label: 'To-Do-list',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.workspace_premium),
              label: 'ranking',
            ),
          ],
          currentIndex: _selectedIndex,
          backgroundColor: Colors.black,
          unselectedItemColor: const Color(0xFF4F4F4F),
          selectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
