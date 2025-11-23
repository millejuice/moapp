import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'util/timer_widget.dart';
import 'attack_overlay.dart';
import 'todo.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({Key? key}) : super(key: key);

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  int _selectedIndex = 1;
  int percent = 80;
  int points = 2;
  late Timer _timer;
  late DateTime _midnight;
  late Duration _timeRemaining;
  bool _showAttackOverlay = false;
  String? _groupToken;
  String? _targetUid;
  final String _currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchUserGroupToken();
  }

  Future<void> _fetchUserGroupToken() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUid).get();
    if (userDoc.exists && userDoc.data() != null) {
      final data = userDoc.data()!;
      final tokens = List<String>.from(data['groupTokens'] ?? []);
      if (tokens.isNotEmpty) {
        setState(() {
          _groupToken = tokens[0];
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(
      () {
        _selectedIndex = index;
      },
    );
    if (index == 0) {
      // Replace current page with TodoPage with a slide-from-left animation
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const TodoPage(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);
          final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: opacityAnimation, child: child),
          );
        },
      ));
    }
  }



  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    double widthScale = size.width / 390;
    double heightScale = size.height / 844;

    return WillPopScope(
      onWillPop: null,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF7B31),
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
              ),
              Image.asset('assets/timer.png',width: 55,height: 55,),
              const TimerWidget(),
              SizedBox(width: size.width * 0.1),
            ],
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: const Center(
                    child: Text(
                      '랭킹',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (_groupToken == null)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF316F),
                      ),
                      child: const Center(
                        child: Text(
                          "그룹에 멤버가 없습니다:--)",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('groups').doc(_groupToken).snapshots(),
                      builder: (context, groupSnapshot) {
                        if (!groupSnapshot.hasData) {
                          return Container(
                            color: const Color(0xFFFF316F),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        }

                        final groupData = groupSnapshot.data!.data() as Map<String, dynamic>?;
                        if (groupData == null) {
                          return Container(
                            color: const Color(0xFFFF316F),
                            child: const Center(child: Text("Group data not found")),
                          );
                        }

                        final groupName = groupData['groupName'] ?? '단짝친구 ><';
                        final pointsMap = Map<String, dynamic>.from(groupData['points'] ?? {});
                        final attackedUser = groupData['attackedUser'] as String?;
                        final members = List<String>.from(groupData['members'] ?? []);

                        if (attackedUser == _currentUid) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pushReplacementNamed(context, '/lock');
                          });
                        }

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 5,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'group name: $groupName',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF316F),
                                ),
                                child: members.isEmpty
                                    ? const Center(
                                        child: Text(
                                          "No members in this group",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .where(FieldPath.documentId, whereIn: members)
                                      .snapshots(),
                                  builder: (context, usersSnapshot) {
                                    if (!usersSnapshot.hasData) {
                                      return const Center(child: CircularProgressIndicator());
                                    }

                                    final users = usersSnapshot.data!.docs.map((doc) {
                                      final data = doc.data() as Map<String, dynamic>;
                                      final uid = doc.id;
                                      return {
                                        'uid': uid,
                                        'nickname': data['nickname'] ?? 'Unknown',
                                        'points': pointsMap[uid] ?? 0,
                                      };
                                    }).toList();

                                    users.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));

                                    final firstPlaceUid = users.isNotEmpty ? users[0]['uid'] : '';
                                    final isAmFirstPlace = firstPlaceUid == _currentUid;

                                    return ListView.builder(
                                      itemCount: users.length,
                                      itemBuilder: (context, index) {
                                        return _buildRankItem(context, users[index], index + 1, widthScale, heightScale, isAmFirstPlace);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 3,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
            if (_showAttackOverlay && _groupToken != null)
              AttackOverlay(
                groupToken: _groupToken!,
                targetUid: _targetUid ?? "",
                onClose: () {
                  setState(() {
                    _showAttackOverlay = false;
                    _targetUid = null;
                  });
                },
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist),
              label: 'to-do-list',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.military_tech),
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

  Widget _buildRankItem(BuildContext context, Map<String, dynamic> user, int rank, double widthScale, double heightScale, bool isAmFirstPlace) {
    final isMe = user['uid'] == _currentUid;
    // Allow attack if I am 1st place AND the target is NOT me.
    // (Original request said "1st place can send 2,3 place to lock screen", so basically anyone else)
    final canAttack = isAmFirstPlace && !isMe;

    return Padding(
      padding: const EdgeInsets.only(
        top: 21,
        left: 15,
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/rank$rank.png',
            width: 76 * widthScale,
            height: 76 * widthScale,
          ),
          const SizedBox(
            width: 19,
          ),
          GestureDetector(
            onTap: canAttack
                ? () {
                    setState(() {
                      _targetUid = user['uid'];
                      _showAttackOverlay = true;
                    });
                  }
                : null,
            child: Container(
              width: 240 * widthScale,
              height: 95 * heightScale,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(41),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 15,
                  ),
                  Image.asset(
                    'assets/user$rank.png', 
                    width: 68 * widthScale,
                    height: 68 * widthScale,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 9,
                      top: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              user['nickname'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(
                                width: 4,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(context, '/lock');
                                },
                                child: Image.asset(
                                  'assets/me.png',
                                  width: 25 * widthScale,
                                  height: 25 * widthScale,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '${user['points']}point',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        LinearPercentIndicator(
                          width: 140 * widthScale,
                          animation: true,
                          animationDuration: 1000,
                          lineHeight: 14.0,
                          percent: (user['points'] as int) / 100.0 > 1.0 ? 1.0 : (user['points'] as int) / 100.0,
                          barRadius: const Radius.circular(19),
                          progressColor: rank == 1 ? const Color(0xFFFF7272) : (rank == 2 ? const Color(0xFFFFCF72) : const Color(0xFF72FFBB)),
                          backgroundColor: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

