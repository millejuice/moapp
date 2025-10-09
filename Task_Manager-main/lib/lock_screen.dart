import 'dart:io';

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
  final CountdownController _controller =
  new CountdownController(autoStart: true);
  int _counter = 10;

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  void closeAppUsingExit() {
    exit(0);
  }

  bool checkDone() {
    if (_counter == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: checkDone()
            ? Image.asset('assets/defence.png')
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Countdown(
              controller: _controller,
              seconds: 100,
              build: (_, double time) => Text(
                time.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 100,
                ),
              ),
              interval: Duration(milliseconds: 100),
              onFinished: () {
                closeAppUsingExit();
              },
            ),
            InkWell(
              child: Lottie.asset(
                'assets/pixel_heart.json',
                width: 200,
                height: 200,
                fit: BoxFit.fill,
              ),
              onTap: () {
                _decrementCounter();
                if (checkDone()) {
                  closeAppUsingExit();
                }
              },
            ),
            Text(
              '$_counter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
