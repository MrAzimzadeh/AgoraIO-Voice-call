import 'package:flutter/material.dart';

class CallPageTest extends StatefulWidget {
  const CallPageTest({super.key});

  @override
  State<CallPageTest> createState() => _CallPageTestState();
}

class _CallPageTestState extends State<CallPageTest> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Call Page'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go back!'),
          ),
        ),
      ),
    );
  }
}

