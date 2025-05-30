import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'nfc_service.dart';
import 'utils.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: NfcPlayground(),
    );
  }
}

class NfcPlayground extends StatefulWidget {
  const NfcPlayground({super.key});

  @override
  State<NfcPlayground> createState() => _NfcPlaygroundState();
}

class _NfcPlaygroundState extends State<NfcPlayground> {
  final _random = Random();

  String _mine = '';
  String _theirs = '';
  final List<String> _messages = [];
  StreamSubscription<String>? _messageSubscription;

  Future<void> _doNfcExchange(bool sendFirst) async {
    setState(() {
      _mine = _random.nextString(5);
      _theirs = '';
      _messages.clear();
    });

    final receivedTheirs = await NfcService.exchangeMessage(_mine, sendFirst);
    setState(() => _theirs = receivedTheirs);
  }

  @override
  void initState() {
    super.initState();
    _messageSubscription = NfcService.messages.stream
        .listen((m) => setState(() => _messages.add(m)));
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Mine: $_mine'),
            Text('Theirs: $_theirs'),
            OutlinedButton(
              onPressed: () => _doNfcExchange(true),
              child: const Text('Do NFC Exchange (send first)'),
            ),
            OutlinedButton(
              onPressed: () => _doNfcExchange(false),
              child: const Text('Do NFC Exchange (receive first)'),
            ),
            Expanded(
              child: ListView(
                children: _messages.map((m) => Text(m)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
