
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LockPage extends StatefulWidget {
  const LockPage({Key? key}) : super(key: key);

  @override
  State<LockPage> createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> {
  final CountdownController _controller = CountdownController(autoStart: true);
  int _counter = 10; // Default tap count
  int _lockState = 0; // 0: Notification, 1: Intro, 2: Action, 3: Success
  String _attackerNickname = "Unknown";
  String _victimNickname = "Friend"; // Placeholder, could fetch real one
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _fetchAttackerInfo();
  }

  Future<void> _fetchAttackerInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. Get user's group token
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final groupTokens = List<String>.from(userDoc.data()?['groupTokens'] ?? []);
      if (groupTokens.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      final groupToken = groupTokens[0];

      // 2. Get group data to find attackerUid
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupToken).get();
      final attackerUid = groupDoc.data()?['attackerUid'] as String?;

      if (attackerUid != null) {
        // 3. Get attacker's nickname
        final attackerDoc = await FirebaseFirestore.instance.collection('users').doc(attackerUid).get();
        setState(() {
          _attackerNickname = attackerDoc.data()?['nickname'] ?? "Unknown";
          _victimNickname = userDoc.data()?['nickname'] ?? "Friend";
          _isLoading = false;
        });
        
        // Auto-advance from Notification to Intro after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _lockState = 1);
          
          // Auto-advance from Intro to Action after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _lockState = 2);
          });
        });
      } else {
        setState(() => _isLoading = false);
         // Fallback flow if no attacker info
         setState(() => _lockState = 2);
      }
    } catch (e) {
      debugPrint("Error fetching lock info: $e");
      setState(() => _isLoading = false);
      setState(() => _lockState = 2);
    }
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) _counter--;
      if (_counter == 0) {
        _lockState = 3; // Success
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/ranking');
          }
        });
      }
    });
  }

  void closeAppUsingExit() {
    Navigator.pushReplacementNamed(context, '/ranking');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
                const Icon(Icons.notifications_active, size: 50, color: Colors.amber),
                const SizedBox(height: 20),
                const Text("기쁜 소식!!!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 10),
                Text("$_attackerNickname님의\n진심 어린 선물이\n도착했어요 ~", 
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
              Text("$_victimNickname아!\n사랑해 ~", 
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              Image.asset('assets/user2.png', width: 150), // Placeholder for Mario
            ],
          ),
        );
      case 2: // Action
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$_victimNickname아!\n사랑해 ~ 'ㅗ'", 
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200, height: 200,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      fontFamily: 'DungGeunMo', // Ensure font is used if available
                    ),
                  ),
                ),
                interval: const Duration(milliseconds: 100),
                onFinished: () {
                  closeAppUsingExit();
                },
              ),
              const SizedBox(height: 20),
              const Text("동안 우리 현생살자 ^^", style: TextStyle(color: Colors.white, fontSize: 18)),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 3: // Success
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/user2.png', width: 150),
              const SizedBox(height: 30),
              const Text("와 너 좀 대단한듯.", style: TextStyle(color: Colors.white, fontSize: 24)),
            ],
          ),
        );
      default:
        return Container();
    }
  }
}
