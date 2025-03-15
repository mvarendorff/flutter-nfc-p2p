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

  Future<void> _doNfcExchange(bool sendFirst) async {
    setState(() {
      _mine = _random.nextString(5);
      _theirs = '';
    });

    final receivedTheirs = await NfcService.exchangeMessage(_mine, sendFirst);
    setState(() => _theirs = receivedTheirs);
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
          ],
        ),
      ),
    );
  }
}
