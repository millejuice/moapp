import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:async';

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

  void _onItemTapped(int index) {
    setState(
      () {
        _selectedIndex = index;
      },
    );
    if (index == 0) {
      Navigator.pushNamed(context, '/todo');
    }
  }

  @override
  void initState() {
    super.initState();
    _midnight = _calculateMidnight();
    _timeRemaining = _calculateTimeRemaining();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining = _calculateTimeRemaining();
        if (_timeRemaining.inSeconds <= 0) {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  DateTime _calculateMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight;
  }

  Duration _calculateTimeRemaining() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final formattedDuration =
        _formatDuration(_timeRemaining); // Format duration here

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
              Text(
                formattedDuration,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: size.width * 0.1),
            ],
          ),
        ),
        body: Column(
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
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'group name: 단짝친구 ><',
                    style: TextStyle(
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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 21,
                        left: 15,
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/rank1.png'),
                          const SizedBox(
                            width: 19,
                          ),
                          Container(
                            width: 240,
                            height: 95,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(41),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Image.asset('assets/user1.png'),
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
                                          const Text(
                                            '김깔깔',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          Image.asset('assets/me.png'),
                                        ],
                                      ),
                                      const Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '57point',
                                            style: TextStyle(
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
                                        width: 140,
                                        animation: true,
                                        animationDuration: 1000,
                                        lineHeight: 14.0,
                                        percent: 0.7,
                                        barRadius: const Radius.circular(19),
                                        progressColor: const Color(0xFFFF7272),
                                        backgroundColor: Colors.grey[300],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 21,
                        left: 15,
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/rank2.png'),
                          const SizedBox(
                            width: 19,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/lock');
                            },
                            child: Container(
                              width: 240,
                              height: 95,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(41),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Image.asset('assets/user2.png'),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 9,
                                      top: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '냠친구',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Row(
                                          children: [
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '32point',
                                              style: TextStyle(
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
                                          width: 140,
                                          animation: true,
                                          animationDuration: 1000,
                                          lineHeight: 14.0,
                                          percent: 0.5,
                                          barRadius: const Radius.circular(19),
                                          progressColor: const Color(0xFFFFCF72),
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 21,
                        left: 15,
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/rank3.png'),
                          const SizedBox(
                            width: 19,
                          ),
                          Container(
                            width: 240,
                            height: 95,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(41),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Image.asset('assets/user3.png'),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 9,
                                    top: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '핑쿠킹',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '12point',
                                            style: TextStyle(
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
                                        width: 140,
                                        animation: true,
                                        animationDuration: 1000,
                                        lineHeight: 14.0,
                                        percent: 0.2,
                                        barRadius: const Radius.circular(19),
                                        progressColor: const Color(0xFF72FFBB),
                                        backgroundColor: Colors.grey[300],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 3,
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
}
