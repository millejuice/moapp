import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'hand_raise_detector.dart';

class LockPage extends StatefulWidget {
  const LockPage({super.key});

  @override
  State<LockPage> createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> {
  final CountdownController _controller = CountdownController(autoStart: true);
  int _counter = 10; // Default tap count
  int _lockState =
      0; // 0: Notification, 1: Intro, 2: Action Selection, 3: Tap Mode, 4: Hand Raise Mode, 5: Success
  String _attackerNickname = "Unknown";
  String _victimNickname = "Friend"; // Placeholder, could fetch real one
  bool _isLoading = true;
  String? _groupToken;
  String? _penaltyMode; // 'tap' or 'handRaise'

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Navigator arguments에서 그룹 토큰 받기
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final passedGroupToken = args?['currentGroupToken'] as String?;
    if (passedGroupToken != null) {
      _groupToken = passedGroupToken;
    }
    _fetchAttackerInfo();
  }

  Future<void> _fetchAttackerInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. Get user's group token (전달받은 게 없으면 가져오기)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      String? groupToken = _groupToken; // 전달받은 토큰 우선

      if (groupToken == null) {
        final groupTokens = List<String>.from(
          userDoc.data()?['groupTokens'] ?? [],
        );
        if (groupTokens.isEmpty) {
          setState(() => _isLoading = false);
          return;
        }
        groupToken = groupTokens[0];
        setState(() {
          _groupToken = groupToken;
        });
      }

      // 2. Get group data to find attackerUid and attackedUser
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupToken)
          .get();
      final attackerUid = groupDoc.data()?['attackerUid'] as String?;
      final attackedUser = groupDoc.data()?['attackedUser'] as String?;
      final currentUid = user.uid;

      // 현재 사용자가 공격을 받은 사람인지 확인
      debugPrint(
        '🔍 Lock Screen - attackedUser: $attackedUser, currentUid: $currentUid, attackerUid: $attackerUid',
      );

      if (attackedUser == currentUid && attackerUid != null) {
        debugPrint('✅ 공격을 받은 사용자입니다. 벌칙 선택 화면으로 이동합니다.');
        // 3. Get attacker's nickname
        final attackerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(attackerUid)
            .get();
        if (!mounted) return;
        setState(() {
          _attackerNickname = attackerDoc.data()?['nickname'] ?? "Unknown";
          _victimNickname = userDoc.data()?['nickname'] ?? "Friend";
          _isLoading = false;
        });

        // Auto-advance from Notification to Intro after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            debugPrint('📢 Intro 화면으로 이동');
            setState(() => _lockState = 1);
          }

          // Auto-advance from Intro to Action (벌칙 선택) after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              debugPrint('🎯 벌칙 선택 화면으로 이동 (탭하기/손들기 옵션)');
              setState(() => _lockState = 2); // 벌칙 선택 화면
            }
          });
        });
      } else {
        debugPrint('⚠️ 공격을 받지 않은 사용자이거나 attackerUid가 없습니다.');
        // 공격을 받지 않은 경우 또는 attackerUid가 없는 경우
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _lockState = 2; // 벌칙 선택 화면으로 바로 이동 (fallback)
        });
        debugPrint('🎯 벌칙 선택 화면으로 바로 이동 (fallback)');
      }
    } catch (e) {
      debugPrint("Error fetching lock info: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _lockState = 2;
      });
    }
  }

  void _decrementCounter() {
    if (_lockState != 3 || !mounted) return; // 탭 모드일 때만 작동

    setState(() {
      if (_counter > 0) _counter--;
      if (_counter == 0) {
        _lockState = 5; // Success
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            debugPrint('✅ 탭하기 성공 - 그룹 토큰: $_groupToken');
            // 원래 있던 그룹의 todo 페이지로 이동
            Navigator.pushReplacementNamed(
              context,
              '/todo',
              arguments: {'joinedGroupToken': _groupToken},
            );
          }
        });
      }
    });
  }

  void _onHandRaised() {
    if (_lockState != 4 || !mounted) return; // 손들기 모드일 때만 작동

    setState(() {
      _lockState = 5; // Success
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        debugPrint('✅ 손들기 성공 - 그룹 토큰: $_groupToken');
        // 원래 있던 그룹의 todo 페이지로 이동
        Navigator.pushReplacementNamed(
          context,
          '/todo',
          arguments: {'joinedGroupToken': _groupToken},
        );
      }
    });
  }

  void _selectPenaltyMode(String mode) {
    if (!mounted) return;
    setState(() {
      _penaltyMode = mode;
      if (mode == 'tap') {
        _lockState = 3; // 탭 모드
      } else if (mode == 'handRaise') {
        _lockState = 4; // 손들기 모드
      }
    });
  }

  void closeAppUsingExit() {
    debugPrint('🚪 Lock Screen 종료 - 그룹 토큰: $_groupToken');
    // 원래 있던 그룹의 todo 페이지로 이동
    Navigator.pushReplacementNamed(
      context,
      '/todo',
      arguments: {'joinedGroupToken': _groupToken},
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_lockState) {
      case 0: // Notification
        return Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.notifications_active,
                  size: 50,
                  color: Colors.amber,
                ),
                const SizedBox(height: 20),
                const Text(
                  "기쁜 소식!!!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "$_attackerNickname님의\n진심 어린 선물이\n도착했어요 ~",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ],
            ),
          ),
        );
      case 1: // Intro
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$_victimNickname아!\n사랑해 ~",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              Image.asset(
                'assets/user2.png',
                width: 150,
              ), // Placeholder for Mario
            ],
          ),
        );
      case 2: // Action Selection
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$_victimNickname아!\n벌칙을 선택해줘!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              // 탭하기 옵션
              InkWell(
                onTap: () => _selectPenaltyMode('tap'),
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7B31),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Column(
                    children: [
                      Lottie.asset(
                        'assets/pixel_heart.json',
                        width: 80,
                        height: 80,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        '탭하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        '10번 탭해서 해제',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // 손들기 옵션
              InkWell(
                onTap: () => _selectPenaltyMode('handRaise'),
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A2B7C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.pan_tool, size: 80, color: Colors.white),
                      const SizedBox(height: 15),
                      const Text(
                        '손 들기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        '양손을 들어서 해제',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case 3: // Tap Mode
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$_victimNickname아!\n사랑해 ~ 'ㅗ'",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  Image.asset('assets/user2.png', width: 120), // Placeholder
                ],
              ),
              const SizedBox(height: 20),
              Countdown(
                controller: _controller,
                seconds: 100, // 100 seconds
                build: (_, double time) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    time.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily:
                          'DungGeunMo', // Ensure font is used if available
                    ),
                  ),
                ),
                interval: const Duration(milliseconds: 100),
                onFinished: () {
                  closeAppUsingExit();
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "동안 우리 현생살자 ^^",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 40),
              InkWell(
                onTap: _decrementCounter,
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/pixel_heart.json',
                      width: 100,
                      height: 100,
                      fit: BoxFit.fill,
                    ),
                    Text(
                      '$_counter번 더 때려보라.',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 4: // Hand Raise Mode
        return HandRaiseDetector(
          onHandRaised: _onHandRaised,
          onClose: closeAppUsingExit,
        );
      case 5: // Success
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/user2.png', width: 150),
              const SizedBox(height: 30),
              const Text(
                "와 너 좀 대단한듯.",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ],
          ),
        );
      default:
        return Container();
    }
  }
}
