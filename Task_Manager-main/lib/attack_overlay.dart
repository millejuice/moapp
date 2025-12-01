import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttackOverlay extends StatefulWidget {
  final VoidCallback onClose;

  final String groupToken;
  final String targetUid;

  const AttackOverlay({
    Key? key,
    required this.onClose,
    required this.groupToken,
    required this.targetUid,
  }) : super(key: key);

  @override
  State<AttackOverlay> createState() => _AttackOverlayState();
}

class _AttackOverlayState extends State<AttackOverlay> {
  int _step = 0; // 0: Intro, 1: User Selection, 2: Penalty Selection, 3: Result, 4: Final
  String _resultMessage = "";
  Map<String, dynamic>? _selectedUser;
  String? _selectedPenaltyType; // 'tap' or 'handRaise'
  late Future<List<Map<String, dynamic>>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMembers();
    // Step 0: Intro "Time to Attack!" -> Step 1: Selection (after 2s)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _step = 1;
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> _fetchMembers() async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupToken).get();
    
    if (!groupDoc.exists) return [];
    
    final members = List<String>.from(groupDoc.data()?['members'] ?? []);
    final otherMembers = members.where((uid) => uid != currentUid).toList();
    
    if (otherMembers.isEmpty) return [];

    // Split into chunks of 10 for whereIn query if needed, but assuming small groups for now
    final userDocs = await FirebaseFirestore.instance.collection('users')
        .where(FieldPath.documentId, whereIn: otherMembers)
        .get();

    return userDocs.docs.map((doc) => {
      'uid': doc.id,
      'nickname': doc.data()['nickname'] ?? 'Unknown',
    }).toList();
  }

  void _handleUserSelection(Map<String, dynamic> user) {
    setState(() {
      _selectedUser = user;
      _step = 2; // 벌칙 타입 선택 단계로 이동
    });
  }

  void _handlePenaltySelection(String penaltyType) {
    if (_selectedUser == null) return;

    setState(() {
      _selectedPenaltyType = penaltyType;
      _resultMessage = "사랑해 친구야~"; // Default message, can be randomized or based on logic
      _step = 3; // Result 단계로 이동
    });

    // Update Firestore to trigger lock screen for the target user
    FirebaseFirestore.instance.collection('groups').doc(widget.groupToken).update({
      'attackedUser': _selectedUser!['uid'],
      'attackerUid': FirebaseAuth.instance.currentUser!.uid, // Save who attacked
      'penaltyType': penaltyType, // 벌칙 타입 저장 ('tap' or 'handRaise')
      'attackTimestamp': FieldValue.serverTimestamp(), // Optional: for tracking or timeout
    }).catchError((error) {
      debugPrint("Failed to attack: $error");
      // Handle error if needed
    });

    // Step 3: Result -> Step 4: Final (after 2s)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _step = 4;
        });
        
        // Close after showing final effect for a bit (e.g., 2s)
        Future.delayed(const Duration(seconds: 2), () {
           widget.onClose();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blur Effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        Center(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_step) {
      case 0:
        return const Text(
          "Time to Attack!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'DungGeunMo', // Assuming font is available, else fallback
          ),
        );
      case 1:
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _membersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(color: Colors.white);
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
               return const Text(
                "공격할 친구가 없어요 ㅠㅠ",
                style: TextStyle(color: Colors.white, fontSize: 20),
              );
            }

            final members = snapshot.data!;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "공격할 나의\n소중한^^ 친구를 골라보기",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: members.asMap().entries.map((entry) {
                    final index = entry.key;
                    final member = entry.value;
                    // Cycle through assets or use a default
                    final assetName = 'assets/user${(index % 2) + 2}.png'; 
                    final color = index % 2 == 0 ? Colors.blue : Colors.purple;
                    
                    return _buildOptionButton(
                      imageAsset: assetName,
                      nickname: member['nickname'],
                      color: color,
                      onTap: () => _handleUserSelection(member),
                    );
                  }).toList(),
                ),
              ],
            );
          }
        );
      case 2: // 벌칙 타입 선택
        if (_selectedUser == null) return const SizedBox.shrink();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${_selectedUser!['nickname']}에게\n어떤 벌칙을 줄까?",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // 휴대폰 잠금 옵션
            InkWell(
              onTap: () => _handlePenaltySelection('tap'),
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
                    const Icon(Icons.lock, size: 80, color: Colors.white),
                    const SizedBox(height: 15),
                    const Text(
                      '휴대폰 잠금',
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
            // 모션 인식 옵션
            InkWell(
              onTap: () => _handlePenaltySelection('handRaise'),
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
                      '모션 인식',
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
        );
      case 3: // Result
        if (_selectedUser == null) return const SizedBox.shrink();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show the selected icon
             Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue, // Simplified color logic
                shape: BoxShape.circle,
                border: Border.all(color: Colors.yellow, width: 4),
                boxShadow: [
                   BoxShadow(
                    color: Colors.yellow.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  'assets/user2.png', // Placeholder for now, ideally pass the asset used
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
             Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _resultMessage,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
             const SizedBox(height: 10),
             const Text(
               "버튼을 누르면 확정^^",
               style: TextStyle(color: Colors.white, fontSize: 12),
             )
          ],
        );
      case 4: // Final
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             const Icon(Icons.local_fire_department, size: 100, color: Colors.orange), // Fire effect placeholder
             const SizedBox(height: 20),
             const Text(
               "공격 성공!",
               style: TextStyle(
                 color: Colors.white,
                 fontSize: 24,
                 fontWeight: FontWeight.bold,
               ),
             ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOptionButton({String? imageAsset, required String nickname, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: imageAsset != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.contain,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          Text(
            nickname,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
