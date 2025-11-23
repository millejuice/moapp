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
  int _step = 0; // 0: Intro, 1: Selection, 2: Result, 3: Final
  String _resultMessage = "";
  Map<String, dynamic>? _selectedUser;
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

  void _handleSelection(Map<String, dynamic> user) {
    setState(() {
      _selectedUser = user;
      _resultMessage = "사랑해 친구야~"; // Default message, can be randomized or based on logic
      _step = 2;
    });

    // Update Firestore to trigger lock screen for the target user
    FirebaseFirestore.instance.collection('groups').doc(widget.groupToken).update({
      'attackedUser': user['uid'],
      'attackerUid': FirebaseAuth.instance.currentUser!.uid, // Save who attacked
      'attackTimestamp': FieldValue.serverTimestamp(), // Optional: for tracking or timeout
    }).catchError((error) {
      debugPrint("Failed to attack: $error");
      // Handle error if needed
    });

    // Step 2: Result -> Step 3: Final (after 2s)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _step = 3;
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
                      onTap: () => _handleSelection(member),
                    );
                  }).toList(),
                ),
              ],
            );
          }
        );
      case 2:
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
      case 3:
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
