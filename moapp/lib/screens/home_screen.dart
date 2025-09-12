import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/counter_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int count = context.watch<CounterProvider>().count;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$count', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterProvider>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}



