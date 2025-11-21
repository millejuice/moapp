import 'dart:ui';
import 'package:flutter/material.dart';

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
  bool _isPizza = false;

  @override
  void initState() {
    super.initState();
    // Step 0: Intro "Time to Attack!" -> Step 1: Selection (after 2s)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _step = 1;
        });
      }
    });
  }

  void _handleSelection(bool isPizza) {
    setState(() {
      _isPizza = isPizza;
      _resultMessage = isPizza ? "아쫌." : "사랑해 친구야~";
      _step = 2;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOptionButton(
                  imageAsset: 'assets/user2.png',
                  color: Colors.blue,
                  onTap: () => _handleSelection(true),
                ),
                const SizedBox(width: 20),
                _buildOptionButton(
                  imageAsset: 'assets/user3.png', // use user3 for the person option
                  color: Colors.purple,
                  onTap: () => _handleSelection(false),
                ),
              ],
            ),
          ],
        );
      case 2:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show the selected icon
             Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _isPizza ? Colors.blue : Colors.purple,
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
                  _isPizza ? 'assets/user2.png' : 'assets/user3.png',
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
             Text(
               _isPizza ? "공격 성공!" : "사랑 전달 완료!",
               style: const TextStyle(
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

  Widget _buildOptionButton({String? imageAsset, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
    );
  }
}
